# Instalar o plugin `Titan` (e o que ele usa por fora)

O plugin `Titan` (skills `planejar`, `auto-gptworker`, `auto-think`, `handoff`, `gpt-optimizer`) **orquestra** ferramentas externas —
ele não empacota elas. Este arquivo reúne tudo que precisa instalar pra ele rodar completo.

A boa notícia: nada disso trava o plugin. A `planejar` tem um **preflight (Fase 0)** que confere
o que está presente e avisa o que falta — só para de verdade se faltar uma dependência **crítica**.
O que tem fallback, degrada sozinho.

---

## 0. Autoinstall — um comando

O `install.sh` instala **tudo que dá** sozinho, via a CLI `claude` (`claude plugin install`),
`npx` e `npm`: o próprio plugin Titan, os plugins externos (superpowers, cloudflare), as skills
via npx (taste-skill, find-skills, gemini-api-dev), o **Codex CLI** (se faltar) e o MCP do Stitch
(se você passar a chave). Não precisa mais colar `/plugin` na mão.

**Numa máquina que ainda não tem o plugin** (bootstrap direto do GitHub):
```bash
curl -fsSL https://raw.githubusercontent.com/cassianodiniz/Titan/main/install.sh | bash
```

**Se já tem o plugin** (roda da pasta dele, ou peça pro Claude *"roda o install.sh do Titan"*):
```bash
bash install.sh                          # instala tudo que dá
STITCH_API_KEY=suachave bash install.sh  # + configura o MCP do Stitch
SKIP_PLUGIN=1 bash install.sh            # só as dependências (não reinstala o Titan)
```

**Só sobra o que depende de chave/conta sua** (o script avisa no fim):
- `codex login` — uma vez, interativo (se ele instalou o Codex agora)
- `GEMINI_API_KEY` — grátis em https://aistudio.google.com/apikey (mockups da planejar)
- `/pesquisa` + Perplexity — vêm do curso/seu provedor; sem eles a planejar pula a pesquisa web
- MCPs `context7`/`firecrawl` — conforme seu provedor (opcionais, degradam sozinhos)

Depois, **reinicie o Claude Code** pra carregar os plugins. As tabelas abaixo são a referência
item-por-item, caso queira instalar na mão.

---

## 1. Instalar o próprio plugin `Titan`

Pelo `/plugin`, adicione o marketplace e instale:

```
/plugin marketplace add cassianodiniz/cassiano.diniz
/plugin install Titan@cassiano.diniz
```

Depois as skills ficam disponíveis como `Titan:planejar`, `Titan:auto-gptworker`, `Titan:handoff`.

---

## 2. Críticas (sem fallback — o preflight PARA se faltar)

| Ferramenta | Quem usa | Como instalar |
|---|---|---|
| **superpowers** (`brainstorming`, `writing-plans`) | `planejar` Fases 1 e 5 | `/plugin marketplace add obra/superpowers-marketplace`<br/>`/plugin install superpowers@superpowers-marketplace` |
| **Taste Skill** (`design-taste-frontend`) | `planejar` Fase 4 (só se houver tela) | `npx skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend"` |
| **Codex CLI** (constrói + revisor GPT-5.6) | `auto-gptworker` (constrói a tarefa e revisa o plano) e `planejar` (revisor do problema e da sanidade) | Instalar o Codex CLI da OpenAI e logar. Sem ele, o Claude assume a construção sozinho (garantia menor, avisando que rodou sem o Codex); em risco alto, fica BLOQUEADO até voltar. |

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
