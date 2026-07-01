# Descoberta de "como já resolveram isso" (prior art)

Etapa da **Fase 1 (Brainstorm)**. Recomendada, mas **pulável** — tarefa pequena ou óbvia
dispensa (informe o usuário e siga). Objetivo: antes de desenhar do zero, ver como o problema
**já foi resolvido lá fora**, porque na maioria dos casos alguém já resolveu — e mostrar ao
usuário ângulos que ele não estava vendo.

O usuário típico desta skill **não é programador avançado** e não conhece todas as ferramentas.
O valor é abrir a visão dele. O risco é o oposto: empurrar uma "visão diferente" que é só mais
nova/bonita e **pior pra ele**. Esta etapa resolve isso com um movimento em dois tempos —
**alarga, depois aperta** — e termina com o usuário decidindo, nunca a pesquisa decidindo.

---

## Tempo 1 — ALARGA (descobrir o que existe)

Rodar a skill `/pesquisa` com foco em **soluções existentes / prior art**, não em validar um
fato. Prompt-modelo (adaptar ao problema real):

> "Como o problema **<problema do escopo>** já é resolvido hoje? Quais abordagens, produtos,
> padrões de arquitetura ou ferramentas existentes atacam isso? Para cada um: o que é, quem usa,
> por que escolheram, e em que contexto funciona melhor ou pior."

- Se a `/pesquisa` estiver disponível (Exa ativo), usar o funil dela — traz fontes
  verificadas e citações, que é o que deixa a "visão diferente" **auditável** pelo usuário.
- **Fallback** (Exa fora, `/pesquisa` faz hard-stop): NÃO travar o planejamento. Cair pra
  uma varredura leve (`web_search_exa` se voltar, ou `WebSearch`/conhecimento próprio),
  e marcar no resultado "descoberta reduzida — sem verificação de fontes".

Saída do Tempo 1: **2-4 caminhos reais**, cada um com: o que é · quem usa · por que · trade-off.

---

## Tempo 2 — APERTA (3 travas contra a "visão pior")

As três travas, nesta ordem. Nenhuma é opcional — são elas que impedem a pesquisa de empurrar
o usuário pra algo pior do que ele faria sozinho.

### Trava 1 — o "jeito simples" SEMPRE na mesa
Incluir, ao lado dos caminhos descobertos, **a abordagem óbvia/simples que o usuário tomaria de
qualquer jeito** como uma opção de pleno direito (o baseline). A pesquisa **acrescenta** opções,
nunca **substitui** o óbvio em silêncio. O usuário compara contra o baseline, não troca às cegas.

### Trava 2 — filtro da REALIDADE do usuário
Julgar cada caminho descoberto por perguntas duras, do ponto de vista de quem vai operar:
- Dá pra **uma pessoa só, não-programador-avançado, construir E manter** isso?
- Custa o quê (serviço pago, conta nova, dependência externa)?
- Usa ferramentas que o usuário **já tem**, ou exige montar um ecossistema novo?

Caminho que só brilha na teoria mas exige um time pra sustentar **cai aqui**. Traduzir tudo pra
linguagem leiga — sem jargão; o benefício e o custo têm que ser legíveis por quem não programa.

### Trava 3 — confronto adversarial do Codex (reaproveita o revisor que já existe)
Mandar a lista curta (baseline + descobertas que passaram na Trava 2) pro revisor independente
Codex GPT-5.5 (`references/codex-revisor.md`), com a pergunta afiada:

> "Alguma dessas alternativas é **mesmo melhor** que o jeito simples (baseline) pra este caso, ou
> são só mais bonitas/novas? Aponte qual ganha e POR QUÊ, ou diga 'fica no simples'."

Isso pega a visão pior **antes** de virar plano. Filtrar o parecer pela regra de ouro do
`codex-revisor.md`: ponto que procede e é grave vira A/B pro usuário; senão, vira nota.

---

## Saída — comparação honesta, o usuário decide

Apresentar em **linguagem de diretor**: uma tabela curta comparando o baseline com 1-3
alternativas que sobreviveram, cada uma com o trade-off real (os dois lados), e um **veredito**
(qual eu recomendo e por quê). Nunca "aqui estão as opções, decide aí" — sempre com recomendação.

A pesquisa **informou**; quem escolhe é o usuário. A direção escolhida aqui alimenta o escopo
(passo 4 da Fase 1) e fica registrada pra Fase 6 (auditoria confere se uma solução existente
obviamente melhor foi ignorada).

**Salvar** a comparação em `docs/<nome>-prior-art.md` (caminhos descobertos, fontes, veredito,
direção escolhida).
