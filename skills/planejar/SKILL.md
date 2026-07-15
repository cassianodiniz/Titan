---
name: planejar
description: 'Metodologia completa para planejar produtos digitais antes de escrever uma linha de código. Cobre desde brainstorm até plano de implementação auditado e corrigido. Use quando o usuário quiser planejar um novo produto (web app, mobile, extensão, SaaS, API), quando disser "vamos planejar", "quero construir X", "tenho uma ideia pra Y", "novo projeto", "MVP", ou quando mencionar que precisa de um plano ou especificação antes de codar. Também use quando o usuário pedir pra transformar uma ideia vaga em especificação técnica. NÃO use para tarefas de implementação — esta skill produz o PLANO, não o código.'
---

# Planejar

Metodologia em 8 fases para transformar uma ideia em um plano de implementacao production-ready. O plano passa por design UX/UI e auditoria tecnica multi-skill antes de qualquer codigo ser escrito, eliminando retrabalho e decisoes ruins.

**Ordem de inicio:** rode primeiro o preflight da **Fase 0** (verificacao de pre-requisitos, abaixo). So depois anuncie as fases.

**Anuncie no inicio:** "Estou usando a skill `/planejar` para conduzir o planejamento. Vou guiar voce por ate 8 fases — algumas podem ser puladas dependendo do produto. Vamos comecar pelo brainstorm."

**Antes de comecar:** Pergunte o que o usuario ja tem resolvido. Se ele ja tem stack definida, pule Fase 3. Se nao ha cliente especifico, pule Fase 2. Se nao ha interface, pule Fase 4. Nunca force fases que o usuario ja resolveu — confirme antes de pular.

**Tracking de progresso:** Ao definir quais fases se aplicam, crie uma todo list com uma entrada por fase. Marque cada fase como concluida apenas apos a aprovacao do usuario. Isso evita pular fases ou esquecer onde parou em sessoes longas.

**Arquivo de estado (retomada):** Planejamentos atravessam multiplas sessoes e o contexto pode ser compactado no meio. Para nao perder o fio, mantenha `docs/<nome-produto>-planejamento-status.md` e atualize ao FIM de cada fase com:
- Fase concluida e data
- Decisoes tomadas (escopo, stack, direcao visual)
- Paths dos artefatos produzidos ate aqui
- Proxima fase e o que falta nela

Ao ser invocada, esta skill deve PRIMEIRO verificar se esse arquivo existe no projeto. Se existir, ler, resumir o estado pro usuario e retomar da fase pendente — nao recomecar do zero. **Retomar = apresentar o estado e CONFIRMAR com o usuario antes de executar a fase pendente.** O gate de inicio de fase vale tambem na retomada — nao execute a fase (nem parte dela) so porque o status diz que ela e a proxima; algo pode ter mudado desde a ultima sessao.

## Fase 0 — Verificacao de pre-requisitos (antes de tudo)

Esta skill orquestra outras skills e MCPs. Nenhum deles e validado automaticamente — se faltar, o buraco so aparece no meio da fase. Por isso, ANTES de anunciar as fases, faca um preflight rapido olhando a lista de skills e ferramentas disponiveis no contexto da sessao.

**Como executar o preflight:**

1. Verifique presenca de cada dependencia na lista da sessao (skills disponiveis + MCPs/tools carregados).
2. Classifique em tres baldes e aja conforme o balde:

**Criticas (sem fallback — a metodologia depende delas):**
- `superpowers:brainstorming` (Fase 1)
- `superpowers:writing-plans` (Fase 5)
- `taste-skill` / `design-taste-skill-pack` (Fase 4, so se houver UI)

Se faltar uma critica, NAO siga em silencio. Avise o usuario nominalmente, explique o que se perde (ex: "sem `writing-plans` o plano sai sem o formato auditavel") e ofereça: (a) instalar agora — invoque `find-skills` pra localizar e proponha instalacao, nunca instale sem aprovacao; ou (b) seguir em modo degradado, com a fase improvisada. Espere a escolha do usuario.

