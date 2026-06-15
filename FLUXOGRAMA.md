# Fluxograma — plugin `dev`

Plugin com **quatro skills**. Cada uma é uma **porta de entrada independente** — você pode começar
por qualquer uma:

- **🧠 /planejar** — desenha um produto/software do zero, **descobre como o problema já foi resolvido lá fora** e **audita a planta** antes de construir.
- **🔬 /auto-think** — **estuda um problema difícil a fundo** (vários ângulos em paralelo, confronta os achados com o Codex) e entrega **soluções com veredito**. Não executa — para na recomendação.
- **⚙️ /auto-prompt** — executa uma tarefa do início ao fim, se corrigindo sozinho, e **verifica a casa** construída.
- **🪢 /handoff** — salva o ponto exato do trabalho e passa o bastão pra outra sessão.

Elas também formam **um ciclo**: o plano sai do `planejar` (ou a solução escolhida sai do
`auto-think`) e vai pro `auto-prompt` pra ser executado; se o trabalho fica longo e o contexto
enche, o `auto-prompt` chama o `handoff`, e numa sessão nova você retoma de onde parou.

> A grande diferença que costuma confundir: **`planejar` revisa o PLANO** (a planta, antes de
> existir código) e **`auto-prompt` revisa o que foi FEITO** (a casa pronta). Não é a mesma
> conferência duas vezes — são dois momentos diferentes.
>
> E entre os dois "pensadores": **`planejar` parte de uma IDEIA de produto** (desenha algo novo);
> **`auto-think` parte de um PROBLEMA difícil** (investiga e recomenda). Os dois entregam pro
> `auto-prompt` executar.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'fontSize':'15px',
  'fontFamily':'Helvetica, Arial, sans-serif',
  'lineColor':'#1f6b4f',
  'edgeLabelBackground':'#ffffff'
}}}%%
flowchart TD
    START(["💡 Você chega com algo pra fazer"])
    PORTAS{"Por onde começar?<br/>as 4 portas são independentes"}
    START --> PORTAS

    E1(["ideia / produto novo"])
    E2(["problema difícil pra estudar"])
    E3(["tarefa pronta pra largar"])
    E4(["recomeçar sessão · reduzir contexto"])
    PORTAS --> E1 --> PINTRO
    PORTAS --> E2 --> TINTRO
    PORTAS --> E3 --> AINTRO
    PORTAS --> E4 --> HINTRO

    %% ───────── PLANEJAR ─────────
    subgraph PLANEJAR[" "]
        direction TB
        PINTRO["<b>🧠 /planejar</b> — desenha o produto e <b>audita a planta</b> (antes de construir)<br/>você aprova entre quase todas as fases (7→8 segue direto)"]
        P0["<b>Fase 0 · Preflight</b><br/><i>confere as ferramentas que vai precisar</i>"]
        P1["<b>1 · Brainstorm</b><br/><i>define o problema e o escopo do MVP</i>"]
        P1B["<b>1b · Como já resolveram isso</b> (prior art)<br/><i>busca soluções existentes, peneira pela sua realidade e compara com o jeito simples · recomendada, pulável</i>"]
        P2["<b>2 · Discovery</b><br/><i>entende cliente, marca e mercado</i>"]
        P3["<b>3 · Pesquisa técnica</b><br/><i>escolhe a stack com dados, não achismo</i>"]
        P4["<b>4 · Design</b><br/><i>estilo, mockups e documento visual</i>"]
        P5["<b>5 · Escreve o plano</b><br/><i>passos miúdos com o código já pronto</i>"]
        P6["<b>6 · Auditoria do PLANO</b><br/><i>especialistas + <b>Codex GPT</b> revisam a planta</i>"]
        P7["<b>7 · Correção</b><br/><i>aplica no plano tudo que a auditoria achou</i>"]
        P8["<b>8 · Montagem</b><br/><i>plano final, limpo, pronto pra executar</i>"]
        PINTRO --> P0 --> P1 --> P1B --> P2 --> P3 --> P4 --> P5 --> P6 --> P7 --> P8
    end

    P8 --> PONTE{"Oferecer execução com a auto-prompt?<br/>opcional, só com seu OK"}
    PONTE -->|"prefiro de outro jeito"| FIMP(["📄 Plano salvo em docs/"])
    PONTE -->|"você aceita"| CONTRATO["<b>📄 Contrato de execução</b><br/><i>trava o objetivo e o que NÃO reabrir</i>"]
    CONTRATO --> AINTRO

    %% ───────── AUTO-THINK ─────────
    subgraph AUTOTHINK[" "]
        direction TB
        TINTRO["<b>🔬 /auto-think</b> — estuda o problema a fundo e <b>entrega soluções com veredito</b> (não executa)<br/>fundo é o padrão; você freia dizendo 'rápido' · o esforço é seu"]
        T1["<b>1 · Enquadra o problema</b><br/><i>separa fato de suposição, decide a fundura</i>"]
        T2["<b>2 · Estuda vários ângulos EM PARALELO</b><br/><i>técnico · simplicidade · custo/risco · precedente · contexto interno</i><br/><i>se é de uma tecnologia com dono → puxa a <b>doc oficial</b> + sua <b>skill instalada</b></i>"]
        T3["<b>3 · Codex GPT confronta</b> — 1ª rodada<br/><i>tenta DERRUBAR cada candidata</i>"]
        T4["<b>4 · Re-cava o que ficou aberto</b><br/><i>só dúvida que muda a decisão · teto duro contra espiral</i>"]
        T5["<b>5 · Codex GPT confronta</b> — 2ª rodada<br/><i>escolhe entre as que sobraram</i>"]
        T6["<b>6 · Entrega soluções com veredito</b><br/><i>a recomendada + alternativas reais + o que o confronto matou</i>"]
        TINTRO --> T1 --> T2 --> T3 --> T4 --> T5 --> T6
    end

    T6 --> TPONTE{"Quer executar a escolhida?<br/>opcional, só com seu OK"}
    TPONTE -->|"é só estudo"| FIMT(["📄 Soluções entregues + detalhe em .md"])
    TPONTE -->|"executa a A"| AINTRO

    %% ───────── AUTO-PROMPT ─────────
    subgraph AUTO[" "]
        direction TB
        AINTRO["<b>⚙️ /auto-prompt</b> — executa até o fim, uma tarefa por vez, e <b>verifica a casa</b><br/>entra do plano (planejar) ou da solução (auto-think) acima, OU direto do zero · o esforço é seu"]
        ARISK{"Qual o risco da tarefa?<br/>ele define quanto verificar"}
        NIVEL["<b>O nível define QUANTO verificar</b> — as travas duras valem em todos:<br/>🟢 <b>baixo</b> · faz e confere (sem crítico obrigatório)<br/>🟡 <b>médio</b> · + <b>Codex GPT</b> confronta antes de fechar<br/>🔴 <b>alto</b> · + testa o que machuca + travas + 1 revisão válida (sem revisor = BLOQUEADO)"]
        AEXE["<b>Claude executa a TAREFA ATUAL e PROVA cada passo</b><br/><i>uma tarefa por vez; o que não dá pra provar vira pendência marcada, nunca passa como pronto</i>"]
        ACRIT["<b>Codex GPT confronta essa tarefa</b><br/><i>tenta refutar: funciona? não vazou? não quebrou?</i>"]
        ADEC{"Tarefa fechou?<br/>até 3 rodadas"}
        AMORE{"Falta tarefa no plano?"}
        AINTRO --> ARISK --> NIVEL --> AEXE --> ACRIT --> ADEC
        ADEC -->|"ainda não → corrige e refaz"| AEXE
        ADEC -->|"sim, fechou"| AMORE
        AMORE -->|"sim → próxima tarefa"| AEXE
    end

    AMORE -->|"não, plano completo → produto pronto"| BORDA{"Bateu numa borda dura?<br/>dinheiro · envio · deploy ·<br/>apagar dado real · credencial"}
    ADEC -->|"sobrou risco na 3ª rodada<br/>ou revisão inválida"| BLOQ(["⛔ BLOQUEADO<br/>não fecha sozinho; chama você"])
    AMORE -->|"ficou longo → passa o bastão"| HINTRO
    BORDA -->|"sim"| PARA(["⛔ Para e te chama<br/>pra decidir"])
    BORDA -->|"não"| ENTREGA(["✅ Entrega traduzida:<br/>o que PROVEI vs o que ASSUMI"])

    %% ───────── HANDOFF ─────────
    subgraph HANDOFF[" "]
        direction LR
        HINTRO["<b>🪢 /handoff</b><br/>salva o ponto e passa o bastão"]
        H0["<b>Ancora no git</b><br/><i>branch, commit, o que mudou</i>"]
        H1["<b>Captura ESTADO + PONTEIROS</b><br/><i>fato vs suposição; não inventa regra</i>"]
        H2["<b>💾 Salva o .md e abre na tela</b><br/><i>e te diz onde guardou</i>"]
        HINTRO --> H0 --> H1 --> H2
    end

    H2 --> NOVA(["🔄 Sessão nova lê o arquivo e retoma o trabalho"])
    NOVA -. "volta ao ponto exato (aqui: a execução)" .-> AINTRO

    %% ───────── cores (uma família por skill) ─────────
    %% planejar=índigo · auto-think=teal · auto-prompt=verde · handoff=âmbar · estrutura=cinza
    classDef cabP fill:#4338ca,color:#ffffff,stroke:#a5b4fc,stroke-width:1.5px;
    classDef cabT fill:#0f766e,color:#ffffff,stroke:#5eead4,stroke-width:1.5px;
    classDef cabA fill:#15803d,color:#ffffff,stroke:#86efac,stroke-width:1.5px;
    classDef cabH fill:#c2410c,color:#ffffff,stroke:#fdba74,stroke-width:1.5px;
    classDef stepP fill:#ffffff,color:#312e81,stroke:#6366f1,stroke-width:1.5px;
    classDef stepT fill:#ffffff,color:#134e4a,stroke:#14b8a6,stroke-width:1.5px;
    classDef stepA fill:#ffffff,color:#143f30,stroke:#1f6b4f,stroke-width:1.5px;
    classDef stepH fill:#ffffff,color:#7c2d12,stroke:#ea580c,stroke-width:1.5px;
    classDef decP fill:#4338ca,color:#ffffff,stroke:#312e81,stroke-width:1.5px;
    classDef decT fill:#0f766e,color:#ffffff,stroke:#134e4a,stroke-width:1.5px;
    classDef decA fill:#15803d,color:#ffffff,stroke:#143f30,stroke-width:1.5px;
    classDef porta fill:#ffffff,color:#0f172a,stroke:#94a3b8,stroke-width:1.5px;
    classDef start fill:#334155,color:#ffffff,stroke:#0f172a,stroke-width:1.5px;
    classDef hub fill:#475569,color:#ffffff,stroke:#0f172a,stroke-width:1.5px;
    classDef fim fill:#1e293b,color:#ffffff,stroke:#0f172a,stroke-width:1.5px;

    %% cabeçalhos (forte na cor da skill)
    class PINTRO cabP;
    class TINTRO cabT;
    class AINTRO cabA;
    class HINTRO cabH;
    %% passos (cartão branco, borda da cor da skill)
    class P0,P1,P1B,P2,P3,P4,P5,P6,P7,P8,CONTRATO stepP;
    class T1,T2,T3,T4,T5,T6 stepT;
    class NIVEL,AEXE,ACRIT stepA;
    class H0,H1,H2 stepH;
    %% decisões (losango forte na cor da skill)
    class PONTE decP;
    class TPONTE decT;
    class ARISK,ADEC,AMORE,BORDA decA;
    %% estrutura compartilhada (cinza neutro)
    class START start;
    class PORTAS hub;
    class E1,E2,E3,E4 porta;
    class FIMP,FIMT,PARA,ENTREGA,NOVA,BLOQ fim;

    %% molduras — cor bem fraquinha em volta de cada skill
    style PLANEJAR fill:#f1f1fc,stroke:#6366f1,stroke-width:2px;
    style AUTOTHINK fill:#eef7f5,stroke:#14b8a6,stroke-width:2px;
    style AUTO fill:#f0f8f1,stroke:#1f6b4f,stroke-width:2px;
    style HANDOFF fill:#fdf6ee,stroke:#ea580c,stroke-width:2px;
```
