#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════
# install.sh — AUTOINSTALL do plugin `Titan` e de tudo que ele usa por fora.
#
# Instala SOZINHO (via a CLI `claude` + `npx` + `npm`):
#   • o próprio plugin Titan (marketplace + install)
#   • os plugins externos que a planejar usa (superpowers, cloudflare)
#   • as skills via npx (taste-skill, find-skills, gemini-api-dev)
#   • o Codex CLI (o crítico), se faltar
#   • o MCP do Stitch (se você passar a chave)
#
# Uso:
#   bash install.sh                          # instala tudo que dá
#   STITCH_API_KEY=xxxx bash install.sh      # + configura o MCP do Stitch
#   SKIP_PLUGIN=1 bash install.sh            # não instala o Titan (só as deps)
#
# Bootstrap direto do GitHub (numa máquina sem o plugin ainda):
#   curl -fsSL https://raw.githubusercontent.com/cassianodiniz/Titan/main/install.sh | bash
#
# Mac/Linux nativo; no Windows, via Git Bash. NÃO roda em PowerShell/cmd.
# ════════════════════════════════════════════════════════════════════════
set -uo pipefail

say()  { printf '%s\n' "$*"; }
ok()   { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*"; }
run()  { local d="$1"; shift; say "→ $d"; if "$@"; then ok "$d"; else warn "$d — falhou; veja o INSTALL.md"; fi; say ""; }

say "=== AUTOINSTALL do plugin Titan ==="
say ""

# ── Pré-requisitos ──────────────────────────────────────────────────────
HAS_CLAUDE=1; HAS_NPX=1
command -v claude >/dev/null 2>&1 || { HAS_CLAUDE=0; warn "CLI 'claude' não encontrada no PATH — instale o Claude Code primeiro (os /plugin e o MCP dependem dela)."; }
command -v npx    >/dev/null 2>&1 || { HAS_NPX=0;    warn "npx (Node.js) não encontrado — instale o Node (https://nodejs.org). As skills via npx e o Codex não vão instalar."; }
say ""

# ── 1. O próprio plugin Titan ────────────────────────────────────────────
if [ "${SKIP_PLUGIN:-0}" != "1" ] && [ "$HAS_CLAUDE" = "1" ]; then
  run "Marketplace cassiano.diniz" claude plugin marketplace add cassianodiniz/cassiano.diniz
  run "Plugin Titan"               claude plugin install Titan@cassiano.diniz -s user
fi

# ── 2. Plugins externos que a planejar orquestra ─────────────────────────
if [ "$HAS_CLAUDE" = "1" ]; then
  run "Marketplace superpowers" claude plugin marketplace add obra/superpowers-marketplace
  run "Plugin superpowers"      claude plugin install superpowers@superpowers-marketplace -s user
  run "Marketplace cloudflare"  claude plugin marketplace add cloudflare/skills
  run "Plugin cloudflare"       claude plugin install cloudflare@cloudflare -s user
fi

# ── 3. Skills via npx ────────────────────────────────────────────────────
if [ "$HAS_NPX" = "1" ]; then
  run "Taste Skill (design-taste-frontend)" npx -y skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend"
  run "Find Skill"                          npx -y skills add https://github.com/vercel-labs/skills --skill find-skills
  run "Gemini (gemini-api-dev)"             npx -y skills add google-gemini/gemini-skills --skill gemini-api-dev --global
fi

# ── 4. Codex CLI (o crítico GPT-5.5) ─────────────────────────────────────
if command -v codex >/dev/null 2>&1; then
  ok "Codex CLI já instalado"; say ""
elif [ "$HAS_NPX" = "1" ]; then
  run "Codex CLI (@openai/codex)" npm install -g @openai/codex
  warn "Falta logar uma vez: rode 'codex login' (interativo). Sem login, auto-think/gpt-optimizer/auto-gptworker caem pro modo reduzido."
  say ""
fi

# ── 5. MCP do Stitch (só com a chave) ────────────────────────────────────
KEY="${STITCH_API_KEY:-${GOOGLE_STITCH_API_KEY:-}}"
if [ -n "$KEY" ] && [ "$HAS_CLAUDE" = "1" ]; then
  run "MCP Google Stitch" claude mcp add stitch --transport http https://stitch.googleapis.com/mcp --header "X-Goog-Api-Key: $KEY" -s user
else
  warn "MCP Stitch pulado (opcional) — rode 'STITCH_API_KEY=suachave bash install.sh' pra configurar."
  say ""
fi

# ── 6. O que NÃO dá pra automatizar (chave/conta/provedor) ───────────────
say "════════════════════════════════════════════════════════════════"
say "FALTA SÓ O QUE DEPENDE DE CHAVE/CONTA SUA:"
say "  • codex login            → uma vez, interativo (se instalei o Codex agora)"
say "  • GEMINI_API_KEY         → grátis em https://aistudio.google.com/apikey (mockups da planejar)"
say "  • /pesquisa + Perplexity → vêm do curso/seu provedor; sem eles a planejar pula a pesquisa web"
say "  • MCPs context7/firecrawl → conforme seu provedor (opcionais; degradam sozinhos)"
say "════════════════════════════════════════════════════════════════"
say ""
say "Reinicie o Claude Code (ou abra sessão nova) pra carregar os plugins."
say "O preflight da Fase 0 do /Titan:planejar confere o que ficou faltando."
