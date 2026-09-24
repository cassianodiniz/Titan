# cass — pensar antes de fazer, construir com prova, conferir antes de confiar

Dez skills pra trabalhar com IA no Claude Code sem cair nas armadilhas de sempre: a IA
que sai construindo antes de entender o pedido, que diz "pronto" sem ter testado, que
inventa número de pesquisa. Cada skill resolve um desses momentos e pode ser chamada
sozinha. Serve pra qualquer projeto.

<p align="center">
  <img src="docs/como-se-encaixam.svg" width="680" alt="Como as skills se encaixam: pensar (planejar, spec-plan, auto-think), construir (implementar ou gpt-builder) e conferir (build-review), com volta ao construtor quando reprova; embaixo, as avulsas ask-me, search, gpt-optimizer e handoff.">
</p>

Detalhe passo a passo em [FLUXOGRAMA.md](FLUXOGRAMA.md).

<table>
<tr>
<th width="50%">📚 Meus estudos sobre IA</th>
<th width="50%">⚡ Extra: economia de tokens</th>
</tr>
<tr>
<td valign="top">

Estas skills nasceram de estudo, não de palpite. O comparativo que eu uso pra decidir qual modelo serve pra quê: qualidade, custo, velocidade e alucinação, com a fonte e a data de cada número.

