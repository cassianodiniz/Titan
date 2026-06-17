#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# run-gpt.sh — chama o Codex (GPT-5.5) como revisor adversarial e grava o
# parecer limpo num arquivo. Encapsula a chamada pra não errar o stdin
# (codex exec trava esperando stdin se rodado sem redirecionar a entrada).
#
# Uso:
#   run-gpt.sh <INPUT_FILE> <OUTPUT_FILE> [EFFORT]
#     INPUT_FILE  = prompt + selo + manifesto, já montado pelo Claude
#     OUTPUT_FILE = onde gravar o parecer do GPT
#     EFFORT      = high (default) | xhigh
#
# Exit:
#   0  ok                        -> ler OUTPUT_FILE
#   3  codex não instalado       -> fallback: Claude faz o papel do crítico
#   5  codex falhou / saída vazia-> fallback
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

IN="${1:?uso: run-gpt.sh <INPUT> <OUTPUT> [EFFORT]}"
OUT="${2:?uso: run-gpt.sh <INPUT> <OUTPUT> [EFFORT]}"
EFFORT="${3:-xhigh}"

[ -f "$IN" ] || { echo "input_ausente: $IN"; exit 5; }
command -v codex >/dev/null 2>&1 || { echo "CODEX_NOT_INSTALLED"; exit 3; }

RAW="$(mktemp)"
trap 'rm -f "$RAW"' EXIT

# -o grava a resposta final já limpa; stdin (-) carrega o pacote inteiro
# sem estourar limite de argumento nem quebrar com aspas/caracteres do diff.
# service_tier="fast" = modo rápido do gpt-5.5. Precisa ser explícito porque
# --ignore-user-config ignora o service_tier do ~/.codex/config.toml.
codex exec \
  --model gpt-5.5 \
  -c model_reasoning_effort="$EFFORT" \
  -c service_tier="fast" \
  --skip-git-repo-check \
  --ignore-user-config \
  --sandbox workspace-write \
  -o "$OUT" \
  - < "$IN" > "$RAW" 2>/dev/null
rc=$?

# Se o -o não produziu nada mas sobrou stdout, aproveita o stdout limpando o
# "chrome" do codex (cabeçalho, telemetria de tokens, linhas de erro internas).
if [ ! -s "$OUT" ] && [ -s "$RAW" ]; then
  grep -avE '^(OpenAI Codex|-{3,}|tokens used|\[[0-9]|ERROR codex|WARN )' "$RAW" \
    | sed '1{/^[[:space:]]*$/d}' > "$OUT"
fi

if [ ! -s "$OUT" ]; then
  echo "CODEX_EMPTY (rc=$rc)"
  exit 5
fi

echo "ok"
