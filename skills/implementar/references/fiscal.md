# Fiscal independente (subagente fresco de verificação)

**Objetivo:** uma resposta independente a "cada item foi realmente provado?", escrita como evidência, não como opinião.

Quem construiu não fiscaliza: re-checar o próprio trabalho reaplica o raciocínio que produziu a falha. Por isso o fiscal é um **subagente fresco** (sem contexto herdado da construção — mas com os requisitos), despachado pela **sessão** depois do último commit da rodada — nunca por um construtor delegado, nunca como filho de um. A sessão pode despachá-lo mesmo quando ela própria construiu. Ele recebe o checklist, o intervalo do diff (`<SHA base>..HEAD`), a fonte original e este arquivo. Roda **só leitura** e não conserta nada. O veredito volta pra sessão e pro usuário, nunca pro construtor.

O trabalho é estreito (rodar prova, localizar asserção, comparar com o checklist), então roda no modelo econômico do runtime. Estreito não é cego: decidir se uma asserção corresponde ao item ainda é julgamento — só que sobre uma pergunta pequena.

Não é opcional e não espera ser pedido: é o que separa "pronto" de um auto-relato. Ele não substitui a revisão geral (`/build-review`): o relatório diz "provas verificadas; revisão geral pendente" enquanto ela não rodar.

## Briefing (prompt do fiscal)

```
Você é o fiscal independente de uma feature no repo <caminho>. Não escreveu nada dela e não vai consertar nada. Só leitura.

Checklist: <caminho de .checks/<feature>.md>
Diff: git diff <SHA base>..HEAD
Fonte original: <caminho da spec / ticket / issue>

Primeiro, abra a fonte original e compare com o checklist: há alguma determinação explícita da fonte que o checklist OMITE ou CONTRARIA (ex.: fonte exige retenção de 30 dias, checklist fixa 7)? Isso é comparação com requisitos, não revisão do produto. Contradição ou omissão é achado, mesmo com todas as provas verdes.

Para CADA item Cn do checklist:
1. Rode a prova você mesmo, em HEAD. Nunca aceite relato de que já rodou. Uma invocação por alvo (vários arquivos/nomes numa chamada só), desde que cada teste nomeado apareça na saída como rodado e aprovado. "Suíte verde" não decide item nenhum.
2. Confirme que o teste nomeado EXISTE e RODOU (`rg -n` com contexto). Filtro que não casa nada sai com código 0 em vários runners — isso seria item verde sem teste atrás. Nome que não aparece na árvore é achado, não detalhe.
3. Cite `arquivo:linha` e reproduza a expressão da asserção que decide o item. A asserção precisa mirar o valor que o CHECKLIST define, não apenas existir. Não vá ler fixtures/setup/helpers: a expressão é a evidência inteira. Valor esperado construído longe da asserção = achado sobre o teste, não pesquisa que você deve.
4. Sem `arquivo:linha` localizado = item NÃO provado. Uma citação nunca vale por vários itens. Procure antes de concluir ausência, e mostre a busca.
5. A pergunta é se a prova EXERCITA o comportamento exigido, não se o teste aparece no diff. Um teste de regressão preexistente que falhava antes e passa depois da correção é evidência válida; quando o item afirma correção de bug, o resultado antes/depois sustenta. Item vago no checklist = registre "lacuna de precisão", não aprove asserção vaga.

Leia as linhas da Varredura que dizem "já existe em <arquivo>" contra o código: a restrição citada está lá mesmo? Não está = achado. Linhas "fora de escopo" são política aprovada; nada a conferir.

Escreva `.checks/<feature>.verificado.md` começando pelo veredito:

# <Feature> - Verificação
**Veredito**: PASS | FAIL
**Diff**: <SHA base>..<head>
**Rodada**: 1 - completa
**Fiscal**: subagente independente (autor != fiscal)
**Escopo**: provas verificadas; revisão geral (/build-review) pendente

## Fonte x checklist
| Determinação da fonte | No checklist? | Omitida / contrariada |

## Itens
| Item | Afirmação | Prova rodada | Evidência | Resultado |
|---|---|---|---|---|
| C1 | ... | `<comando>` exit 0 | `arquivo:linha` - `<asserção>` | PASS |

## Varredura "já existe"
| Linha | Arquivo citado | Está lá? |

## Portão
<comando da suíte> - N passaram, 0 falharam

Devolva no chat: PASS ou FAIL, itens provados de N, e a lista de lacunas em ordem de gravidade. Não conserte nada.
```

## O que reprova

Qualquer item sem `arquivo:linha`, teste nomeado que não existe, prova que só passou em commit anterior, asserção que não mira o valor do checklist, restrição "já existe" que não está lá, determinação da fonte omitida ou contrariada pelo checklist. Um FAIL volta pra sessão, que roteia a correção (mesmo executor, ou ela própria) e despacha o fiscal de novo — **no máximo três rodadas** antes de parar e escalar ao usuário.

## Rodada seguinte (depois de uma correção)

Escopo: o diff da correção e todo veredito que não foi PASS. O resto carrega adiante, marcado `carregado de <sha>`; o cabeçalho diz `Rodada: 2 - parcial`. Provas sempre rodam de novo em HEAD (verde é propriedade de um commit). Escopo pelo diff, não pela intenção da correção: mexer num helper, fixture ou config tem raio maior que a descrição.
