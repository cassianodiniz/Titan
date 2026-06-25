#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# verify-selo.sh — confere o "selo" (impressão digital) que o crítico
# carimbou no topo da revisão contra o estado REAL de agora.
#
# Pega o erro recorrente: o crítico revisou uma versão VELHA do arquivo em
# vez da atual (Claude entregou a nova, mas o Codex leu a anterior). Sem
# isso não há como detectar — o parecer parece válido mas validou o errado.
#
# O crítico é instruído a carimbar, como PRIMEIRA seção da resposta:
#   ## Selo
#   - Manifesto (sha256): <hash>
# Onde o manifesto = o PACOTE inteiro enviado ao crítico (diff + lista de arquivos +
# comandos + saídas). Selar 1 arquivo só nao prova que ele leu o pacote certo.
# Se não conseguir, escreve a palavra literal: SELO INDISPONIVEL
#
# Uso:
#   verify-selo.sh <ARQUIVO_DA_REVISAO> <MANIFESTO>
#     <ARQUIVO_DA_REVISAO> = o parecer do crítico (onde está o selo carimbado)
#     <MANIFESTO>          = o pacote bruto que FOI enviado ao crítico (estado atual)
#
# Exit:
#   0  selo BATE com o estado atual              -> confiar no parecer
#   3  selo NAO bate (leu versao errada)         -> DESCARTAR e re-rodar so o critico
#   4  selo ausente / "SELO INDISPONIVEL"        -> nao da pra verificar, decidir com o dono
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

REVIEW="${1:?uso: verify-selo.sh <ARQUIVO_DA_REVISAO> <MANIFESTO>}"
TARGET="${2:?uso: verify-selo.sh <ARQUIVO_DA_REVISAO> <MANIFESTO>}"

[ -f "$REVIEW" ] || { echo "sem_arquivo_de_revisao"; exit 4; }
[ -f "$TARGET" ] || { echo "manifesto_ausente"; exit 4; }
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

# Aceita prefixo nos dois sentidos (o critico pode carimbar sha curto).
case "$want" in "$got"*) echo "ok ($got)"; exit 0 ;; esac
case "$got"  in "$want"*) echo "ok ($got)"; exit 0 ;; esac

echo "MISMATCH critico=$got atual=$want"
exit 3
