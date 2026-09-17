---
name: planejar
description: >
  Planeja produtos digitais antes de qualquer código: brainstorm → spec verificável (EARS) →
  stack → design → plano auditado. Use quando o usuário quiser planejar um novo produto ou
  projeto (web app, mobile, extensão, SaaS, API), tiver uma ideia pra transformar em produto,
  ou pedir spec, PRD, MVP ou plano antes de codar. Entrega o PLANO; o código vem depois.
---

# Planejar

Metodologia em 9 fases para transformar uma ideia em um plano de implementacao production-ready. A ideia vira requisitos verificaveis e uma constituicao de projeto antes de qualquer decisao tecnica; o plano passa por design UX/UI e auditoria adversarial multi-skill antes de qualquer codigo ser escrito, eliminando retrabalho e decisoes ruins.

**Ordem de inicio:** rode primeiro o preflight da **Fase 0** (verificacao de pre-requisitos, abaixo). So depois anuncie as fases.

**Anuncie no inicio:** "Estou usando a skill `/planejar` para conduzir o planejamento. Vou guiar voce por ate 9 fases — algumas podem ser puladas dependendo do produto. Vamos comecar pelo brainstorm."

**Antes de comecar:** Pergunte o que o usuario ja tem resolvido. Se ele ja tem stack definida, pule Fase 4. Se nao ha cliente especifico, pule so o bloco 2B (cliente) — o 2A (benchmark de mercado) roda sempre. Se nao ha interface, pule Fase 5. Produto trivial? Considere a rota expressa (ver Atalhos). Nunca force fases que o usuario ja resolveu — confirme antes de pular.

**Tracking de progresso:** Ao definir quais fases se aplicam, crie uma todo list com uma entrada por fase e **EXIBA-A ao usuario ja na primeira resposta** (renderizada em texto, uma linha por fase) — nao basta prometer "vou montar a todo list"; ela e o mapa que o usuario usa pra saber onde esta, entao aparece de fato, nao como intencao. Marque cada fase como concluida apenas apos a aprovacao do usuario. Isso evita pular fases ou esquecer onde parou em sessoes longas.

**Arquivo de estado (retomada):** Planejamentos atravessam multiplas sessoes e o contexto pode ser compactado no meio. Para nao perder o fio, mantenha `docs/<nome-produto>-planejamento-status.md` e atualize ao FIM de cada fase com:
- Fase concluida e data
- Decisoes tomadas (escopo, stack, direcao visual)
- Paths dos artefatos produzidos ate aqui
- Proxima fase e o que falta nela

Ao ser invocada, esta skill deve PRIMEIRO verificar se esse arquivo existe no projeto. Se existir, ler, resumir o estado pro usuario e retomar da fase pendente — nao recomecar do zero. **Retomar = apresentar o estado e CONFIRMAR com o usuario antes de executar a fase pendente.** O gate de inicio de fase vale tambem na retomada — nao execute a fase (nem parte dela) so porque o status diz que ela e a proxima; algo pode ter mudado desde a ultima sessao.

**Converge (retomada com codigo existente):** se o repo ja tem codigo de produto (nao so os docs do planejamento), antes de retomar compare os artefatos (spec, plano) com o codigo real: o que o plano previa ja foi feito? Alguma premissa morreu? Anote as divergencias no status e apresente junto com o resumo — nao planeje por cima de premissa morta.

## Fase 0 — Verificacao de pre-requisitos (antes de tudo)

Esta skill orquestra outras skills, CLIs e MCPs. Nenhum deles e validado automaticamente — se faltar, o buraco so aparece no meio da fase, quando ja custa caro. Por isso a Fase 0 resolve o SETUP INTEIRO de uma vez, ANTES de anunciar as fases: monte o checklist completo, mostre pro usuario tudo que falta e ofereça instalar em bloco. Nao mergulhe nas fases pra descobrir dependencia faltando la na frente.

**Como executar:**

1. Leia `references/preflight.md` — lista completa de dependencias (criticas / recomendadas / opcionais), instrucoes de instalacao e o modelo de saida.
2. Verifique presenca de cada dependencia na lista da sessao (skills disponiveis + MCPs/tools carregados + CLIs via `which`).
3. Determine o **perfil do produto** o quanto der (tem UI? tem backend/infra? tem IA/LLM?) — itens marcados "so se UI" so contam se houver interface. Na duvida, considere que conta.
4. Monte o **checklist de setup**: ✅ presente / ❌ faltando, por balde.
5. **Se faltar QUALQUER coisa (critica OU recomendada relevante pro produto): PARE e apresente o checklist completo com uma unica oferta de instalar tudo que falta de uma vez.** Essa mesma resposta ja traz o mapa: exiba a todo list das fases aplicaveis junto com o checklist — o gate segura a EXECUCAO das fases, nao a visao do caminho (e o "Tracking de progresso" acima vale desde a primeira resposta). Nao siga degradando peca por peca. Espere a decisao do usuario. So os "opcionais" podem passar sem oferta (mencione e siga). Nunca instale nada sem aprovacao explicita.

Se **tudo** estiver presente, uma linha ("Preflight OK, tudo instalado — comecando pelo brainstorm") e siga direto.

---

## As 9 Fases

```
Fase 1: Brainstorm ─── explorar o problema, alternativas, escopo
    │ usuario aprova direcao
    ▼
Fase 2: Discovery ──── 2A benchmark de mercado (sempre) + 2B cliente/persona (se houver)
    │ usuario confirma entendimento
    ▼
Fase 3: Especificacao ─── requisitos verificaveis (EARS) + constituicao do projeto
    │ usuario aprova spec + constituicao
    ▼
Fase 4: Pesquisa Tecnica ─── stack, trade-offs, dados reais
    │ usuario aprova stack
    ▼
Fase 5: Design ──── usuario escolhe UM caminho (design-lab | design-taste-frontend) → direcao + telas, design doc
    │ usuario escolhe o caminho + aprova mockup + design doc
    ▼
Fase 6: Escrita do Plano ─── implementacao detalhada com codigo, rastreada aos requisitos
    │ plano salvo
    ▼
Fase 7: Auditoria ─── analyze cross-artefato + skills especializadas + red-team + verificacao de achados
    │ relatorio de achados confirmados
    ▼
Fase 8: Correcao ─── aplicar achados no plano
    │ plano corrigido
    ▼
Fase 9: Montagem ─── plano final consolidado + feature list de aceitacao
```

**Regra inviolavel:** human-in-the-loop entre cada fase. Nao pular fases sem aprovacao.

**Protocolo de gate (entrega visivel):** texto que antecede uma tool call pode NAO ser exibido no terminal do usuario — e AskUserQuestion e uma tool call. Em TODO gate: (1) entregue o conteudo da fase (resumo, explicacao, opcoes) como mensagem final de texto, SEM tool call depois; (2) a pergunta do gate vem no turno seguinte via AskUserQuestion, ou em texto puro na propria mensagem final; (3) se usar AskUserQuestion, as descricoes das opcoes devem ser autossuficientes — nunca referenciar "o texto acima", que o usuario pode nao ter visto. (Licao de 2026-07-28: dois gates seguidos ficaram invisiveis por texto + AskUserQuestion no mesmo turno.)

---

## Pesquisa profunda

Toda pesquisa das Fases 1-4 (alternativas de mercado, presenca online do cliente, comparativos tecnicos, validacao de trade-offs) e feita com a **skill `search`** (Exa Research Orchestrator): varredura multi-angulo com dedup/rank, fan-out de subagents haiku. Exige Exa (OAuth mcp.exa.ai ou `EXA_API_KEY`); sem Exa, rode as mesmas perguntas com `WebSearch`+`WebFetch` nativos. Achado que vai sustentar decisao por escrito (stack, fornecedor, arquitetura) entra no artefato da fase com a fonte citada.

**Quando NAO usar:** extrair conteudo de UMA URL ja conhecida (site do cliente, um artigo especifico) — isso e scraping, use a ordem abaixo. Pesquisa e pra investigar/enumerar um tema, nao pra raspar uma pagina.

## Scraping com fallback

Sempre que precisar raspar uma URL conhecida (Fases 2 e 4), usar essa ordem:

1. **Skill `firecrawl`** (comando `scrape` da CLI Firecrawl, `Bash(firecrawl scrape <url>)`) — melhor resultado, lida com JS pesado. Precisa de CLI autenticada (`firecrawl --status` confirma — credential store ou `FIRECRAWL_API_KEY`). Delegue pra skill, nao chame tool MCP crua (o connector claude.ai nao expoe tool no terminal).
2. `Bash: curl -s "https://r.jina.ai/<url>"` — fallback gratuito, markdown limpo, ~10s
3. `WebFetch(url)` — ultimo recurso: resume/parafraseia, nao extrai verbatim
4. Pular URL, anotar como indisponivel