**Com fallback (degradam sozinhas — so informe):**
- `firecrawl_scrape` → `curl r.jina.ai` → `WebFetch`
- Nano Banana (`GEMINI_API_KEY`) + Stitch MCP → uma sozinha → HTML estatico via taste-skill → pular mockup
- `context7` → confiar em memoria/Exa (pior, mas roda)
- skill `/pesquisa` + Exa (descoberta de prior art, Fase 1) → varredura leve (`web_search_exa` / `WebSearch`) → pular a descoberta
- Skills de auditoria por dominio (Fase 6) → `find-skills` → `context7` + boas praticas

Liste o que esta indisponivel e qual fallback sera usado. Nao precisa pedir aprovacao — so transparencia.

**Opcionais (perda silenciosa — mencione se faltar):**
- `exa` (`web_search_exa`/`web_fetch_exa`) → sem pesquisa de mercado/trade-offs com fonte real; cai pra WebSearch/conhecimento proprio
- `find-skills` → dominios sem skill local vao direto pro context7

**Saida do preflight:** uma linha-resumo pro usuario, ex:
> Preflight: criticas OK. Indisponiveis: `firecrawl` (uso jina.ai), `context7` (uso memoria/Exa). Pesquisa de mercado reduzida (sem Exa). Seguimos?

Se tudo critico estiver presente e so faltarem itens com fallback, mencione e prossiga direto pro anuncio das fases. So pare e pergunte quando faltar uma dependencia critica.

---

## Por que esse processo existe

Codigo escrito sem planejamento solido gera retrabalho. Mas um plano escrito sem pesquisa e auditoria tambem gera retrabalho — so que mais tarde, quando custa mais caro corrigir. Esta skill resolve isso: pesquisa antes de planejar, audita antes de executar.

## As 8 Fases

```
Fase 1: Brainstorm ─── explorar o problema, alternativas, escopo
    │ usuario aprova direcao
    ▼
Fase 2: Discovery ──── pesquisar cliente/persona/mercado
    │ usuario confirma entendimento
    ▼
Fase 3: Pesquisa Tecnica ─── stack, trade-offs, dados reais
    │ usuario aprova stack
    ▼
Fase 4: Design ──── estilo (taste-skill), mockups (Nano Banana), design doc
    │ usuario aprova mockup + design doc
    ▼
Fase 5: Escrita do Plano ─── implementacao detalhada com codigo
    │ plano salvo
    ▼
Fase 6: Auditoria ─── skills especializadas contra o plano
    │ relatorio de achados
    ▼
Fase 7: Correcao ─── aplicar achados no plano
    │ plano corrigido
    ▼
Fase 8: Montagem ─── plano final consolidado, pronto pra executar
```

**Regra inviolavel:** human-in-the-loop entre cada fase — nao pular fases sem aprovacao. **Unica excecao:** a transicao 7 → 8 segue direto, sem gate de aprovacao. A Fase 8 e so montagem e faxina do que a Fase 7 ja produziu (consolidar, limpar, conferir consistencia) — nao introduz decisao nova, entao nao precisa de aprovacao propria. Todas as outras transicoes exigem o OK do usuario.

---

## Scraping com fallback

Sempre que precisar raspar uma URL (Fases 2 e 3), usar essa ordem:

1. `firecrawl_scrape(url)` — melhor resultado, lida com JS pesado
2. `Bash: curl -s "https://r.jina.ai/<url>"` — fallback gratuito, markdown limpo, ~10s
3. `WebFetch(url)` — ultimo recurso: resume/parafraseia, nao extrai verbatim
4. Pular URL, anotar como indisponivel

Usar o mesmo fallback tanto no scrape do site do cliente (Fase 2) quanto nos artigos tecnicos (Fase 3).

---

## Fase 1 — Brainstorm

**Objetivo:** Explorar o espaco do problema antes de convergir em solucao.

**Como executar:**

1. Invocar `superpowers:brainstorming` — seguir o fluxo completo da skill
2. Explorar: o que o produto faz, pra quem, qual problema resolve
3. **Descoberta de "como ja resolveram isso" (prior art) — recomendada, pulavel.** Antes de
   convergir no escopo, alargar a visao: ver como o problema ja foi resolvido la fora e trazer
   2-4 caminhos reais; depois apertar pelas 3 travas (o jeito simples SEMPRE na mesa · filtro da
   realidade do usuario · confronto adversarial do Codex) e apresentar comparacao honesta com
   veredito — a pesquisa informa, o usuario decide. Tarefa pequena/obvia: pular (informe e siga).
   Metodo completo (prompt da `/pesquisa`, as 3 travas, fallback sem Exa, onde salvar) em
   `references/descoberta-prior-art.md` — ler antes de rodar.
