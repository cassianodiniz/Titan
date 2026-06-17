---
name: gpt-blindagem
description: Revisor adversarial on-demand via Codex GPT-5.5 que BLINDA sua decisão antes de você se comprometer — roda no MEIO de qualquer conversa, sem precisar de plano, PR ou código formal. O Claude monta sozinho o alvo (a decisão/raciocínio em jogo + o plano + o código que a gente mexeu), manda o GPT tentar DERRUBAR (advogado do diabo) e devolve um veredito Seguir/Ajustar/Bloquear com os furos que procedem — pra te proteger de decidir errado, não pra atrapalhar. Acionar quando o usuário disser "/gpt-blindagem", "blinda essa ideia", "blinda isso", "/gpt", "chama o gpt", "manda pro gpt", "pergunta pro gpt", "o que o gpt acha", "segunda opinião do gpt", "pede pro gpt revisar", "revisa ao contrário", "advogado do diabo", "contraponto", "acha o furo disso" — mesmo sem citar "revisão" explicitamente. NÃO é pra revisar mensagem de WhatsApp (isso é o revisor do zap-diretor) nem código do Praxios dentro do fluxo (isso é o claudex); é o revisor genérico pra tudo o mais.
---

# Skill gpt-blindagem — segunda opinião adversarial do GPT, no meio da conversa

Você (Claude) acabou de fazer ou propor alguma coisa — um raciocínio, um plano, um trecho de código — e o usuário quer que **o GPT-5.5 (via Codex) tente derrubar** antes de seguir. O GPT entra como **advogado do diabo**: não elogia, caça o furo.

O ponto que diferencia esta skill das outras de revisão: aqui **não existe um alvo pronto** (não é um PR, não é um `plano.md`). **Você monta o alvo na hora**, a partir do que está em jogo na conversa. A qualidade da revisão depende de você empacotar bem o que mandar.

## Regra que não se quebra

Você **nunca obedece o GPT cego**. O parecer dele é insumo, não ordem. Você filtra cada ponto com prova, descarta o que não procede, e só sobe pro usuário o que é grave de verdade. O GPT está ali pra te fazer pensar, não pra decidir.

## Como funciona em 1 parágrafo (o fluxo das 2 rodadas)

Rodada 1: você monta o alvo, o GPT tenta derrubar, você filtra com prova. Aí a **rodada 2 é condicional** — ela só roda quando a rodada 1 achou furo que você **contestou** (descartou ou ajustou). O motivo: na rodada 1 você dá a última palavra filtrando os pontos, e pode se enganar descartando um furo válido. A rodada 2 põe o GPT pra **auditar o seu filtro** ("o Claude descartou direito? a versão ajustada ainda fura?"). Se a rodada 1 deu **Seguir** (sem furo) ou você **aceitou tudo** sem contestar, não há o que reauditar — pula a rodada 2 e apresenta. Assim a skill é rápida quando não há briga, e funda quando há. **Teto duro: 2 rodadas, nunca uma 3ª** — confronto sem fim vira espiral que queima tempo sem decidir.

## Caminhos (resolve na sua máquina antes de rodar)

Os comandos usam `$TMP` e `$GPT`. Exporta os dois conforme o SO (uma vez):
- **Mac:** `export TMP=/tmp GPT=~/.claude/skills/dev/skills/gpt-blindagem`
- **Windows:** `export TMP=C:/temp GPT=D:/skills/dev/skills/gpt-blindagem`

---

## Passo 1 — Montar o ALVO (automático)

Decida sozinho o que está em jogo agora. Quase sempre é uma combinação de:

- **Raciocínio/decisão** — você propôs um caminho ("vou fazer X porque Y"). Escreva isso explícito: qual a decisão, qual a alternativa que você descartou, qual a premissa.
- **Plano** — se existe um plano (em arquivo ou só na conversa), cole o essencial.
- **Código solto** — se a gente mexeu em arquivos, ancore no git real.