Usar o mesmo fallback tanto no scrape do site do cliente (Fase 2) quanto nos artigos tecnicos (Fase 4).

---

## Fase 1 — Brainstorm

**Objetivo:** Explorar o espaco do problema antes de convergir em solucao.

**Como executar:**

1. Invocar `superpowers:brainstorming` — seguir o fluxo completo da skill
2. **Usar o visual companion (nativo da brainstorming) quando a pergunta pedir:** se uma pergunta do brainstorm fica mais clara MOSTRADA do que descrita (fluxo de telas, comparacao de estruturas, navegacao), a propria skill tem um companion de navegador com mockups clicaveis — oferta just-in-time, como ela manda. **Limite de fase:** o que sai dali e wireframe de ALINHAMENTO DE ESCOPO (estrutura e fluxo), nunca direcao estetica — estilo, tokens e telas finais nascem na Fase 5, e o mockup da Fase 1 entra la como insumo de contexto, nao como decisao de design (a regra "nao empilhe caminhos" do 5.1 continua valendo).
3. Explorar: o que o produto faz, pra quem, qual problema resolve
4. **Se o produto tem login, classificar o modelo de uso** (pergunta obrigatoria): uso proprio · time interno/poucos · muitos usuarios publicos · **multi-tenant** (varios clientes, cada um com ambiente privado — multiusuario ≠ multi-tenant). Muda schema, auth e custo; errar aqui nao se corrige depois. Criterios e consequencias: `references/auth-multitenancy.md`.
5. Mapear alternativas existentes no mercado — skill `search` (ver "Pesquisa profunda" acima)
6. Definir escopo do MVP — o que entra, o que fica pra depois
7. Nomear o produto (brainstorm de nomes se necessario)
8. Anotar as perguntas/respostas importantes do dialogo — elas viram a secao "Clarifications" da spec na Fase 3; estruturas escolhidas no companion viram as telas-chave do documento de escopo

**Entrega:** Documento de escopo com:
- Problema e publico
- Fluxos principais (quem faz o que)
- MVP vs futuro
- Nome do produto

**Nao avance sem:** Usuario confirmar escopo e nome.

---

## Fase 2 — Discovery

**Objetivo:** Duas frentes independentes — **(A) Discovery de produto/mercado:** como o mundo ja resolve esse problema, pra roubar as melhores ideias antes de desenhar as suas. **(B) Discovery de cliente:** entender a fundo o cliente/persona, quando existe um.

**Quando pular:** **A fase NUNCA e pulada inteira.** O bloco **A (produto/mercado) roda SEMPRE** — inclusive (e principalmente) em projeto pessoal/tech, que e onde mais se ganha olhando o estado da arte la fora. So o bloco **B (cliente)** e pulado quando nao ha cliente externo (projeto pessoal, SaaS generico) — informe o usuario antes de pular so o B.

### 2A — Discovery de produto/mercado (sempre)

Vai alem da lista rasa de concorrentes da Fase 1: aqui e o mergulho pra **puxar ideias**. A busca e feita com a skill `search` (ver "Pesquisa profunda"), em **tiers com ordem obrigatoria**:

- **Tier 1 — idioma/localidade do mercado-alvo (primeiro, sempre).** E onde estao os concorrentes que disputam o MESMO cliente — os que importam pra preco, expectativa de feature e brecha. Queries na lingua e na giria do nicho ("resumo de grupo", nao so "group summarizer"). O vocabulario que o Tier 1 revela alimenta as queries seguintes.
- **Tier 2 — global/ingles (depois, sempre).** Nao pra achar quem disputa o cliente, mas pra roubar estado da arte: padroes de UX, features que ainda nao chegaram ao mercado local, erros ja cometidos la fora.
- **Tier 3 — mercados analogos (condicional).** So quando 1 e 2 voltarem magros: nichos onde outro pais e o epicentro (WhatsApp → Brasil/India/Indonesia; pagamento instantaneo → Brasil/India).

**Cada tier e multi-modal:** web + lojas de app (Play/App Store da regiao) + YouTube/Instagram/TikTok + diretorios (Product Hunt etc.) + reviews/reclamacoes (Reclame Aqui quando aplicavel). Concorrente de nicho popular raramente aparece em busca web tradicional — ele anuncia em rede social e vive na loja de app.

**Guard de vazio — zero externo nunca e resultado.** Menos de 3 concorrentes diretos REAIS e VERIFICADOS no Tier 1 apos a filtragem = falha de busca, nao conclusao de mercado. Re-varra o Tier 1 com outra modalidade/queries antes de subir de tier. Subir de tier nao substitui esgotar o anterior. (Licao real: uma execucao filtrou os falsos positivos do subagent — bots inventados, produto descontinuado, frameworks listados como produto — ficou com lista quase vazia e escreveu o benchmark so com material do Tier 2. O produto nasceu sem conhecer um unico concorrente local.)

**Verificacao de existencia E de disputa:** referencia so entra no benchmark como concorrente direto com DUAS evidencias — (a) esta viva (site/loja acessado, nao citacao de subagent) e (b) disputa o MESMO cliente (cite o job-to-be-done e o publico declarados pela propria pagina do concorrente). Referencia que so passa em (a) entra como "adjacente" — e adjacente NAO conta para o minimo de 3 do guard. Subagent de pesquisa alucina produto e lista ferramenta-de-construir como concorrente — confira cada um.

**Esgotamento e mercado raso:** o Tier 1 esta esgotado quando TODAS as modalidades listadas foram varridas com pelo menos 2 formulacoes de query cada. Esgotado com <3 diretos, "mercado raso" e resultado LEGITIMO — vira item explicito do gate, com a evidencia de varredura, para o usuario decidir. O guard combate busca preguicosa, nao proibe a realidade; promover adjacente a direto pra fechar a conta e o mesmo defeito com outra roupa.

**Scrape dos concorrentes (obrigatorio, nao opcional):** para cada concorrente direto verificado do Tier 1 (e os 2-3 melhores do Tier 2), raspe via skill `firecrawl` (fallback na secao "Scraping com fallback") a landing, a pagina de precos e docs/FAQ, e extraia: funcionalidades REAIS (as descritas na doc, nao as prometidas no marketing), modelo de preco, fluxo de onboarding, limites declarados e vocabulario usado com o cliente. O mergulho profundo que o bloco 2B faz no cliente, o 2A faz nos concorrentes.

Do material extraido, tire:
- **Padroes que se repetem** nos melhores (fluxos, telas-chave, onboarding) — feature que 3+ concorrentes tem e convencao: o usuario ja espera
- **Features que valem roubar** (e as que sao ruido — o que cortar)
- **Onde os concorrentes falham** (reviews, reclamacoes, threads) — sua brecha de diferenciacao
- **Termos e mental models** que o publico daquele nicho ja usa

Consolidar em `docs/<nome>-benchmark.md`: 3-6 referencias verificadas com print/link, a tabela "funcionalidade → quem tem → roubar/ignorar/melhorar → por que" (alimentada pelo scrape, nao por impressao), as 2-3 ideias que entram no escopo (Fase 1 pode ser revisitada) e viram requisitos na Fase 3, e a **declaracao de cobertura por tier**: "Tier 1: N varreduras, X concorrentes verificados; Tier 2: ...". A linha "Tier 1: menos de 3 verificados" nao pode passar em silencio — e o guard de vazio nao cumprido.

### 2B — Discovery de cliente (so com cliente externo)

**Ferramentas:** skill `firecrawl` (ou fallback jina.ai) pra scrape do site; skill `search` pra presenca online (Instagram, LinkedIn, YouTube) e fatos de mercado do cliente.

1. **Scrape do site** do cliente/empresa: identidade visual (cores, fontes, tom), servicos, posicionamento e linguagem.
2. **Redes sociais:** tipo de conteudo, publico visivel, tom de comunicacao.
3. **Consolidar** em `docs/<nome>-perfil.md`: quem e, formacao, servicos, numeros, identidade visual, contexto pro produto.

**Entrega:** `docs/<nome>-benchmark.md` (sempre) + `docs/<nome>-perfil.md` (se houve cliente).

**Nao avance sem:** Usuario confirmar o benchmark (e o perfil, se houve).

---

## Fase 3 — Especificacao

