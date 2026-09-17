# Skills de Auditoria por Dominio

Referencia de quais skills usar na Fase 7 (Auditoria) baseado na stack do projeto.

**Esta tabela e um EXEMPLO de mapeamento, nao a fonte da verdade.** A fonte da verdade e a lista de skills disponiveis no contexto da sessao (sempre presente no system prompt). Skills instaladas depois desta tabela tambem devem ser consideradas — filtre a lista da sessao pelos dominios da stack do projeto.

## Mapeamento (exemplos)

| Dominio | Skills |
|---------|--------|
| Supabase | `supabase-audit-rls`, `supabase-audit-rpc`, `supabase-best-practices`, `supabase-postgres-best-practices` |
| React/Next.js | `react-best-practices`, `vercel-react-best-practices`, `next-best-practices`, `nextjs-app-router-fundamentals`, `nextjs-seo` |
| Tailwind | `tailwind-4-docs`, `tailwind-v4-shadcn`, `tailwind-design-system` |
| Chrome Extension | `chrome-extension-wxt`, `chrome-extension-development` |
| Monorepo | `monorepo-management` |
| Animacoes | `framer-motion`, `accessible-motion` |
| Acessibilidade | `accessibility` |
| Cloudflare (default de toda a stack) | `cloudflare-atlas` (obrigatoria — como a Fase 4 e Cloudflare-first pra tudo, quase todo plano tem stack Cloudflare; audita frontend/backend/DB/storage/LLM/Workers/config e caca API alucinada com refs atuais) + `cloudflare-forum` (erros conhecidos/changelogs) SEMPRE, mais UMA skill por produto especifico que o plano realmente usa (nao invoque todas — so as que o plano toca): `workers-best-practices`/`wrangler` (Workers), `durable-objects` (estado coordenado), `agents-sdk`/`cloudflare:build-agent` (agente na Cloudflare), `cloudflare:build-mcp` (servidor MCP), `d1-drizzle-schema` (schema/migrations D1), `cloudflare-one`/`cloudflare-one-migrations` (Zero Trust/Access), `cloudflare-email-service` (email), `turnstile-spin` (anti-bot), `sandbox-sdk` (sandboxes), `web-perf` (performance). Produto sem skill dedicada instalada → `cloudflare` (base) como fallback |
| Svelte | `svelte5-best-practices` |
| Testes | `vitest`, `e2e-testing-patterns` |
| TanStack Query | `tanstack-query-best-practices` |
| Validacao de dados | `zod` |
| Performance web | `web-perf` |
| Seguranca | `security-review` |
| Auth (Better Auth) | `better-auth-best-practices`, `better-auth-security-best-practices` (rate limit, secrets, CSRF, cookies), `create-auth`, `email-and-password-best-practices`, `two-factor-authentication-best-practices` |
| Multi-tenancy com Better Auth | `organization-best-practices` (organization = tenant: membros, convites, papeis) |
| Multi-tenancy | red-team com mandato de isolamento + principios da constituicao (ver `auth-multitenancy.md`) — todo furo de isolamento e P0 |
| IA/LLM | `claude-api`, `gemini-api-dev`, `ai-sdk` |
| Estado (React) | `zustand-5`, `jotai` |

## Dominios transversais

Independente da stack, considere sempre nesses casos:

- **Seguranca** (`security-review`) — qualquer produto com auth, dados de usuario ou API publica
- **Acessibilidade** (`accessibility`) — qualquer produto com UI
- **Testes** (`vitest`, `e2e-testing-patterns`) — qualquer plano que inclua testes (todos deveriam)

## Como atualizar

Quando instalar novas skills tecnicas, adicione-as na tabela acima no dominio correspondente — mas lembre: mesmo sem atualizar a tabela, o modelo deve filtrar a lista da sessao na hora da auditoria.

## Prompt do auditor de dominio (Fase 7, passo 5)

Modelo do prompt de cada subagent auditor — substitua `<nome-da-skill>`, `<path-do-plano>`, `<path-da-constituicao>` e `<dominio>`:

```
Voce e um auditor tecnico. Tarefa:
1. Invoque a skill `<nome-da-skill>` e absorva as boas praticas dela.
2. Leia o plano de implementacao em `<path-do-plano>` e a constituicao em `<path-da-constituicao>`.
3. Audite APENAS o dominio <dominio> do plano, perguntando:
   - O codigo proposto segue as boas praticas dessa tecnologia?
   - Tem vulnerabilidades de seguranca?
   - Tem problemas de performance?
   - Faltam patterns recomendados?
   - Viola algum principio da constituicao?
4. Retorne os achados em markdown, cada um com:
   - Prioridade (P0 bugs/seguranca, P1 performance/arquitetura, P2 UX/boas praticas, P3 opcional)
   - Secao do plano afetada (titulo + trecho)
   - O que esta errado e como corrigir (com codigo quando aplicavel)
5. REGRA DE FONTE: achado cuja confirmacao depende de QUALQUER afirmacao sobre sistema
   fora do plano (comportamento, garantia, formato, nome, versao, limite de API/lib/servico)
   so entra como achado com verificacao em doc ATUAL (context7 ou 1-2 buscas), com a fonte
   citada no achado — em QUALQUER prioridade, P2/P3 incluidos. Sua memoria de treino pode
   estar desatualizada — ja aconteceu de um auditor sugerir como "correcao" a API obsoleta.
   Sem fonte viva, registre APENAS como "a validar" — em nenhuma prioridade (rebaixar a P2
   pra escapar da verificacao e a brecha classica).
Nao retorne elogios nem resumo do plano — so achados acionaveis.
```
