---
name: auto-worker
description: "Modo largar-e-esquecer: o Claude EXECUTA a tarefa com protocolo de segurança e verificação embutido, e o Codex confronta o trabalho antes de fechar. Acionar por comando: /auto-worker <tarefa>. Quando a tarefa tocar produção, dado real de pessoa, credencial, dinheiro, envio/publicação, deploy, infra ou mudança destrutiva, prepara tudo de forma reversível e PARA na borda até autorização explícita — não executa a ação sensível sozinha. Fronteira: ESTUDAR um problema sem executar = /auto-think; planejar produto novo do zero = /planejar."
---

# auto-worker

Modo de trabalho pro usuário **largar uma tarefa e sumir**. O trabalho é executado e
conferido sozinho; ele só reaparece pra DECISÃO real ou pra escolher entre opções no fim.
Repo-agnóstica — serve pra qualquer tarefa, em qualquer projeto.

**Quem manda no esforço é o usuário, não a skill.** Quão fundo ir — quantas rodadas de revisão,
quanto investigar — é decisão dele; a skill nunca escala isso sozinha. Esta skill é só o
**protocolo de COMO trabalhar**: segurança, verificação e honestidade. Ele vale igual numa
tarefa rápida ou numa pesada — muda o esforço (dele), não o protocolo.

Meta central: **some SEM dar erro**, porque a verificação é estrutural, não depende do usuário olhando. Se você se pegar querendo "encurtar a conferência pra ele pegar o erro",
parou: a saída é fazer a verificação ser real, não chamar ele.

`references/protocolo.md` é o contrato de segurança e verificação — vale pro trabalho todo (e,
quando o trabalho for dividido entre vários agentes, vai embutido em cada um). Leia antes de começar.

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

Cada executor segue `references/protocolo.md`. Núcleo:
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

## O executor e o crítico

O Claude executa — numa sessão única, ou dividido entre vários agentes quando **o usuário**
escolher ir mais fundo (a skill não escala isso sozinha). O **crítico do trabalho é o Codex**
(outro modelo, nunca o próprio executor — ninguém se auto-aprova).

**Fallback se o Codex não estiver disponível** (CLI ausente, erro, timeout repetido): o crítico
vira um agente Claude SEPARADO e adversarial (NUNCA o mesmo que executou), com o parecer marcado
"revisão de menor garantia — mesmo modelo". Em risco ALTO, revisão só do mesmo modelo NÃO basta:
estado final BLOQUEADO até o Codex voltar ou o usuário autorizar explicitamente assumindo o risco.

---

## Revisar com o crítico (Codex) + a TRAVA DE VERSÃO

O crítico nunca é o próprio executor (não se auto-aprova). É o Codex, via Bash.

**A mecânica completa mora no motor compartilhado `../_shared/confronto-codex.md`** (por que
stdin, o teto `alarm 900`, o selo de versão, o fallback se o Codex cair, o mascaramento de dado
e a regra de ouro de filtrar com prova) — essa é a fonte única; se a mecânica mudar lá, esta
seção acompanha. O comando abaixo é a **variante do auto-worker**, deliberadamente mais
conservadora que a do `/auto-think`: `model_reasoning_effort="high"` (não `xhigh`) e **sem**
`service_tier="fast"`, porque aqui é revisão de trabalho rotineira a cada passo, não o estudo
caro de vários ângulos — não vale forçar a via paga rápida em toda entrega.

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 -c model_reasoning_effort="high" --skip-git-repo-check - < /tmp/critico-input.md
```
O `perl -e 'alarm 900'` é o teto de 15 min: Codex que passa disso travou, o SO mata sozinho
(`timeout` puro não existe no Mac, `perl` existe no Mac e no Windows). Travou → mata e refaz uma
vez; travou de novo → cai no fallback (crítico vira agente Claude separado).

**Quantas rodadas de revisão é decisão do usuário** (faz parte do esforço dele). O que a
skill garante: risco ALTO exige pelo menos 1 revisão VÁLIDA antes de fechar — sem ela,
BLOQUEADO. Nenhum teto de rodadas vira aprovação por cansaço: sobrou risco na última →
BLOQUEADO, não "quase pronto". E o crítico só BLOQUEIA por segurança, objetivo não atendido
ou prova quebrada; melhoria não-bloqueante vira "opcional", não trava.

### A trava de versão (o selo) — pega "revisou/editou o arquivo errado"
Erro recorrente: o Claude entrega a versão nova mas o Codex revisa a anterior; ou alguém
edita uma cópia velha. Três defesas, nenhuma presume nada:

1. **Antes de mandar:** confere que o arquivo que vai pro crítico é a última versão (não uma
   cópia defasada). Se o Claude corrigiu mas não salvou por cima → para aqui, antes de revisar.
2. **O revisor SELA o PACOTE que leu:** o crítico recebe um manifesto (o diff + lista de
   arquivos + comandos + saídas) e carimba no topo a impressão digital (hash) do manifesto
   inteiro — não de um arquivo só, senão não prova que leu o pacote certo. Instrua o crítico a
   carimbar como PRIMEIRA seção, **EXATAMENTE neste formato literal** (o `scripts/verify-selo.sh`
   procura esta frase; outro formato faz a conferência reportar "sem selo" mesmo com pacote certo):

   ```
   ## Selo
   - Manifesto (sha256): <hash>
   ```

   Se não conseguir, escrever a palavra literal `SELO INDISPONIVEL`. O script
   `scripts/verify-selo.sh` confere se o hash bate com o manifesto que foi enviado. Não
   bateu → o Codex leu versão/pacote velho → DESCARTA o parecer e re-roda só ele, na mesma rodada.
3. **O revisor falhou** (travou / sem resposta / não carimbou) → NUNCA presume "aprovado"
   nem "reprovado". Classifica (lento / travou / sem output). O que fazer depende do risco:
   risco **baixo** não exige crítico (não se aplica); **médio** pode seguir marcado "não
   revisado" se não houver trava dura; **alto** NÃO pode seguir sem revisão válida → estado
   final BLOQUEADO até re-rodar com sucesso ou o usuário autorizar explicitamente assumindo o risco.

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
