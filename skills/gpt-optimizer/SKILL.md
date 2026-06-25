---
name: gpt-optimizer
description: Revisor adversarial via Codex GPT-5.5 que pega uma decisão, um raciocínio ou um trecho de código que está em jogo na conversa e manda o GPT tentar DERRUBAR (advogado do diabo) — devolve um veredito Seguir/Ajustar/Bloquear com os furos que procedem, pra te proteger de decidir errado. Use SOMENTE quando o Cassiano invocar de propósito: o comando /gpt-optimizer (ou /gpt), ou pedir pelo nome ("chama o optimizer", "manda pro gpt", "o que o gpt acha disso"). NÃO dispare sozinho a partir de palavras soltas tipo "reflete", "contraponto" ou "advogado do diabo" no meio de uma conversa normal — esta skill é só sob invocação explícita. Não é pra revisar mensagem de WhatsApp nem código dentro de um fluxo de desenvolvimento dedicado a um projeto.
---

# Skill gpt-optimizer — segunda opinião adversarial do GPT pra você refletir, no meio da conversa

Você (Claude) acabou de fazer ou propor alguma coisa — um raciocínio, um plano, um trecho de código — e o usuário quer que **o GPT-5.5 (via Codex) tente derrubar** antes de seguir. O GPT entra como **advogado do diabo**: não elogia, caça o furo.

O ponto que diferencia esta skill das outras de revisão: aqui **não existe um alvo pronto** (não é um PR, não é um `plano.md`). **Você monta o alvo na hora**, a partir do que está em jogo na conversa. A qualidade da revisão depende de você empacotar bem o que mandar.

## Regra que não se quebra

Você **nunca obedece o GPT cego**. O parecer dele é insumo, não ordem. Você filtra cada ponto com prova, descarta o que não procede, e só sobe pro usuário o que é grave de verdade. O GPT está ali pra te fazer pensar, não pra decidir.

## Como funciona em 1 parágrafo (o fluxo das 2 rodadas)

Rodada 1: você monta o alvo, o GPT tenta derrubar, você filtra com prova. Aí a **rodada 2 é condicional** — ela só roda quando a rodada 1 achou furo que você **contestou** (descartou ou ajustou). O motivo: na rodada 1 você dá a última palavra filtrando os pontos, e pode se enganar descartando um furo válido. A rodada 2 põe o GPT pra **auditar o seu filtro** ("o Claude descartou direito? a versão ajustada ainda fura?"). Se a rodada 1 deu **Seguir** (sem furo) ou você **aceitou tudo** sem contestar, não há o que reauditar — pula a rodada 2 e apresenta. Assim a skill é rápida quando não há briga, e funda quando há. **Teto duro: 2 rodadas, nunca uma 3ª** — confronto sem fim vira espiral que queima tempo sem decidir.

## Caminhos (resolva 1 vez, sem cerimônia)

Os comandos usam `$TMP` (arquivos temporários) e `$GPT` (a pasta desta skill, onde está este `SKILL.md` + a pasta `scripts/`). Você está lendo este arquivo agora — então já tem o caminho absoluto da pasta. Resolva os dois e siga; pode exportar ou só substituir direto nos comandos:
- `$GPT` = a pasta desta skill.
- `$TMP` = `/tmp` no Mac/Linux, `C:/temp` no Windows.

> Pré-requisito: esta skill chama o **Codex CLI** (GPT-5.5). Sem o `codex` instalado, ela não roda o confronto externo — o Claude assume o papel do revisor sozinho e avisa que rodou sem o GPT (ver **Fallback** no fim).

---

## Passo 1 — Montar o ALVO (automático)

Decida sozinho o que está em jogo agora. Quase sempre é uma combinação de:

- **Raciocínio/decisão** — você propôs um caminho ("vou fazer X porque Y"). Escreva isso explícito: qual a decisão, qual a alternativa que você descartou, qual a premissa.
- **Plano** — se existe um plano (em arquivo ou só na conversa), cole o essencial.
- **Código solto** — se a gente mexeu em arquivos, ancore no git real.

