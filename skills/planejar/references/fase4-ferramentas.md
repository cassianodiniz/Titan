# Fase 4 — Ferramentas e roteamento de pesquisa

Mapa de ferramentas da Pesquisa Tecnica. A `cloudflare-atlas` e o ponto de partida obrigatorio (regra no SKILL.md); aqui esta o resto do arsenal e qual ferramenta responde qual pergunta.

## Ferramentas

- **Skill `search`** — so na excecao Cloudflare: enumerar candidatos externos ("quais alternativas existem pra camada X") e levantar trade-offs/issues dos 2-3 finalistas, com fontes citadas na tabela de decisao.
- `context7` (resolve-library-id + query-docs) — documentacao oficial atualizada
- skill `firecrawl` (ou fallback jina.ai) — artigos tecnicos, benchmarks, issues em URL conhecida (ver "Scraping com fallback" no SKILL.md)
- **`cloudflare-forum` — complemento da atlas.** Erros conhecidos (5xx, 1020, etc.), changelogs, limites reais e solucoes da comunidade. Use junto com a atlas quando precisar validar comportamento ou custo no mundo real.
- **CLI `wrangler` (autenticada) — auditoria da conta real (passo 4 da Fase 4).** `wrangler whoami` + `d1 list` / `r2 bucket list` / `kv namespace list` / `queues list`: plano da conta, billing, recursos existentes (reuso/conflito). Alternativa se conectado: MCP da Cloudflare API. A regua do que cada plano suporta vem da `cloudflare-atlas`, nunca de memoria.
- **Skills de implementacao Cloudflare, uma por produto.** O ecossistema tem bem mais que as 4 mais óbvias — verifique a lista de skills disponiveis na sessao pelo PRODUTO especifico que a `cloudflare-atlas` escolheu pra cada componente, nao so pelas mais conhecidas. Exemplos (nao exaustivo — cresce com o tempo):
  - Workers em geral: `workers-best-practices`, `wrangler`
  - Coordenacao com estado: `durable-objects`
  - Agente/IA rodando na Cloudflare: `agents-sdk`, `cloudflare:build-agent`
  - Servidor MCP na Cloudflare: `cloudflare:build-mcp`
  - Schema/migrations do D1: `d1-drizzle-schema`
  - Login corporativo / Zero Trust / Access: `cloudflare-one` (e `cloudflare-one-migrations` se for migracao)
  - Envio/recebimento de email: `cloudflare-email-service`
  - Anti-bot / CAPTCHA: `turnstile-spin`
  - Sandboxes de execucao: `sandbox-sdk`
  - Performance depois de no ar: `web-perf`
  - Produto sem skill dedicada: `cloudflare` (base, ampla, doc-biased) como fallback
  Invoque pelo nome exato que aparecer na lista da sessao — pode vir com prefixo de plugin (`cloudflare:build-mcp`) ou sem (`agents-sdk`), os dois funcionam igual. Nesta fase, uso e leve (validar viabilidade/pattern da escolha); a revisao funda de codigo acontece na Fase 6 (escrita) e Fase 7 (auditoria) — ver `references/audit-skills.md`.
- **Skills externas — so na excecao (cobertura/custo).** Quando uma camada cair numa das duas excecoes, aí sim consulte a skill da alternativa antes da busca web: `supabase`/`supabase-best-practices`, `vercel:nextjs`, e pra LLM externo `claude-api`/`gemini-api-dev` (preferindo acesso via AI Gateway). Fora da excecao, nao invoque essas — a decisao ja e Cloudflare.

- **Camada de auth** — decisao guiada por `references/auth-multitenancy.md` (modelo de uso → Access vs Better Auth, com numeros confirmados e pegadinhas). Skills de implementacao: `create-auth`, `better-auth-best-practices`, `better-auth-security-best-practices`.

## Roteamento — qual ferramenta pra qual pergunta

| Tipo de pergunta | Ferramenta | Fallback se indisponivel |
|------------------|-----------|--------------------------|
| Doc/API/pattern de produto **Cloudflare** ("como configurar D1", "limite do Workers KV") | `cloudflare-atlas` + MCP `cloudflare-docs` | — (ambos cobrem; e a stack default) |
| Assinatura/pattern de **lib de aplicacao** com versao conhecida ("hook X no Next 16", "config do Vitest") | `context7` | Sem context7 → skill `search` direcionada a doc oficial |
| **Enumeracao de candidatos, comparacao, trade-off, "tem problema conhecido?"** | skill `search` | `WebSearch`+`WebFetch` nativos |

Resumo: doc canonica versionada = `context7`/`cloudflare-docs` (cirurgico, barato); todo o resto da pesquisa = `search`. Nao use `context7` pra decidir entre alternativas (ele so tem a doc de uma).
