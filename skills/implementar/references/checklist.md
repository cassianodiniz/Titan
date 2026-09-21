# Checklist de itens (`.checks/<feature>.md`)

Escrito **antes de qualquer código**, depois de ler a fonte inteira (spec, ticket, issue, thread) e andar pelo código que ela toca, para que os itens caiam em caminhos reais e reaproveitem o que já existe. É a barra da construção: os itens não mudam enquanto se constrói. Baixar a barra é renegociação com o usuário, visível no diff — nunca um ajuste silencioso.

## Recuse em vez de chutar

Um item só entra quando as três coisas são verdadeiras:

- **Prova nomeável** — dá pra dizer qual teste ou comando decide o item, com código de saída. Não sabe qual? Está vago demais pra escrever.
- **Valor concreto** — um código de status, um campo, um limite numérico. Nunca "corretamente", "de forma adequada", "rápido".
- **Limite dito** — dá pra afirmar o que fica explicitamente fora.

Faltou uma → pergunte (perguntar é barato). Continua vago depois de perguntar → nomeie o que falta e pare ali. O motivo: item vago vira teste vago que passa, e esse é o único erro que este arquivo existe pra impedir.

**Prova nomeia um teste, não uma suíte.** `npm test` verde não diz nada sobre *este* item. Se um teste não cobre o item inteiro, liste mais de uma `Prova:`; todas precisam ficar verdes. Antes de escolher a prova, descubra os comandos reais no manifesto, task runner e CI; prefira o que já roda no CI. Não existe comando pro que o item precisa → pergunte, nunca invente: prova que não roda é pior que nenhuma.

## Varredura dos 9 esquecidos

Requisitos que ninguém escreve na spec. Passe por cada um e diga **onde caiu** — item `Cn`, "já existe em `<arquivo>`", ou "fora de escopo porque X". Os três são respostas completas; passar em silêncio não é.

1. validação de entrada
2. modos de falha (o que acontece quando dá errado)
3. idempotência e retry (repetir a mesma ação não duplica)
4. autorização (quem pode)
5. concorrência e ordem
6. ciclo de vida do dado (criação, retenção, remoção)
7. falha de dependência externa
8. transições de estado
9. observabilidade (log, métrica)

Levantar um é sempre grátis; crescer o escopo é decisão do usuário.

Quando a issue já traz a seção `Varredura (decidida na entrevista)`, parta dela: confira cada linha contra o código e pergunte só o que ela não cobriu — o usuário já respondeu o resto.

## Formato

Escreva `.checks/<feature>.md` no formato canônico: [Checklist format](../../build-review/references/checklist-format.md) — é o mesmo arquivo que o `$build-review` lê (`Sources`, `Out of scope`, `Landing`, `Checks`, `Swept`, `Coverage`). Abra-o só depois de passar pelo "Recuse em vez de chutar" e pela varredura acima; o resultado da varredura dos 9 vai na seção `Swept`.

## Handoff (só quando a construção troca de agente ou de sessão)

Quem continua lê o checklist e o **diff do que já entrou** — nunca um resumo narrado. Acrescente três linhas nesta seção antes de passar: onde a fronteira caiu (itens fechados + commit); o que o usuário decidiu no meio (clarificações que não viraram item); o que foi tentado e abandonado, e por quê. É o que nem o código nem o checklist preservam.

Os itens agrupam sob as fatias de onde vieram (uma fatia = um resultado observável); numeram-se direto (`C1..Cn`) porque o contrato de cada fatia e o fiscal se referem a eles pelo número.

Escrito o checklist, siga pra fatiar e construir. O commit-marco de início (`chore(checks): start <nome deste arquivo, sem .md>`) já foi feito antes deste arquivo existir, como manda o SKILL.md; este checklist entra num commit depois dele. Esperar aprovação por padrão não compra nada quando a fonte já foi decidida e o checklist só a reescreve com prova. Pare só pelo que o usuário sozinho decide: escopo que a varredura levantou e que cresceria o trabalho; o que o "recuse em vez de chutar" pegou e perguntar não resolveu.