Levante o estado de verdade quando houver repositório:

```bash
# Só ancora em git SE esta pasta for um repositório. Em pastas SEM git
# (ex.: a pasta de skills, que roda sem git), pula sem cuspir "not a git repository".
if git rev-parse --git-dir >/dev/null 2>&1; then
  git rev-parse --show-toplevel; git branch --show-current
  git status --short
  git diff
else
  echo "(sem git nesta pasta — ancore o alvo só em arquivos/trechos, não em git diff)"
fi
```

Escreva o **manifesto** em `$TMP/gpt_alvo.md`. Estrutura:

```markdown
# Alvo da revisão

## O que estamos decidindo / fazendo
<1-2 parágrafos: a decisão ou tarefa, em estado atual. Cite literal — valor, caminho, comando, regra. Não parafraseie.>

## Por quê (a premissa)
<o raciocínio que sustenta o caminho. Onde você pode estar errado, diga.>

## Alternativa(s) descartada(s)
<o que você NÃO fez e por quê — pra o GPT poder questionar a escolha.>

## Régua de boas práticas (fonte: <X>)   ← só se houver, ver abaixo
<os pontos da régua curada que se aplicam ao alvo>

## Estado real (git / arquivos)   ← só se houver código
<git diff colado, ou trechos relevantes>
```

Regras do manifesto:
- **Cite literal**, não resuma. Parafrasear é como você esconde o detalhe que o furo mora.
- **Mascare segredo**: token, senha, chave, dado pessoal real → troca por placeholder antes de salvar. Se a evidência só faz sentido expondo dado sensível, pare e peça autorização.
- Manifesto enxuto e de alto sinal vence manifesto inchado.

### Bônus — a régua de boas práticas (só quando o domínio tem dono claro)
Confrontar contra uma régua curada vale muito mais que confrontar contra achismo. Então, **se o alvo for claramente de uma tecnologia/domínio com régua** (Cloudflare, Supabase, React, Postgres, vendas, conteúdo…), antes de fechar o manifesto puxa a régua e cola os pontos que se aplicam na seção `## Régua de boas práticas`:
- **Doc oficial via `context7`** (sempre disponível, nada a instalar) quando for tecnologia com dono.
- **Skill de boas práticas instalada** do domínio, se houver — **match FORTE** (o domínio do alvo bate de verdade com a descrição da skill), no máximo **1**. Invoca pela Skill tool e pega só os pontos que se aplicam.

Sem domínio claro, ou sem régua disponível → **pula essa seção**, não sai varrendo o catálogo de skills (varrer skill em toda chamada é desperdício). A régua é munição pro GPT, não etapa obrigatória.

## Passo 2 — Rodada 1: montar o input e chamar o GPT

Escreva `$TMP/gpt_input.md` = **o prompt fixo abaixo** + o conteúdo de `gpt_alvo.md`.

Prompt fixo (copie literal, cortando a pergunta 4 se não houver código):

```
Você é um revisor ADVERSARIAL. Sua função é DERRUBAR o trabalho abaixo, não validar. Não elogie. Não resuma o que leu. Não seja gentil — seja útil. Tente refutar:

1. Isso resolve MESMO o problema declarado, ou está resolvendo a coisa errada / só um sintoma?
2. Tem furo de raciocínio, premissa frágil vendida como fato, ou risco / caso de erro que não foi considerado?
3. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
4. [se houver código] O código tem bug, caso-limite não tratado, ou efeito colateral fora do escopo? Aponte arquivo:linha.

Devolva NESTE formato, sem nada antes nem depois:

## Veredito
SEGUIR | AJUSTAR | BLOQUEAR

## Pontos
- (no máximo 5; cada ponto curto e acionável, com a evidência ESPECÍFICA que o sustenta — QUAL premissa, QUAL linha, QUAL valor, QUAL caso de erro. É proibido ponto abstrato tipo "a premissa é frágil" sem dizer qual premissa e por que cai. Sem elogio, sem resumo.)

Critério do veredito:
- SEGUIR = não achou furo que mude a decisão.
- AJUSTAR = achou furos corrigíveis sem mudar o rumo; liste-os.
- BLOQUEAR = achou furo grave que invalida o caminho ou exige decisão de quem manda.
```

