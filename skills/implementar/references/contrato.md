# Contrato de entrega (prompt para um executor delegado)

Um contrato por **entrega inteira** — nunca por arquivo, teste ou etapa. Serve para um processo Codex (`/codex-build` usa este mesmo formato) e para um subagente do runtime. O executor começa com zero contexto: tudo que ele precisa está aqui ou em disco, por ponteiro (caminhos, números de issue, SHA), não por cópia longa. Seção vazia é sinal vermelho.

```
Você implementa UMA entrega do repo <caminho>. Trabalhe só nela. Não faça commit nem push; não crie branch; não abra outros agentes.

GOAL
Pronto quando cada item abaixo tem sua prova verde:
- <Cn - afirmação observável, copiada de .checks/<feature>.md>
- <Cm - ...>

SPEC
Fonte: <caminho da spec / ticket / issue #N>. Checklist: <.checks/<feature>.md> — itens desta entrega: <C1, C2>.
Junção acordada: <interface pública onde o teste vive>.
Ordem (TDD): para cada item, escreva o teste na junção, rode só esse arquivo e cole a saída FALHANDO; escreva o mínimo que passa e cole a saída PASSANDO; ao fim, rode <comando de tipos> e cole a saída. Não rode a suíte completa; isso é da sessão.
Se algo da spec for contraditório ou impossível, pare e devolva a dúvida em vez de escolher.

KEY PATHS
Mexer em: <arquivos/pastas permitidos>.
Não encostar em: <arquivos/pastas proibidos, migrations existentes, outras entregas>.

CONSTRAINTS
<convenções do repo que valem aqui, ex.: validação com zod como em `<arquivo>`; nada de dependência nova>.

NON-GOALS
<o que NÃO fazer mesmo que pareça útil>.

PROOF
Para cada item: <comando que roda o teste nomeado>. Cole a saída real com o código de saída.

OUTPUT
Responda exatamente com:
1. Arquivos criados/alterados (uma linha cada: caminho + o quê/por quê).
2. Saída real de cada comando, com o comando e o código de saída.
3. Decisões tomadas que a spec não fixava.
4. Dúvidas que impediram algo (ou "nenhuma").
```

## Rodada de correção

**Mesmo executor** (Codex: `resume` do `thread_id`; subagente: `SendMessage` ao `agentId`). Repita `GOAL` sem mudanças e acrescente:

```
REVIEW
O que está errado: <fato observado pela sessão ou pelo fiscal, com arquivo:linha e o comando/saída que provou>.
Plano de correção:
1. <passo>
2. <passo>
Mantém: <o que já está certo e não deve ser refeito>.
Devolva no formato de OUTPUT, incluindo a saída nova dos comandos.
```

Até duas rodadas; na terceira, a sessão assume ou para e pergunta. Trabalho que o executor fez fora da própria entrega sai do diff dela.