4. Definir escopo do MVP — o que entra, o que fica pra depois (ja considerando a direcao escolhida no passo 3)
5. Nomear o produto (brainstorm de nomes se necessario)
6. **Salvar o escopo** em `docs/<nome>-escopo.md` (problema, publico, fluxos, MVP vs futuro, nome).
7. **Revisao do problema pelo Codex (uma vez so).** Antes de pedir aprovacao, mandar o escopo pro revisor independente GPT-5.5 (esforco `high`) responder: e esse o problema mesmo? o escopo ataca ele? sugeriria repensar algo antes de investir em pesquisa e plano? Ver `references/codex-revisor.md` (Chamada 1). O Claude filtra o parecer (regra de ouro do arquivo): ponto que procede e e grave vira A/B pro usuario; se o Codex disser SEGUIR, menciona em uma linha e avanca. Codex indisponivel → o proprio Claude faz a revisao critica e informa. **Salvar o veredito** (SEGUIR/REPENSAR + os pontos) em `docs/<nome>-revisao-problema.md`.

**Entrega:** Documento de escopo + parecer do revisor do problema.

**Nao avance sem:** Usuario confirmar escopo e nome (ja considerando o parecer do Codex).

---

## Fase 2 — Discovery

**Objetivo:** Entender profundamente o cliente/persona e o contexto de negocio.

**Quando pular:** Se o produto nao tem um cliente especifico (projeto pessoal, SaaS generico), pule direto pra Fase 3. Informe o usuario antes de pular.

**Ferramentas:**
- `firecrawl_scrape` (ou fallback jina.ai) — site do cliente/empresa
- `web_search_exa` (ou `web_search_advanced_exa`, se existir) — presenca online geral (query semântica). No conector avancado da pra filtrar fonte oficial com `includeDomains`; passe `textMaxCharacters` (1500) pra nao estourar o limite de tokens
- Apify — redes sociais específicas (Instagram, TikTok, LinkedIn) quando precisar do perfil/posts
- Leitura de documentos existentes no projeto

**Como executar:**

1. **Scrape do site** do cliente/empresa (se existir), usando a ordem de fallback acima:
   - Identidade visual (cores, fontes, tom)
   - Servicos/produtos oferecidos
   - Posicionamento e linguagem

2. **Pesquisa de redes sociais** (Instagram, LinkedIn, YouTube):
   - Tipo de conteudo publicado
   - Publico-alvo visivel
   - Tom e estilo de comunicacao

3. **Consolidar em documento de referencia:**
   - Salvar como `docs/<nome>-perfil.md`
   - Incluir: quem e, formacao, servicos, numeros, identidade visual, contexto pro produto

**Entrega:** Documento de perfil que qualquer pessoa consiga ler e entender o cliente.

**Nao avance sem:** Usuario confirmar que o perfil esta correto.

---

## Fase 3 — Pesquisa Tecnica

**Objetivo:** Tomar decisoes de stack baseadas em dados, nao achismo.

**Quando pular:** Se o usuario ja definiu a stack completa e nao quer revisar, pule esta fase. Confirme antes.

**Ferramentas:**
- `web_search_exa` (ou `web_search_advanced_exa`, se existir) — varredura rapida de alternativas (busca; a comparacao/trade-off e minha, lendo as fontes com `web_fetch_exa`). No avancado, `includeDomains` so pra fonte oficial/primaria; descrever a fonte na query cobre o resto. Passe `textMaxCharacters` (1500)
- `context7` (resolve-library-id + query-docs) — documentacao oficial atualizada
- `firecrawl_scrape` (ou fallback jina.ai) — artigos tecnicos, benchmarks, issues (ver "Scraping com fallback" acima)
- **Skills locais de plataforma** — quando uma candidata da comparacao tem skill instalada, consulte a skill ANTES da pesquisa web: ela e curada e mais confiavel que resultado de busca. Exemplos: `cloudflare` + plugins (`cloudflare:workers-best-practices`, `cloudflare:durable-objects`, `cloudflare:agents-sdk`) pra Workers/D1/R2/KV/Pages; `supabase` e `supabase-best-practices`; `vercel:nextjs` e afins. **Produto com feature de IA/LLM:** consultar `claude-api` e `gemini-api-dev` pra escolha de provider/modelo — modelos atuais, pricing, limites e capacidades mudam rapido demais pra confiar em memoria ou busca web. IMPORTANTE: a skill alimenta a avaliacao da candidata, nao decide por ela — a comparacao continua neutra, com 2-3 alternativas reais por componente.

