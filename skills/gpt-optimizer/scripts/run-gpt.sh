#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# run-gpt.sh — chama o Codex (GPT-5.6) como revisor adversarial e grava o
# parecer limpo num arquivo. Encapsula a chamada pra não errar o stdin
# (codex exec trava esperando stdin se rodado sem redirecionar a entrada).
#
# Uso:
#   run-gpt.sh <INPUT_FILE> <OUTPUT_FILE> [EFFORT] [THREAD_FILE]
#     INPUT_FILE  = prompt + selo + manifesto, já montado pelo Claude
#     OUTPUT_FILE = onde gravar o parecer do GPT
#     EFFORT      = xhigh (default) | high
#     THREAD_FILE = memória do revisor (opcional). Vazio/inexistente = rodada 1:
#                   abre sessão nova e GRAVA o thread_id aqui. Já preenchido =
#                   rodada 2+: RETOMA a mesma sessão, e o GPT lembra o que já
#                   apontou (não re-litiga ponto morto).
#
# Tenta o Codex 2x antes de desistir (a 1ª falha costuma ser transitória) e
# NÃO esconde o erro: se falhar de vez, devolve o motivo real pra quem chamou
# poder avisar o usuário, em vez de fingir que rodou.
#
# Exit:
#   0  ok                        -> ler OUTPUT_FILE
#   3  codex não instalado       -> fallback: Claude faz o papel do crítico
#   5  codex falhou / saída vazia-> fallback (motivo impresso no stdout)
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

IN="${1:?uso: run-gpt.sh <INPUT> <OUTPUT> [EFFORT]}"
OUT="${2:?uso: run-gpt.sh <INPUT> <OUTPUT> [EFFORT]}"
EFFORT="${3:-xhigh}"
THREAD_FILE="${4:-}"

[ -f "$IN" ] || { echo "input_ausente: $IN"; exit 5; }
command -v codex >/dev/null 2>&1 || { echo "CODEX_NOT_INSTALLED"; exit 3; }

RAW="$(mktemp)"; ERR="$(mktemp)"
trap 'rm -f "$RAW" "$ERR"' EXIT

# Uma tentativa do Codex. Devolve 0 se produziu parecer não-vazio em $OUT.
# - service_tier="flex" = modo flex (mais barato/lento que fast).
#   Precisa ser explícito porque --ignore-user-config ignora o tier do config.
# - --sandbox read-only: o revisor recebe o alvo inteiro via stdin; é uma
#   revisão de leitura, não pode (nem precisa) escrever no workspace.
# - -o grava a resposta final já limpa; stdin (-) carrega o pacote inteiro sem
#   estourar limite de argumento nem quebrar com aspas/caracteres do diff.
# - stderr vai pra $ERR (não /dev/null): se falhar, mostramos o motivo real.
#
# Memória (THREAD_FILE): rodada 1 abre sessão com --json e pesca o thread_id do
# stream; rodadas seguintes usam `codex exec resume <id>`.
# ⚠️ `codex exec resume` NÃO aceita -s/--sandbox (só o --dangerously-bypass...).
#    Sem o -c sandbox_mode="read-only" abaixo ele herda o config e PASSA A
#    ESCREVER ARQUIVOS. Verificado 09/07/2026, codex-cli 0.140. Não remover.
run_codex () {
  : > "$OUT"; : > "$RAW"; : > "$ERR"

  local TID=""
  [ -n "$THREAD_FILE" ] && [ -s "$THREAD_FILE" ] && TID="$(tr -d '[:space:]' < "$THREAD_FILE")"

  if [ -n "$TID" ]; then
    # --model e --ignore-user-config são obrigatórios aqui: sem eles o resume lê o
    # `model` do ~/.codex/config.toml, que o app do Codex reescreve sozinho ao
    # atualizar. A sessão retomada NÃO carrega o modelo da rodada 1.
    # Modelo padrão: gpt-5.6-sol (ordem Cassiano 10/07/2026; o 400 antigo era
    # CLI desatualizada — 0.144.1 aceita; provado com exec real).
    codex exec resume "$TID" \
      --model gpt-5.6-sol \
      -c model_reasoning_effort="$EFFORT" \
      -c service_tier="flex" \
      -c sandbox_mode="read-only" \
      --skip-git-repo-check \
      --ignore-user-config \
      -o "$OUT" \
      - < "$IN" > "$RAW" 2>"$ERR"
    rc=$?
  else
    codex exec \
      --model gpt-5.6-sol \
      -c model_reasoning_effort="$EFFORT" \
      -c service_tier="flex" \
      --skip-git-repo-check \
      --ignore-user-config \
      -c windows.sandbox="elevated" \
      --sandbox read-only \
      ${THREAD_FILE:+--json} \
      -o "$OUT" \
      - < "$IN" > "$RAW" 2>"$ERR"
    rc=$?
  fi

  # Fallback de stdout só existe no modo SEM memória: com --json o stdout é JSONL,
  # e "limpar o chrome" dele produziria lixo em vez de parecer.
  if [ -z "$THREAD_FILE" ] && [ ! -s "$OUT" ] && [ -s "$RAW" ]; then
    grep -avE '^(OpenAI Codex|-{3,}|tokens used|\[[0-9]|ERROR codex|WARN )' "$RAW" \
      | sed '1{/^[[:space:]]*$/d}' > "$OUT"
  fi

  [ -s "$OUT" ] || return 1

  # Só grava o thread_id de uma rodada que DEU CERTO. Guardar o id de uma sessão
  # que falhou faria o retry virar `resume` de sessão morta.
  if [ -n "$THREAD_FILE" ] && [ -z "$TID" ] && [ -s "$RAW" ]; then
    sed -n 's/.*"thread_id":"\([^"]*\)".*/\1/p' "$RAW" | head -1 > "$THREAD_FILE"
    [ -s "$THREAD_FILE" ] || rm -f "$THREAD_FILE"   # sem id → próxima abre nova, não improvisa
  fi
  return 0
}

# Tenta 2x: a 1ª falha do Codex costuma ser transitória (rede / fila flex).
if run_codex; then echo "ok"; exit 0; fi
if run_codex; then echo "ok (2ª tentativa)"; exit 0; fi

# Falhou de vez: NÃO esconde o motivo — devolve o erro real do Codex pra quem
# chamou poder avisar o usuário, em vez de fingir que o GPT rodou.
echo "CODEX_FAILED (rc=${rc:-?})"
if [ -s "$ERR" ]; then
  echo "--- erro do codex (últimas linhas) ---"
  tail -n 8 "$ERR"
fi
exit 5
