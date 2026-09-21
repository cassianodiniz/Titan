# Fase 2 — Spec, issues e handoff

Use apenas as decisões confirmadas na Fase 1. Não reabra escolhas fechadas; se surgir uma lacuna que muda escopo, comportamento ou seam de teste, volte ao usuário antes de concluir o rascunho.

## 1. Escrever a spec-mãe

Produza uma visão única do plano com:

- **Problema:** situação do usuário e resultado desejado.
- **Solução:** comportamento proposto, sem transformar a spec em código.
- **Histórias e cenários:** necessidades numeradas e cenários Given/When/Then para fluxos, falhas, permissões e transições relevantes.
- **Decisões de implementação:** módulos ou interfaces afetados, contratos, schema e integrações; evite caminhos de arquivo e snippets que envelhecem, salvo quando um protótipo registrou uma decisão melhor que prosa.
- **Decisões de teste:** seams aprovados, precedentes existentes e comandos reais já conhecidos.
- **Fora de escopo:** exclusões explícitas.
- **Notas:** riscos, migração, rollout e pontos ainda `UNKNOWN` que não impedem o fatiamento.

Use o vocabulário do domínio e respeite ADRs do projeto.

## 2. Fatiar em issues executáveis

Quebre a spec em tracer bullets verticais:

- cada issue entrega um comportamento completo e verificável através das camadas necessárias;
- cada issue cabe em uma sessão nova de contexto;
- cada issue declara os bloqueadores reais;
- issues sem bloqueadores formam a fronteira disponível para implementação paralela;
- prefatoração necessária vem primeiro;
- refatoração ampla usa expandir → migrar em lotes verdes → contrair, com dependências explícitas.

Cada issue deve ser autocontida. Quem receber somente seu arquivo precisa saber o que construir, por que, como observar que terminou, quais decisões já foram tomadas e o que não está autorizado.

Use este formato:

```markdown
# <issue-key> — <título>

**Status:** draft | approved | published
**Plano-pai:** <caminho do index.md>
**Tracker:** <URL/ID ou "não publicado">
**Bloqueada por:** <issue-keys ou "nenhuma">

## Resultado
<comportamento completo entregue por esta fatia>

## Cenários e critérios de aceite
- [ ] <resultado observável e concreto>

## Decisões de implementação
- <contrato ou decisão já aprovada>

## Contrato de teste
- Seams aprovados: <interfaces públicas>
- Provas conhecidas: <comandos reais ou UNKNOWN>

## Varredura (decidida na entrevista)
- <cada um dos 9 que toca esta issue>: <critério de aceite acima | já existe em … | fora de escopo porque …>

## Fora de escopo
- <limite desta issue>
```

## 3. Aprovação antes de qualquer efeito

Mostre ao usuário a spec-mãe e o conteúdo integral de cada arquivo de issue proposto, incluindo decisões, contrato de teste e fora de escopo. Acrescente uma tabela curta com título, resultado e bloqueadores para facilitar a visão do conjunto, mas não use o resumo no lugar dos arquivos completos. Peça aprovação sobre:

1. conteúdo da spec;
2. granularidade das issues;
3. dependências e fronteira paralela;
4. seams de teste;
5. autorização para salvar esses artefatos locais nos caminhos mostrados.

Itere até o usuário aprovar. Antes da aprovação, não grave arquivos, não crie issues e não aplique labels.

A aprovação precisa incluir autorização explícita para persistir os artefatos locais nos caminhos mostrados. Ela **não** autoriza publicação externa. Para GitHub, Linear ou outro tracker, peça autorização explícita informando destino, quantidade de issues e labels; dispense nova pergunta somente quando o usuário já tiver autorizado esses elementos de forma inequívoca.

## 4. Persistência sem colisões

Nunca use `PLAN.md` na raiz. Detecte primeiro a convenção existente do repositório; na ausência dela, use:

```text
docs/plans/<plan-id>/index.md
docs/plans/<plan-id>/issues/<issue-key>-<slug>.md
```

O `<plan-id>` precisa ser único e estável:

- com issue-pai real: `<tracker>-<id>-<feature-slug>`;
- sem issue-pai: `<YYYYMMDDTHHMMSSZ>-<feature-slug>`.

O `index.md` contém a spec-mãe, o grafo de dependências e links para as issues. Ele é contexto, não uma unidade de implementação.

Cada arquivo em `issues/` contém exatamente uma issue. Use como `<issue-key>` uma chave local estável (`01`, `02`, `03`) em ordem de dependência; registre o ID real do tracker dentro do arquivo, sem renomeá-lo depois da publicação. Não reutilize diretório de outra sessão e não sobrescreva artefato existente; em colisão, gere outro `plan-id`.

Se a publicação externa for autorizada, crie as issues em ordem de dependência, registre URLs/IDs nos arquivos locais e use relações nativas de bloqueio quando existirem. Caso contrário, os arquivos locais são as issues canônicas. Nunca feche ou modifique uma issue-pai existente sem autorização específica.

## 5. Handoff para implementar uma issue

Liste as issues da fronteira atual e peça ao usuário que escolha a próxima. Depois da escolha, ofereça somente um comando:

```text
$implementar SPEC_FILE="docs/plans/<plan-id>/issues/<issue-key>-<slug>.md"
```

Uma invocação implementa uma issue. O fluxo padrão é sequencial: só ofereça outra issue depois que a atual sair da fronteira ou for concluída.

Se o usuário pedir implementação paralela, não presuma isolamento. Só ofereça vários handoffs quando cada sessão já tiver checkout/worktree e branch próprios e o artefato aprovado estiver disponível numa base compartilhada; caso contrário, explique o pré-requisito e mantenha o fluxo sequencial. Nunca passe `index.md`, o diretório do plano ou vários arquivos na mesma invocação.

Depois da implementação, `$build-review` usa o mesmo arquivo da issue como fonte original, junto da checklist exclusiva e do diff deixados pela `$implementar`. A `spec-plan` não chama nenhuma dessas skills automaticamente; apenas oferece o próximo passo.