**Como executar:**

1. **Listar componentes do sistema** (frontend, backend, banco de dados, infra, etc.)
2. **Para cada componente, pesquisar:**
   - 2-3 alternativas viaveis
   - Trade-offs reais (performance, experiencia de desenvolvimento, maturidade, ecossistema)
   - Issues conhecidas, breaking changes recentes
   - Documentacao oficial para confirmar patterns atuais
3. **Montar tabela de decisao:**

```markdown
| Camada | Escolha | Alternativas | Razao |
|--------|---------|--------------|-------|
| Frontend | Next.js 16 | Remix, Astro | App Router maduro, Vercel deploy |
| DB | Supabase | Firebase, PlanetScale | Auth + Storage + Realtime integrado |
```

4. **Validar patterns com context7** — nao confiar em memoria, buscar docs atuais
5. **Documentar decisoes que impactam a arquitetura** (ex: WXT vs CRXJS, qual biblioteca de animacao)

**Entrega:** Stack definida com justificativa baseada em pesquisa.

**Nao avance sem:** Usuario aprovar stack.

---

## Fase 4 — Design

**Objetivo:** Definir a experiencia do usuario e o sistema visual antes de escrever codigo.

**Quando pular:** CLIs, APIs sem interface, scripts de automacao — qualquer produto sem UI visual. Informe o usuario antes de pular.

Construir sem design e como construir uma casa sem planta — funciona, mas voce vai derrubar paredes depois. Esta fase garante que a interface seja pensada como produto, nao como "coisa que o dev fez".

**IMPORTANTE — esta fase NAO escreve codigo.** A skill de estilo abaixo e uma skill de construcao frontend; aqui ela e usada apenas para ESCOLHER a direcao visual e EXTRAIR o sistema de design. Nenhuma pagina e construida na Fase 4 — codigo so existe dentro do plano (Fase 5) e na execucao (pos-skill).

**Como executar:**

### 4.1 — Escolha de estilo

1. Invocar a skill `taste-skill` (Taste Skill Pack, name interno `design-taste-frontend`) e usar o ROUTER dela para escolher 1 dos 14 estilos (minimalism, editorial-premium, dark-luxe, swiss-system, etc.).
2. Inputs da decisao: perfil do cliente da Fase 2 (marca, tom, publico) + tipo de produto + stack da Fase 3.
3. Ler o `skill.md` do estilo escolhido + a secao correspondente em `components/style-recipes.md` — isso alimenta os passos seguintes.
4. **Se o cliente tem marca existente** (identidade visual capturada na Fase 2): o estilo escolhido deve acomodar as cores, fontes e tom da marca. Adaptar, nao reinventar.

### 4.2 — Mockups: Nano Banana Pro + Stitch (complementares)

Aprovar direcao visual olhando uma imagem e mais barato que aprovar lendo um documento de tokens. Gere mockups ANTES de detalhar o design doc — se o usuario rejeitar o visual, voce nao perdeu tempo especificando tokens de uma direcao morta.

Duas ferramentas, dois eixos — usar AMBAS quando disponiveis, nao escolher uma:

- **Nano Banana Pro** (`gemini-3-pro-image-preview`) → **direcao visual/mood**: paleta, atmosfera, materialidade, energia da marca
- **Google Stitch MCP** (tools `mcp__stitch__*`) → **telas UI estruturadas**: layout real, componentes, hierarquia — funciona pra web app E mobile/iOS

O usuario escolhe entre alternativas nos dois eixos e pode MISTURAR (ex: layout do Stitch + mood do Nano Banana). Essa combinacao vira a referencia aprovada.

