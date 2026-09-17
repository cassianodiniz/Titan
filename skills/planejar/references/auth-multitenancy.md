# Modelo de uso, auth e multi-tenancy (Fases 1, 3, 4 e 7)

Tres decisoes que TODO produto com login atravessa, e que custam caro se descobertas tarde. A Fase 1 pergunta, a Fase 3 registra, a Fase 4 decide a camada de auth, a Fase 7 ataca.

## A pergunta obrigatoria (Fase 1 — brainstorm)

Todo produto com login exige classificar o **modelo de uso** — sao coisas DIFERENTES e mudam schema, auth e custo:

1. **Uso proprio** — so o dono (ou 1-2 pessoas). Auth minima.
2. **Time interno / poucos usuarios** — grupo fechado e conhecido (funcionarios, familia, ate ~dezenas).
3. **Muitos usuarios publicos** — qualquer pessoa cria conta; todos no MESMO ambiente compartilhado.
4. **Multi-tenant** — varios CLIENTES usam o mesmo app, cada um com ambiente PRIVADO e isolado (SaaS pra empresas, app de agencia com N clientes). Multiusuario ≠ multi-tenant: no 3 todo mundo ve o mesmo mundo; no 4 o tenant A nao pode nem saber que o B existe.

Errar 3 vs 4 e o erro mais caro da lista: multi-tenancy nao se "adiciona depois" — e schema, e toda query, e todo objeto de storage. A resposta entra na spec (premissas) e na constituicao.

## Decisao de auth (Fase 4) — dados confirmados 2026-07 (re-validar com `cloudflare-atlas` se fizer tempo)

| Modelo de uso | Camada de auth default | Por que |
|---------------|------------------------|---------|
| Uso proprio / time interno **ate ~50 pessoas somando TODOS os apps da conta** | **Cloudflare Access (Zero Trust)** | Zero codigo de auth; plano Free cobre 50 seats. |
| Muitos usuarios publicos OU multi-tenant OU conta ja perto dos 50 seats | **Better Auth** no proprio Worker + D1 | Open-source (MIT), self-hosted, **sem limite de usuarios**, custo zero de licenca. |

**Pegadinhas do Access (apresente ao usuario antes de escolher):**
- Os 50 seats sao **POR CONTA Zero Trust, compartilhados entre TODAS as aplicacoes Access** — um usuario consome 1 seat mesmo acessando 10 apps, mas 10 apps de clientes diferentes na mesma conta somam usuarios no MESMO pool. Pra agencia com varios apps de cliente na propria conta, os 50 esgotam rapido.
- Estourou 50: usuarios novos sao **bloqueados no login** ate upgrade.
- Plano pago (Zero Trust Standard): **US$ 7/usuario/mes cobrado de TODOS os usuarios**, nao so os excedentes — 51 usuarios = ~US$ 357/mes. E a virada de custo mais brusca da stack.
- Portanto: Access so quando o teto de usuarios e CONHECIDO e folgado. Registre o teto como premissa com gatilho de replanejamento ("passou de N usuarios → migrar pra Better Auth").

