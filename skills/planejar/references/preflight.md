# Preflight — dependencias e instalacao (Fase 0)

Detalhe completo do preflight. O SKILL.md tem a regra de execucao (resolver o setup INTEIRO de uma vez, parar e ofertar em bloco); aqui esta O QUE verificar e COMO instalar.

## Criticas (sem elas a metodologia quebra — bloqueiam ate o usuario decidir)

- `superpowers:brainstorming` (Fase 1) — plugin **superpowers**
- `superpowers:writing-plans` (Fase 6) — plugin **superpowers**
- `cloudflare-atlas` (Fase 4 — pre-requisito de TODA a stack; Cloudflare-first pra tudo) — skill `cloudflare-atlas`
- **Pelo menos UM caminho de design** (Fase 5, **so se houver UI**) — `design-lab` OU `design-taste-frontend`. Sem nenhum, so o fallback artifact

## Recomendadas (tem fallback, mas a perda de qualidade e grande — entram na oferta de instalar)

- Skill `search` — motor unico de pesquisa das Fases 1-4 (apoio na 7). Roda em modo Exa se houver **MCP `exa` conectado OU `EXA_API_KEY`** (basta um — o conector `exa` ja traz a auth, nao precisa de env var). Sem Exa (ou sem a skill), as mesmas perguntas rodam com `WebSearch`+`WebFetch` nativos
- Skill `firecrawl` + CLI — scraping das Fases 2 e 4; fallback `curl r.jina.ai` → `WebFetch`. **Verificacao canonica: `firecrawl --status`** (mostra auth e creditos). A CLI autentica por credential store OU `FIRECRAWL_API_KEY` — se o `--status` diz "Authenticated", esta ✅ mesmo sem env var; so marque ❌ se o `--status` falhar
- `cloudflare-forum` — complemento da atlas (erros/changelogs/custo real)
- **CLI `wrangler` autenticada** (`which wrangler` + `wrangler whoami`) — auditoria da conta Cloudflare real no passo 4 da Fase 4 (plano Free vs Paid, billing, recursos existentes). Sem ela, a stack e aprovada "condicionada a verificacao de conta" e a pendencia fica no status file — funciona, mas empurra o risco pra frente
- `context7` (MCP) — docs de libs de app na Fase 4; fallback skill `search` direcionada a doc oficial
- **Caminhos de design da Fase 5** (**so se houver UI**) — sao **alternativos, nao empilhaveis**: cada um faz direcao + peca sozinho. Ter os dois e melhor, porque a Fase 5 pergunta ao usuario qual usar:
  - **`design-lab`** (skill) — UI de produto (app/SaaS/dashboard/prototipo); desenha em HTML no terminal, verifica com Chrome headless
  - **`design-taste-frontend`** (skill) — landing/portfolio/redesign; anti-slop, infere a direcao e entrega a interface. **Escopo declarado exclui dashboards e UI de produto multi-step**
  - Sem nenhum dos dois → fallback: mockup `artifact-design`
- `find-skills` — localizar skills de auditoria por dominio na Fase 7; fallback `context7` + boas praticas

## Opcionais (perda pequena — so mencione, nao precisa oferta)

- Skills de auditoria de dominio ja instaladas (Fase 7) — se faltar, `find-skills` busca na hora

## Como instalar (quando o usuario aprovar)

- **Skills** (`search`, `firecrawl`, `cloudflare-atlas`, `cloudflare-forum`, `find-skills`, `design-taste-frontend`, `design-lab`): invoque `find-skills` pra localizar e instalar do marketplace; skills `superpowers:*` vem do plugin **superpowers**.
- **Skills do Better Auth** (nao sao pre-req daqui — so entram se a auth cair nelas na Fase 4): skill-pack oficial em `github.com/better-auth/skills`. Instale pela CLI `skills` — `npx skills add better-auth/skills` (traz as 6). **Nao instale pela rota de plugin:** o `marketplace.json` do repo empacota so 2 das 6 (`create-auth`, `best-practices`) e deixa de fora justamente `organization-best-practices` (multi-tenancy) e `better-auth-security-best-practices` (regua da Fase 7). Criterio e lista em `references/auth-multitenancy.md`.
- **MCPs** (`context7`): `claude mcp add --transport http --scope user <nome> <url> [--header "KEY: valor"]`.
- **Motor de pesquisa Exa** (para a skill `search`): e um **conector de 1 clique, SEM chave** — no Claude Desktop, abra **Conectores**, busque `exa` e conecte. Requer **conta no Exa** (gratuita, exa.ai), mas nao pede API key nem env var: ja entra autorizado. So use `EXA_API_KEY` como caminho alternativo em ambiente headless/terminal sem o conector.
- **Keys/env** (`FIRECRAWL_API_KEY`): peça a key ao usuario e configure (`.env` ou credential store da CLI). Nunca invente key.
- Nunca instale nada sem aprovacao explicita. Depois de instalar MCP/CLI, avise que as tools novas podem so aparecer na proxima sessao.

## Modelo de saida (checklist + oferta unica)

> **Preflight da /planejar — setup:**
> ✅ superpowers · cloudflare-atlas · search · firecrawl (autenticada) · context7
> ❌ Faltando: `cloudflare-forum` (skill), motor Exa (nem MCP `exa` nem `EXA_API_KEY` — search cai pra busca nativa), os dois caminhos de design da Fase 5 (`design-lab`, `design-taste-frontend` — sem nenhum, o design cai pro fallback artifact)
>
> Quer que eu instale/configure o que falta agora antes de comecar? (ou seguimos com os fallbacks — busca nativa, sem mockup)

Se **tudo** estiver presente, uma linha ("Preflight OK, tudo instalado — comecando pelo brainstorm") e siga direto. So dispensa a oferta quando nada relevante falta.