1. **Pre-requisitos:**
   - Nano Banana: `GEMINI_API_KEY`. Se nao houver, PEDIR ao usuario ("Preciso de uma GEMINI_API_KEY pra gerar os mockups visuais — voce tem uma? Da pra criar gratis em https://aistudio.google.com/apikey").
   - Stitch: MCP conectado (tools `mcp__stitch__*` visiveis).
   - Tem so uma das duas → seguir so com ela. Nenhuma → fallback: mockup HTML estatico construido com a taste-skill (descartavel) + screenshot. Nem isso → pular pro 4.3.
2. **Nano Banana — 2-3 conceitos de mood** da(s) tela(s)-chave. Invocar a skill `gemini-api-dev` para os detalhes de API (nao duplicar codigo aqui; nao usar modelos `gemini-2.0-*`/`gemini-1.5-*`, deprecados). O prompt de imagem descreve: estilo do 4.1 (paleta, tipografia, densidade, mood), conteudo real da tela (escopo da Fase 1) e formato ("high-fidelity UI mockup, desktop 16:10" pra web; "iOS app screen, mobile 9:19.5" pra app iOS).
3. **Stitch — 2-3 alternativas de tela estruturada**: `generate_screen_from_text` pra tela principal + `generate_variants` pras alternativas. Informar no prompt a plataforma (web ou mobile/iOS) e o estilo do 4.1. Se o produto tem web E iOS, gerar pros dois form factors.
4. **Apresentar tudo lado a lado, colher escolha** — qual direcao de mood, qual estrutura de tela, ou a mistura dos dois. No maximo 1 rodada de iteracao sobre o escolhido — mockup e ferramenta de alinhamento, nao produto final.
5. **Salvar mockups** em `docs/mockups/<nome-produto>-<tela>-<ferramenta>-v<N>.png` e registrar a combinacao aprovada.

**Limite do mockup:** mockup gera direcao, nao spec. Nenhuma das imagens respeita tokens pixel-perfect — o design doc do 4.3 e a fonte da verdade pra implementacao; a combinacao aprovada e referencia de mood e layout.

### 4.3 — Design doc

1. Com estilo escolhido + mockup aprovado, consolidar o documento de design:
   - Salvar como `docs/<nome-produto>-design.md`
   - Incluir: brief de design, estilo escolhido (e por que), variaveis CSS/tokens (derivados do style skill + recipes), inventario de componentes, regras responsivas, link pros mockups aprovados

**Entrega:** Mockup(s) aprovado(s) + documento de design com especificacoes visuais e lista de componentes.

**Nao avance sem:** Usuario aprovar mockup E design doc.

---

## Fase 5 — Escrita do Plano

**Objetivo:** Plano de implementacao detalhado, com passos pequenos e codigo completo.

**Como executar:**

1. Invocar `superpowers:writing-plans` — seguir o fluxo completo da skill
2. O plano deve incluir:
   - Header com objetivo, arquitetura, stack escolhida
   - Estrutura de arquivos completa (quais arquivos criar/modificar)
   - Tarefas com checkboxes, codigo completo, comandos exatos
   - Testes antes da implementacao de cada modulo
   - Commits frequentes ao longo do desenvolvimento
3. Salvar em `docs/superpowers/plans/YYYY-MM-DD-<nome-produto>.md`

**Formato de referencia:** Ver skill `superpowers:writing-plans` para estrutura exata.

**Entrega:** Plano salvo no filesystem.

**Nao avance sem:** Plano escrito e salvo.

---

## Fase 6 — Auditoria

**Objetivo:** Encontrar bugs, vulnerabilidades, e problemas de arquitetura ANTES de implementar.

Esta e a fase que diferencia esta metodologia de "so escrever um plano". O plano passa por review de skills especializadas como se fosse codigo real.

**Como executar:**