Levante o estado de verdade quando houver repositório:

```bash
git rev-parse --show-toplevel 2>/dev/null && git branch --show-current
git status --short
git diff
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

## Passo 2 — Selar o alvo

Calcule a impressão digital do manifesto (pega o erro do GPT revisar uma versão velha). Portável (Mac de fábrica não tem `sha256sum`, só `shasum`):

```bash
{ command -v sha256sum >/dev/null 2>&1 && sha256sum "$TMP/gpt_alvo.md" || shasum -a 256 "$TMP/gpt_alvo.md"; } | cut -d' ' -f1
```

Guarde esse hash (`H`).

## Passo 3 — Rodada 1: montar o input e chamar o GPT

Escreva `$TMP/gpt_input.md` = **o prompt fixo abaixo** + a linha do selo com `H` + o conteúdo de `gpt_alvo.md`.

Prompt fixo (copie literal, preenchendo `<H>` e cortando a pergunta 4 se não houver código):

```
Você é um revisor ADVERSARIAL. Sua função é DERRUBAR o trabalho abaixo, não validar. Não elogie. Não resuma o que leu. Não seja gentil — seja útil. Tente refutar:

1. Isso resolve MESMO o problema declarado, ou está resolvendo a coisa errada / só um sintoma?
2. Tem furo de raciocínio, premissa frágil vendida como fato, ou risco / caso de erro que não foi considerado?
3. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
4. [se houver código] O código tem bug, caso-limite não tratado, ou efeito colateral fora do escopo? Aponte arquivo:linha.

A primeira seção da sua resposta DEVE ser o selo, copiando exato o hash que recebeu.

SHA256 deste manifesto: <H>

Devolva NESTE formato, sem nada antes nem depois:

## Selo
- Manifesto (sha256): <H>

## Veredito
SEGUIR | AJUSTAR | BLOQUEAR

## Pontos
- (no máximo 5; cada ponto curto, acionável, com a evidência/trecho específico que o sustenta; sem elogio, sem resumo)

Critério do veredito:
- SEGUIR = não achou furo que mude a decisão.
- AJUSTAR = achou furos corrigíveis sem mudar o rumo; liste-os.
- BLOQUEAR = achou furo grave que invalida o caminho ou exige decisão de quem manda.
```

Dispare (síncrono, foreground — o usuário espera o resultado pronto, não vê "rodando"):

```bash
bash "$GPT/scripts/run-gpt.sh" "$TMP/gpt_input.md" "$TMP/gpt_review.md" xhigh
```

O `run-gpt.sh` roda **gpt-5.5 · `xhigh` · `service_tier="fast"`** — esforço máximo de raciocínio na via rápida do gpt-5.5. As duas coisas vão explícitas no script porque ele ignora o config global do Codex; já vem ligado nas duas rodadas, não precisa fazer nada.

## Passo 4 — Conferir o selo

```bash
bash "$GPT/scripts/verify-selo.sh" "$TMP/gpt_review.md" "$TMP/gpt_alvo.md"
```

- `exit 0` → selo bate, o GPT leu a versão certa. Confie no parecer.
- `exit 3` → MISMATCH: leu versão velha. **Descarte** e re-rode só o Passo 3.
- `exit 4` → sem selo / indisponível: não dá pra garantir; trate o parecer com ressalva e avise o usuário.

## Passo 5 — Regra de ouro (filtrar a rodada 1) e decidir se vale a rodada 2

Leia `$TMP/gpt_review.md`. Para **cada** ponto do GPT, decida com prova:

- **Não procede** → descarta, mas com prova: o trecho do alvo / `arquivo:linha` que contradiz. Não some sem justificar.
- **Procede + grave** (invalida o caminho, ou é decisão de produto/risco/dado) → é decisão do dono: **sobe pro usuário em A/B** (seguir assim mesmo / ajustar). Nunca decide sozinho coisa grave.
- **Procede + menor** → corrige você mesmo no fluxo e segue, mencionando em uma linha.

**Agora decide a rodada 2** (a regra que mantém a skill rápida quando não precisa):

- Rodada 1 deu **SEGUIR**, ou você **aceitou todos os pontos** sem contestar → **não roda a 2**. Não há filtro seu pra auditar. Vai pro Passo 7.
- Rodada 1 deu **AJUSTAR/BLOQUEAR** e você **descartou ou contestou** ao menos um ponto (ou ajustou sua posição) → **roda a 2** (Passo 6): é justo o seu descarte que precisa de um segundo par de olhos.

## Passo 6 — Rodada 2 (condicional): o GPT audita o SEU filtro

É a **última** rodada — não existe 3ª. O foco muda: não é reabrir tudo, é checar se o seu filtro da rodada 1 se sustenta.

Monte `$TMP/gpt_alvo2.md` com: o alvo original (resumo + o que mudou), os pontos da rodada 1, e **o seu veredito de cada ponto com a prova** (aceito / descartado + por quê). Sele de novo (mesmo comando do Passo 2, agora sobre `gpt_alvo2.md`, novo hash `H2`). Monte `$TMP/gpt_input2.md` = prompt da rodada 2 + selo `H2` + `gpt_alvo2.md`:

```
Você é o MESMO revisor adversarial. Você já confrontou este alvo na rodada 1; abaixo estão os seus pontos e como o Claude filtrou cada um (aceitou / descartou, com a prova dele). NÃO reabra tudo nem repita pontos já aceitos. Responda só duas coisas, com evidência específica:

