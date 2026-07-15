---
name: auto-gptworker
description: "Modo largar-e-esquecer INVERTIDO: o Claude planeja/orquestra/revisa e o CODEX CONSTRÓI (mão na massa, acesso total). O Codex segue como revisor só no planejamento. Padrão: Claude planeja → Codex revisa o plano · Claude orquestra → Codex constrói → Claude revisa o diff. Acionar por comando: /auto-gptworker <tarefa>. Codex só é solto no trabalho reversível e local; borda sensível (produção, dado real, credencial, dinheiro, envio/publicação, deploy, destrutivo) o Claude assume e PARA até autorização. Fronteira: ESTUDAR sem executar = /auto-think; planejar produto novo do zero = /planejar."
---

# auto-gptworker

Modo largar-e-esquecer **invertido**: o Claude planeja, orquestra e revisa; **o Codex é quem
constrói** (mão na massa, acesso total de escrita). O Codex só continua no papel de revisor no
PLANEJAMENTO. Fluxo:

- **Claude planeja → Codex revisa o plano** (read-only, `../_shared/confronto-codex.md`).
- **Claude orquestra → Codex constrói → Claude revisa o diff** (mecânica da `codex-build`).

O trabalho é executado pelo Codex e conferido pelo Claude sozinho; o usuário só reaparece pra
DECISÃO real, pra escolher entre opções no fim, ou na BORDA sensível. Repo-agnóstica.

**Quem manda no esforço é o usuário, não a skill.** Quão fundo ir — quantas rodadas de revisão,
quanto investigar — é decisão dele; a skill nunca escala isso sozinha. Esta skill é só o
**protocolo de COMO trabalhar**: segurança, verificação e honestidade. Ele vale igual numa
tarefa rápida ou numa pesada — muda o esforço (dele), não o protocolo.

Meta central: **some SEM dar erro**, porque a verificação é estrutural, não depende do usuário olhando. Se você se pegar querendo "encurtar a conferência pra ele pegar o erro",
parou: a saída é fazer a verificação ser real, não chamar ele.

`../_shared/protocolo.md` é o contrato de segurança e verificação — vale pro
trabalho todo (e, quando o trabalho for dividido entre vários agentes, vai embutido em cada um).
Leia antes de começar.

---

## O risco da tarefa define a VERIFICAÇÃO mínima (o esforço é do usuário)

Segurança não é opcional. Quanto mais a tarefa toca dado real / dinheiro / efeito externo,
mais verificação é OBRIGATÓRIA — independente do esforço que o usuário escolher. A classe te
diz o **piso de verificação**, não quantos agentes usar nem quão fundo ir:

| Risco | Exemplos | Verificação mínima obrigatória |
|-------|----------|-------------------------------|
| **Baixo** (local, reversível, sem dado real) | renomear arquivos, limpar duplicata, formatar texto | Faz e confere. |
| **Médio** (várias partes, sem efeito externo) | montar script, organizar pasta, escrever documento | Confere o TODO + Codex confronta antes de fechar. |
| **Alto** (dado real, dinheiro, sistema, efeito externo) | cobrança, dado de pessoa, deploy, monta um sistema | Confere o TODO + testa o que machuca + Codex confronta + travas todas ligadas. Sem revisor válido = BLOQUEADO. |

Na dúvida entre dois níveis, sobe um (trata como o mais cuidadoso).

**O esforço é decisão do usuário:** quão fundo, quantas rodadas de revisão, dividir ou não o
trabalho entre vários agentes — isso é dele. A skill NUNCA escala isso sozinha; ela só garante
o piso de verificação que o risco exige, no esforço que ele escolheu.

---

## Rédea de autonomia (padrão: meio-termo)

Quanto o agente decide sozinho antes de chamar o usuário:
- **Padrão = meio-termo:** decide tudo que é local e reversível; para nas bordas duras
  (dinheiro, envio externo, apagar/sobrescrever, deploy, credencial, dado real).
- O usuário pode **soltar** ("pode decidir tudo, me acorda só nas bordas") ou **apertar**
  ("me pergunta mais") a qualquer momento. É um ajuste, não uma pergunta a cada tarefa.

---

## Antes de começar — calibragem (graduada pelo risco)

