#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# cold-read.sh — entrega o handoff PRONTO ao Codex (GPT-5.5) como LEITOR CEGO
# (não viu a conversa) e grava o parecer limpo num arquivo: "só com este doc,
# o que você NÃO conseguiria continuar?". Encapsula a chamada pra não errar o
# stdin (codex exec trava esperando stdin se rodado sem redirecionar a entrada).
# Auto-contido de propósito: NÃO depende de outra skill nem do _shared morto.
#
# Uso:
#   cold-read.sh <INPUT_FILE> <OUTPUT_FILE> [EFFORT]
#     INPUT_FILE  = instrução de leitura cega + o handoff inteiro, montado pelo Claude
#     OUTPUT_FILE = onde gravar a lista de buracos do leitor cego
#     EFFORT      = high (default pro handoff) | xhigh
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
EFFORT="${3:-high}"

[ -f "$IN" ] || { echo "input_ausente: $IN"; exit 5; }
command -v codex >/dev/null 2>&1 || { echo "CODEX_NOT_INSTALLED"; exit 3; }

RAW="$(mktemp)"; ERR="$(mktemp)"
trap 'rm -f "$RAW" "$ERR"' EXIT

# Uma tentativa do Codex. Devolve 0 se produziu parecer não-vazio em $OUT.
# - service_tier="flex" = modo flex do gpt-5.5 (mais barato/lento que fast).
#   Precisa ser explícito porque --ignore-user-config ignora o tier do config.
# - --sandbox read-only: o revisor recebe o alvo inteiro via stdin; é uma
#   revisão de leitura, não pode (nem precisa) escrever no workspace.
# - -o grava a resposta final já limpa; stdin (-) carrega o pacote inteiro sem
#   estourar limite de argumento nem quebrar com aspas/caracteres do diff.
# - stderr vai pra $ERR (não /dev/null): se falhar, mostramos o motivo real.
run_codex () {
  : > "$OUT"; : > "$RAW"; : > "$ERR"
  # perl -e 'alarm 900' = teto de 15 min direto no codex (timeout puro não existe
  # no Mac; perl existe nos dois SOs). Passou disso, o SO mata e a tentativa falha.
  perl -e 'alarm 900; exec @ARGV' codex exec \
    --model gpt-5.5 \
    -c model_reasoning_effort="$EFFORT" \
    -c service_tier="flex" \
    --skip-git-repo-check \
    --ignore-user-config \
    -c windows.sandbox="elevated" \
    --sandbox read-only \
    -o "$OUT" \
    - < "$IN" > "$RAW" 2>"$ERR"
  rc=$?

  # Se o -o não produziu nada mas sobrou stdout, aproveita o stdout limpando o
  # "chrome" do codex (cabeçalho, telemetria de tokens, linhas de erro internas).
  if [ ! -s "$OUT" ] && [ -s "$RAW" ]; then
    grep -avE '^(OpenAI Codex|-{3,}|tokens used|\[[0-9]|ERROR codex|WARN )' "$RAW" \
      | sed '1{/^[[:space:]]*$/d}' > "$OUT"
  fi

  [ -s "$OUT" ] && return 0 || return 1
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