**Objetivo:** Transformar o escopo aprovado em requisitos verificaveis e nos principios que governam todas as decisoes seguintes. E a ponte entre "entendemos o problema" e "vamos decidir stack/design/plano" — sem ela, o plano nasce de um documento de escopo solto e nada downstream tem criterio de aceite pra rastrear.

**Como executar** (templates completos em `references/spec-template.md` — leia antes de escrever):

1. **Ler os insumos:** escopo (Fase 1) + perfil (Fase 2, se houve).
2. **Escrever a spec** em `docs/<nome>-spec.md`:
   - Requisitos numerados (`R1`, `R2`...) — user story + criterios de aceite em **notacao EARS** ("QUANDO X, o sistema DEVE Y"). Criterio vago nao entra: reescreva ate ter condicao + comportamento observavel.
   - **Fora de escopo** explicito — evita escopo furtivo no plano.
   - **Clarifications** — as perguntas/respostas do brainstorm. Sobrou lacuna? Pergunte AGORA (poucas perguntas, direcionadas) e registre. Lacuna pequena na spec vira arquitetura errada em dezenas de arquivos no plano.
   - **Premissas e gatilhos de replanejamento** — cada premissa relevante (volume, orcamento, integracao externa) com o gatilho que obriga a revisitar e o que revisitar. Premissa morta e a forma mais cara de um plano quebrar. Produto com login: registre aqui o **modelo de uso** classificado na Fase 1 (e o teto de usuarios, se Access for candidato).
3. **Se multi-tenant:** entra UM principio na constituicao — "tenant resolvido no servidor, todo acesso a dado e arquivo filtrado por tenant, com testes de que tenant A nao acessa tenant B". O desenho concreto e decisao das Fases 4-6 (nivel de isolamento D1 compartilhado vs por tenant e decisao da Fase 4); o red-team da Fase 7 cobra com os vetores de `references/auth-multitenancy.md`.
4. **Escrever a constituicao** em `docs/<nome>-constituicao.md`: principios invioláveis, cada um com o porque e como auditar. Defaults da metodologia (Cloudflare-first com as duas excecoes, testes antes de cada modulo, HITL nos gates) + principios do produto definidos com o usuario (acessibilidade, LGPD, etc.). Excecoes aprovadas ficam documentadas no proprio arquivo — encerram o assunto, nenhuma fase re-litiga.
5. **Numeracao estavel:** as fases seguintes referenciam `R<n>`/`R<n.m>` (tela cobre R2, task implementa R1.1, auditoria rastreia R3). Nunca renumere.

**Regra de mudanca:** requisito que mudar depois desta fase e editado na spec PRIMEIRO, e a mudanca se propaga — nunca so no plano.

**Entrega:** Spec + constituicao.

**Nao avance sem:** Usuario aprovar os dois documentos.

---

## Fase 4 — Pesquisa Tecnica

**Objetivo:** Tomar decisoes de stack baseadas em dados, nao achismo.

**Principio inviolavel — Cloudflare-first pra TUDO.** O default de TODAS as camadas e Cloudflare, sem excecao: frontend (Pages/Workers Assets), backend (Workers), banco (D1), storage (R2), cache/estado (KV, Durable Objects), filas (Queues), cron (Cron Triggers), IA/LLM (Workers AI + AI Gateway), auth, email, realtime, etc. A arquitetura NASCE 100% na Cloudflare. Alternativa externa so entra em cena quando UMA das duas for verdade:
1. **Cobertura:** a Cloudflare genuinamente nao oferece aquela funcionalidade (o produto/recurso nao existe no ecossistema).
2. **Custo:** rodar aquilo na Cloudflare fica caro/inviavel demais pro caso concreto.

So nesses dois casos voce pesquisa 2-3 alternativas externas e justifica a saida por escrito. Fora deles, NAO apresente comparacao neutra — a resposta e Cloudflare. Quando precisar de modelo de LLM que Workers AI nao hospeda, prefira acessa-lo via AI Gateway da Cloudflare (proxy/observabilidade/cache), nao direto.

Este principio esta registrado na **constituicao** (Fase 3) — leia-a antes de comecar; toda saida da Cloudflare vira excecao documentada la, e os auditores da Fase 7 cobram o plano contra ela.

**Excecao de contexto — projeto com stack ja decidida.** Se a stack ja esta fechada e documentada (docs/, `CLAUDE.md` do projeto, constituicao, arquivo de status), NAO re-litigue a forca nem imponha Cloudflare por cima de decisao fechada — respeite o que existe (a Fase 4 pula, o `CLAUDE.md` do projeto prevalece sobre este principio). **Mas SEMPRE de a chance de usar Cloudflare:** ofereca UMA vez, como convite, o equivalente Cloudflare — ex: "esse projeto ja usa React+Supabase; posso desenhar o equivalente 100% Cloudflare (Workers+D1+R2) pra voce comparar custo/simplicidade — quer ver?". Se o usuario recusar, registre a excecao na constituicao e siga com a stack existente sem insistir. Regra de ouro: **sempre oferecer, nunca forcar.**

**Quando pular:** Se o usuario ja definiu a stack completa e nao quer revisar, pule esta fase — mas antes ofereca UMA vez o equivalente Cloudflare como convite (acima). Se recusar, respeite, registre na constituicao e pule. Confirme antes. **Mesmo pulando, execute o passo 7 (cobertura de skills da stack):** a stack existe, e as skills de melhores praticas dela precisam estar instaladas antes da Fase 6. Se a stack existente incluir Cloudflare, execute tambem o passo 4 (auditoria da conta) — stack decidida em papel tambem assume plano/limite.

**Ferramentas:** `cloudflare-atlas` e o ponto de partida obrigatorio — invoque-a antes de sugerir qualquer camada (frontend, backend, banco, storage, IA/LLM, etc.): ela arquiteta o produto 100% na Cloudflare e traz endpoint/param/limite/pricing ATUAIS (nao confie em memoria nem busca web pra isso). Mapa completo de ferramentas e o roteamento de pesquisa por tipo de pergunta: leia `references/fase4-ferramentas.md`.

**Como executar:**

1. **Listar componentes do sistema** (frontend, backend, banco de dados, storage, IA/LLM, infra, etc.) — derive dos requisitos da spec, nao de memoria
2. **Mapear cada componente pro produto Cloudflare correspondente** via `cloudflare-atlas` — esse e o passo default. Para cada componente, so pesquise alternativas externas (2-3, com trade-offs reais, issues, breaking changes, docs oficiais) se ele cair numa das duas excecoes. Registre qual excecao justificou a saida (tabela + constituicao).
   - **Camada de auth: a decisao vem do MODELO DE USO** (classificado na Fase 1, registrado na spec) — nao do reflexo. Time interno pequeno com teto conhecido → Cloudflare Access (Zero Trust, Free ate 50 seats POR CONTA — compartilhados entre todos os apps; depois US$7/usuario/mes em TODOS). Muitos usuarios, multi-tenant ou conta perto do teto → Better Auth no Worker + D1 (sem limite de usuarios; estabelecido mas nao maduro — pin de versao + workarounds documentados; alternativa gerenciada Clerk/Stack Auth pela excecao de custo). Numeros, pegadinhas e criterio completo: `references/auth-multitenancy.md`. Apresente a escolha com o trade-off de custo explicito no gate.
   - **Produto multi-tenant: decidir o NIVEL de isolamento aqui** — D1 compartilhado + tenant_id (ate ~10 tenants, MVP) vs **D1 por tenant** (recomendacao da Cloudflare em escala: 10GB rigidos POR banco, banco compartilhado e single-threaded → noisy neighbor). Bifurcacao com criterios e gatilho de migracao: `references/auth-multitenancy.md`. Nivel escolhido vira premissa na spec. **Atencao ao plano da conta:** os limites do D1 mudam brutalmente entre Free e Paid (Free = 10 bancos de 500MB), e no Free o banco-por-tenant simplesmente nao cabe — cruze com o passo 4 abaixo.
   - **Produto multi-tenant: perguntar tambem se o tenant traz o DOMINIO dele** (`app.cliente.com.br`). Se sim, e **Cloudflare for SaaS** (custom hostnames — fallback origin, CNAME target, certificado por cliente, dois status a monitorar); se o cliente quiser dominio apex, o add-on e Enterprise e pode inviabilizar a conta. Decida aqui, nao na implementacao: `references/auth-multitenancy.md`.
3. **Montar tabela de decisao** — coluna de alternativa/razao so preenchida quando houve saida da Cloudflare:

```markdown
| Camada | Escolha Cloudflare | Saiu? Por que (cobertura/custo) | Alternativa | Plano exigido / status na conta |
|--------|--------------------|--------------------------------|-------------|--------------------------------|
| Frontend | Workers + Assets | — | — | Free ✅ |
| Backend | Workers | — | — | ⚠️ Free = **10ms de CPU/request** (hash de senha ja estoura) — Paid US$5 sobe pra 30s |
| DB | D1 | — | — | Free ✅ pro volume previsto (Free: 10 bancos, 500MB cada) |
| Storage | R2 | — | — | ⚠️ assinatura R2 propria, fora dos US$5 — free tier 10GB-mes |
| Filas | Queues | — | — | Free ✅ (10k operacoes/dia) |
| LLM | Workers AI (via AI Gateway) | Custo: precisa de modelo X nao hospedado | Claude via AI Gateway | pay-per-use alem da cota |
```

4. **Auditar a conta Cloudflare REAL contra a stack proposta.** A tabela de decisao ate aqui foi montada olhando pro catalogo — este passo confere se a CONTA do usuario sustenta cada escolha, antes do gate de aprovacao. Papel nao aceita tudo; a conta aceita menos:
   - **Estado da conta:** `wrangler whoami` (autenticado? qual account?). Sem wrangler autenticado, peca `wrangler login` — ou registre a pendencia (abaixo). Se o MCP da Cloudflare API estiver conectado, use-o como alternativa.
   - **Recursos existentes:** `wrangler d1 list`, `wrangler r2 bucket list`, `wrangler kv namespace list`, `wrangler queues list`, workers ja deployados. Serve pra dois fins: reaproveitar o que ja existe (um D1 do mesmo projeto, um design system de Worker) e evitar conflito de nome/limite de quantidade.
   - **Plano vs produto:** pra cada linha da tabela, confira via `cloudflare-atlas` (nunca memoria — isso muda) se o produto/limite escolhido existe no plano ATUAL da conta. Pegadinhas reais (verificadas 2026-07-28 — RE-VERIFIQUE, mudam): **CPU por request e o muro do Free — 10ms contra 30s no Paid** (hash de senha, render + query ja estouram, muito antes do teto de requests); **KV no Free so aceita 1.000 escritas/dia** (sessao ou contador por request morre ai); **R2 tem assinatura propria, fora dos US$5** (free tier 10GB-mes); **D1 no Free e 10 bancos de 500MB** (contra 50.000 de 10GB no Paid); Workers AI cobra por uso alem da cota. Nao herde gotcha de memoria: "Queues exige Workers Paid" ja foi verdade e HOJE E FALSO (Free tem 10k operacoes/dia) — e exatamente por isso que este passo existe.
   - **Saida:** acrescente a coluna `Plano exigido / status na conta` na tabela de decisao. Toda inconsistencia (produto pago + conta Free, limite estourado pelo volume previsto nas premissas da spec) vira item EXPLICITO no gate: "isso exige upgrade (custo X/mes) OU redesenho — qual prefere?". Custo mensal estimado da stack entra nas premissas da spec e na constituicao.
   - **Sem acesso a conta** (wrangler nao instalado/autenticado e usuario nao quer logar agora): NAO invente o estado. Aprove a stack como "condicionada a verificacao de conta", registre a pendencia no status file e verifique no inicio da Fase 6 — nunca deixe pra descobrir na implementacao.
5. **Validar patterns com context7** — nao confiar em memoria, buscar docs atuais
6. **Documentar decisoes que impactam a arquitetura** (ex: WXT vs CRXJS, qual biblioteca de animacao)
7. **Cobertura de skills da stack (apos o usuario aprovar a stack):** varra a lista de skills da sessao componente por componente — TODA a stack, nao so as camadas Cloudflare (framework, linguagem, ORM, auth, UI, testes). Monte a tabela `componente → skill encontrada → situacao` (dedicada / coberta por skill geral / sem skill). Pra cada componente sem skill, busque com `find-skills` e apresente UMA oferta unica de instalar tudo que falta (nunca instale sem aprovacao; recusa nao bloqueia — o componente fica registrado como gap e a Fase 7 audita com `context7`). Essas skills sao a regua dos auditores da Fase 7 e o insumo da implementacao.

**Scaffold oficial (depois da stack aprovada, nunca antes).** O repo `cloudflare/templates` (github.com/cloudflare/templates) e o catalogo oficial de starters mantidos pela Cloudflare — React/Next/Remix/React Router, D1, R2, Durable Objects, Workflows, Hyperdrive, OpenAuth, containers, entre outros. Com a stack ja escolhida, confira se existe um template que case com ela e anote o path no artefato da fase; ele vira ponto de partida do plano na Fase 6.

Duas travas:
- **Confira o repo na hora, nao de memoria.** Template entra e sai do catalogo, e o conteudo muda. Se nao abriu, nao afirme que existe.
- **Nao e fonte de limite, preco nem estado de conta.** Isso continua sendo `cloudflare-atlas` + passo 4. Template mostra que a combinacao roda; nao mostra que ela cabe no plano da conta do usuario. Template nunca decide a arquitetura — ele so materializa uma decisao ja tomada.

**Entrega:** Stack definida com justificativa baseada em pesquisa + tabela de cobertura de skills da stack (instaladas ou gaps registrados).

**Nao avance sem:** Usuario aprovar stack.

---

## Fase 5 — Design

**Objetivo:** Definir a experiencia do usuario e o sistema visual antes de escrever codigo.

**Quando pular:** CLIs, APIs sem interface, scripts de automacao — qualquer produto sem UI visual. Informe o usuario antes de pular.

**IMPORTANTE — esta fase NAO escreve codigo de produto.** O artefato desta fase e direcao visual + design system + telas aprovadas — nunca paginas de producao. O codigo real so nasce na Fase 6, a partir do handoff. Vale mesmo quando o caminho escolhido cospe HTML: **HTML de mockup nao e codigo de producao**, e alinhamento descartavel.

### 5.1 — Escolher o caminho (PORTAO — pergunte, nao escolha sozinho)

Ha dois caminhos, e **cada um faz a fase inteira sozinho**: le o contexto, decide a direcao estetica, monta o sistema visual e produz a peca. **Nao empilhe caminhos** — nao existe "um define a direcao e o outro desenha". Isso e redundante e castra os dois: cada skill tem o proprio portao estetico, e alimentar uma com a decisao da outra mata justamente onde ela e boa.

**Sempre apresente as opcoes e espere o usuario apontar.** Nunca assuma o caminho por conta propria, nunca decida "pelo que ja esta instalado". Se so um estiver disponivel, ofereca instalar os outros ou seguir pro fallback — mas pergunte.

Modelo da pergunta e criterios de recomendacao: `references/design-paths.md` (secao "Portao 5.1"). Se o usuario nao tiver preferencia, recomende pelo criterio de la — mas ainda espere ele confirmar.

Registre no design doc **qual caminho foi escolhido e por que**.

### 5.2 — Executar o caminho escolhido

Leia `references/design-paths.md` (secao do caminho escolhido) — passo a passo de cada caminho, insumos, tratamento de marca existente, fallback e nota mobile.

### 5.3 — Design doc

1. Com a direcao + telas aprovadas, consolidar o documento de design:
   - Salvar como `docs/<nome-produto>-design.md`
   - Incluir: brief de design, **qual caminho o usuario escolheu no 5.1 e por que**, direcao estetica escolhida (e por que), variaveis CSS/tokens, inventario de componentes, regras responsivas
   - **Rastreabilidade:** mapear cada tela pros requisitos `R<n>` da spec que ela cobre — requisito com UI sem tela e furo que a Fase 7 vai apontar
   - **Insumo da Fase 6:** HTMLs + screenshots no repo.

**Entrega:** Telas aprovadas + design system + documento de design.

**Nao avance sem:** Usuario aprovar as telas E o design doc.

---

## Fase 6 — Escrita do Plano

**Objetivo:** Plano de implementacao detalhado, com passos pequenos e codigo completo.

**Como executar:**

