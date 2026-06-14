# Instalar o plugin `dev` (e o que ele usa por fora)

O plugin `dev` (skills `planejar`, `auto-prompt`, `handoff`) **orquestra** ferramentas externas —
ele não empacota elas. Este arquivo reúne tudo que precisa instalar pra ele rodar completo.

A boa notícia: nada disso trava o plugin. A `planejar` tem um **preflight (Fase 0)** que confere
o que está presente e avisa o que falta — só para de verdade se faltar uma dependência **crítica**.
O que tem fallback, degrada sozinho.

---

## 0. Jeito rápido (instalador guiado) — recomendado pra quem não curte terminal

Tem um script que **instala sozinho** a parte que dá pra automatizar. Você roda (ou pede pro
Claude: *"roda o install.sh do dev"*):

```bash
bash install.sh                      # instala as skills automáticas
STITCH_API_KEY=suachave bash install.sh   # + configura o MCP do Stitch
```

**O script instala pra você:** Taste Skill, Find Skill, gemini-api-dev e (se passar a chave) o
MCP do Stitch.

**Só você consegue fazer** (o script não digita `/plugin` por você — ele te lembra disso no fim):

1. Colar no Claude Code, uma linha por vez:
   ```
   /plugin marketplace add obra/superpowers-marketplace
   /plugin install superpowers@superpowers-marketplace
   /plugin marketplace add cloudflare/skills
   /plugin install cloudflare@cloudflare
   ```
2. Dar as chaves: `GEMINI_API_KEY` (mockups) e a chave do Stitch.
3. Pegar a `/pesquisa` no curso do professor e ter os MCPs `context7`/`firecrawl`/`perplexity`
   + o **Codex CLI** (o crítico) no ambiente.

As tabelas abaixo são a referência completa, item por item, caso queira instalar na mão.

---

## 1. Instalar o próprio plugin `dev`

Pelo `/plugin`, adicione o marketplace e instale:

```
/plugin marketplace add cassianodiniz/cassiano.diniz
/plugin install dev@cassiano.diniz
```

Depois as skills ficam disponíveis como `dev:planejar`, `dev:auto-prompt`, `dev:handoff`.

---

## 2. Críticas (sem fallback — o preflight PARA se faltar)

| Ferramenta | Quem usa | Como instalar |
|---|---|---|
| **superpowers** (`brainstorming`, `writing-plans`) | `planejar` Fases 1 e 5 | `/plugin marketplace add obra/superpowers-marketplace`<br/>`/plugin install superpowers@superpowers-marketplace` |
| **Taste Skill** (`design-taste-frontend`) | `planejar` Fase 4 (só se houver tela) | `npx skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend"` |
| **Codex CLI** (revisor/crítico GPT-5.5) | `auto-prompt` (crítico) e `planejar` (revisor do problema e da sanidade) | Instalar o Codex CLI da OpenAI e logar. Sem ele, o crítico cai pra um agente Claude separado (garantia menor); em risco alto, fica BLOQUEADO até voltar. |

---

## 3. Com fallback (degradam sozinhas — o preflight só informa)

| Ferramenta | Quem usa | Como instalar |
|---|---|---|
| **find-skills** | `planejar` Fase 6 (acha skill de auditoria por domínio) | `npx skills add https://github.com/vercel-labs/skills --skill find-skills` |
| **/pesquisa** (busca profunda) + **Perplexity** | `planejar` Fase 1 — descoberta de "como já resolveram isso" (prior art) | A skill `/pesquisa` é distribuída pelo curso do professor (operacaoautonomia.escoladeautomacao.com.br). Precisa do MCP **Perplexity** ativo; sem ele, a descoberta cai pra varredura leve. |
| **Cloudflare** (skills de plataforma) | `planejar` Fases 3 e 6 (Workers/D1/R2/KV) | `/plugin marketplace add cloudflare/skills`<br/>`/plugin install cloudflare@cloudflare` |
| **gemini-api-dev** | `planejar` Fase 4 (mockups Nano Banana) e Fase 3 (escolha de modelo de IA) | `npx skills add google-gemini/gemini-skills --skill gemini-api-dev --global` |
| **Google Stitch (MCP)** | `planejar` Fase 4 (telas estruturadas) | `claude mcp add stitch --transport http https://stitch.googleapis.com/mcp --header "X-Goog-Api-Key: SUA_CHAVE" -s user` |
| **GEMINI_API_KEY** (env) | `planejar` Fase 4 (mockups visuais) | Criar grátis em https://aistudio.google.com/apikey e exportar como variável de ambiente |
| **context7** (MCP) | `planejar` Fase 3 (doc oficial atualizada) | Adicionar o MCP context7 conforme seu provedor |
| **firecrawl** (MCP) | `planejar` Fases 2 e 3 (raspar sites/artigos) | Adicionar o MCP firecrawl; sem ele, cai pra `curl r.jina.ai` → `WebFetch` |

---

## 4. Conferir se está tudo lá

Rode `/planejar` em qualquer ideia: o **preflight da Fase 0** lista, em uma linha, o que está
presente, o que está indisponível e qual fallback será usado. É a forma oficial de auditar a
instalação — não precisa conferir item por item na mão.

> Observação honesta: `/pesquisa`, `context7` e `firecrawl` não têm um comando público único
> aqui porque dependem do seu provedor/curso. Os demais têm o comando exato acima, do jeito que
> o professor passou.