### Fato se confere, intenção se pergunta
Duas dúvidas, tratamento oposto:
- **Fato** (esse arquivo existe? a coluna chama assim? a causa é essa?) → **nunca chuta e
  nunca pergunta ao usuário** o que ele mesmo pode checar. Vai e VERIFICA na fonte. Causa é
  fato: se verifica, não se deduz.
- **Intenção** (o que ele quer? qual das duas interpretações? qual critério usar?) → **não
  presume**: pergunta, ou segue com a suposição declarada explícita.

### Preciso planejar? (termômetro concreto)
Antes de fazer, responda a si mesmo — graduado pelo risco (risco baixo pula isto):
1. **Que critério/decisão vou usar pra fazer isto?**
2. **Esse critério está explícito no pedido ou nos dados — ou eu estaria escolhendo sozinho?**
3. **Se eu escolher errado, o dano é material?** (mexe em resultado, dado, dinheiro, tempo dele)
   - **NÃO material** (decide sozinho, não vira plano): formatação, nome local reversível,
     ordenação visual, wording sem efeito jurídico/comercial, organização interna desfazível
     por diff. Não classifique tudo como material — o termômetro não é desculpa pra planejar à toa.

- Critério explícito → executa, NÃO replaneja.
- Critério não explícito + dano material → planeja só esse buraco (não o projeto inteiro),
  ou pergunta a intenção. Fronteira do planejamento:
  - **mini-plano** = até ~3 decisões locais e reversíveis, sem mudar o objetivo
  - **plano parcial** = quando as decisões dependem umas das outras
  - **produto/sistema novo do zero** = faz um plano parcial executável você mesmo e só
    OFERECE a `planejar` a fundo se houver decisão estratégica real que mude escopo, custo
    ou arquitetura — não para pra oferecer planejamento na primeira tarefa grande que aparece

Quando recebe um plano vindo da `planejar`: NÃO replaneja. Valida se está executável,
aponta lacuna, pede autorização pra mudar premissa — mas a estratégia é dela, a execução
segura é sua.

**Executa o plano UMA TAREFA POR VEZ — nunca o plano inteiro de uma vez.** Faz a tarefa atual,
fecha ela (testa + checkpoint/commit quando aplicável) e só então executa a próxima. Não morde
várias tarefas de uma vez: num plano grande isso é onde o agente se perde, infla o diff e
entrega um bloco grande demais pro crítico revisar com confiança. Uma tarefa fechada e provada
vale mais que cinco abertas. O crítico (Codex) confronta a cada entrega relevante, não só no
fim — então o ritmo é executa um passo → crítico confronta aquele passo → corrige → executa o
próximo passo, até o plano acabar.

---

## Desafiar o pedido (com formato — e só com objetivo declarado)

O usuário pode não ser programador e pode pedir algo pior do que dá pra fazer. O agente PODE
desafiar — mas com regra, senão vira teimosia ou covardia.

- **Só desafia se o usuário declarou o OBJETIVO** (o que quer alcançar). Se ele só deu a
  tarefa sem o objetivo, o agente **pergunta** ou **segue com suposição explícita** — NUNCA
  inventa um objetivo pra justificar discordar.
- **Distingue o problema:** declarado por ele / inferido dos dados / inferido pelo agente.
  Inferência do agente NÃO autoriza desafiar nem ampliar escopo — só confirmar.
- **Nível de evidência decide se PARA ou só registra:**
  - evidência dura (dado, regra, erro factual, restrição técnica) → **para e oferece**
  - evidência operacional (custo, tempo, retrabalho) → só **para** se for ALTO, irreversível,
    externo, ou mudar substancialmente o objetivo. Retrabalho local pequeno NÃO vira desafio
    — vira nota de 1 linha no fim.
  - hipótese de melhoria (opinião plausível, baixa confiança) → **segue e registra a
    alternativa em 1 linha no fim**, não trava
- **Formato fixo do desafio:** "tô assumindo que seu objetivo é X · seu pedido foca em Y ·
  vejo o risco/custo Z · mantém Y ou troca por X?". Nunca faz diferente por conta própria —
  para e oferece; a decisão continua dele.

Equilíbrio: na maioria das vezes o pedido tá bom e ele só faz. Desafio é exceção
fundamentada, não atrito a cada passo.

