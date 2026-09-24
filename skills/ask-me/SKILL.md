---
name: ask-me
description: Use when user invokes /ask-me, or asks to be interviewed before a task ("me pergunta antes", "me entrevista", "vamos alinhar o que eu quero"), especially before handing work to an agent that tends to drift or overdo what was asked.
---

# /ask-me

Interview the user relentlessly until you reach a shared understanding. Map this as a design tree: every decision branches into the decisions that hang off it.

## Rounds

Work the tree in rounds. The frontier is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you haven't heard yet. Number each question and give your recommended answer. Then wait for the user's answers before the next round.

A round has at most 4 questions. If the frontier is bigger, ask the 4 whose answers unblock the most of the tree; the rest go to the next round. A decision with an obvious default is not a question: state it as an assumption in one line under the round, and the user corrects it only if wrong.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one. A settled decision is not asked again unless the user reopens it.

From the second round on, every round opens with a check: list each limit the user already set ("nada", "nunca", "só", "fixo", "sem", "fica como está") and, next to it, whether any new answer touches it (✓ or ⚠️). Read limits literally: "nada pode ser apagado" covers empty folders too. When unsure, mark ⚠️ — asking costs one line. Each ⚠️ becomes a question naming both and asking which holds. Before adding any other question to a round with a ⚠️, ask yourself: "if the user picks option a (keep the old rule), does this question still make sense?" If not, it waits for the next round.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment, repository, tools, or other available sources, find it yourself; don't ask the user for anything you could look up once access is available. Don't block on it: an unresolved fact is an unsettled prerequisite, so only the questions downstream of it wait; ask the rest of the frontier now. The decisions are the user's: put each to them and wait.

Simplicity must never remove required behavior, input validation at trust boundaries, error handling needed to prevent data loss, security requirements, accessibility basics, or anything explicitly agreed with the user.

Write the questions in Portuguese, in plain words (the user is not a programmer).

## Round format

```
Conferi com o combinado:
 ✓ "<limite 1>"
 ⚠️ "<limite 2>" × "<resposta nova>"

⚠️ Antes você disse "<decisão anterior>", agora "<resposta nova>". Qual vale?
 a) <a anterior>
 b) <a nova>
 c) <as duas, combinadas assim: …>
 ✅ <letra> — <por quê>

📝 1 - <pergunta>
 a) <opção>
 b) <opção>
 c) <opção>
 ✅ <letra recomendada> — <por quê, em uma frase>

📝 2 - <pergunta>
 a) <opção>
 b) <opção>
 ✅ <letra recomendada> — <por quê, em uma frase>

Assumindo (corrija se estiver errado): <padrões óbvios, uma linha cada>
```

The user can answer in short form ("1a 2c") or in their own words.

## Closing

When the frontier is empty and no ⚠️ is open, ask one last question, in a message of its own (after the check, if any):

```
📝 Fechamos? Quer que eu transforme isso no pedido pronto pro agente?
 a) Sim, pode gerar
 b) Antes, quero ajustar alguns pontos
 c) Quero só revisar o entendimento comigo primeiro
 ✅ <a if nothing is pending; otherwise b, naming what is pending>
```

The closing question goes alone and ends the message; the brief comes only after the user answers "a" to it. A "pode fechar" said earlier means it's time to ask the closing question, not to skip it. Then deliver it in one block, ready to paste to the agent. Every item comes from an answer or a stated assumption the user did not correct: if you can't point to where the user said it, it stays out.

```
Objetivo: <o que é pra fazer, em uma frase>
Pronto quando: <linha de chegada verificável>
Fazer: <o que foi decidido, em tópicos>
NÃO fazer: <lista específica do que ficou de fora — itens concretos, não "não exagere">
Parar e perguntar: sempre que surgir uma decisão que não está neste pedido, antes de algo irreversível, e quando não der pra seguir sem mim. Na dúvida, pergunte.
Antes de começar: diga em uma linha o que vai fazer.
Se tomar alguma decisão que não está neste pedido, diga em uma linha em que se baseou.
Ao terminar: um resumo curto do que fez; marque o que não conseguiu confirmar e diga onde procurou.
```

If the task depends on information spread across several places (Drive, WhatsApp, e-mail, spreadsheets), add this line before "Parar e perguntar":

```
Antes de mexer em qualquer coisa: olhe tudo que pode ser relevante (<os lugares desta tarefa>), inclusive o que o pedido não cita. Se o que encontrar contradisser este pedido, pare e me pergunte.
```

Right after the brief, in the same message, end with one execution question. Pick it with this check: does the brief change code in a repository **and** its "Fazer" list name two or more separate features (for example: login, a trash bin and an export)?

- **No** (one feature, a small edit, or any task outside code: files, spreadsheets, messages, research): ask "Executo aqui agora?"
- **Yes**: ask the question below, because an agent that builds several features in one go tends to skip steps, and /spec-plan slices them into tasks built and tested one at a time:

```
Executo aqui agora, ou levo pra /spec-plan fatiar em tarefas?
 a) Executa aqui
 b) Leva pra /spec-plan
```

Execute only on a yes (or a). On b, invoke /spec-plan and hand it the brief as its input.