1. **Carregar as boas praticas da stack:** invoque as skills de melhores praticas instaladas no passo 7 da Fase 4 (sem `find-skills` aqui — so carregar o que ja esta instalado). O plano nasce seguindo as praticas, nao corrigido depois. Se forem muitas, carregue inline so as do nucleo (framework, auth, banco); o resto segue como regua dos auditores da Fase 7, que rodam em subagents.
2. **Contrato se le no momento de ESCREVER o codigo, nao so ao decidir a arquitetura.** Vale para os dois tipos de dependencia:
   - **Integracao externa** (API de terceiro, webhook, gateway): ao escrever a tarefa que a toca, ABRA a referencia (skill dedicada, doc oficial) e confira payload, headers, assinatura e campos — cada leitura de campo no codigo do plano cita arquivo/linha (ou URL/secao) da referencia. **Fixtures de teste sao copiadas literalmente da doc, nunca escritas de memoria — teste que fabrica o proprio contrato nao e teste** (ele valida a implementacao contra si mesma e passa verde com o contrato todo errado).
   - **Bibliotecas/frameworks**: antes do codigo de cada tarefa, confira via `context7` a assinatura, o import path e a config atual de cada lib que a tarefa usa. A Fase 4 validou a ESCOLHA; isso valida o USO.
   - **Contrato ENTRE tarefas do plano segue a mesma regra**: o fixture da tarefa consumidora e copiado do bloco de codigo da tarefa produtora (citando a tarefa), nunca escrito de memoria. `Recursos nomeados` trava nomes, nao formas — payload de fila, shape de retorno e schema tambem sao contrato.

   Por que: numa execucao real, a referencia da API de mensagens foi lida na Fase 1 (e acertou a arquitetura), mas na hora de escrever a tarefa do webhook o agente nao voltou nela — inventou assinatura HMAC (a real era segredo compartilhado), formato de payload e dois campos inexistentes. Resultado: produto que nao capturaria UMA mensagem em producao, com 139 testes verdes — porque os testes fabricavam o mesmo contrato inventado. So o red-team da Fase 7 pegou.

3. **Partir do scaffold oficial, se a Fase 4 encontrou um.** Quando ha template de `cloudflare/templates` casando com a stack, o plano nao reinventa a estrutura: a primeira tarefa e clonar/gerar o scaffold (`npm create cloudflare@latest`, escolhendo o template) e as tarefas seguintes descrevem o DELTA sobre ele — arquivos que o produto acrescenta ou altera. Menos codigo inventado no papel, menos achado na Fase 7. Antes de escrever, abra o template e confira a estrutura real de arquivos e o `wrangler.jsonc` dele — plano escrito por cima de scaffold imaginado e pior que plano do zero.
4. Invocar `superpowers:writing-plans` — seguir o fluxo completo da skill
5. O plano deve incluir:
   - Header com objetivo, arquitetura, stack escolhida, links pra spec e constituicao
   - Estrutura de arquivos completa (quais arquivos criar/modificar)
   - Tarefas com checkboxes, codigo completo, comandos exatos
   - **Cada tarefa referencia o requisito que implementa** (`R<n>`/`R<n.m>`). Tarefa sem requisito = escopo furtivo (corte ou volte na spec); requisito sem tarefa = buraco no plano. Essa amarracao e o que o analyze da Fase 7 checa.
   - Testes antes da implementacao de cada modulo (principio da constituicao)
   - Commits frequentes ao longo do desenvolvimento
6. **Todo teste do plano declara a mutacao que o faz falhar.** Uma linha depois do codigo do teste: `Falha se: <mudanca no codigo que quebraria este teste>`. Nao e burocracia — e o unico jeito de o teste ser verificavel no papel. Um teste que ninguem sabe dizer como quebrar nao esta testando nada, e isso e invisivel numa leitura normal, porque a assercao PARECE certa.

   Padrao concreto do que isso pega: um teste afirmava que a linha salva no banco nao carregava a credencial, e o fixture gravava o campo **ja redigido** — a string procurada nunca esteve na entrada, entao a assercao passaria intacta com o vazamento presente. Outro afirmava que uma funcao recusava gravar, mas verificava por um caminho de leitura que sempre preferia o outro valor: passaria identico com a guarda removida. Nos dois casos, escrever o "Falha se:" teria exposto o problema na hora de escrever o plano.

   Regra pratica: se o "Falha se:" so consegue dizer "se a funcao nao existir" ou "se retornar erro", o teste e fraco — reescreva ate a mutacao ser especifica.

7. **Alocar num unico lugar todo nome com escopo global.** Antes de escrever as tarefas, faca uma secao `## Recursos nomeados` no plano listando: numero e nome de cada migracao, cada rota/path, cada chave de binding, cada nome de tabela e de var de ambiente — com a tarefa dona de cada um. As tarefas **consomem dessa lista**, nunca inventam.

   Sem isso, duas tarefas escrevem `0002_*.sql` e o Wrangler quebra, porque rastreia migracao por nome. Cada tarefa so ve o proprio texto: colisao de nome e invisivel de dentro da tarefa, por construcao.

8. **Declarar os portoes nas Restricoes Globais**, com o comando exato e o estado exigido: type check, lint, suite, build — o que a stack tiver. E exigir que **cada tarefa reporte a contagem antes e depois, no relatorio dela, sob o titulo fixo `## Portoes`** — um comando por linha, com os dois numeros.

   O lugar fixo nao e detalhe: contagem sem lugar definido vira frase solta no meio de um relatorio e ninguem consegue comparar duas tarefas depois. E o mesmo furo que a secao `Recursos nomeados` resolve para nome global — dado sem endereco nao e rastreavel.

   Portao so serve enquanto esta verde. Num projeto real o type check acumulou 7 erros desde a primeira tarefa e virou ruido de fundo; quando uma tarefa introduziu um erro novo, o relatorio dela disse "sao os mesmos erros pre-existentes" e ninguem conferiu item a item — duas vezes. Portao que sempre acusa nao acusa nada. Se um erro herdado nao puder ser consertado na hora, ele entra na lista com dono e prazo, nao no silencio. **Essa regra do erro herdado e ESCRITA NO PROPRIO PLANO, junto aos portoes das Restricoes Globais** — quem executa le o plano, nao esta skill.

9. Salvar em `docs/superpowers/plans/YYYY-MM-DD-<nome-produto>.md`

**Formato de referencia:** Ver skill `superpowers:writing-plans` para estrutura exata.

**Entrega:** Plano salvo no filesystem.

**Nao avance sem:** Plano escrito e salvo.

---

## Fase 7 — Auditoria

**Objetivo:** Encontrar bugs, vulnerabilidades e problemas de arquitetura ANTES de implementar — sem introduzir problema novo corrigindo achado falso.

O plano passa por review adversarial como se fosse codigo real.

**Como executar:**

1. **Analyze — consistencia cross-artefato (ANTES dos auditores).** Um subagent compara spec × constituicao × design doc × plano:
   - Todo `R<n>` tem tarefa(s) no plano? Toda tarefa aponta pra um `R<n>`?
   - Toda tela do design cobre requisitos? Requisito com UI ficou sem tela?
   - O plano viola algum principio da constituicao (fora das excecoes documentadas)?
   - Nomes/paths/referencias cruzadas batem entre os artefatos?
   - **Todo teste tem `Falha se:` e a mutacao e especifica?** Marque como achado todo teste cujo `Falha se:` seja generico ("se a funcao nao existir", "se der erro") — e, mais importante, todo teste em que a mutacao descrita **nao faria a assercao falhar de verdade**. Simule mentalmente: aplique a mutacao ao codigo do plano e confira se a assercao muda de resultado. Se nao muda, o teste e vacuoso e o `Falha se:` esta mentindo.
   - **A secao `Recursos nomeados` existe, e cada nome global aparece nela uma vez so?** Dois nomes iguais com donos diferentes e colisao garantida — e invisivel de dentro de cada tarefa.
   - **Os portoes das Restricoes Globais tem comando exato e estado exigido?** Portao sem comando nao e portao.
   - **Toda tarefa que toca integracao externa cita a referencia (URL/secao ou arquivo/linha) nos campos que le, e os fixtures batem com a doc citada?** Tarefa de integracao sem citacao de contrato e achado P1.
   Retorna matriz de cobertura + furos. Furos entram no relatorio com a mesma regua de prioridade dos demais achados. E barato e pega as lacunas compostas que os auditores de dominio nao veem (cada um olha so o proprio dominio).

2. **Identificar dominios relevantes** baseado na stack escolhida na Fase 4.

3. **Selecionar skills de auditoria** olhando a lista de skills disponiveis no contexto da sessao e filtrando por dominio. Use `references/audit-skills.md` como exemplo de mapeamento, mas a fonte da verdade e a lista da sessao. Inclua sempre que aplicavel: seguranca (`security-review` se disponivel), testes e performance.

4. **Dominio sem skill local? Buscar com `find-skills`.** Encontrou algo bom → propor instalacao ao usuario (nunca instalar sem aprovacao) e usar na auditoria. Nao encontrou (ou usuario recusou) → NAO pular o dominio: o subagent daquele dominio audita usando docs oficiais via `context7` + boas praticas gerais, e o relatorio marca o dominio como "auditado sem skill especializada".

