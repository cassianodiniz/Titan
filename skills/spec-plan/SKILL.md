---
name: spec-plan
description: Use quando o usuário invocar explicitamente /spec-plan, $spec-plan ou @spec-plan para transformar uma ideia ou mudança ainda não fechada em um plano executável. Não use quando o trabalho já estiver decidido nem para implementar.
disable-model-invocation: true
---

# Spec Plan

Transforme a ideia em issues aprovadas, cada uma autocontida e pronta para uma sessão separada de `$implementar`.

Siga duas fases, nesta ordem. Leia cada referência somente quando a fase começar:

1. **Investigar:** leia `references/phase-1-investigate.md`. Feche escopo, decisões e seams de teste antes de pedir a confirmação de entendimento compartilhado.
2. **Planejar e fatiar:** depois da confirmação, leia `references/phase-2-spec.md`. Produza a spec e as issues, mostre tudo ao usuário e espere aprovação antes de gravar ou publicar.

Invariantes:

- Nunca implemente a feature.
- Nunca publique externamente sem autorização explícita para o destino exato.
- Nunca use um `PLAN.md` compartilhado. Cada plano tem diretório próprio e cada issue tem um único arquivo de implementação.
- O handoff para `$implementar` aponta para exatamente um arquivo de issue, nunca para o índice ou para o diretório inteiro.
