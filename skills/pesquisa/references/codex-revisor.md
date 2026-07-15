# Revisor Codex (segundo par de olhos) — específico do `/pesquisa`

A mecânica de chamar o Codex (como invocar sem travar, mascarar dado, selar a versão, a **regra
de ouro** de filtrar com prova, o registro obrigatório e o fallback) mora no motor compartilhado:
**`../../_shared/confronto-codex.md` — leia antes de rodar.** Este arquivo cobre só o que é do
`/pesquisa`: os dois momentos em que o revisor entra e o que fazer com o parecer em cada um.

A `/pesquisa` usa o Codex GPT-5.6 como revisor independente em dois momentos: a sanidade do
**enquadramento** (fim do Nível 2, antes de aprofundar) e a sanidade da **conclusão** (fim do
Nível 3, antes de entregar o relatório). É um modelo DIFERENTE do que conduz a pesquisa. Não
substitui o Phase Gate v3.1 (aquele fiscal — via subagent `Explore` — confere se o relatório TEM
evidência suficiente, fato por fato); aqui a lente é outra: **essa pergunta/conclusão faz
sentido, ou está errada por baixo?** As duas checagens rodam juntas, não uma no lugar da outra.

O parecer de cada chamada é filtrado pela regra de ouro do motor e o veredito de cada ponto é
registrado (tabela do motor) no `.md` do relatório correspondente.

---

## Chamada 1 — Sanidade do ENQUADRAMENTO (fim do Nível 2, uma vez só)

Roda DEPOIS de identificar os sub-tópicos e os fatos-chave do Nível 2, ANTES do HITL que escolhe
os sub-tópicos pro Nível 3 (Deep Dive é a parte cara — buscas em paralelo, extração de páginas —
vale conferir o enquadramento antes de gastar nisso). Esforço `high` (checagem rápida, não
revisão pesada).

Monte o input em `/tmp/confronto-input.md` = o prompt abaixo + a linha do selo (motor, seção 2) +
a entrega do Nível 2 (comparativo, recomendação preliminar, sub-tópicos propostos, fatos-chave).
Depois chame conforme o motor (seção 3):

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.6-terra \
  -c model_reasoning_effort="high" \
  --skip-git-repo-check --ignore-user-config --sandbox read-only \
  - < /tmp/confronto-input.md > /tmp/pesquisa-revisao-enquadramento.md 2>/dev/null
```

Prompt a colocar no input:

```
Você é um revisor crítico de PESQUISA. Alguém vai investigar um tema e já fez uma varredura
inicial + análise. NÃO pesquise por conta própria, NÃO sugira fonte nova. Repita o hash do selo
como primeira seção (## Selo). Uma passada só, responda três perguntas:
1. A pergunta/tema que está sendo investigado está clara, ou está vaga / mal formulada?
2. Os sub-tópicos escolhidos pro aprofundamento atacam essa pergunta, ou estão apontando pro
   lugar errado (tangencial, redundante entre si, ou faltando o ângulo óbvio)?
3. Você sugeriria repensar algo ANTES de gastar buscas caras no aprofundamento? (recomendação
   preliminar baseada em premissa frágil, fato-chave mal escolhido, viés óbvio na análise)

Devolva NESTE formato:
## Selo
<o hash>
## Veredito
SEGUIR  |  REPENSAR
## Pontos
- (no máximo 5, cada um curto e acionável; se REPENSAR, diga exatamente o que repensar)
Sem elogio, sem resumo do que você leu.
```

Depois: o Claude confere o selo, lê o parecer, filtra pela regra de ouro do motor e apresenta ao
usuário. `REPENSAR` com ponto que procede → A/B (segue assim mesmo / ajusta o enquadramento antes
do Nível 3). `SEGUIR` → menciona em uma linha e segue pro HITL normal de sub-tópicos.

---

## Chamada 2 — Sanidade da CONCLUSÃO (fim do Nível 3, junto do Phase Gate)

Roda em paralelo ao Phase Gate v3.1 (o fiscal de evidência), depois que o relatório do Nível 3
está redigido — mas ANTES de apresentá-lo como fechado. Lente: a conclusão resolve a pergunta
original? Esforço `xhigh` (é a entrega final).

Monte o input em `/tmp/confronto-input.md` = o prompt abaixo + a linha do selo + o relatório
completo do Nível 3 (o `.md` inteiro, já com Resumo Executivo, Comparativo Final, Recomendação).
Depois:

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.6-terra \
  -c model_reasoning_effort="xhigh" \
  --skip-git-repo-check --ignore-user-config --sandbox read-only \
  - < /tmp/confronto-input.md > /tmp/pesquisa-revisao-conclusao.md 2>/dev/null
```

Prompt a colocar no input:

```
Você é o crítico de SANIDADE de um relatório de pesquisa. NÃO refaça a checagem de evidência
(outro processo já confere se cada fato tem 2+ fontes) — assuma que as fontes citadas existem.
Repita o hash do selo como primeira seção (## Selo). Responda só três perguntas, com evidência:

1. A Recomendação do relatório RESOLVE a pergunta original, ou responde outra coisa?
2. Existe uma conclusão substancialmente MAIS SIMPLES que os dados do próprio relatório já
   sustentam, sem precisar da recomendação como está?
3. Tem parte do relatório que não sustenta a conclusão (peso morto, tangente, contradição não
   endereçada que o relatório varreu pra baixo do tapete)?

Devolva NESTE formato:
## Selo
<o hash>
## Veredito
RESOLVE  |  RESOLVE PARCIAL  |  NÃO RESOLVE
## Pontos
- (cada um citando a SEÇÃO do relatório afetada; se houver conclusão mais simples ou peso morto,
  seja específico)
Se o veredito for NÃO RESOLVE ou houver conclusão mais simples, deixe explícito — isso é decisão
de quem pediu a pesquisa, não um ajuste de redação. Sem elogio, sem resumo.
```

Depois: o Claude confere o selo e aplica a regra de ouro do motor.
- `NÃO RESOLVE` (que procede) ou "conclusão mais simples" → **PARA**, sobe pro usuário em A/B
  antes de apresentar o relatório como fechado.
- `RESOLVE PARCIAL` / pontos menores que procedem → entram no relatório como ressalva (seção
  "Contradições Identificadas" ou nota na Recomendação) antes da entrega final.
- Pontos que não procedem → descarta, registra o motivo.

**Codex indisponível** (qualquer uma das duas chamadas): segue o fallback do motor (seção 5) — o
próprio Claude veste a lente crítica, avisando que rodou sem o GPT.
