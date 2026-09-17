# Instalar a skill `/planejar`

Metodologia em 9 fases pra transformar uma ideia em plano de implementacao auditado, antes de codar — com especificacao de requisitos verificaveis (EARS) e constituicao de projeto no meio do caminho.

## Instalacao

```bash
cd ~/.claude/skills && tar -xzf planejar-skill.tar.gz
```

Cria `~/.claude/skills/planejar/` (SKILL.md + references/ + evals/). Reinicie a sessao do Claude Code e invoque com `/planejar`.

## Dependencias

A skill NAO empacota suas dependencias — ela orquestra outras skills, CLIs e MCPs que precisam existir nesta maquina. No primeiro `/planejar`, a **Fase 0 (preflight)** verifica tudo, monta um checklist (✅/❌) e — se faltar qualquer coisa critica ou recomendada relevante pro produto — **oferece instalar tudo que falta de uma vez, antes de comecar as fases** (com sua aprovacao). Nao degrada peca por peca no meio do caminho. So os itens de perda pequena passam com aviso. Detalhe completo em `references/preflight.md`.

### Criticas (sem fallback — preflight para e pede pra instalar)

| Dependencia | Fase | Como obter |
|-------------|------|------------|
| `superpowers:brainstorming` | 1 | plugin **superpowers** |
| `superpowers:writing-plans` | 6 | plugin **superpowers** |
| Pelo menos UM caminho de design | 5 (so se houver UI) | skill `design-lab` **ou** `design-taste-frontend` |
| `cloudflare-atlas` | 4 (toda stack — Cloudflare-first) | skill `cloudflare-atlas` |

### Recomendadas (tem fallback, mas perda de qualidade grande — entram na oferta de instalar)

| Dependencia | Fallback |
|-------------|----------|
| Skill `search` — motor unico de pesquisa das Fases 1-4 (apoio na 7). Motor Exa: MCP `exa` **ou** `EXA_API_KEY` (basta um) | sem Exa, as mesmas perguntas rodam com `WebSearch`+`WebFetch`; sem a skill, busca nativa crua |
| Skill `firecrawl` + CLI autenticada (`firecrawl --status` confirma — credential store ou `FIRECRAWL_API_KEY`) | `curl r.jina.ai` -> `WebFetch` |
| CLI `wrangler` autenticada (auditoria da conta Cloudflare real, passo 4 da Fase 4) | stack aprovada "condicionada a verificacao de conta"; pendencia fica no status file |
| Caminhos de design da Fase 5 — `design-lab` · `design-taste-frontend` | alternativos, nao empilhaveis: cada um faz direcao + peca sozinho. Ter os dois e melhor — a Fase 5 pergunta qual usar. Sem nenhum, mockup `artifact-design` (HTML vivo descartavel) |
| MCP `context7` (docs de libs de app na Fase 4) | skill `search` direcionada a doc oficial |
| `cloudflare-forum` | complemento da atlas; sem ela, so a `cloudflare-atlas` |
| `find-skills` (localiza skills de auditoria na Fase 7) | `context7` + boas praticas gerais |

### Opcionais (perda silenciosa — preflight menciona)

| Dependencia | Sem ela |
|-------------|---------|
| Skills de auditoria de dominio ja instaladas (Fase 7) | `find-skills` busca na hora |
| Tool `Workflow` (orquestra auditoria find→verify da Fase 7) | Agent tool em dois turnos (auditores; depois verificadores) |

## Setup minimo recomendado

Pra rodar o pipeline completo:
- plugin **superpowers** (criticas das fases 1 e 6)
- skills `cloudflare-atlas` + `cloudflare-forum` (Cloudflare-first pra toda a stack, Fases 4 e 7)
- skill `search` + motor Exa: conector `exa` de **1 clique** (Conectores do Claude Desktop — precisa **conta Exa gratuita** em exa.ai, mas **sem chave/API key**) **ou** `EXA_API_KEY` (só em headless/terminal). Sem nenhum, roda em modo nativo
- um caminho de design — skill `design-lab` (UI de produto) ou `design-taste-frontend` (landing/portfolio) — se for planejar produto com UI (a Fase 5 pergunta qual usar)
- skill `firecrawl` + CLI autenticada (scraping das Fases 2 e 4 — `firecrawl --status` confirma)
- CLI `wrangler` autenticada (auditoria da conta real na Fase 4)
- MCP: `context7`

Sem nada disso a skill ainda roda em modo degradado — mas perde pesquisa, mockups e auditoria especializada. O preflight te diz exatamente o que esta faltando no momento do uso.