1. **Identificar dominios relevantes** baseado na stack escolhida na Fase 3 (ex: Next.js, Supabase, Tailwind, extensao Chrome).
2. **Selecionar skills de auditoria** olhando a lista de skills disponiveis no contexto da sessao e filtrando por dominio. Use `references/audit-skills.md` como exemplo de mapeamento, mas a fonte da verdade e a lista da sessao — skills novas instaladas depois da tabela tambem contam. Inclua sempre que aplicavel: seguranca (`security-review` se disponivel), testes e performance.
3. **Dominio sem skill local? Buscar com `find-skills`.** Se algum dominio da stack nao tem skill de auditoria instalada (ex: SwiftUI, Vue, Django), invocar a skill `find-skills` para procurar uma skill de boas praticas daquela tecnologia. Encontrou algo bom → propor instalacao ao usuario (nunca instalar sem aprovacao) e usar na auditoria. Nao encontrou (ou usuario recusou) → NAO pular o dominio: o subagent daquele dominio audita usando docs oficiais via `context7` + boas praticas gerais, e o relatorio marca o dominio como "auditado sem skill especializada".
4. **Despachar UM SUBAGENT POR DOMINIO, em paralelo** (Agent tool, todos no mesmo turno) E, na MESMA leva, **disparar o revisor de SANIDADE do plano (Codex GPT-5.5, esforco `xhigh`)** — ver `references/codex-revisor.md` (Chamada 2). As duas coisas rodam juntas: os subagents olham a tecnica de cada dominio; o Codex olha uma coisa que subagent de dominio nao olha — *o plano resolve o problema declarado? tem caminho muito mais simples? tem peso morto?*. Nao invocar as skills de auditoria inline no contexto principal — cada skill tecnica tem centenas de linhas e 4-6 delas juntas estouram o contexto. O subagent carrega a skill no contexto DELE e devolve so os achados.

   **Roteamento do parecer de sanidade (regra de ouro do `codex-revisor.md`):** o Claude filtra cada ponto do Codex e DOCUMENTA todos — aceito ou refutado — na tabela de veredito (ver `references/codex-revisor.md`, "Registro obrigatorio"). Refutar exige prova concreta (`arquivo:linha` ou secao que ja cobre o ponto); sem prova, nao descarta. Ponto que procede e e grave (`NAO RESOLVE` o problema, ou caminho substancialmente mais simples) e decisao de produto: **PARA antes da Fase 7 e sobe pro usuario em A/B**, nunca decide sozinho. Pontos menores que procedem entram no relatorio como achados normais.

   Prompt de cada subagent:

   ```
   Voce e um auditor tecnico. Tarefa:
   1. Invoque a skill `<nome-da-skill>` e absorva as boas praticas dela.
   2. Leia o plano de implementacao em `<path-do-plano>`.
   3. Audite APENAS o dominio <dominio> do plano, perguntando:
      - O codigo proposto segue as boas praticas dessa tecnologia?
      - Tem vulnerabilidades de seguranca?
      - Tem problemas de performance?
      - Faltam patterns recomendados?
   4. Retorne os achados em markdown, cada um com:
      - Prioridade (P0 bugs/seguranca, P1 performance/arquitetura, P2 UX/boas praticas, P3 opcional)
      - Secao do plano afetada (titulo + trecho)
      - O que esta errado e como corrigir (com codigo quando aplicavel)
   Nao retorne elogios nem resumo do plano — so achados acionaveis.
   ```

5. **Consolidar achados em relatorio** com prioridades:
   - **P0**: Bugs e seguranca — corrigir antes do MVP
   - **P1**: Performance e arquitetura — corrigir durante MVP
   - **P2**: UX e boas praticas — corrigir pos-MVP
   - **P3**: Melhorias opcionais

   Deduplicar achados que dois auditores reportaram (ex: seguranca e backend apontando o mesmo endpoint).
6. **Salvar relatorio** em `docs/<nome-produto>-audit.md`. **Salvar tambem o parecer de sanidade do Codex** (veredito RESOLVE/NAO RESOLVE + a tabela de veredito) em `docs/<nome-produto>-revisao-sanidade.md`.

**Entrega:** Relatorio de auditoria com achados priorizados.

**Nao avance sem:** Relatorio completo.

---

## Fase 7 — Correcao

**Objetivo:** Aplicar todos os achados da auditoria de volta no plano.

**Como executar:**

1. **Agrupar achados por secao do plano** (backend, frontend, banco de dados, extensao, etc.)
2. **Aplicar por reescrita de secao, nao find-and-replace pontual.** Em planos longos, busca-e-troca de trechos pequenos erra match e deixa correcao pela metade. Para cada secao com achados:
   - Ler a secao inteira do plano
   - Reescrever a secao ja incorporando todos os achados dela (codigo corrigido completo)
   - Substituir o bloco inteiro no arquivo