5. **Despachar UM SUBAGENT POR DOMINIO, em paralelo** (todos no mesmo turno). Nao invocar as skills de auditoria inline no contexto principal — cada skill tecnica tem centenas de linhas e 4-6 delas juntas estouram o contexto. O subagent carrega a skill no contexto DELE e devolve so os achados. Se a tool `Workflow` estiver disponivel, prefira-a: pipeline auditores → verificadores sem barreira (o achado de um dominio ja e verificado enquanto outro dominio ainda audita).

   Prompt de cada subagent: modelo pronto em `references/audit-skills.md` (secao "Prompt do auditor de dominio").

6. **Red-team (junto com os auditores de dominio).** Um subagent adicional, SEM skill de dominio, com mandato adversarial: estressar o plano com edge cases, carga fora da premissa, falha de dependencia externa, abuso e seguranca logica — e atacar as premissas da spec ("o que quebra primeiro se a premissa X cair?"). Ele nao audita boas praticas; ele tenta quebrar o produto no papel. Mesmo formato de achados. **Produto multi-tenant:** o red-team recebe mandato explicito de quebrar o isolamento entre tenants (IDOR, tenant forjado, prefixo R2/KV colidido, JOIN sem filtro, e os caminhos SEM sessao: job de fila herdando contexto, webhook sem mapeamento, cache/log cross-tenant — lista em `references/auth-multitenancy.md`); cada furo e P0.

   **Pesquisa pontual dentro da auditoria:** a regua dos auditores sao as skills de dominio + `context7` + a constituicao — auditoria e verificacao contra referencia, nao investigacao aberta. Se um auditor (ou o red-team) esbarrar num fato datado que a skill de dominio nao cobre ("esse limite do D1 mudou?", "essa lib foi abandonada?"), ele pode usar a skill `search` em **modo simples**: 1-2 buscas Exa inline, SEM despachar os subagents dela (o auditor ja E um subagent), citando a fonte no achado. Duvida grande demais pra 1-2 buscas entra no relatorio como achado "a validar" e roda depois da consolidacao, no contexto principal.

   **Alegacao factual exige fonte viva — memoria de treino nao e fonte para achado.** O criterio e de DEPENDENCIA, nao de tipologia: achado cuja confirmacao depende de qualquer afirmacao sobre sistema fora do plano (comportamento, garantia, formato, nome, versao, limite de API/lib/servico) so entra no relatorio com verificacao em doc atual (context7 ou busca) citada no proprio achado — em QUALQUER prioridade; sem fonte, entra apenas como "a validar", nunca como P0/P1/P2/P3 (rebaixar a P2 pra escapar da verificacao e a brecha classica). Licao real: um auditor alegou como P0 que a API de teste usada no plano nao existia e sugeriu o nome "correto" — de memoria de treino. A API do plano estava documentada em duas paginas oficiais atuais; a sugerida era a OBSOLETA. Aceitar teria reescrito tres tarefas pra tras. Simetricamente, o **verificador** (passo 7) de um achado cujo objeto e fato externo (API, versao, limite) verifica contra a doc viva, nao so contra o texto do plano — refutar lendo apenas o plano nao derruba um achado factualmente errado.

7. **Verificar achados P0/P1 antes de corrigir (find → verify).** Achado falso vira "correcao" que piora o plano. Para cada achado P0/P1, despache um verificador com contexto fresco (nunca o autor do achado) com mandato de REFUTAR: "Este achado e real NESTE plano concreto? Tente derruba-lo — cite a secao do plano que o refuta ou confirme." So achado confirmado mantem P0/P1; refutado sai ou cai pra P3 com a nota do verificador. P2/P3 nao passam por verificacao (custo > beneficio).

8. **Consolidar achados em relatorio** com prioridades:
   - **P0**: Bugs e seguranca — corrigir antes do MVP
   - **P1**: Performance e arquitetura — corrigir durante MVP
   - **P2**: UX e boas praticas — corrigir pos-MVP
   - **P3**: Melhorias opcionais

   Deduplicar achados que dois auditores reportaram. Registrar tambem os achados refutados na verificacao (evita re-descoberta em auditoria futura).

9. **Salvar relatorio** em `docs/<nome-produto>-audit.md`

**Entrega:** Relatorio de auditoria com achados confirmados e priorizados.

**Nao avance sem:** Relatorio completo.

---

## Fase 8 — Correcao

**Objetivo:** Aplicar todos os achados da auditoria de volta no plano — sem criar contradicao nova entre as partes.

**Principio da fase — auditoria e paralela, correcao e serial.** Outputs que COMPETEM (mockups da Fase 5, auditores da Fase 7 — escolhe-se/consolida-se) podem nascer em paralelo. Outputs que se INTEGRAM (secoes reescritas do MESMO plano) nao podem: cada escritor paralelo e cego ao que os outros escrevem, e a contradicao entre eles e invisivel de dentro de cada secao, por construcao. Licao real: 6 reescritores paralelos consertaram 50 achados e criaram 27 contradicoes novas — tabela criada duas vezes com esquemas incompativeis (derrubava TODAS as migracoes), 4 funcoes importadas que ninguem criava, a mesma tabela com tres formas em tres tarefas, migracoes com numero colidido. A sessao levou 3h extras pra achar e consolidar. Paralelismo aqui so entre secoes comprovadamente disjuntas (ver passo 3).

**Como executar:**

1. **Mapa de impacto (antes de qualquer reescrita).** Agrupe os achados por secao — e, para cada achado que muda um CONTRATO (schema de tabela, assinatura de funcao, semantica de coluna, forma de chamada, nome global), liste TODAS as tarefas que consomem esse contrato. **Tarefa consumidora entra na rodada de reescrita mesmo sem achado proprio.** Licao real: 3 tarefas sem achados ficaram fora da rodada enquanto o contrato que elas consumiam mudava — resultado: telas importando 4 funcoes que nao existiam mais em lugar nenhum. Obrigacao declarada por uma reescrita ("as tarefas X, Y devem passar a fazer Z") vira item de trabalho rastreado no mapa, nunca so prosa.

2. **Atualizar `Recursos nomeados` SERIALMENTE, antes do fan-out — criacao E remocao.** Toda mudanca de nome global (migracao nova, tabela, rota, binding, arquivo compartilhado — e tambem REMOCAO ou renomeacao de qualquer um) e alocada primeiro na lista canonica, pelo orquestrador, em serie. Recurso removido sai da lista na mesma alocacao, e o orquestrador varre o plano por consumidores do nome morto antes do fan-out — consumir um nome que ainda esta na lista mas ja nao existe e a variante silenciosa da colisao. Os reescritores recebem a lista atualizada como insumo com a regra: **consomem, nunca inventam** — precisou de nome global novo no meio da reescrita, devolve como pedido ao orquestrador, nao cria localmente. A lista funcionou com 1 escritor (zero colisao em 6.687 linhas) e falhou com 6 escritores sem lock — o mecanismo certo e alocacao serial, nao a lista sozinha.

3. **Particionar pelo grafo de recursos — medido contra o PLANO, nao contra o mapa.** Duas secoes so podem ser reescritas em paralelo se um grep dos arquivos/tabelas/imports citados nas duas nao tiver intersecao (o mapa do passo 1 lista o que os ACHADOS tocam; o acoplamento real vive no plano inteiro). Intersecao nao-vazia = mesmo agente, ou serie. Reescritor e proibido de tocar recurso fora da propria secao — precisou "aproveitar pra ajustar" um helper compartilhado, devolve pedido ao orquestrador. Na duvida, serie — o custo de serializar e minutos; o de contradicao e a auditoria inteira de novo.

4. **Aplicar por reescrita de secao, nao find-and-replace pontual.** Em planos longos, busca-e-troca de trechos pequenos erra match e deixa correcao pela metade. Para cada secao com achados:
   - Ler a secao inteira do plano
   - Reescrever a secao ja incorporando todos os achados dela (codigo corrigido completo)
   - Substituir o bloco inteiro no arquivo
   Se o plano for muito grande (2000+ linhas), delegar cada secao a um subagent — respeitando o particionamento do passo 3.

5. **Cada reescrita devolve os DELTAS DE CONTRATO** num bloco estruturado ao fim da secao devolvida: "contratos que criei/mudei" (tabela, funcao, rota, com a forma final) e "contratos que passo a exigir de outras tarefas" (quem, o que). O orquestrador cruza os deltas de todas as reescritas ENTRE SI antes de aceitar qualquer uma — dois deltas definindo o mesmo nome, ou um delta exigindo o que ninguem entrega, e conflito que volta pra reescrita agora, nao achado da proxima auditoria.

