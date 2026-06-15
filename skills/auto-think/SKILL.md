---
name: auto-think
description: "Modo larga-e-some pra ESTUDAR um problema difícil A FUNDO — dispara vários ângulos EM PARALELO (agentes independentes), pesquisa o que o mundo já resolveu, levanta um LEQUE de soluções candidatas, confronta cada uma com o Codex em mais de uma rodada, verifica o que se sustenta, re-cava o que ficou aberto, e entrega as soluções viáveis COM VEREDITO. Fundo é o padrão; o usuário FREIA dizendo 'rápido'. NÃO executa a solução (quem executa é /auto-prompt) — para na recomendação. Acionar quando o usuário disser '/auto-think <problema>', 'auto-think', 'estuda isso a fundo', 'pesquisa e me traz a melhor forma de fazer X', 'qual o melhor jeito de', 'investiga esse problema de vários ângulos', 'confronta as opções e decide', 'pensa nisso e volta com solução', 'larga isso pra estudar' — mesmo sem citar 'auto-think'. NÃO acionar pra pergunta factual rápida que se responde direto (sem estudo), nem pra EXECUTAR/implementar uma tarefa (isso é /auto-prompt), nem pra planejar um produto novo do zero (isso é /planejar)."
---

# auto-think

Modo de trabalho pro usuário **largar um problema difícil e sumir** — e voltar com solução
pronta pra decidir. O auto-think não executa nada: ele **estuda a fundo**. Pesquisa, ataca o
problema por vários lados ao mesmo tempo, levanta um leque de candidatas, confronta cada uma
até sobrar só o que aguenta porrada, e entrega as soluções viáveis **com veredito** (a
recomendada + as alternativas reais). Quem executa a escolhida depois é o `/auto-prompt` —
esta skill só pensa.