**[Comparativo de modelos de IA, lado a lado →](https://claude.ai/artifact/UeTaqkfwazmmBcgRvtFAiM)**

</td>
<td valign="top">

Não é uma skill: é um guia que instala duas ferramentas (RTK + Ponytail) pro Claude gastar menos da sua cota. Você cola uma frase no Claude Code e ele instala sozinho, no Mac ou no Windows.

**[Como instalar a economia de tokens →](economia-tokens.md)**

</td>
</tr>
</table>

**Autoria:** Cassiano Diniz · **Co-autoria:** Thales Laray (skill `planejar`)

---

## Instalar

**1. O plugin.** No Claude Code, uma linha por vez:

```
/plugin marketplace add cassianodiniz/cass
/plugin install cass@cass
```

Reinicie o Claude Code. As skills aparecem como `/cass:planejar`, `/cass:spec-plan` etc.

**2. As ferramentas que algumas skills usam por fora.** Um comando no terminal instala o que
dá automático (Mac/Linux; no Windows, pelo Git Bash):

```bash
curl -fsSL https://raw.githubusercontent.com/cassianodiniz/cass/main/install.sh | SKIP_PLUGIN=1 bash
```

Fica manual só o que depende de conta sua: o **`codex login`** (as skills que usam o GPT), a
conta no **Exa** (a `search`) e a **GEMINI_API_KEY** (mockups da `planejar`). Detalhe item a
item no **[INSTALL.md](INSTALL.md)**.

> Nenhuma dependência trava o plugin: se faltar alguma, a skill avisa e segue do jeito que dá.

---

## Qual eu uso?

Comece pela sua situação, não pelo nome da skill.

| Quando você... | Use | O que recebe no fim |
|---|---|---|
| quer **ser entrevistado antes** de mandar uma tarefa pro agente, pra ele não sair do pedido | `/cass:ask-me` | um pedido fechado, pronto pra colar: o que fazer, o que não fazer e quando parar e perguntar |
| tem a ideia de um **produto que ainda não existe** e quer saber se vale e como fazer | `/cass:planejar` | um plano completo, com pesquisa de mercado, tecnologia e telas, já revisado |
| quer **mudar ou acrescentar algo** num projeto, ou tem uma ideia solta que precisa virar tarefas | `/cass:spec-plan` | um plano fatiado em tarefas pequenas, sem dúvida em aberto |
| tem um **problema difícil e ainda não sabe a resposta** | `/cass:auto-think` | a opção recomendada e as alternativas, cada uma com o porquê |
| tem um **plano aprovado** e quer que o Claude construa | `/cass:implementar` | o trabalho pronto e testado, salvo no seu computador |
| tem um **plano aprovado** e quer que o GPT construa, gastando menos Claude | `/cass:gpt-builder` | o mesmo resultado: o Codex constrói, o Claude confere |
| **terminou de construir** e quer uma vistoria antes de publicar | `/cass:build-review` | Aprovado ou Reprovado, com a prova de cada item |
| precisa de **pesquisa confiável**, com a fonte de cada número | `/cass:search` | os achados com página, frase e data de cada dado |
| **já decidiu algo** e quer saber se a decisão aguenta | `/cass:gpt-optimizer` | Seguir, Ajustar ou Bloquear, com os furos que procedem |
| vai **fechar a conversa** e quer continuar depois | `/cass:handoff` | um documento de passagem e um texto pronto pra colar na sessão nova |

---

## As skills parecidas: como não confundir

Algumas skills fazem trabalhos vizinhos. A diferença está no **momento** em que você está.

### Pensar: `planejar`, `spec-plan` ou `auto-think`?

- **`planejar`** é pra algo **totalmente novo**, que ainda não existe e pede pesquisa de
  mercado: quem já faz isso, pra quem é, que tecnologia usar, como vão ser as telas. É a
  mais longa das três.
- **`spec-plan`** é pra todo o resto: uma função nova num sistema que já existe, uma mudança,
  uma ideia que você já sabe o que é mas ainda não virou tarefa. Ela te entrevista até não
  sobrar dúvida e fatia o trabalho.
- **`auto-think`** é pra quando **você ainda não sabe a resposta**. Ela não planeja nem
  constrói: estuda o problema e te devolve opções com veredito. Escolhida a opção, o próximo
  passo é a `spec-plan`.

### Construir: `implementar` ou `gpt-builder`?

As duas entregam a mesma coisa, com a mesma régua de qualidade: uma lista do que foi
prometido, a prova de cada item, testes e o trabalho salvo no seu computador. Nada vai pro
GitHub sem o seu OK. Muda só **quem digita o código**:

- **`implementar`**: o próprio Claude constrói. É o caminho padrão e funciona tanto no
  Claude Code quanto no Codex.
- **`gpt-builder`**: o Claude planeja e confere, o Codex (GPT) constrói. É como ter um gerente
  e um pedreiro: fica **mais barato** porque o trabalho pesado sai da cota do Claude. Exige o
  Codex instalado e logado.

### Conferir: `gpt-optimizer`, `auto-think` ou `build-review`?

- **`gpt-optimizer`**: a decisão **já está tomada** e você quer testá-la antes de agir. O GPT
  tenta derrubar. Leva minutos.
- **`auto-think`**: a pergunta **ainda está aberta**. Estudo completo, com pesquisa. Leva
  bem mais tempo.
- **`build-review`**: o trabalho **já foi construído** e vai ser publicado. Três revisores
  conferem o resultado, não a ideia.

---

## As dez skills

Cada linha: o que faz em português claro, e o detalhe técnico pra quem programa.

**`/cass:ask-me`** — Antes de mandar uma tarefa, a skill te entrevista em rodadas curtas
(no máximo 4 perguntas, cada uma com a resposta que ela recomenda) até os dois entenderem
a mesma coisa. A cada rodada confere se alguma resposta nova bate com um limite que você
já deu. No fim, entrega o pedido pronto pro agente. Não executa nada sem o seu sim.
<br/>*Técnico:* árvore de decisões resolvida por fronteira; fatos do ambiente ela busca sozinha; pedido final com Objetivo / Pronto quando / Fazer / NÃO fazer / Parar e perguntar.

**`/cass:planejar`** — Você conta a ideia de um produto novo e a skill conduz em etapas:
pesquisa de mercado, o que o produto precisa fazer, qual tecnologia usar, como vão ser as
telas e um plano de construção revisado por outros agentes. Você aprova cada etapa. Não
escreve código.
<br/>*Técnico:* 9 fases com portão de aprovação; requisitos em EARS; stack com viés Cloudflare; auditoria multiagente; entrega plano + `features.json`.

**`/cass:spec-plan`** — Transforma uma mudança ou ideia em um plano com tarefas pequenas.
Pergunta em rodadas curtas, sempre com opções e uma recomendação, até não sobrar dúvida.
No fim, oferece construir com `implementar` ou `gpt-builder`.
<br/>*Técnico:* spec + issues autocontidas em `docs/plans/<plano>/issues/`; cenários de comportamento; varredura dos "9 esquecidos" (validação, falhas, idempotência...).

**`/cass:auto-think`** — Estuda um problema sem resposta pronta: pesquisa com fonte, ataca
por vários ângulos e manda o GPT tentar derrubar cada ideia, duas vezes. Volta com a
recomendada e as alternativas. Não executa nada. Antes de mandar qualquer coisa pra fora,
troca nomes e dados pessoais por etiquetas.
<br/>*Técnico:* confronto adversarial com Codex `gpt-6-sol` em 2 rodadas; pesquisa via `search`.

**`/cass:implementar`** — O Claude constrói um plano já aprovado, uma tarefa por vez: escreve
a lista do que foi prometido com a prova de cada item, testa e salva no seu computador. Um
fiscal independente confere as provas.
<br/>*Técnico:* TDD vermelho→verde; checklist em `.checks/` com teste nomeado por item; commits na branch atual; push e PR só com OK.

**`/cass:gpt-builder`** — Mesmo trabalho do `implementar`, mas quem constrói é o Codex. O
Claude escreve a ordem de serviço, lê tudo o que o Codex fez como se fosse revisar o trabalho
de um colega, e só salva o que passou na prova.
<br/>*Técnico:* `codex exec` com `gpt-6-sol` esforço `medium`; fiscal prova cada item no HEAD; até 2 rodadas de correção antes do Claude assumir.

**`/cass:build-review`** — Vistoria final antes de publicar. Três revisores que não conversam
entre si: um confere as regras do projeto, outro se o que foi pedido foi feito, e um fiscal
prova cada item da lista, inclusive estragando o código de propósito pra ver se os testes
percebem.
<br/>*Técnico:* 3 subagentes (Standards, Spec, Fiscal) sobre `<marco>..HEAD`; injeção de defeito em `git worktree`; o veredito é do Fiscal.

**`/cass:search`** — Pesquisa na internet sem número inventado: cada dado volta com a página,
a frase exata e a data em que foi lido. O que não achar, ela diz que não achou. Guarda tudo
numa pasta do projeto.
<br/>*Técnico:* orquestrador Exa com subagentes; registro de procedência por número; arquivo em `search-findings/`. Precisa de conta Exa (tem plano grátis).

**`/cass:gpt-optimizer`** — Segunda opinião sobre uma decisão que você já tomou. O GPT recebe
uma ordem: tentar derrubar. Volta com Seguir, Ajustar ou Bloquear e só os furos que
procedem. Só roda quando você chama.
<br/>*Técnico:* Codex `gpt-6-sol` esforço `high`, só leitura; a 2ª rodada audita o seu filtro dos pontos.

**`/cass:handoff`** — A conversa ficou longa e você quer continuar depois. A skill escreve um
documento de passagem com o que foi decidido, o que falta e onde estão as coisas, separando
fato de suposição, e te dá um texto pronto pra colar na sessão nova.
<br/>*Técnico:* ancorado em git; cada afirmação marcada `[GIT]`/`[ARQUIVO]`/`[CHAT]`/`[SUPOSIÇÃO]`; leitor cego opcional via Codex.

---

## Requisitos, em uma linha cada

- **Claude Code** — onde as skills rodam.
- **Codex CLI** (≥ 0.156, com `codex login`) — `gpt-builder`, `gpt-optimizer`, `auto-think` e o leitor cego do `handoff`. Sem ele, essas skills avisam e o Claude assume o papel, com garantia menor.
- **Exa** — a `search` (e a pesquisa de quem chama a `search`).
- **git** — `implementar`, `gpt-builder` e `build-review` trabalham num repositório git.

Histórico de versões em [CHANGELOG.md](CHANGELOG.md).