6. **AUDITAR A PROPRIA REESCRITA — passo obrigatorio, nao pule.** O texto que sai daqui foi escrito por agente e ainda nao passou por revisao nenhuma. A Fase 7 auditou o plano ANTIGO; ela nao viu uma linha do que voce acabou de escrever.

   Despache **um auditor por secao reescrita**, escopado ao diff da reescrita (nao ao plano inteiro), com este mandato:
   - O achado que motivou a mudanca esta REALMENTE resolvido, ou so parece?
   - A correcao introduziu defeito novo? Procure em especial: requisito que ficou contraditorio com outro; codigo que viola um principio da constituicao; teste cujo titulo promete uma coisa e a assercao verifica outra; teste que passaria com uma implementacao ingenua; instrucao que manda escrever em documento que nao e da tarefa.
   - A secao reescrita contradiz um requisito da spec, ou uma secao do plano que o proprio diff referencia (import, tabela, contrato citado no trecho)? (Contradicao entre secoes que o diff NAO toca e funcao do passo 7 — nao cobre aqui.)
   - Sobrou placeholder, "TBD", ou "similar a Task N"?

   Achado desta auditoria volta para a reescrita, na mesma rodada. **Atencao ao limite dele:** o auditor escopado ao diff pega defeito local e contradicao com o que o diff referencia; contradicao entre secoes que ele NAO ve e funcao do passo 7.

7. **Auditoria de costuras (serial, obrigatoria — ultima verificacao antes do checklist de saida).** Depois de todas as reescritas aceitas, UMA passada com visao do plano INTEIRO, verificando as junções — onde a contradicao mora. Checagens mecanicas primeiro (grep/script sobre o plano, nao julgamento):
   - Cada `CREATE TABLE` aparece UMA vez; cada tabela tem UMA forma; toda tabela referenciada em QUALQUER SQL do plano (inclusive dentro de strings) tem exatamente um CREATE
   - Numeros de migracao unicos e sequenciais, cada um com UM dono
   - Todo import/chamada tem definicao em alguma tarefa; todo arquivo compartilhado tem UM dono na lista canonica
   - Toda obrigacao do mapa de impacto ("tarefas X devem Z") tem implementacao correspondente
   - Contagens de portoes recontadas a partir dos blocos de teste do plano (script conta, agente nao declara — licao real: portao declarado "46 → 81" com 45 testes contaveis no arquivo). **Proxy validado antes de confiar:** conte 1 secao a mao e confira contra o script; divergiu, o padrao do script esta errado (grep que pega `fit(` e perde `test(` sai carimbado de "recontado" com o numero errado). Prefira o MESMO comando declarado nos portoes (a suite real), nunca grep ad hoc
   Depois, o julgamento: as secoes reescritas contam a MESMA historia (semantica de coluna, fluxo de dados, quem resolve o que na leitura/escrita)? Achado de costura volta pra correcao — em serie — antes do gate.

8. **Checklist final e criterio de saida BINARIO.** Percorrer o relatorio de auditoria e confirmar que cada achado P0/P1 tem correcao correspondente no plano, e que nenhum requisito da spec ficou descoberto. A fase so fecha em UM de dois estados:
   - **Plano executavel:** zero P0/P1 aberto — cada um corrigido no plano, refutado na verificacao, ou descartado com motivo registrado E aprovado pelo usuario no gate — zero teste vacuoso conhecido sem correcao, fila "a validar" da auditoria vazia (cada item validado com fonte e promovido, ou descartado com a fonte que o refutou), costuras verificadas; ou
   - **A fase continua** — nao existe terceiro estado "restam 3 P0 menores, quer que eu feche?".

   **Proibido transformar trabalho pendente em pergunta.** Achado com correcao CONHECIDA — escrita no relatorio, ou descritivel em uma frase — NUNCA vira pergunta ao usuario: aplica-se (nao escrever a correcao pra poder "descartar" e a mesma fuga com outra roupa). Descarte de P0/P1 so e oferecivel quando o motivo e trade-off de PRODUTO (mudanca de escopo ou risco nomeado, que se propaga para spec/constituicao); custo ou tempo de corrigir NUNCA e motivo de descarte. A unica pergunta legitima no gate e trade-off real (mudar o produto, assumir risco declarado, custo acima do teto). Descarte aprovado se registra no relatorio com motivo — e decisao documentada, nao pendencia. Licao real: uma sessao de 3h terminou apresentando "o plano ainda nao esta executavel — restam 3 P0, 1 P1 e 16 testes vacuosos, todos com correcao ja escrita" seguido de "quer que eu feche?". Isso e a fase entregue pela metade com a conta empurrada pro usuario.

**Por que os passos 6 e 7 existem.** Duas execucoes reais, duas camadas do mesmo problema. Na primeira, 11 reescritores entraram no plano sem revisao ("sairam de uma auditoria") e deixaram 6 defeitos novos, todos achados so na implementacao — dai o passo 6 (auditor por secao). Na segunda, o passo 6 rodou e pegou os defeitos locais — e mesmo assim 27 contradicoes ENTRE secoes passaram, porque o auditor escopado ao diff nao enxerga costura — dai o passo 7. **Texto gerado por agente merece a mesma desconfianca que codigo gerado por agente — e integracao de textos gerados por agentes merece a mesma desconfianca que merge de codigo.**

**Entrega:** Plano corrigido com todos os achados P0 e P1 resolvidos, reescritas auditadas e costuras verificadas.

---

## Fase 9 — Montagem

**Objetivo:** Plano final consolidado, limpo, pronto para execucao.

**Como executar:**

1. **Verificar consistencia** — nomes, paths, imports, referencias cruzadas. Re-rode as checagens mecanicas do passo 7 da Fase 8 (costuras) como confirmacao final — sao baratas e o plano pode ter mudado desde entao.
2. **Recontar todo numero declarado a partir da fonte.** Totais de tarefas/testes/criterios e qualquer numero do resumo final: contagem sai de script sobre os arquivos, nunca de numero declarado por agente em relatorio anterior (portoes ja foram recontados pelas checagens do passo 1 — aqui entra o resto). Numero declarado e propagado sem recontagem foi defeito real (a licao do passo 7 da Fase 8) — e erro de aritmetica em portao propaga pra todas as tarefas seguintes.
3. **Remover artefatos de correcao** — comentarios temporarios, marcacoes de diff
4. **Validar que o plano e auto-contido** — alguem (ou um agente) consegue executar so lendo o plano
5. **Gerar a feature list de aceitacao** em `docs/<nome>-features.json` — uma entrada por criterio de aceite da spec:
   ```json
   [{"id": "R1.1", "criterio": "QUANDO o cliente confirma o horario, o sistema DEVE...", "status": "pending"}]
   ```
   E o estado duravel da execucao: quem implementar (ex: `subagent-driven-development`) marca `passing`/`failing`, e ninguem declara "pronto" com item `pending`. **Proibido editar ou remover criterios pra passar** — mudanca de criterio = editar a spec primeiro.

   **`passing` exige o campo `prova`,** nomeando o teste que demonstra o criterio: `{"id": "R1.1", "criterio": "...", "status": "passing", "prova": "test/agenda.test.ts › confirma horario e grava"}`. A prova tem que cobrir a **frase inteira** — criterio com duas metades e `passing` so quando as duas tem teste; se so uma tem, o status e `pending` com nota dizendo qual falta.

   Gere junto o portao executavel `scripts/validar-features.js`, que sai com codigo diferente de zero quando alguma entrada `passing` nao tem `prova`, usa status fora de `pending`/`passing`/`failing`, **ou tem `prova` fantasma** — o script resolve a prova: extrai o path antes de `›`, confere que o arquivo existe e que o nome do teste aparece nele (grep literal). Nao prova que o teste testa o criterio (isso continua julgamento), mas mata a prova preenchida com string plausivel.

   **Por que:** num projeto real, **sete** criterios foram marcados `passing` sem implementacao atras e rebaixados depois — um deles duas vezes, pela mesma clausula. Um dizia "remover do arquivo web em ate 24 horas" com codigo que nao removia nada. Quando o portao foi criado, ele acusou **16** marcacoes sem prova de uma vez, e a auditoria delas rebaixou mais 3 — uma exigia "autor e horario" e o horario nunca fora asserido. Julgamento nao escala; invariante escala.