Repo-agnóstica: serve pra problema técnico ("qual a melhor forma de fazer X no sistema"),
de decisão ("vale a pena trocar Y por Z"), de investigação ("por que isso acontece e como
resolve"), ou de pesquisa pura ("o que o mundo já resolveu sobre isto").

**A fronteira que define tudo:**
- `/planejar` = desenhar um PRODUTO novo do zero antes de codar.
- `/auto-prompt` = EXECUTAR uma tarefa e entregar feito.
- `auto-think` = ESTUDAR um problema a fundo e entregar solução(ões) recomendada(s). Não executa.

Se no fim o usuário quiser rodar a solução escolhida, o ponteiro é: "quer que eu execute a A?
→ /auto-prompt". O auto-think nunca cruza essa linha sozinho.

---

## A CALIBRAGEM: fundo é o padrão (a regra que define o caráter da skill)

Esta skill existe pra quando o problema é difícil e vale gastar pensamento de verdade. Por
isso o padrão **não é meio-termo — é fundo**: muitos ângulos em paralelo, pesquisa externa,
um leque de candidatas, confronto em mais de uma rodada. Um auto-think que entrega uma resposta
rasa "falhou", mesmo que a resposta esteja certa — porque o pedido foi *estudar*, e estudar
raso não é estudar.

**Quem freia é o usuário, não a skill.** O sentido normal da escala é pra BAIXO: se ele disser
"rápido", "só o essencial", "não precisa tanto", aí sim a skill encolhe (menos ângulos, um
confronto só, sem re-cavar). Sem esse freio, **vai fundo**. A skill nunca decide sozinha
"acho que isso é simples, vou de leve" — na dúvida entre raso e fundo, vai fundo, porque foi
pra isso que foi chamada.

**O custo entra avisado, nunca como freio.** Ir fundo gasta mais (Codex em mais rodadas,
pesquisa, agentes paralelos). Isso aparece na entrega como nota de transparência ("rodei N
ângulos, M confrontos") — mas não é desculpa pra entregar menos. O usuário escolheu esta skill
sabendo que ela é a cara.

**Pisos concretos do modo fundo** (pra não recair no mínimo):
- **≥ 4 ângulos** atacados em paralelo, cada um como agente independente (ver passo 2).
- **Pesquisa externa obrigatória** sempre que o problema for "qual a melhor forma de X" / "como
  os outros resolvem isto" — nunca decidir a melhor forma só de cabeça.
- **≥ 3 candidatas** levantadas antes de podar (poda escolhe entre opções reais, não settla na
  primeira).
- **2 rodadas de confronto:** a primeira em todas as candidatas, a segunda nos sobreviventes.
- Re-cava enquanto houver **incerteza em aberto que mude a decisão** (o motor da profundidade —
  ver passo 5), não enquanto "achar coisa nova".

No modo freado (usuário pediu rápido): ≥2 ângulos, 1 confronto, sem re-cavar, entrega a
recomendada + no máximo 1 alternativa.

---

## Por que o coração desta skill é CONFRONTAR, não pesquisar

Como o auto-think só estuda (não envia, não apaga, não deploya), o perigo aqui **não é quebrar
sistema** — é entregar **raciocínio bonito mas errado vendido como verdade**. Pesquisar é a
parte fácil; qualquer um junta links. O valor está em **atacar os próprios achados** até sobrar
só o que se sustenta. Por isso o confronto é em mais de uma rodada, e a honestidade ("prova ou
silêncio") vale igual aqui, mesmo sem dado real em risco.

O contrato de honestidade e segurança é o mesmo do `/auto-prompt`:
`../auto-prompt/references/protocolo.md`. Leia antes de começar. O resumo operacional do que
mais importa pro auto-think está abaixo.

---

## A TRAVA DE DADO PRA FORA (a única trava dura que pega aqui)

O auto-think pode investigar o sistema do usuário — código, banco, arquivos — e isso pode
esbarrar em dado real de paciente/aluno, em senha ou em chave. A etapa de confrontar manda o
material pro **Codex (OpenAI, fornecedor externo)**, e a pesquisa pode mandar trechos pra
**web**. Logo:

> **Antes de qualquer coisa sair pro Codex ou pra web, mascarar dado real de pessoa
> (nome, CPF, telefone, email, endereço) e qualquer credencial (token, senha, chave).**
> Vai o RACIOCÍNIO do problema; não vai a identidade de quem quer que seja.

Como mascarar sem perder o sentido: troca por etiqueta estável (`PACIENTE_1`, `ALUNO_A`,
`TELEFONE_X`, `TOKEN_***`), preservando a estrutura pra o confronto ainda fazer sentido. Se o
problema SÓ faz sentido expondo o dado real → **para e pede autorização específica**, não
manda mesmo assim. Isso vale tanto pro confronto (Codex) quanto pra busca na web. Vale também
pros agentes paralelos: cada agente recebe o problema já mascarado.

**A régra concreta do que sai:** o que vai pra fora é o **problema abstraído** — a estrutura, o
padrão, o raciocínio — **nunca o registro real verbatim**. Campos que mascara sempre: nome,
CPF/documento, telefone, email, endereço, e qualquer credencial (token, senha, chave, string de
conexão). Antes de salvar o arquivo que vai pro Codex ou montar a busca, relê e confirma que
nenhum desses campos passou cru. A pesquisa na web usa o enunciado genérico do problema ("como
resolver X nesse tipo de sistema"), nunca um dado interno colado.

Fora isso, o auto-think é leitura: não escreve em banco, não envia mensagem, não mexe em
arquivo do usuário (a não ser rascunho próprio em `/tmp`). Nenhuma trava dura de execução se
aplica, porque ele nunca executa — só na borda de "mandar dado pra fora" é que ele para.

**Leitura de dado sensível também é graduada** (do protocolo): consulta mínima e agregada,
nunca `SELECT *` em tabela sensível, nunca copiar dado real pra arquivo. O objetivo é entender
o problema, não baixar a base.

---

## O núcleo de honestidade (reusado do protocolo)

- **Prova ou silêncio:** nenhuma afirmação importante sem evidência citada (`arquivo:linha`,
  comando + saída, fonte com data/versão, trecho de log). Sem prova → escrever
  "ASSUMIDO, não verificado". Vale pra achado interno E pra afirmação vinda da web.
- **Fato se confere, intenção se pergunta:** se é fato (esse arquivo existe? a causa é essa?
  essa biblioteca faz isso?) → **vai e verifica na fonte**, nunca chuta nem pergunta ao
  usuário o que dá pra checar. Se é intenção (qual o objetivo? qual critério?) → não presume:
  pergunta, ou segue com a suposição declarada explícita.
- **Fonte da web tem o mesmo rigor:** afirmação de blog/fórum vale menos que doc oficial. Cita
  a fonte e a data; marca como ASSUMIDO quando a fonte é fraca ou a versão não bate. Confrontar
  a pesquisa = checar se a fonte sustenta a afirmação, não só se "alguém disse na internet".
- **Não se auto-aprova:** o confrontador é o Codex (outro modelo). O auto-think nunca aprova o
  próprio raciocínio sozinho.

---

## O CICLO (larga e some, volta só com as soluções)

Executa este ciclo do começo ao fim sem devolver o controle, exceto nas paradas da lista
fechada lá embaixo. Anuncia cada virada em uma linha, mas não pede licença pra seguir.

### 1. Enquadrar o problema
Antes de cavar, separa o que é **fato** do que é **suposição** e decide o terreno:
- O problema é interno (sobre o sistema/código/operação do usuário), externo (conhecimento do
  mundo lá fora), ou os dois? Lembrar: **pesquisa externa pode servir pra resolver um problema
  interno** quando não se sabe a melhor forma — esse é o caso de uso central.
- **Escreve em 1-2 linhas o que assumiu** antes de sumir: qual o escopo, onde vai olhar, e o
  que conta como "resolvido" (o critério de sucesso). Isso é o que protege o "larga e some":
  se a suposição estiver errada, o usuário corrige cedo em vez de no fim.
- **Decide a profundidade aqui:** fundo por padrão (ver a Calibragem). Só cai pro modo freado
  se o usuário pediu "rápido/essencial" no enunciado. Na dúvida, fundo. **Nunca encolhe por
  chute** ("acho que isso é simples") — isso é o que fazia a skill trabalhar pouco.
- **Escape do trivial (única exceção ao fundo-por-padrão):** se ao enquadrar o problema ele se
  revelar trivial ou JÁ resolvido — e isso for **provável com evidência colada**, não com
  palpite — diz isso direto e não gasta o ciclo. "Já tem resposta pronta aqui: <prova>" é uma
  entrega honesta; gastar 5 ângulos pra confirmar o óbvio não é fundo, é desperdício. O teste:
  só usa o escape se conseguir PROVAR que é trivial; não conseguiu provar → vai fundo.
- Só **para e pergunta** se a intenção tiver **duas leituras plausíveis de verdade** que
  mudem o que seria estudado. Ambiguidade rasa → segue com a suposição declarada, não trava.

### 2. Estudar de vários ângulos — EM PARALELO DE VERDADE
Aqui mora a maior diferença entre "estudar a fundo" e "pensar um pouco". Não é refletir sobre
vários lados na mesma cabeça — é **disparar agentes independentes**, um por ângulo, cada um
cego pro que os outros acham. É a cegueira mútua que dá cobertura: dois agentes que conversam
convergem cedo e perdem o ponto cego um do outro.

**Como disparar:** um agente por ângulo via a Agent tool com `run_in_background` (até ~5 ao
mesmo tempo), ou via Workflow quando o problema for grande e valer orquestrar leque + confronto
junto. Os ângulos de coleta/leitura podem rodar em modelo mais leve (sonnet); a síntese e o
confronto ficam no modelo forte (opus). A regra é não estudar em série na thread principal —
era isso que fazia a skill "pesquisar pouco".

**Fallback se não houver paralelo** (Agent/Workflow indisponível, sem permissão, ou orçamento
estourado): NÃO desiste de cobrir os ângulos — roda os mesmos ângulos **em série**, um de cada
vez na thread principal, e marca na entrega "rodou em série, sem paralelo". Série lenta cobrindo
tudo é melhor que paralelo que não existe; o pecado é deixar ângulo sem estudar, não a forma de
disparar. Antes de montar um leque grande, **prova numa fatia** que o disparo paralelo responde
(um agente de teste) — se não responder, cai pro série desde já, não no meio do ciclo.

Ângulos (no modo fundo, **≥ 4**; escolhe os que cabem, mas sem encolher por preguiça):
- **Técnico:** qual a solução correta pelo mérito de engenharia.
- **Simplicidade:** existe um caminho muito mais simples pro mesmo resultado?
- **Custo/risco:** o que cada caminho cobra (dinheiro, dependência nova, manutenção, o que
  quebra quando crescer).
- **Precedente (fonte oficial + web):** o que o mundo já resolveu sobre isto — padrões, armadilhas
  conhecidas. **Obrigatório** quando o problema é "melhor forma de X" ou "como os outros fazem".
  Quando o problema é claramente de uma tecnologia com dono (Cloudflare, Supabase, React,
  Postgres…), a fonte de MAIOR garantia não é a web aberta — é a régua oficial daquele domínio: a
  **documentação oficial** (via `context7`, sempre disponível, nada a instalar) e, se houver, uma
  **skill de boas práticas instalada** daquele domínio (conhecimento curado). Essas vêm ANTES da
  web aberta; a web cobre o que elas não respondem. Como casar e o que fazer sem skill instalada:
  logo abaixo.
- **Contexto interno:** como isto encaixa no sistema real do usuário (código, banco, arquivos).
- Ângulos extras quando o problema pedir: **contrário** (e se a premissa do pedido estiver
  errada?), **escala** (e quando crescer 10x?), **alternativa radical** (e se não fizer nada / se
  resolver por fora?).

Pra a parte web, **reusa o que já existe**: `/pesquisa` (funil com fontes/citações) ou
`deep-research` (leque + verificação + síntese citada). Não reescreve um pesquisador do zero.
Pra a parte interna, lê o código/banco/arquivos com a régua de leitura mínima de dado sensível.

**Fonte de domínio — só quando o problema é de uma tecnologia identificável.** Isto NÃO é um passo
fixo: só dispara quando o enquadramento (passo 1) marcou o problema como "domínio técnico com dono
claro". Sem domínio → nem considera, não sai varrendo o catálogo de skills (varrer skill em todo
problema é o mesmo pecado de inflar por chute). Quando dispara, o agente do ângulo Precedente faz,
no contexto DELE (não na thread principal, pra não inchar):
1. **Documentação oficial sempre** — puxa via `context7` a doc oficial daquela tecnologia. É a
   régua de maior garantia, está sempre disponível e não depende de nada instalado — em especial,
   é independente do Perplexity, então se a busca web tropeçar, esta perna ainda segura o estudo.
2. **Skill de boas práticas, se houver** — casa o domínio do problema (fornecedor/framework + a
   tarefa) com a *descrição* das skills no catálogo da sessão (a lista do system prompt). Match
   FORTE: na dúvida entre uma skill que parece do domínio e uma vizinha, não usa — fica só na doc
   oficial. No máximo 1 skill por domínio. Achou → invoca via Skill tool e devolve só os achados.
3. **Skill útil que NÃO está instalada → nunca para o ciclo.** Segue com a doc oficial + boas
   práticas gerais e marca "estudei sem a skill curada de X". A falta de skill é um *achado*, não
   uma parada — a lista fechada de paradas (lá embaixo) não ganha item novo por causa disso.

**O aviso de skill faltante é GRADUADO** (decidido pelo motor do passo 5, "isto muda o estado da
decisão?"), porque "não parar" não pode virar "esconder que faltou algo essencial":
- **Só poliria** (a doc oficial já respondeu; a skill só refinaria) → nota `🅿️ opcional` no fim:
  "se instalar a skill X de boas práticas, eu refino — quer instalar e refazer, ou seguir assim?".
- **Mudaria a resposta** (sem a régua curada o estudo fica de baixa confiança) → NÃO é nota de
  rodapé: a recomendação cai pra 🟡 Hipótese, o diagnóstico (bloco 🧠) não fecha como certeza, e o
  aviso sobe pro TOPO da entrega. Como nem sempre dá pra saber se "mudaria" sem consultar, na
  dúvida trata pela criticidade do domínio: alto impacto + skill faltante → rebaixa a confiança
  por precaução, nunca vende como sólido.
- **Refazer com custo declarado:** refazer = rodar o estudo caro de novo (mesmo gasto da primeira
  vez). Lista TODAS as skills faltantes identificadas no enquadramento de uma vez (não uma por
  refação); teto de **1 refação** — uma segunda só se a skill nova for decisiva.

Cada ângulo devolve: achados + uma ou mais soluções candidatas, cada uma com a evidência que a
sustenta. Junta tudo num leque — **mira ≥ 3 candidatas distintas** antes de podar qualquer uma.
Se os ângulos convergiram todos na mesma candidata, dispara mais um ângulo (contrário ou
radical) pra garantir que não é falta de imaginação, e não convergência real.

### 3. Confrontar os achados (Codex tenta derrubar) — 1ª rodada
Cada achado e cada candidata passa pelo Codex como **advogado do diabo** — o mesmo mecanismo do
`/gpt`. O Codex tenta REFUTAR: isto resolve mesmo o problema ou só um sintoma? A premissa é fato
ou foi vendida como fato? Tem caminho mais simples? A fonte sustenta a afirmação? O que
sobrevive fica; o que é refutado cai (com o motivo registrado pra a entrega).

Como chamar o Codex (mascarando dado real ANTES — ver a trava acima; sempre com o teto de 15 min
da trava #4):
```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 -c model_reasoning_effort="high" --skip-git-repo-check - < /tmp/autothink-confronto.md
```
Use `xhigh` quando o problema for pesado (decisão de arquitetura, comparação grande). Confronta
em LOTE quando der (várias candidatas num input só) pra não estourar custo. Como montar o
manifesto e os prompts adversariais das duas rodadas: `references/confronto.md`. Mecânica de
chamada, selo de versão e fallback: motor compartilhado `../_shared/confronto-codex.md`.

### 4. O PORTÃO DE QUALIDADE — 4 perguntas que toda candidata passa
Achar uma solução não é o fim — é o gatilho pra interrogá-la. Nenhuma candidata vira "séria"
sem passar por estas quatro perguntas (cada uma com prova, não com confiança). É este portão
que impede os dois medos do dono: **parar na primeira** e **aceitar lixo**.

1. **Achei a resposta?** — isto responde o problema *declarado*, ou tô confundindo sintoma com
   causa? Resolve a doença ou só o sintoma? Se for sintoma, não é candidata — é remendo.
2. **Funciona mesmo?** — prova colada **ligada à afirmação que ela sustenta** (não prova solta):
   **PROVEI** com `arquivo:linha`, comando+saída ou fonte oficial+data, registrando o que ela
   exclui ou muda. "Parece bom" não passa. O que não deu pra provar vira **ASSUMI**, com o porquê.
3. **Tem mais algo que ajuda?** — obriga olhar ALÉM desta candidata antes de cravar: **ainda
   sobra alguma incerteza que mudaria a decisão?** (dá pra combinar com outra? tem ângulo que
   ninguém olhou? uma melhoria que some o ponto fraco dela?). É a trava anti-"parou na primeira":
   só fecha quando não sobra dúvida decisiva — não quando a primeira pareceu suficiente. (É essa
   pergunta que alimenta a lista viva do passo 5.)
4. **Como evito lixo?** — filtro de qualidade: candidata sem evidência, fonte fraca (blog/fórum
   contra doc oficial), afirmação sem lastro, solução que só funciona no papel → **marca lixo e
   cai**, com o motivo registrado. Fonte forte derruba fonte fraca; prova derruba opinião.

Candidata que passa nas 4 é finalista. Candidata que trava em qualquer uma cai (ou volta pro
passo 2 pra ser consertada, se valer). Verificar é "o que melhora ou não de verdade".

### 5. Re-cavar guiado pelas INCERTEZAS QUE MUDAM A DECISÃO
Quanto cavar **não é um número escolhido antes**, nem "contar achados novos". É guiado por uma
lista viva das dúvidas que, se respondidas pra um lado ou outro, **mudariam a decisão**. Isso é o
que faz o estudo se ajustar sozinho ao problema — e o que bloqueia tanto parar raso quanto
espiralar em lixo.

**A LISTA VIVA (1-3 incertezas decisivas).** A cada rodada, mantém no máximo 1-3 incertezas em
aberto cuja resposta mudaria o **ESTADO DA DECISÃO** — e estado da decisão é mais que a
recomendação headline: conta também **subir/derrubar a confiança nela, fechar ou abrir um risco,
mudar uma restrição, ou resolver uma incerteza crítica**. (Um achado que não muda qual solução
vence mas elimina um risco real continua valendo — por isso "muda a decisão", não "muda a
recomendação".)

**Como roda:**
- Cada re-cava ataca **uma incerteza decisiva aberta** — não reestuda tudo, dispara só o ângulo
  que fecha aquela dúvida.
- **Entre re-cavas, um check barato** (não um confronto Codex inteiro): "qual premissa, se for
  falsa, derruba a direção atual?". Se achar uma, ela vira a próxima incerteza a cavar. O
  confronto Codex caro fica nos passos 3 e 6 (no conjunto e nos finalistas) — crítico a cada
  volta é caro e, pior, **circular** (um modelo julgando o outro ratifica o ponto cego em vez de
  achar).
- **Achado que não toca nenhuma incerteza decisiva = ruído:** vira nota "🅿️ opcional" e é
  reportado no fim, **não compra rodada**. É isso que mata o lixo e o truque de inflar achado
  marginal pra justificar continuar — lixo não resolve incerteza decisiva.

**Como mata os dois extremos:**
- *Pensa demais / cata lixo* → lixo não fecha incerteza decisiva → não segura o loop. E não dá
  pra **fabricar** uma incerteza decisiva, porque ela é amarrada à decisão real.
- *Pensa pouco* → enquanto sobra incerteza que muda a decisão, **continua**. Problema difícil tem
  muitas → cava mais; simples tem poucas → para rápido. Ajusta sozinho ao problema.

**Quando para:** quando **não resta nenhuma incerteza decisiva aberta**. Quanto insistir antes de
dar uma incerteza por resolvida depende do que está em jogo: decisão trivial/reversível resolve
numa passada; decisão cara ou de alto impacto pede uma rodada a mais de confirmação. **Teto de
segurança:** 3 re-cavas é o limite duro contra espiral. Se bater o teto **com incerteza decisiva
ainda aberta**, NÃO para calado: entrega o que tem e **pergunta "ainda tem dúvida que muda a
decisão e bati o teto — continuo?"**. O teto é rede contra descontrole, não tesoura escondida.

### 6. Confrontar os sobreviventes — 2ª rodada
Antes de entregar, os finalistas (a recomendada + as alternativas reais) voltam ao Codex **uma
segunda vez**, agora com a pergunta afiada: *dessas que sobraram, qual escolher e por quê — e o
que ainda fura na recomendada?* Essa segunda passada é o que separa "sobreviveu por sorte" de
"sobreviveu de verdade", e costuma melhorar a justificativa do veredito. No modo freado, pula
esta rodada.

### 7. Entregar
Ver "Entrega final" abaixo.

---

## AS TRAVAS — anti-espiral e orçamento (o que segura a coleira de verdade)

Ir fundo tem um perigo real: o confronto Codex↔Claude virar **espiral** — os dois discutindo
sem fim, ou litigando frivolidade, queimando dinheiro sem chegar a lugar nenhum. A coleira
contra isso é **estrutural e contável**, não um cronômetro (texto de skill não mata processo).

**1. O confronto NÃO é debate.** O Codex opina UMA vez por rodada; o Claude filtra cada ponto
com prova e decide; acabou. **Não existe réplica-da-réplica** — Claude não reescreve pra
rebater o Codex que reescreve pra rebater o Claude. Quem produziu não defende; quem confrontou
não insiste. Uma passada, uma decisão.

**2. Filtro de frivolidade.** Pra cada ponto do Codex: ele muda QUAL candidata vence, ou muda se
ela funciona? **Sim** → conta, trata. **Não** (questão de estilo, de gosto, melhoria cosmética,
"eu faria diferente") → **descarta na hora**, não litiga. O que não muda o veredito não merece
uma segunda chamada.

**3. Orçamento de chamadas (a trava dura — porque espiral = chamadas infinitas).** O ciclo todo
gasta no máximo: **2 rodadas de confronto** (1ª em todas as candidatas, 2ª nos finalistas) +
**3 re-cavas**. Bateu o teto → para e entrega o que tem, com aviso. Contar chamada o modelo
consegue cumprir; matar por relógio, não. No modo freado: 1 confronto, 0 re-cava.

**4. O GPT tem 15 min — passou disso, travou.** A chamada do Codex vai envelopada num teto de
15 min que o sistema operacional mata sozinho. **Portátil** (o `timeout` puro NÃO existe no Mac;
o `perl` existe no Mac e no Windows):
```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 -c model_reasoning_effort="high" --skip-git-repo-check - < /tmp/autothink-input.md
```
(No Linux ou Mac com coreutils dá pra usar `timeout 900` / `gtimeout 900` no lugar — mas o `perl`
acima funciona em todos.) Rodou mais de 15 min = **travou**, ponto. O processo é morto. Regra do
dono: **mata e refaz** — re-dispara a mesma chamada uma vez. Travou de novo → desiste dela e cai
no fallback de confronto (ver composição), seguindo com o que tem.

**5. Agente em background que não volta não trava o ciclo.** Dispara com `run_in_background`,
faz um check-in; o ângulo que não retornou até o ponto de síntese **não segura o resto** —
entrega sem ele, marcado "ângulo X não retornou". O modelo não espera infinito: segue quando os
que voltaram já dão pra decidir.

O `alarm 900` do item 4 é a regra: GPT que roda mais de 15 min travou, o SO mata, refaz uma
vez. Junto com o teto de rodadas (item 3) e o agente em background que não segura o ciclo (item
5), nada fica pendurado.

---

## Quando PARAR (lista fechada) — fora disto, segue e anuncia

O auto-think é larga-e-some. Só devolve o controle nestes casos:
1. **Intenção ambígua de verdade** — 2+ leituras plausíveis do problema que mudam o que estudar.
2. **Trava de dado pra fora** — o confronto/pesquisa só faria sentido expondo dado real de
   pessoa ou credencial (ver a trava). Para e pede autorização específica.
3. **Descobriu que o problema é outro** — a investigação mostrou que a pergunta real é
   diferente da que foi feita. Reporta a divergência ANTES de propor solução (achado divergente
   vem antes da solução).
4. **O usuário pediu pausa** ("espera", "mostra antes").
5. **Bateu o teto de segurança com incerteza decisiva ainda aberta** — 3 re-cavas estouradas mas
   ainda sobra dúvida que mudaria a decisão (passo 5). Entrega o que tem e pergunta "continuo?".

Fora disso: não pergunta "sigo?" depois de cada etapa — segue e anuncia em uma linha. Em
especial, **não para pra perguntar se deve ir fundo** — fundo é o padrão.

---

## Entrega final — a apresentação é tão crítica quanto a pesquisa

O usuário pode não entender de IA. Uma apresentação confusa faz ele **decidir errado mesmo com
estudo bom** — então a entrega é parte do trabalho, não enfeite no fim. A entrega é traduzida:
português comum, sem jargão; termo que ele conhece (deploy, merge, cache, MCP) pode aparecer, o
resto vira analogia ou nota técnica que ele abre se quiser. **Sem infantilizar** — ele é esperto,
só não é da área; linguagem clara não é linguagem de bebê.

**Por que este padrão é assim** (saiu de um estudo do próprio auto-think, confrontado): o leigo
lê em camadas e desiste cedo, trata palpite e fato com a mesma fé se aparecem igual, e o que ele
MAIS precisa pra decidir não é "qual a melhor" e sim "quão certo você está e qual o tombo se
errar". O padrão é desenhado pra entregar isso nos primeiros 5 segundos de leitura.

### A ordem fixa da entrega (6 blocos, nesta ordem)

Curto é regra: o CHAT recebe só o enxuto; o aprofundamento vai pra um ARQUIVO que ele abre se
quiser (igual o claudex faz com o plano). Nada de manchete subjetiva tipo "em que pé ficou" —
abre com o diagnóstico concreto. A ordem abaixo é fixa: o usuário decora o mapa uma vez.

**1. 🧠 DIAGNÓSTICO — o que é, com prova.** Diz CLARAMENTE o que o estudo achou e de que TIPO é.
O tipo vem de uma lista FECHADA, pra "não achei nada" ser resposta de primeira classe e o agente
nunca inventar solução pra preencher formato: `ACHEI A SAÍDA` · `EMPATE` · `SEM SAÍDA BOA` ·
`SEM EVIDÊNCIA PRA DECIDIR` · `OPORTUNIDADE` · `O PROBLEMA É OUTRO` · `CONTRADIÇÃO/BUG` ·
`AINDA INVESTIGANDO`.
- **Vários achados → TABELA** `Achado/Pergunta | Veredito | Prova`. Veredito curto e tipado
  (✅/❌/⚠️ + 1 frase). **A coluna Prova carrega a confiança** (prova forte = certeza alta) — não
  precisa de bloco "confiança" à parte. Prova em linguagem de origem, adulta: "fui lá e contei",
  "é o padrão, não testei no seu caso", "é leitura minha — confirme antes".
- **Um achado só → 1-2 linhas.** NÃO forçar tabela — sem comparação real, tabela inventada é
  pior que uma frase.

**2. 🎯 RECOMENDO — em 1 frase.** A recomendação direta. Se não há uma clara, o tipo do
diagnóstico já disse (EMPATE, SEM SAÍDA BOA) — não inventa recomendação pra preencher.

**3. 🗺️ SÓLIDO / HIPÓTESE / NÃO FAÇA — o mapa do terreno.** Três rótulos:
- ✅ **Sólido:** o que pode confiar (provado).
- 🟡 **Hipótese:** vale, mas rotulado — não é verdade ainda, é pra testar.
- ☠️ **Não faça:** o veneno — o que vai te enganar / dar errado. Este é proteção, fica sempre
  visível no chat. Só aparece o rótulo que tiver conteúdo real (não inventar veneno).

**4. 🔬 COMO ESTUDEI — curto, mas COM AS FONTES.** 1-2 linhas: ângulos, confrontos, custo de ir
fundo. **Nunca omitir as fontes** (web com nome/data, `arquivo:linha`, comando) — a rastreabilidade
importa pro usuário. Curto não é vago: cita de onde veio, só não se alonga.

**5. 👉 O QUE VOCÊ DECIDE — a decisão, nunca ordem solta.** A/B/C objetivo, cada opção com
ganha/perde dos DOIS lados. **Reversibilidade colada aqui** ("reversível num clique" vs "difícil
de desfazer"). É uma ESCOLHA ("A ou B", "me autoriza", "me dá o dado X"), não "vá fazer". Se uma
opção domina, "as outras eram piores, nem listo" — não fingir empate (falsa simetria paralisa).

**6. ▸ DETALHE COMPLETO EM `<arquivo>`.** O fundo do estudo — as correções do confronto, o mapa
completo, o que o Codex matou, raciocínio longo — vai pra um `.md` em disco; o chat mostra só a
linha apontando. O usuário abre se quiser cavar. É isso que mantém o chat enxuto sem perder nada.

### Esqueleto (o que vai no CHAT)

```
🧠 DIAGNÓSTICO — [TIPO]: <o que é, 1 frase leiga>
   | Pergunta / Achado | Veredito | Prova |          ← tabela se vários achados; 1-2 linhas se um só
   | <o que checou>    | ✅/❌/⚠️ <frase> | <evidência em linguagem de origem> |

🎯 RECOMENDO: <1 frase>

🗺️ SÓLIDO / HIPÓTESE / NÃO FAÇA:
   ✅ Sólido: <pode confiar>
   🟡 Hipótese: <vale, mas é pra testar — não é verdade ainda>
   ☠️ Não faça: <o veneno — o que te engana>

🔬 Como estudei: <ângulos + confrontos + custo, curto> · Fontes: <web com data / arquivo:linha>

👉 O QUE VOCÊ DECIDE: <A/B/C, ⚖️ ganha X / perde Y + reversível ou não>

▸ Detalhe completo em: <caminho do .md>
```

Sem jargão; sem infantilizar (ele é esperto, só não é da área); nunca estimar tempo (custo é
qualitativo: escopo, reversível/destrutivo, dependência nova — nunca "leva X horas").

---

## A mecânica de composição (provar numa fatia antes de cavar fundo)

O auto-think depende de acionar outras peças: o Codex (via Bash, comprovado), `/pesquisa` e
`deep-research` (via Skill), e agentes paralelos (via Agent/Workflow). Antes de montar um ciclo
grande num problema novo, **prova numa fatia pequena que a peça que você vai usar responde**
(uma chamada de Codex de teste, uma busca curta) — assim um problema de encaixe aparece cedo,
não no fim de um ciclo caro. Se uma peça falhar (Codex fora, pesquisa sem resultado), o ciclo
não trava: degrada com aviso (confronto vira um agente Claude separado e adversarial, marcado
"revisão de menor garantia — mesmo modelo") e segue, dizendo na entrega o que rodou sem a peça.

Ir fundo com agentes paralelos é mais barato em tempo do que parece: 4-5 ângulos em background
terminam quase juntos, não em fila. O gasto real é em tokens e em chamadas de Codex — e esse é
o custo que o usuário aceitou ao chamar uma skill chamada "estudar a fundo".