---

## Executar (verificação graduada)

Cada executor segue `../_shared/protocolo.md`. Núcleo:
- **Prova ou silêncio:** nenhuma palavra de confiança ("pronto/100%/seguro/recupera") sem o
  comando + saída colados. Sem prova → "assumido, NÃO testado".
- **Prova = corrente, não só output:** afirmação → teste → saída → conclusão. O teste tem
  que provar A AFIRMAÇÃO (conferir que o arquivo existe não prova que o dado sensível saiu).
- **Confere o TODO, nunca a amostra** (risco médio/alto); baixo dispensa.
- **Testa o que machuca** (risco alto): caminho de erro, limite, vazamento entre
  pessoas — antes do "pronto".
- **Para na borda de toda trava dura.** Faz 100% da preparação, não cruza a borda.
- **Antes de editar qualquer arquivo:** confere que é o arquivo certo e a versão atual, não
  uma cópia velha. (Ver "trava de versão" abaixo.)

---

## A borda — travas duras (resumo; detalhe no protocolo)

Regra-mãe: na dúvida entre agir e ser seguro, **segurança ganha**. Só age sozinho no que
PROVA ser local, reversível, sem dado real, sem custo, sem efeito externo. O resto para na
borda e pede autorização. Nunca dispara efeito externo (direto OU indireto via fila/status/
automação), nunca faz destrutivo **real/externo/irreversível** (deletar/sobrescrever dado
real, desativar/enfraquecer proteção — editar arquivo local reversível por diff é trabalho
normal, não trava), nunca push/merge/deploy, nunca bypass de segurança (inclusive "preparar
script pra ele rodar"), nunca mexe em credencial — sem autorização específica daquela ação.

---

## Codex só no seguro (a inversão da borda)

`--yolo` executa comandos de verdade sem pedir permissão. Por isso o Codex **só constrói** ordem
de serviço de risco **baixo/médio** — local, reversível, sem efeito externo. Toda ordem que toca
uma trava dura (envio real, dado de pessoa, deploy, credencial, dinheiro, destrutivo real) **NÃO
vai pro Codex**: o Claude assume essa parte, prepara 100% reversível e PARA na borda pedindo o "s"
por ação (o mesmo protocolo de borda de sempre, sem mudança). Regra mecânica: antes de montar o
prompt do Codex, classifique o risco da ordem (a tabela de risco já existente); risco ALTO → não
solta o Codex, é o Claude na borda. Na dúvida, sobe um nível.

---

## O construtor (Codex) e o revisor (Claude)

O **Codex constrói** com acesso de escrita (nunca o Claude executa o trabalho aqui — essa é a
inversão). O **revisor do trabalho é o Claude** (outro modelo que o construtor — ninguém se
auto-aprova): lê o diff inteiro como um PR de contribuidor, exige prova, e itera correções na
MESMA sessão do Codex.

**Fallback se o Codex-construtor cair** (CLI ausente, erro, timeout repetido): o Claude ASSUME a
construção diretamente (ele sabe fazer) e marca a entrega "construído pelo Claude, sem o Codex".
Não trava o fluxo. No planejamento, o fallback do revisor é o do `confronto-codex.md` §5.

---

## 1) Revisar o PLANO com o Codex (só quando há plano/decisão de rumo)

Quando o passo "Preciso planejar?" gerar um mini-plano/plano parcial com decisão de rumo, o
Codex REVISA esse plano antes de construir — read-only, mecânica canônica em
`../_shared/confronto-codex.md` (variante auto-gptworker: `high`, sem `service_tier="fast"`).
Aplique a regra de ouro (§4): cada ponto do Codex vira uma linha de veredito com prova.
Critério explícito e tarefa trivial NÃO exigem revisão de plano — segue direto pra construção.

## 2) Codex constrói, Claude revisa o diff (a execução)

**Mecânica movida pro motor compartilhado (extraído daqui pra não divergir entre skills que
usam o mesmo padrão): `../_shared/codex-constroi.md` — leia antes de lançar.** Cobre: pré-requisitos, classificação de risco (o que NUNCA vai pro Codex), o
contrato (GOAL/SPEC/KEY PATHS/CONSTRAINTS/NON-GOALS/PROOF/OUTPUT), como lançar e retomar, como o
Claude revisa o diff, o fix-loop de 2 rodadas, e — importante pra qualquer skill que dependa de
ferramenta de sessão (MCP, Browser pane, aprovação visual) — a seção "O que NÃO delegar pro
Codex". O motor já gera um caminho único por chamada (`mktemp`, seção 4) — nunca hardcode
`/tmp/auto-gptworker-build.txt` fixo (sessões paralelas sobrescreveriam o relatório uma da outra).

### A trava de versão (o selo), invertida
Antes, o selo garantia que o Codex leu a versão certa do trabalho do Claude. Aqui é o
CLAUDE que revisa o diff do Codex: a defesa é confirmar que o diff revisado é o do HEAD atual
(o Codex acabou de escrever) e não um estado velho — `git diff` contra o working tree recém-escrito,
não contra um arquivo em cache. `../_shared/scripts/verify-selo.sh` segue disponível para o
caso de revisão de plano com selo.

---

## Quando PARAR (lista fechada) e quando NÃO parar

Pausa pra perguntar APENAS nestes casos. Fora deles, segue e anuncia — sem pedir licença:
1. Trava dura na borda (efeito externo, destrutivo, dinheiro, credencial, deploy, dado real).
2. Intenção ambígua de verdade (2+ leituras plausíveis do pedido).
3. Desafio fundamentado com evidência dura/operacional (formato acima).
4. Crítico retornou bloqueio real, ou não dá pra confiar na revisão (selo não bate / falhou).
5. O usuário pediu pausa ("espera", "mostra antes").

**NÃO pare** (anti-atrito): depois de uma etapa sem problema não pergunte "sigo?" — siga e
anuncie. Dentro de uma sequência (executa → crítico → corrige), anuncia o resultado e já
executa o próximo passo no mesmo fôlego, sem devolver controle no meio.

---

## Diário de bordo — documenta ENQUANTO trabalha, não no fim

O usuário sumiu; a memória da sessão não é dele. Mantenha um arquivo `DIARIO-AUTOWORK.md` na
pasta de trabalho, escrito **durante** a execução — nunca reconstruído de memória no fechamento.

O diário existe pra responder, sem o chat aberto: **o que já foi feito, o que está provado, o
que ficou assumido, e onde parou.** Cada unidade de trabalho fechada acrescenta uma entrada com
o que mudou, o comando + saída que provou aquilo (ou a marca `assumido, NÃO testado`), e o que
o crítico apontou. Trava dura encontrada na borda entra também, com a autorização que falta.
Cada unidade fechada registra também **o que o Codex construiu** (resumo do relatório dele) +
**o veredito do Claude no diff** (o que passou/falhou na revisão) + rodadas de fix usadas.

Regras do arquivo: uma lição por entrada, com resumo de 1 linha no topo; registra tanto correção
quanto abordagem que se confirmou, sempre com o porquê; **não** duplica o que o repo, o diff ou
o histórico do git já guardam; atualiza a entrada em vez de criar uma nova sobre o mesmo ponto;
apaga a lição que se provou errada. Antes de começar, leia o diário se ele já existir — ele é
o estado da execução anterior.

Segredo e dado pessoal real nunca entram no diário (vale a mesma máscara do manifesto do crítico).

Risco baixo dispensa o diário — tarefa de 2 linhas não precisa de rastro.

---

## Entrega final — linguagem de diretor

O usuário pode não ser programador. A entrega que chega nele é traduzida: o que mudou e o que ganha,
em português comum. Termo que ele conhece (deploy, merge, commit, MCP, webhook, cache) pode
aparecer; o resto vira analogia ou fica num bloco técnico que ele abre só se pedir.

**Graduado pelo risco:**
- **Risco baixo:** "Feito + a conferida que fiz". 2 linhas, sem cerimônia.
- **Risco médio / alto:** estrutura completa, separando visível **PROVEI** (com evidência) vs
  **ASSUMI** (não testado, com o porquê), mais: Feito · o que mudou · validações (comando +
  resultado, dizendo se houve mock/filtro/corte) · problemas (com referência) · **⛔ depende
  de você** (toda trava dura na borda + risco aberto).
