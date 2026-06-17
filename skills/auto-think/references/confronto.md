# Confronto via Codex — específico do /auto-think

A mecânica de chamar o Codex (mascarar dado antes, selar a versão com hash, a invocação com teto
de 15 min, a regra de ouro de filtrar com prova e o fallback se o Codex cair) mora no motor
compartilhado: **`../../_shared/confronto-codex.md` — leia antes de rodar.** Este arquivo cobre
só o que é do `/auto-think`: como montar o manifesto, o prompt adversarial das duas rodadas, e o
que muda da 1ª pra 2ª.

O passo 3 do ciclo manda os achados e candidatas pro Codex tentar DERRUBAR; o passo 6 traz os
sobreviventes de volta pra escolher entre eles.

## Montar o manifesto (o material que vai ser confrontado)

Escreva o manifesto com as candidatas a confrontar. Cite literal, não parafraseie — o furo mora
no detalhe. Manifesto enxuto e de alto sinal vence manifesto inchado. Estrutura:

```markdown
# Confronto — <problema em 1 linha>

## O problema (estado atual)
<o que está sendo estudado, com o critério de sucesso declarado>

## Soluções candidatas (cada uma com sua evidência)
### Candidata A
<o que é + a evidência que a sustenta (arquivo:linha, fonte+data, comando+saída)>
### Candidata B
...

## Achados que sustentam as candidatas
<fatos verificados, com fonte; marque ASSUMIDO o que não foi provado>
```

Depois siga o motor: mascarar dado (seção 1), selar (seção 2), montar o input final
(`/tmp/confronto-input.md` = prompt adversarial abaixo + linha do selo + manifesto) e chamar
(seção 3). Confronta em LOTE quando der (várias candidatas num input só) pra não estourar custo.
O confronto do auto-think roda **SEMPRE em `xhigh` + `service_tier="fast"`** (gpt-5.5) — máximo de
raciocínio na via rápida; já vem assim no comando do motor (`../../_shared/confronto-codex.md`).

## Prompt adversarial — 1ª rodada (passo 3: derrubar cada candidata)

O prompt pede ao Codex pra DERRUBAR, não validar. As perguntas:

```
Repita o hash do selo como primeira secao (## Selo). Voce e advogado do diabo: tente DERRUBAR
cada candidata, nao validar. Pra cada uma, responda com evidencia:
1. Isso resolve MESMO o problema declarado, ou a coisa errada / so um sintoma?
2. Tem furo de raciocinio, premissa fragil vendida como fato, ou risco/caso de erro ignorado?
3. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
4. As fontes/evidencias sustentam mesmo as afirmacoes, ou tem afirmacao sem lastro?

Formato:
## Selo
<o hash>
## Veredito
- (por candidata) SEGUIR | AJUSTAR | BLOQUEAR
## Pontos
- (curtos, acionaveis, cada um com a evidencia que o sustenta)
```

Filtre pela regra de ouro do motor (seção 4): o confronto BLOQUEIA uma candidata por furo de
mérito (não resolve, premissa falsa, fonte não sustenta) ou por caminho mais simples que a torna
obsoleta. Melhoria pequena não derruba a candidata — vira nota. Registra o que o confronto matou,
pra entrega ("o que o confronto derrubou e por quê").

## Prompt adversarial — 2ª rodada (passo 6: escolher entre os sobreviventes)

Os finalistas (recomendada + alternativas reais) voltam ao Codex. O foco muda: não é mais
"derruba cada candidata" e sim **"escolhe entre as que sobraram"**. Mesmo selo, mesma invocação.
Estrutura do manifesto da 2ª rodada:

```markdown
# Confronto final — escolher entre os sobreviventes

## As candidatas que aguentaram a 1ª rodada
### A (atual recomendada) — <o que é + evidência>
### B — <o que é + evidência>

## Pergunta
1. Das que sobraram, qual escolher e por quê (critério de sucesso declarado)?
2. O que AINDA fura na recomendada A que a 1ª rodada não pegou?
3. Tem combinação A+B melhor que qualquer uma sozinha?
```

O resultado afina o veredito da entrega ("por quê A venceu nos dois confrontos") e às vezes troca
a recomendada. Pula esta rodada só no modo freado.