Dispare (síncrono, foreground — o usuário espera o resultado pronto, não vê "rodando"):

```bash
bash "$GPT/scripts/run-gpt.sh" "$TMP/gpt_input.md" "$TMP/gpt_review.md" xhigh
```

O `run-gpt.sh` roda **gpt-5.5 · `xhigh` · `service_tier="flex"`** — esforço máximo de raciocínio na via flex do gpt-5.5 (mais barata/lenta que a fast). Roda como **só-leitura** (`--sandbox read-only`): o revisor recebe o alvo inteiro via stdin, não precisa nem pode tocar em arquivo. Se o Codex falhar, o script **tenta de novo sozinho** e só então desiste com o motivo — você não fica sem aviso (ver **Fallback**).

## Passo 3 — Regra de ouro (filtrar a rodada 1) e decidir se vale a rodada 2

Leia `$TMP/gpt_review.md`. Para **cada** ponto do GPT, decida com prova:

- **Não procede** → descarta, mas com prova: o trecho do alvo / `arquivo:linha` que contradiz. Não some sem justificar.
- **Procede + grave** (invalida o caminho, ou é decisão de produto/risco/dado) → é decisão do dono: **sobe pro usuário em A/B** (seguir assim mesmo / ajustar). Nunca decide sozinho coisa grave.
- **Procede + menor** → corrige você mesmo no fluxo e segue, mencionando em uma linha.

**Agora decide a rodada 2** (a regra que mantém a skill rápida quando não precisa):

- Rodada 1 deu **SEGUIR**, ou você **aceitou todos os pontos** sem contestar → **não roda a 2**. Não há filtro seu pra auditar. Vai pro Passo 5.
- Rodada 1 deu **AJUSTAR/BLOQUEAR** e você **descartou ou contestou** ao menos um ponto (ou ajustou sua posição) → **roda a 2** (Passo 4): é justo o seu descarte que precisa de um segundo par de olhos.

## Passo 4 — Rodada 2 (condicional): o GPT audita o SEU filtro

É a **última** rodada — não existe 3ª. O foco muda: não é reabrir tudo, é checar se o seu filtro da rodada 1 se sustenta.

Monte `$TMP/gpt_alvo2.md` com: o alvo original (resumo + o que mudou), os pontos da rodada 1, e **o seu veredito de cada ponto com a prova** (aceito / descartado + por quê). Monte `$TMP/gpt_input2.md` = prompt da rodada 2 abaixo + `gpt_alvo2.md`:

```
Você é o MESMO revisor adversarial. Você já confrontou este alvo na rodada 1; abaixo estão os seus pontos e como o Claude filtrou cada um (aceitou / descartou, com a prova dele). NÃO reabra tudo nem repita pontos já aceitos. Responda só duas coisas, com evidência específica:

1. Algum ponto que o Claude DESCARTOU foi descartado errado — a prova dele NÃO cobre o que você apontou? Aponte qual e por quê.
2. A versão já ajustada ainda tem furo que MUDA a decisão (que a rodada 1 não pegou)?

Devolva NESTE formato:

## Veredito final
SEGUIR | AJUSTAR | BLOQUEAR

## Pontos
- (só o que sobrou de verdade; vazio se o filtro do Claude se sustentou. Cada ponto com a evidência específica que o sustenta. Sem elogio, sem resumo.)
```

```bash
bash "$GPT/scripts/run-gpt.sh" "$TMP/gpt_input2.md" "$TMP/gpt_review2.md" xhigh
```