3. **Se o plano for muito grande (2000+ linhas):** delegar cada secao a um subagent ("leia a secao X do plano + estes achados, devolva a secao reescrita") e aplicar os retornos um a um.
4. **Checklist final:** percorrer o relatorio de auditoria e confirmar que cada achado P0/P1 tem correcao correspondente no plano. Nenhum pode ficar sem resposta — se algum achado for descartado de proposito, registrar o motivo no relatorio.

**Entrega:** Plano corrigido com todos os achados P0 e P1 resolvidos.

---

## Fase 8 — Montagem

**Objetivo:** Plano final consolidado, limpo, pronto para execucao.

**Como executar:**

1. **Verificar consistencia** — nomes, paths, imports, referencias cruzadas
2. **Remover artefatos de correcao** — comentarios temporarios, marcacoes de diff
3. **Validar que o plano e auto-contido** — alguem (ou um agente) consegue executar so lendo o plano
4. **Limpar arquivos temporarios** (fix files, rascunhos)
5. **Apresentar resumo ao usuario:**

```markdown
## Resumo do Planejamento

**Produto:** [nome]
**Plano:** `docs/superpowers/plans/YYYY-MM-DD-<nome>.md`
**Auditoria:** `docs/<nome>-audit.md`

### Numeros
- [N] tarefas de implementacao
- [N] achados de auditoria ([N] P0, [N] P1, [N] P2, [N] P3)
- Todos P0/P1 corrigidos no plano

### Proximo passo
Quando quiser executar, use `superpowers:subagent-driven-development`
apontando para o plano.
```

**Entrega:** Plano final + resumo.

**Nao executar codigo sem aprovacao explicita do usuario.**

---

## Ponte com a auto-gptworker (executar o plano) — OPCIONAL, nunca automatico

A `auto-gptworker` e a skill irma deste plugin (`Titan`): o modo "largar e esquecer" invertido
em que o Claude planeja/orquestra/revisa e o **Codex constrói** (mão na massa), so chamando o
usuário nas decisoes reais e na borda sensivel. Quando o plano final estiver pronto e aprovado,
OFERECA executar com ela — mas so OFERECA, nunca dispare sozinho:

> "Plano pronto. Quer que eu execute com a auto-gptworker? O Codex constroi, eu reviso o diff
> inteiro antes de fechar, e so te chamo nas decisoes que importam. Ou prefere executar de
> outro jeito?"

Se o usuário aceitar, **salve um CONTRATO DE EXECUCAO em arquivo** (`docs/<nome>-execution-contract.md`)
— NUNCA passe o plano solto na conversa (ela perde premissa no caminho). O arquivo tem schema
fixo e a auto-gptworker e chamada apontando pra ele. Isso impede a auto-gptworker de replanejar
do zero ou perder as travas que voce ja definiu (a estrategia e desta skill; a execucao segura e
dela). Campos obrigatorios do contrato:

- **Objetivo** — o problema que o plano resolve
- **Fora de escopo** — o que NAO fazer
- **Criterios de sucesso** — como saber que ficou pronto
- **Decisoes ja tomadas** — premissas que a auto-gptworker NAO reabre
- **Decisoes proibidas ao executor** — o que ela tem que subir pro usuário
- **Pontos de parada** — onde ela para e pergunta
- **Permissoes concedidas** — o que o Codex pode construir sozinho, sem passar pela borda do Claude

Chamada explicita (aponta pro arquivo, ordem clara): `/auto-gptworker executar docs/<nome>-execution-contract.md (sem replanejar)`.

A auto-gptworker recebe isso como "plano vindo da planejar": ela EXECUTA (Codex constroi, Claude
revisa o diff), valida se esta executavel, aponta lacuna e pede autorizacao pra mudar premissa —
mas NAO replaneja.

**Ordem de execucao (resolve o caminho duplo):** o caminho PRIMARIO e a `auto-gptworker` (skill
irma deste plugin). `superpowers:subagent-driven-development` (citado no "Proximo passo" acima)
e FALLBACK — so quando o usuário recusa a auto-gptworker ou ela nao esta disponivel.

