# Caminhos de design — portao e execucao (Fases 5.1–5.2)

Como perguntar o caminho (portao 5.1) e como executar cada um dos dois (5.2). Na execucao, leia APENAS a secao do caminho escolhido.

## Portao 5.1 — modelo da pergunta e recomendacao

> **Fase 5 — quem vai desenhar, e como?**
> **a) `design-lab` (terminal)** — desenho as telas aqui, em HTML, e verifico renderizando com Chrome headless. Tem catalogo de formatos × estilos (26 estilos) pra voce ver amplitude antes de cravar a direcao. Melhor pra **UI de produto**: app, SaaS, dashboard, prototipo, design system. Fica tudo no repo.
> **b) `design-taste-frontend` (terminal)** — skill anti-slop que le o brief, infere a direcao e entrega a interface. Escopo declarado: **landing pages, portfolios e redesigns** — nao dashboards, nao UI de produto multi-step. Melhor quando o produto E uma pagina de marketing.
>
> Qual prefere?

**Como recomendar, se o usuario nao tiver preferencia** (recomende, mas ainda espere ele confirmar):
- Produto e **app / SaaS / dashboard / ferramenta interna** → `design-lab`. A `design-taste-frontend` esta fora do escopo dela aqui, por escrito.
- Produto e **landing / portfolio / site de marketing**, ou e um **redesign** de pagina existente → `design-taste-frontend`.

## Execucao (5.2) — insumos comuns

**Insumos, qualquer que seja o caminho:** spec da Fase 3 (requisitos que a UI cobre), perfil do cliente da Fase 2 (marca, tom, publico), escopo/telas-chave da Fase 1 (com conteudo real, hierarquia e fluxo), stack da Fase 4.

**Marca existente** (identidade visual capturada na Fase 2): a direcao deve acomodar as cores, fontes e tom da marca. **Adaptar, nao reinventar** — passe isso ao caminho escolhido como restricao, nao como sugestao.

**Produto multi-tenant** (modelo de uso classificado na Fase 1, premissa na spec): a administracao do tenant TEM tela. Passe ao caminho escolhido as telas que a primitiva de organizations implica — gestao de membros, convite pendente/aceite, papeis por tenant e, se o usuario puder estar em 2+ tenants, o seletor de tenant. Cada uma cobre um `R<n>` da spec; se nao existir requisito pra elas, volte a Fase 3 antes de desenhar (ver `auth-multitenancy.md`).

**(Opcional — so marca forte)** mood board de atmosfera via referencias reais (scrape de sites parecidos). Pulado por padrao — so quando a identidade visual pede.

## Caminho A — `design-lab` (UI de produto, tudo no terminal)

Desenha em HTML puro no filesystem e verifica renderizando com Chrome headless (`--screenshot`).

1. **Alimente o contexto** com os insumos acima. Ela explora contexto antes de criar — quanto mais concreto, melhor.
2. **Deixe ela rodar o portao estetico dela.** Peca o formato certo (`prototipo interativo / mockup de app`, que carrega `references/prototype.md`) e **deixe ela abrir o leque de direcoes** — o catalogo de formatos × estilos e o valor dela. Se houver marca existente, entre como restricao.
3. **Aprovar:** o usuario olha os screenshots/HTML e aprova. Max 1-2 rodadas — e alinhamento, nao produto final.
4. **Guardar:** telas ficam no repo como HTML + screenshots. Sao o insumo da Fase 6.

## Caminho B — `design-taste-frontend` (landing / portfolio / redesign)

Anti-slop (sucessora da antiga `taste-skill`, que nao existe mais). Le o brief, declara o "design read" numa linha, infere a direcao e entrega a interface.

1. **Alimente o contexto** com os insumos acima. Em redesign, ela e **audit-first**: os ativos de marca existentes sao material de partida, nao input opcional.
2. **Deixe ela inferir a direcao** — e o nucleo da skill. Ela pergunta no maximo uma coisa se o brief for ambiguo.
3. **Aprovar:** usuario olha e aprova. Max 1-2 rodadas.
4. **Cuidado com o limite da fase:** ela "ships interfaces". O que sai aqui e **mockup de alinhamento**, nao a pagina de producao — a pagina real nasce na Fase 6. Se o escopo do produto for exatamente essa landing, deixe explicito no design doc que o HTML da Fase 5 e referencia visual, e a Fase 6 reconstroi na stack decidida na Fase 4.

## Fallback e mobile

**Fallback (nenhum dos dois disponivel):** mockup navegavel como **Claude Artifact** (`artifact-design`) — HTML vivo e descartavel, aprovado olhando/clicando. Nem isso → HTML estatico + screenshot → pular pro design doc (5.3).

**Mobile/iOS nativo:** qualquer caminho renderiza mock responsivo em viewport mobile — direcao visual, nao app nativo real.
