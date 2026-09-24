---
name: handoff
description: "Use quando o usuário disser /handoff, \"gera um handoff\", \"vou limpar o contexto\", \"passa isso pra uma sessão nova\", \"documento de continuação\", \"resume pra eu continuar depois\", \"tô chegando no limite de contexto\", ou quando uma conversa longa vai terminar e ele quer retomar o trabalho — ou começar do zero algo que surgiu nela — numa sessão nova, sem o histórico da conversa."
---

# Handoff — passagem de bastão entre sessões

Você escreve um documento para um você do futuro que abre uma sessão limpa, sem nada desta conversa. Quando a sessão fecha, a conversa some; sobrevive o que está em disco e no git. Por isso o handoff se ancora num commit e aponta arquivos, e só copia do chat o que não existe em disco. Não é resumo: é o estado de agora, com fato separado de suposição.

Se a sessão já foi compactada, diga isso no documento ("parte da conversa pode ter se perdido na compactação").

## Passo 0 — Trava do git

Rode `git status --short` (e `git log -1 --oneline`, `git branch --show-current`).

**Algum arquivo que esta conversa criou ou alterou aparece sem commit?** Pare aqui, sem escrever o handoff. Diga ao usuário quais são esses arquivos, proponha a mensagem de commit e pergunte se pode commitar. Gere o handoff só depois do commit. Motivo: o handoff aponta um commit; trabalho fora dele pode se perder ou se misturar com outra frente, e a sessão nova não teria como conferir o ponto de partida.

Arquivos na lista que esta conversa nunca tocou são de outra frente: não travam, não entram no commit e aparecem no handoff numa linha "fora deste trabalho".

Pasta sem git: não há trava; registre o `pwd` e diga que a validade depende dos arquivos de hoje.

## Qual âncora

- **Continuar o mesmo trabalho** (o padrão): âncora = ramo atual + hash do HEAD.
- **Começar do zero algo que surgiu** (o usuário diz que o trabalho atual acabou — PR mergeada, "do zero", "outra coisa"): âncora = ramo principal. Registre o hash dele (`git rev-parse --short main`, ou `origin/main` depois de `git fetch` se houver remoto). O handoff manda a sessão nova atualizar o principal e abrir ramo novo a partir dele. O trabalho encerrado entra em uma linha de contexto, não como pendência.

## Regras de escrita

1. Varra a conversa inteira. Decisão do começo que nunca foi revogada ainda vale; decisão revista vale na forma final.
2. Copie literal valor, caminho, comando, número, regra de negócio. Parafrasear é como se inventa o que não foi dito.
3. Marque a origem: `[GIT]` / `[ARQUIVO]` / `[CHAT]` / `[SUPOSIÇÃO]`. `[GIT]` e `[ARQUIVO]` exigem ponteiro que a sessão nova reabre e confirma (`arquivo:linha` no HEAD, ou comando + saída). Palpite seu — inclusive um que já virou código — é `[SUPOSIÇÃO]`, nunca restrição.
4. Decisão que só viveu no chat vai copiada com o porquê; ponteiro para arquivo que não existe é informação perdida.
5. Segredo (token, senha, chave) nunca entra no handoff: aponte onde ele mora (ex.: `.env`).
6. Corte o que já foi resolvido, a menos que vire restrição para o que vem.
7. Buraco real vira pergunta em "O QUE NÃO SEI". Gap nomeado vale mais que gap preenchido com chute.

## Estrutura

Estes títulos, nesta ordem. Seção vazia: "Nada relevante".

```
Leia [arquivos essenciais]. Depois continue o trabalho descrito abaixo.

## OBJETIVO
[1-2 frases.]

## ÂNCORA
- Gerado em: [data hora] · Pasta: [raiz do repo]
- Modo: continuar | trabalho novo a partir do principal
- Ramo: [ramo] · Commit: [hash + mensagem]
- Fora deste trabalho (sem commit, não mexer): [arquivos, ou "nada"]

## ESTADO AGORA
[O que existe e funciona, com origem marcada.]

## DECISÕES (e por quê)
Já em arquivo/commit: 1 linha — `decisão — porque X [ponteiro]`.
Só no chat: **Decisão** · **Por quê** (o problema e o que venceu) · **Descartado** (o que não fazer).

## JÁ TENTADO E NÃO DEU
## RESTRIÇÕES FIRMES
[Só as que o usuário disse (fala literal) ou que estão no código (arquivo:linha).]
## ARQUIVOS-CHAVE
- `caminho` — pra que serve
## O QUE NÃO SEI / CONFIRMAR
## PRÓXIMOS PASSOS
1. [Verbo + ação verificável]
## COMO SABER QUE DEU CERTO

## COMO RETOMAR
1. Continuar: `git log -1 --oneline` e `git status --short` devem bater com a ÂNCORA. Trabalho novo: atualize o principal, confira que ele contém o commit da ÂNCORA e abra ramo novo. Não bateu → diga ao usuário o que mudou antes de seguir.
2. Leia os ARQUIVOS-CHAVE e confirme cada ponteiro das RESTRIÇÕES. Arquivo de hoje vence o documento.
3. Rode [comando de estado: testes / build].
4. Siga os PRÓXIMOS PASSOS.
```

Antes de salvar, releia e tire a linha que repete o resolvido, afirma como regra o que foi dedução, ou aponta arquivo que não existe.

## Entrega

1. Salve em `<raiz-do-repo>/.claude/handoffs/handoff-<ramo>-AAAA-MM-DD-HHMMSS.md` (troque `/` do ramo por `-`); sem git, `~/handoffs/handoff-AAAA-MM-DD-HHMMSS.md`. O arquivo não entra em commit.
2. No chat, um bloco de código colável, sem nada para preencher:
   ```
   Leia o handoff em <caminho ABSOLUTO> e continue o trabalho descrito nele: <objetivo em 1 linha>.

   Antes de tocar em qualquer coisa, faça o COMO RETOMAR do handoff. Só depois siga os PRÓXIMOS PASSOS.
   ```
3. Uma linha abaixo com o caminho salvo. Não cole o documento no chat. Se nenhum local for gravável, aí sim mostre o documento inteiro num bloco e avise.