**Better Auth em Workers + D1 (caminho ESTABELECIDO mas nao maduro — verificado adversarialmente 2026-07):**
- Adapter: `drizzleAdapter(db, { provider: "sqlite" })` ou, a partir do Better Auth 1.5+, binding D1 nativo. Pacote comunitario `better-auth-cloudflare` cobre D1/KV/R2. Receita oficial com Hono existe. (Adquirido pela Vercel em jul/2026 — segue MIT/open-source.)
- (1) Binding D1 so existe DENTRO do request — instancie o auth por request (factory), nunca no escopo global do Worker (issues #207/#1272).
- (2) Bug `cookieCache` + secondaryStorage (issue #4203, REABERTO jan/2026, sem patch): logout forcado apos ~5 min; workaround e desabilitar `cookieCache`.
- (3) Rate limiter com KV: endpoints com TTL de 10s violam o minimo de 60s do KV — `Math.max(ttl, 60)` no secondaryStorage ou `rateLimit.customStorage`.
- (4) Historico de breaking changes agressivas e bugs de producao em Workers (#6665) — pin de versao + testes de auth no plano sao obrigatorios, nao opcionais.
- **Alternativas legitimas pela excecao de cobertura/custo** (usuario avesso a operar auth propria): Clerk / Stack Auth / Supabase Auth — gerenciadas, custo por MAU. Apresente como opcao quando o usuario nao quiser carregar os workarounds acima; a saida vira excecao documentada na constituicao.
- **Skills a usar** (planejamento, plano e auditoria) — sao o **skill-pack OFICIAL do Better Auth** ([github.com/better-auth/skills](https://github.com/better-auth/skills), doc em better-auth.com/docs/ai-resources/skills). Instala-se com a CLI `skills` — `npx skills add better-auth/skills` (pack inteiro, traz as 6) ou `npx skills add better-auth/skills@<nome-da-skill>` (avulsa). **Nao instale pela rota de plugin:** o repo tem `.claude-plugin/marketplace.json`, mas o plugin `auth-skills` declara so 2 das 6 (`create-auth`, `best-practices`) — ficam de fora `organization-best-practices` (a primitiva de multi-tenancy) e `better-auth-security-best-practices` (que mora em `security/`, fora da pasta `better-auth/`). Puxe as relevantes ao que a spec pede, nao todas:
  - `create-auth` — scaffold inicial (detecta framework, adapters, rotas)
  - `better-auth-best-practices` — config, adapters, sessoes
  - `better-auth-security-best-practices` — rate limit, secrets, CSRF, cookies, encriptacao de token
  - `organization-best-practices` — **plugin de organizations: a primitiva de multi-tenancy do Better Auth** (organization = tenant, com membros/convites/papeis prontos). Se o produto for multi-tenant, olhe isso ANTES de desenhar tabela de tenant na mao — pode ja resolver metade do modelo.
  - `email-and-password-best-practices` — verificacao de email, reset de senha, politica de senha
  - `two-factor-authentication-best-practices` — 2FA, quando a spec exigir
  - Essas skills entram na cobertura de skills da stack (passo 7 da Fase 4) e viram regua dos auditores da Fase 7 — se nao estiverem instaladas, `find-skills` as busca ali.
- **Pacote (nao e skill — vai no plano como dependencia do projeto):** `better-auth-cloudflare` (zpg6) cobre a integracao com D1/KV/R2; alternativa e o adapter Drizzle/D1 nativo.

## Multi-tenant (Fase 3 → constituicao; Fase 4 → nivel de isolamento; Fase 6 → plano; Fase 7 → red-team)

### Primeira decisao (Fase 4): NIVEL de isolamento — nao existe default unico

Verificado adversarialmente (2026-07): a Cloudflare recomenda ativamente **D1 database-per-tenant** em escala — o D1 foi DESENHADO pra milhares de bancos por conta, cada banco tem teto rigido de **10GB** e e single-threaded (uma query lenta de um tenant trava os outros no banco compartilhado). Apresente a bifurcacao no gate:

| Nivel | Quando | Trade-off |
|-------|--------|-----------|
| **1 — D1 compartilhado + tenant_id** | Poucos tenants (ate ~10), MVP, dados pequenos, schema muda com frequencia | Simples de operar (1 ALTER, analytics cross-tenant facil); isolamento e DISCIPLINA (uma query sem filtro = vazamento), noisy neighbor garantido, 10GB divididos entre todos |
| **2 — D1 por tenant** | Escala (>10 tenants), tenant grande, compliance/isolamento critico | Isolamento ARQUITETURAL (query nao alcanca outro tenant fisicamente), 10GB POR tenant, custo ~zero na Cloudflare; migrations replicadas N vezes, analytics cross-tenant exige agregacao |

**Os numeros acima sao do Workers PAID. No Free, o nivel 2 nao existe** (verificado ao vivo 2026-07-28): o Free da **10 bancos D1 na conta inteira, de 500MB cada** — contra 50.000 bancos de 10GB no Paid (ampliavel sob pedido a "milhoes"). Ou seja, prometer "comeca compartilhado e migra pra per-tenant depois" numa conta Free e prometer uma saida que nao existe: o teto de 10 bancos chega junto com o ~10º tenant. Se o produto nasce no Free e o gatilho de migracao e real, o upgrade pro Paid (US$5/mes) faz parte do gatilho, nao e detalhe posterior — registre assim na premissa.

Escolheu nivel 1: registre como PREMISSA com gatilho ("passou de ~10 tenants ou tenant chegou a XGB → migrar pra per-tenant **e, se a conta estiver no Free, subir pro Workers Paid**"). Durable Objects por tenant complementam qualquer nivel pra estado/coordenacao real-time (objetos ilimitados, 10GB cada, nos dois planos).

### Segunda decisao (Fase 4): o tenant traz o DOMINIO dele?

Pergunte no gate, junto com o nivel de isolamento — muda a stack e nao se improvisa depois. Duas respostas:

- **Nao** (`cliente.seuapp.com.br`, subdominio seu): nada a decidir, Workers resolve com um wildcard.
- **Sim** (`app.cliente.com.br`, dominio do cliente): isso e **Cloudflare for SaaS** (custom hostnames), produto proprio. Precisa de *fallback origin* (um registro proxied na sua zona), *CNAME target* (o que voce manda o cliente apontar) e uma chamada de API por cliente pra criar o hostname; a Cloudflare emite o certificado. Preco (verificado 2026-07-28): **100 hostnames inclusos**, depois **US$0,10/hostname**, teto de 50.000.
  - **Gotcha de operacao:** ha DOIS status independentes — `result.status` (hostname) e `result.ssl.status` (certificado). So e producao quando os DOIS estao `active`. Isso vira passo do plano na Fase 6 e jornada na Fase 9 ("cliente aponta o DNS → dominio ativo com HTTPS"), nao um "depois a gente configura".
  - **Dominio apex** (cliente quer `cliente.com.br` na raiz, sem CNAME): exige Apex Proxying ou BYOIP, add-ons **Enterprise**. Se algum cliente vai querer isso, descubra AGORA — e o unico item aqui que pode inviabilizar a conta.

**Workers for Platforms** e um produto diferente e quase sempre NAO e o caso: so entra se os proprios tenants fizerem deploy de CODIGO deles (site builder, low-code, plataforma de vibe coding). SaaS normal — voce roda seu codigo pra todos os tenants — usa Workers comum. Nao confunda os dois so porque ambos dizem "multi-tenant".

### Principio da constituicao (uma linha — o COMO e decisao do planejamento)

> **SaaS multi-tenant na Cloudflare: o tenant e resolvido no SERVIDOR (nunca de URL/header/body), TODO acesso a dado e arquivo e filtrado por tenant, e o plano inclui testes provando que tenant A nao acessa tenant B.**

E isso. O desenho concreto (repository central, helpers de chave, formato de sessao, como webhook descobre o tenant) e trabalho das Fases 4-6 — a skill decide no planejamento, guiada pelos fatos acima (nivel de isolamento) e cobrada pelos vetores abaixo (red-team). Nao prescreva a solucao na constituicao; prescreva o invariante e o teste.

**Unico fato tecnico a manter em vista no desenho:** D1 nao tem RLS — o filtro por tenant e responsabilidade da aplicacao, entao o plano precisa dizer ONDE essa muralha mora (e como uma query nova nao escapa dela).

**Red-team (Fase 7) — vetores de ataque ao isolamento** (verificados em incidentes reais 2025-26; cada furo e P0):
- IDOR classico: trocar IDs em URL/body; tenant forjado em header
- Caminhos SEM sessao: token de API sem escopo de tenant; webhook aplicado sem mapear payload→tenant; job de fila/cron herdando contexto do job anterior
- Usuario em 2+ tenants (org switching) trocando de tenant sem re-validacao
- Chaves R2/KV: colisao de prefixo (`tenant_a` vs `tenant_ab`), path traversal (`..`), chave montada fora do helper
- Recursos compartilhados: cache servindo resposta de outro tenant, logs vazando dado cross-tenant, rate limit global (um tenant derruba os demais)
- Query nova adicionada depois do MVP sem filtro (a muralha tem porta dos fundos?)

**Jornadas (Fase 9):** incluir jornada negativa "tenant A tenta acessar recurso do tenant B → bloqueado" — com evidencia, cobrindo tambem um caminho sem sessao.