---

## Documentos Produzidos

Ao final das 8 fases, o projeto tera:

| Documento | Path | Conteudo |
|-----------|------|----------|
| Status do planejamento | `docs/<nome>-planejamento-status.md` | Fases concluidas, decisoes, paths — usado pra retomar |
| Escopo (Fase 1) | `docs/<nome>-escopo.md` | Problema, publico, fluxos, MVP vs futuro, nome — lido pelo revisor do problema |
| Prior art (Fase 1) | `docs/<nome>-prior-art.md` | Como o problema ja foi resolvido la fora — caminhos, fontes, veredito, direcao escolhida (se a descoberta rodou) |
| Parecer do problema | `docs/<nome>-revisao-problema.md` | Veredito SEGUIR/REPENSAR do Codex (Fase 1) |
| Perfil do cliente | `docs/<nome>-perfil.md` | Persona, marca, contexto |
| Mockups | `docs/mockups/<nome>-<tela>-v<N>.png` | Conceitos visuais gerados (Nano Banana Pro), aprovado marcado |
| Design system | `docs/<nome>-design.md` | Estilo escolhido, tokens, componentes, regras responsivas |
| Plano de implementacao | `docs/superpowers/plans/YYYY-MM-DD-<nome>.md` | Tarefas com codigo completo |
| Relatorio de auditoria | `docs/<nome>-audit.md` | Achados priorizados (tecnicos + sanidade) |
| Parecer de sanidade | `docs/<nome>-revisao-sanidade.md` | Veredito RESOLVE/NAO RESOLVE do Codex (Fase 6) |

---

## Atalhos

Nem todo produto precisa das 8 fases completas. Sempre confirme com o usuario antes de pular uma fase.

| Cenario | Fases |
|---------|-------|
| Produto com cliente + UI | Todas as 8 |
| Projeto pessoal / tech com UI | Pular Fase 2 → 1 → 3 → 4 → 5 → 6 → 7 → 8 |
| CLI / API / sem interface | Pular Fases 2 e 4 → 1 → 3 → 5 → 6 → 7 → 8 |
| Prototipo rapido | Fases 1 → 3 → 4 → 5 (sem auditoria) |
| Refactoring de produto existente | Fases 3 → 5 → 6 → 7 → 8 |
| Usuario ja tem stack definida | Pular Fase 3 — perguntar antes |

---

## Integracao com Outras Skills

Esta skill orquestra outras skills. Ela nao substitui nenhuma — ela define QUANDO e POR QUE usar cada uma.

| Fase | Skills / ferramentas invocadas |
|------|-------------------------------|
| 1. Brainstorm | `superpowers:brainstorming`, **descoberta de prior art via `/pesquisa`** (`references/descoberta-prior-art.md`, recomendada/pulavel), revisor do problema via Codex GPT-5.5 `high` (`references/codex-revisor.md`, uma vez) |
| 2. Discovery | `firecrawl_scrape` (ou fallback jina.ai), `web_search_exa` (presenca online), Apify (redes sociais) |
| 3. Pesquisa Tecnica | `web_search_exa` + `web_fetch_exa` (busca; comparativo/trade-off e meu), `context7`, `firecrawl_scrape` (ou fallback jina.ai), skills locais de plataforma (`cloudflare`+plugins, `supabase`, `vercel:*`), skills de API de IA (`claude-api`, `gemini-api-dev`) |
| 4. Design | `taste-skill` (router de estilo); mockups complementares: Nano Banana Pro via `gemini-api-dev` (mood) + Stitch MCP (telas estruturadas, web e iOS) |
| 5. Escrita | `superpowers:writing-plans` |
| 6. Auditoria | Skills especializadas por dominio (ver `references/audit-skills.md`) — um subagent por dominio, em paralelo; `find-skills` pra dominios sem skill local, `context7` como fallback; + revisor de sanidade do plano via Codex GPT-5.5 `xhigh` (`references/codex-revisor.md`) |
| 7. Correcao | — (aplica achados da fase 6) |
| 8. Montagem | — |

**Execução do plano** (pós-skill): `superpowers:subagent-driven-development` ou `superpowers:executing-plans`