6. **Gerar o mapa de jornadas** em `docs/<nome>-jornadas.md` — o roteiro de teste pos-implementacao. Derive das user stories da spec: cada jornada e uma sequencia de passos (acao do usuario → comportamento esperado) com os `R<n>` que atravessa e um status por passo (`pending` → ✅/🐛). Inclua NO PROPRIO arquivo o protocolo de validacao (ele roda numa sessao futura, sem esta skill no contexto):
   - **Quando rodar:** depois da implementacao, com o app rodando e o `features.json` todo `passing`.
   - **Como rodar:** percorrer cada jornada NO NAVEGADOR (dev server + browser controlado pelo agente), passo a passo, marcando ✅/🐛 com evidencia (screenshot, erro de console ou log).
   - **Resolucoes:** cada jornada com UI e percorrida em mobile (375px), tablet (768px) e desktop (1280px) — quebra de layout/design em qualquer resolucao e 🐛 igual a bug de logica. Produto sem UI: percorrer os fluxos via terminal.
   - **Loop ate zerar:** achou 🐛 → corrige → percorre a jornada afetada DE NOVO do inicio (a correcao pode quebrar um passo anterior). Criterio de pronto binario: TODAS as jornadas 100% ✅ em TODAS as resolucoes. Proibido declarar "pronto pra lancar" com qualquer 🐛 aberto, e proibido editar jornada pra passar — mudanca de jornada = editar a spec primeiro (mesma regra do features.json).
7. **Gravar a governanca no `CLAUDE.md` do projeto** — criar o arquivo (ou ADICIONAR uma secao "## Regras do projeto (geradas pela /planejar)" se ja existir; nunca sobrescrever conteudo alheio). E o unico arquivo que toda sessao futura carrega automaticamente — sem ele, estas regras morrem com a sessao do planejamento. Conteudo:
   - **Mapa dos artefatos** (paths): spec, constituicao, design doc, plano, audit, `features.json`, `jornadas.md`.
   - **Regra de mudanca:** qualquer alteracao no app (feature nova, mudanca de comportamento) comeca editando a SPEC (novo `R<n>` ou edicao do existente) e propaga, nesta ordem: `features.json` (criterio novo) → `jornadas.md` (jornada nova ou passo novo) → **o PLANO** (corrigir a secao da tarefa afetada, ou marca-la SUPERADA apontando o requisito novo) → so entao o codigo.
     **O plano no meio da cadeia nao e formalidade.** Ele e congelado no fim do planejamento e e ele que gera os briefs das tarefas. Num projeto real a spec foi mantida com rigor e o plano nao — e quatro briefs chegaram ao dispatch descrevendo um desenho morto: migracao com numero ja ocupado por outra tarefa, tipos de duas versoes atras, um campo que deixou de existir depois de uma mudanca de seguranca, e um criterio de eval escrito pro desenho antigo. Nos quatro, quem pegou foi o operador lendo o brief contra o codigo. Spec viva com plano velho e uma fonte de verdade que se contradiz.
   - **Regra de marcacao:** `passing` no `features.json` exige `prova` nomeando o teste, cobrindo a frase inteira do criterio. `node scripts/validar-features.js` e o portao.
   - **Regra de validacao:** depois de qualquer mudanca, rodar o loop de validacao das jornadas afetadas (protocolo dentro do proprio `jornadas.md`) e auditar a mudanca contra a constituicao. Mudanca so esta pronta com jornadas ✅.
   - **Constituicao permanente:** os principios valem pra toda a vida do projeto; excecao nova = documentar na constituicao ANTES de implementar.
8. **Limpar arquivos temporarios** (fix files, rascunhos)
9. **Apresentar resumo ao usuario:**

```markdown
## Resumo do Planejamento

**Produto:** [nome]
**Spec:** `docs/<nome>-spec.md` · **Constituicao:** `docs/<nome>-constituicao.md`
**Plano:** `docs/superpowers/plans/YYYY-MM-DD-<nome>.md`
**Auditoria:** `docs/<nome>-audit.md` · **Feature list:** `docs/<nome>-features.json` · **Jornadas:** `docs/<nome>-jornadas.md`

### Numeros
- [N] requisitos ([N] criterios de aceite)
- [N] tarefas de implementacao
- [N] achados de auditoria confirmados ([N] P0, [N] P1, [N] P2, [N] P3; [N] refutados na verificacao)
- Todos P0/P1 corrigidos no plano

### Proximo passo
Quando quiser executar, use `superpowers:subagent-driven-development`
apontando para o plano + feature list. Terminada a implementacao, rode
o loop de validacao de `docs/<nome>-jornadas.md` — so lance com tudo ✅.
```

**Entrega:** Plano final + feature list + mapa de jornadas + `CLAUDE.md` de governanca + resumo.

**Nao executar codigo sem aprovacao explicita do usuario.**

---

## Documentos Produzidos

Ao final das 9 fases, o projeto tera:

| Documento | Path | Conteudo |
|-----------|------|----------|
| Status do planejamento | `docs/<nome>-planejamento-status.md` | Fases concluidas, decisoes, paths — usado pra retomar |
| Benchmark de mercado | `docs/<nome>-benchmark.md` | Referencias mundiais, padroes a roubar/ignorar, ideias que viram requisito |
| Perfil do cliente | `docs/<nome>-perfil.md` | Persona, marca, contexto (so se houve cliente) |
| Spec | `docs/<nome>-spec.md` | Requisitos EARS, fora de escopo, clarifications, premissas |
| Constituicao | `docs/<nome>-constituicao.md` | Principios invioláveis + excecoes documentadas |
| Telas / design | HTMLs + screenshots no repo | Telas + design system aprovados no 5.1 |
| Design system | `docs/<nome>-design.md` | Estilo escolhido, tokens, componentes, regras responsivas, mapa tela→requisito |
| Plano de implementacao | `docs/superpowers/plans/YYYY-MM-DD-<nome>.md` | Tarefas com codigo completo, rastreadas a requisitos |
| Relatorio de auditoria | `docs/<nome>-audit.md` | Achados confirmados priorizados + refutados |
| Feature list | `docs/<nome>-features.json` | Criterios de aceite passing/failing — estado da execucao |
| Mapa de jornadas | `docs/<nome>-jornadas.md` | Jornadas passo a passo + protocolo de validacao pos-implementacao (navegador, 3 resolucoes, loop ate zero 🐛) |
| Governanca do projeto | `CLAUDE.md` (raiz do projeto) | Mapa dos artefatos + regras permanentes: mudanca comeca na spec e propaga pra features/jornadas, validacao + auditoria apos toda mudanca |

---

## Atalhos

Nem todo produto precisa das 9 fases completas. Sempre confirme com o usuario antes de pular uma fase.

| Cenario | Fases |
|---------|-------|
| Produto com cliente + UI | Todas as 9 |
| Projeto pessoal / tech com UI | Fase 2 so o bloco 2A (benchmark) → 1 → 2A → 3 → 4 → 5 → 6 → 7 → 8 → 9 |
| CLI / API / sem interface | Fase 2 so 2A, pular Fase 5 → 1 → 2A → 3 → 4 → 6 → 7 → 8 → 9 |
| Prototipo rapido | Fases 1 → 3 (spec minima) → 4 → 5 → 6 (sem auditoria) |
| Refactoring de produto existente | Converge + Fases 3 (delta) → 4 → 6 → 7 → 8 → 9 |
| Usuario ja tem stack definida | Pular Fase 4 (exceto passos 4 e 7 — auditoria da conta e cobertura de skills) — oferta unica Cloudflare antes, registrar na constituicao |
| Produto trivial | **Rota expressa** (abaixo) |

**Rota expressa (produtos triviais):** script pequeno, feature isolada, prototipo de 1 dia — o processo completo custa mais que o trabalho. Nesses casos, UMA passada so: mini-brainstorm inline + spec minima (3-6 requisitos EARS, meia pagina — nunca zero: sem requisito verificavel nao ha regua de pronto) + stack default (constituicao herdada, sem pesquisa) + plano curto, apresentados juntos num UNICO gate no final. Sem auditoria multi-agente (no maximo um self-review). Criterio pra oferecer: o plano inteiro caberia em ~1 pagina e nao ha cliente externo. Sempre confirme com o usuario que a rota expressa basta.

---

**Execução do plano** (pós-skill): `superpowers:subagent-driven-development` ou `superpowers:executing-plans` apontando pro plano + `docs/<nome>-features.json`. Depois da implementação: loop de validação de `docs/<nome>-jornadas.md` até todas as jornadas ✅ em todas as resoluções.
