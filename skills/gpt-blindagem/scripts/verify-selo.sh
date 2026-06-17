#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# verify-selo.sh — confere o "selo" (impressão digital) que o GPT carimbou
# no topo do parecer contra o estado REAL do alvo agora.
#
# Pega o erro recorrente: o GPT revisou uma versão VELHA do alvo em vez da
# atual. Sem isso o parecer parece válido mas validou o errado.
#
# O GPT é instruído a carimbar, como PRIMEIRA seção:
#   ## Selo
#   - Manifesto (sha256): <hash>
# Onde o manifesto = o alvo inteiro enviado (gpt_alvo.md).
#
# Uso:
#   verify-selo.sh <ARQUIVO_DO_PARECER> <ALVO>
#     <ARQUIVO_DO_PARECER> = o parecer do GPT (onde está o selo carimbado)
#     <ALVO>               = o manifesto que FOI enviado (estado atual)
#
# Exit:
#   0  selo BATE          -> confiar no parecer
#   3  selo NÃO bate      -> DESCARTAR e re-rodar só o GPT
#   4  selo ausente       -> não dá pra verificar, tratar com ressalva
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

REVIEW="${1:?uso: verify-selo.sh <ARQUIVO_DO_PARECER> <ALVO>}"
TARGET="${2:?uso: verify-selo.sh <ARQUIVO_DO_PARECER> <ALVO>}"

[ -f "$REVIEW" ] || { echo "sem_arquivo_de_parecer"; exit 4; }
[ -f "$TARGET" ] || { echo "alvo_ausente"; exit 4; }
grep -qi "SELO INDISPONIVEL" "$REVIEW" && { echo "indisponivel"; exit 4; }

sha256_of () {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

want=$(sha256_of "$TARGET")
got=$(grep -ioE 'Manifesto \(sha256\):[[:space:]]*[0-9a-f]{32,64}' "$REVIEW" \
      | grep -ioE '[0-9a-f]{32,64}' | head -1)

[ -z "${want:-}" ] && { echo "estado_atual_indisponivel"; exit 4; }
[ -z "${got:-}" ]  && { echo "sem_selo_no_parecer"; exit 4; }

# Aceita prefixo nos dois sentidos (o GPT pode carimbar sha curto).
case "$want" in "$got"*) echo "ok ($got)"; exit 0 ;; esac
case "$got"  in "$want"*) echo "ok ($got)"; exit 0 ;; esac

echo "MISMATCH gpt=$got atual=$want"
exit 3