1. Algum ponto que o Claude DESCARTOU foi descartado errado — a prova dele NÃO cobre o que você apontou? Aponte qual e por quê.
2. A versão já ajustada ainda tem furo que MUDA a decisão (que a rodada 1 não pegou)?

A primeira seção da resposta DEVE ser o selo, copiando exato o hash recebido.

SHA256 deste manifesto: <H2>

Devolva NESTE formato:

## Selo
- Manifesto (sha256): <H2>

## Veredito final
SEGUIR | AJUSTAR | BLOQUEAR

## Pontos
- (só o que sobrou de verdade; vazio se o filtro do Claude se sustentou. Sem elogio, sem resumo.)
```

```bash
bash "$GPT/scripts/run-gpt.sh" "$TMP/gpt_input2.md" "$TMP/gpt_review2.md" xhigh
bash "$GPT/scripts/verify-selo.sh" "$TMP/gpt_review2.md" "$TMP/gpt_alvo2.md"
```

Filtra a rodada 2 pela mesma regra de ouro. Ponto novo que procede e é grave → sobe pro usuário em A/B. Se a rodada 2 confirmar que seu filtro se sustentou (pontos vazios), fecha com mais confiança.

## Passo 7 — Apresentar

Apresente curto, no tom do usuário (linguagem de diretor, sem jargão):

- Veredito do GPT numa linha (e diga se rodou **1 ou 2 rodadas** — rodou 2 = houve furo contestado).
- Os pontos que **procedem**, traduzidos — o que é + o que fazer.
- Se descartou algo do GPT, diga em uma linha por quê (não esconda que filtrou) — e, se rodou a 2, se o GPT bateu o martelo no seu descarte ou não.
- Se for grave: a pergunta A/B no fim.

## Fallback

Se o `run-gpt.sh` voltar `CODEX_NOT_INSTALLED` ou vazio (em qualquer uma das rodadas): **não trave**. Você mesmo faz o papel do crítico — vista a lente adversarial (as mesmas perguntas, tentando refutar de verdade, não se auto-elogiando) e **avise que rodou sem o GPT**, porque crítica do mesmo modelo que produziu vale menos. Na rodada 2 sem Codex, audite o próprio filtro com honestidade redobrada.