Filtra a rodada 2 pela mesma regra de ouro. Ponto novo que procede e é grave → sobe pro usuário em A/B. Se a rodada 2 confirmar que seu filtro se sustentou (pontos vazios), fecha com mais confiança.

## Passo 5 — Apresentar (é aqui que a skill te serve)

O objetivo único deste passo: **você sai sabendo exatamente o que decidir, sem ter que perguntar de novo.** Tamanho não é o problema — vagueza é. Não espreme em uma linha; explique o suficiente pra decisão ficar óbvia, e nem uma palavra a mais.

Três regras que valem pra cada coisa que você mostrar:

- **Concreto, nunca abstrato.** Todo furo vem com o gatilho específico que o sustenta: QUAL premissa, QUAL valor, QUAL `arquivo:linha`, QUAL caso de erro. "A premissa é frágil" sozinho é proibido — diga qual premissa e por que ela cai.
- **Traduzir ≠ abstrair.** Trocar jargão pelo EFEITO PRÁTICO concreto ("vai deixar o usuário esperando na tela de carregamento"), nunca por nuvem vaga ("tem um problema de performance"). Sem termo técnico cru; sem vaguidão também.
- **Sempre fecha com a decisão na mesa** — mesmo quando passou.

Formato (tom de diretor, sem jargão):

```
**A decisão em jogo:** <a coisa exata que está sendo decidida, 1 frase concreta — cite o valor/caminho/regra literal>

**Veredito do GPT: SEGUIR | AJUSTAR | BLOQUEAR** — <o porquê em 1 frase, com o efeito prático> (rodou 1 ou 2 rodadas — 2 = houve furo contestado)

**Os furos que procedem:**
1. <o furo, com a evidência específica que o sustenta> → na prática: <o que muda pra você se ignorar>
   O que fazer: <ação concreta>
2. ...

**O que descartei do GPT (e por quê):** <1 linha por ponto descartado — não esconda que filtrou. Se rodou a 2ª rodada, diga se o GPT bateu o martelo no seu descarte ou recuou.>

**👉 Sua decisão:** <só quando for chamada SUA — grave, produto, risco ou dado. A) <faz X · ganha/perde>  B) <faz Y · ganha/perde>>
```

Casos onde a clareza costuma se perder — trate cada um:
- **Veredito SEGUIR (passou limpo):** não despache em "passou, segue". Diga o que o GPT **tentou** derrubar e por que não conseguiu, em concreto — é isso que te dá confiança real de que passou.
- **Furos só menores:** mesmo corrigindo você mesmo, mostre o que era e o que mudou — uma linha cada, concreta. Não some com a informação.
- **Nada procedeu:** diga "o GPT levantou X e Y; nenhum se sustenta porque <prova>". Não resuma pra "nada relevante".

**Se o veredito final for SEGUIR** (a decisão passou no confronto): ofereça **levar pra execução** — pergunte se ele quer que a `/Titan:auto-worker` execute a decisão agora. É opcional e só com o OK dele; se aceitar, passe o alvo já refletido como objetivo pra `auto-worker`. Se for **AJUSTAR/BLOQUEAR**, não ofereça executar — primeiro resolve o que o confronto apontou.

## Fallback — quando o GPT não responde

O `run-gpt.sh` já **tenta 2 vezes** sozinho antes de desistir, e não esconde mais o erro do Codex. Se ainda assim ele voltar `CODEX_NOT_INSTALLED`, `CODEX_FAILED` ou vazio (em qualquer uma das rodadas): **não trave** —

- **Avise o usuário, claramente, que o GPT não rodou** (e o motivo, se o script devolveu um) — nunca apresente o resultado como se o GPT tivesse revisado.
- Aí sim **você mesmo veste a lente adversarial**: as mesmas perguntas, tentando refutar de verdade, sem se auto-elogiar. Diga explícito que é crítica do mesmo modelo que produziu o trabalho, então vale menos.
- Na rodada 2 sem Codex, audite o próprio filtro com honestidade redobrada.
