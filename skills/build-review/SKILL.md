---
name: build-review
description: Use quando uma feature já construída vai ser revisada antes do merge e existem uma checklist do que foi prometido (`.checks/<feature>.md`), um diff `<base>..HEAD` e a issue/spec original. Junta três revisores independentes num só passo — dois eixos de qualidade (padrões da casa + aderência ao pedido) e um fiscal que prova cada item da checklist rodando os testes e injetando defeito. Acionada só pelo usuário com /build-review. Não use pra planejar nem construir, nem quando ainda não há checklist.
disable-model-invocation: true
license: os textos em references/ são cópias verbatim — Matt Pocock (CC-BY-4.0, github.com/mattpocock) e a skill implement (Tech Leads Club, CC-BY-4.0)
---

# Build Review — três revisores sobre o mesmo diff

**Onde entra no fluxo:** roda depois de `/gpt-builder` — que já deixa a checklist `.checks/<feature>.md` e o diff prontos. É o pente-fino final; não planeja nem constrói.

## O que é

Um maestro. Ele **não revisa com texto próprio**: dispara três subagentes independentes sobre o mesmo diff e junta os relatórios sem misturá-los. Os textos que cada subagente segue são cópias verbatim, em `references/` — este arquivo só conduz.

Os três revisores respondem perguntas diferentes, e por isso não se substituem:

- **Standards** (`references/matt-code-review.md`, eixo Standards) — o código segue os padrões documentados da casa + a base fixa de "maus cheiros"? É palpite, não veredito.
- **Spec** (`references/matt-code-review.md`, eixo Spec) — o código faz o que a issue pediu? Falta algo, sobrou algo, ou implementou errado?
- **Fiscal** (`references/verify.md`) — cada item da checklist está *provado*? Roda a prova, confere a asserção, e **injeta defeito** pra provar que os testes pegam uma regressão. Devolve PASS/FAIL.

Por que os três juntos: um modelo esperto acha bugs sozinho, mas de forma não-determinística e sem os dentes. Standards e Spec pegam o que o Fiscal não olha (qualidade e escopo); o Fiscal pega o que eles não tocam (prova executável, item a item, à prova de teste decorativo).

## Roda na sessão principal

Os três SÃO subagentes, e subagente não abre subagente. Quem dispara e junta é a **sessão principal**. Se você está dentro de um subagente, pare e devolva pra sessão.

## Antes de tudo: as entradas (portão)

Reúna uma vez, e reparta pra cada revisor a fatia que o texto dele pede:

| Entrada | Quem usa | Como obter |
|---|---|---|
| Ponto fixo `<base>..HEAD` | os três | `git log --oneline`; confirme com `git rev-parse` |
| Issue / spec original | Spec, Fiscal | o caminho que o usuário deu, ou a referência no commit |
| Docs de padrão da casa | Standards | `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`/`AGENTS.md` |
| Checklist `.checks/<feature>.md` | Fiscal | a checklist que a construção deixou |

**Sem checklist, o Fiscal não tem o que provar.** Não invente uma nem deixe o Fiscal virar revisão genérica: pare e diga ao usuário que falta a checklist. Sem issue/spec, o eixo Spec e o passo 1 do Fiscal ficam sem âncora — siga com os outros e registre a ausência no relatório.

## Dispara os três em paralelo

Um subagente por revisor, no mesmo turno, cada um com o briefing **verbatim** do seu texto de referência. Não resuma o texto no prompt — aponte o arquivo e passe as entradas.

1. **Standards** — siga `references/matt-code-review.md`, eixo Standards, com a base de maus cheiros colada por inteiro (o subagente não tem outro acesso a ela).
2. **Spec** — siga `references/matt-code-review.md`, eixo Spec, com a issue/spec.
3. **Fiscal** — siga `references/verify.md` do começo ao fim, **todos os passos, incluindo a injeção de defeito**. Ele recebe a checklist, o diff, a fonte, e roda só leitura (a injeção acontece num `git worktree` isolado, nunca na árvore real).
   - **Force o perfil `standard` no mínimo** (`ui` se a feature tem telas). O `verify.md` assume `light` por padrão, e `light` pula exatamente a injeção de defeito, a enumeração de cobertura e as regras de teste — que são o motivo de existir a build-review. Diga o perfil no prompt do Fiscal; não deixe ele cair no padrão.

O Fiscal faz julgamento pesado (mutação, cobertura) — não rode ele no modelo econômico. Standards e Spec também são julgamento.

## Junta sem misturar

A saída É exatamente estes quatro blocos, nesta ordem:

```
## Standards
<relatório do subagente Standards, verbatim ou levemente limpo>

## Spec
<relatório do subagente Spec, verbatim ou levemente limpo>

## Fiscal
<veredito PASS/FAIL do Fiscal + as tabelas de evidência>

## Portão
<PASS ou FAIL — este é o veredito do FISCAL>
Standards e Spec: <nº de achados em cada, o pior de cada eixo>
```

Regras da junção, que vêm dos próprios textos-fonte:

- **O portão é do Fiscal.** Só ele faz afirmação binária (o Matt não dá veredito de propósito). Standards e Spec entram como conselho que o usuário lê — um "mau cheiro" não reprova o merge sozinho.
- **Não reordene entre blocos e não funda num placar único.** Os eixos são separados de propósito: um passa e o outro falha, e juntar esconde isso. Reporte o pior *dentro de cada* bloco, nunca um vencedor entre eles.
- **Spec e o passo 1 do Fiscal se encostam** (código×pedido vs checklist×fonte). Achado dobrado às vezes é cobertura, não erro — deixe os dois falarem.

## Erros comuns

| Erro | Por que quebra |
|---|---|
| Fundir os três numa lista única "do mais grave ao menos grave" | apaga a separação de eixos do Matt; é o que um agente sozinho faz por padrão |
| Deixar o Fiscal pular a injeção de defeito | vira uma revisão que aceita teste decorativo (verde que não prova nada) |
| Um smell do Standards reprovar o merge | o portão é do Fiscal; o Matt é conselho |
| Rodar dentro de um subagente | subagente não abre subagente; os três nascem mortos |
| Resumir os textos de `references/` no prompt | o valor está no texto verbatim; resumir é reintroduzir o buraco |

## Red flags — pare

- "Vou juntar tudo num relatório só pra ficar mais limpo"
- "Os testes já passam, não preciso injetar defeito"
- "Não tem checklist, mas dá pra o Fiscal revisar mesmo assim"
- "Rodo os três em sequência, um de cada vez" (são paralelos, e na sessão principal)
