# Changelog — cass (antigo Titan)

## 3.3.0 — 2026-09-25

- **`gpt-builder` passa a se chamar `gpt-implementar`.** Ela faz o mesmo trabalho da `implementar`; só muda quem digita o código (o GPT, e o Claude confere). O nome novo deixa o par visível: `/cass:implementar` e `/cass:gpt-implementar`. Quem digitar o nome antigo ainda cai nela, porque a descrição cita `/gpt-builder`. Citações atualizadas em todas as skills, no README, no INSTALL, no instalador e no mapa `docs/qual-sua-situacao.svg`.

## 3.2.0 — 2026-09-24

- **`handoff` enxuta (de ~2.500 pra ~900 palavras).** Sai o leitor cego via Codex (`references/leitor-cego.md` e `scripts/cold-read.sh`): nos testes ele não evitou nada. Entram três coisas medidas:
  - **Trava do git.** Arquivo que a conversa criou ou alterou e está sem commit: a skill para, lista os arquivos, propõe a mensagem de commit e espera o sim. Arquivo que a conversa nunca tocou não trava e aparece como "fora deste trabalho".
  - **Trabalho novo.** Quando o trabalho atual acabou (PR mergeada, "do zero"), a âncora passa a ser o ramo principal e o documento manda abrir ramo novo a partir dele. Antes, ancorava no ramo encerrado e a sessão nova dava falso alarme.
  - **Segredo nunca entra no documento**; ele aponta onde o segredo mora.
  Teste com 26 agentes isolados, comparando sem skill, a versão antiga e a nova: a trava parou 4 de 4 (a antiga, 0 de 2); token fora do documento em 4 de 4 (a antiga, 1 de 4); âncora certa ao começar do zero em 3 de 3 (a antiga, 0 de 3).
- **`implementar` e `gpt-builder`: cada issue começa com o seu próprio sim** (PR #6). "Merge feito" ou "ok" fecha a issue atual; não autoriza a próxima.

## 3.1.0 — 2026-09-24

- **Nova skill `ask-me`.** Te entrevista em rodadas curtas (até 4 perguntas, cada uma com a resposta recomendada) antes de mandar uma tarefa pro agente, confere a cada rodada se uma resposta nova contradiz um limite já dado, e fecha com o pedido pronto pra colar. README, FLUXOGRAMA, INSTALL e manifestos passam a contar dez skills.
- **Desenho novo no topo do README** (`docs/como-se-encaixam.svg`): linha de montagem pensar → construir → conferir, com a volta quando reprova e as avulsas numa faixa à parte; acompanha o modo escuro do GitHub. O diagrama antigo (mermaid) de "Como elas se encaixam" saiu.

## 3.0.0 — 2026-09-23

O plugin passa a se chamar **`cass`** (antes `Titan`) e o repositório passa a ser o próprio catálogo de instalação. **Quebra:** quem instalou o `Titan` pelo catálogo `cassiano.diniz` precisa reinstalar (o catálogo antigo saiu do ar).

- **Instalação consertada.** O README mandava usar o catálogo `cassianodiniz/cassiano.diniz`, que não existe mais. Agora o repositório traz `.claude-plugin/marketplace.json`: `/plugin marketplace add cassianodiniz/cass` + `/plugin install cass@cass`. `install.sh` e `INSTALL.md` acompanham.
- **Um modelo só pra falar com o GPT: `gpt-6-sol`.** `gpt-optimizer` (esforço `high`), `auto-think` e o motor `_shared/confronto-codex.md` (antes `gpt-5.6-sol`/`gpt-5.6-terra`) e o leitor cego do `handoff` (antes `gpt-5.6-terra`). O `gpt-6-sol` recusa `service_tier="flex"` (HTTP 400), então o `gpt-optimizer` e o `handoff` deixaram de pedir essa via. Testado com chamada real, rodada 1 e rodada 2.
- **Sincronizadas com as versões locais:** `spec-plan` (oferece os dois construtores no fim), `implementar` (relatório abre pelo que precisa do usuário), `build-review` (relatório abre pelo veredito), `gpt-builder` (passa a usar as referências do `implementar`; a pasta `references/` própria saiu), `gpt-optimizer` e `handoff` (ganha `references/leitor-cego.md` e o aviso de árvore suja).
- **Auditoria de funcionamento:** removidas as citações a skills que não vêm no plugin (`/revisar`, `/gpt-review`, `/codex-build`, `/setup-matt-pocock-skills`); corrigidos dois links quebrados em `build-review/references/checklist-format.md`; tirados trechos que se dirigiam ao autor como se fosse o usuário; `planejar` passa a oferecer `implementar`/`gpt-builder` pra construir o plano; `auto-think` passa a citar `spec-plan` na fronteira.
- **README reescrito** pra quem está começando: guia "Qual eu uso?", seção sobre as skills parecidas, detalhe técnico de cada uma, link pros estudos de IA do autor e o prompt de instalação do guia de economia de tokens.

## 2.4.0 — 2026-09-20

Re-sincroniza `spec-plan`, `build-review` e `implementar` com as versões locais evoluídas. Espelho completo (a versão local é a verdade): o conteúdo novo entra e o que a versão local não tem é removido. Aditivo no todo, com uma remoção de referência cruzada anotada abaixo.

- **`implementar` ganha TDD embutido.** Nova pasta `references/tdd/` (`tdd.md`, `tests.md`, `mocking.md`) com o laço vermelho → verde: o que é um bom teste, onde os testes moram e as regras do loop. O SKILL.md manda lê-la antes do primeiro teste e agora trabalha a checklist **um item por vez** (escreve o teste, vê falhar, implementa o mínimo, roda a prova), com stage por nome (`git add <caminho>`) pra cada commit conter só o que aquela peça mudou.
- **`implementar`: árvore limpa + marca de início.** Antes de tudo, `git status --porcelain` tem que estar limpo (só caminhos do plano ou de `.checks/`); qualquer outra coisa é trabalho inacabado de alguém e a skill para e pergunta. Com a árvore limpa, cria o **commit-marco** `chore(checks): start <nome do checklist>` **antes** de escrever a checklist — é a estaca que diz onde o trabalho começou. Logo após, roda a suíte inteira uma vez e registra o resultado na linha `Suite before start` (teste já vermelho ali vira pré-existente no relatório).
- **`build-review` acha a base pela marca, não deduzindo.** O ponto fixo `<base>..HEAD` agora é o commit-marco que a construção deixou (`git log --grep="^chore(checks): start …"`), não mais uma leitura do `git log` (três leituras davam três bases). Sem marco, ou mais de um → para e pergunta. Novo sinal de alerta na lista de "nunca".
- **`implementar/checklist.md` enxuto.** O formato longo saiu; agora delega ao formato canônico único que o `$build-review` lê (`build-review/references/checklist-format.md`) e parte da `Varredura (decidida na entrevista)` da issue quando ela existe.
- **`spec-plan` limpa resíduo.** Removido o `references/rules-phase-2-spec.md` (versão antiga em inglês; o conteúdo já vive no `phase-2-spec.md`). `phase-1-investigate.md` expandido.
- **`agents/openai.yaml`** adicionado em `spec-plan` e `implementar` (política do Codex: sem invocação implícita, casando com o `disable-model-invocation` do cabeçalho).
- **Consequência do espelho:** as referências cruzadas ao `/gpt-builder` que o 2.3.0 tinha adicionado no rodapé de fluxo de `spec-plan` e `implementar` **saíram** (a versão local não as tem) e esse rodapé de `implementar` voltou ao inglês. `/gpt-builder` segue no plugin; só deixou de ser citado no rodapé dessas duas skills.

## 2.3.0 — 2026-09-17

Sincroniza `spec-plan` e `implementar` com as versões locais evoluídas, remove o legado "grelhar" e corrige a documentação. Aditivo, sem quebra.

- **`spec-plan` atualizada.** Adota o fluxo de **issues fatiadas** (cada issue é um arquivo autocontido em `docs/plans/<plano>/issues/`, pronta para uma sessão separada de construção) no lugar do antigo `PLAN.md` na raiz. Descrição reescrita em PT (dispara só por invocação explícita) e `disable-model-invocation` reposto.
- **`implementar` atualizada.** Ganha o **contrato de origem do `spec-plan`** (implementa uma issue por vez, com checklist exclusivo por issue) e `disable-model-invocation` reposto. Corrigido resíduo que ainda citava `.checks/<feature>.md`.
- **Handoff aponta para os dois construtores.** `spec-plan` e `implementar` deixam explícito: construir é escolha do usuário — `/implementar` (o próprio Claude) ou `/gpt-builder` (um subagente GPT/Codex constrói e o Claude revisa o diff).
- **Legado "grelhar" removido** de `plugin.json`, README, FLUXOGRAMA, da descrição do `spec-plan` e do corpo do `gpt-builder` (resquício da skill de origem). No lugar: "sabatina até o entendimento comum".
- **Documentação corrigida:** README e FLUXOGRAMA diziam "sete skills" — são **nove**. Descrição do `auto-think` passa a apontar os dois executores.
- Removido resíduo `/setup-matt-pocock-skills` em `spec-plan/references/rules-phase-2-spec.md`.
- **`planejar` substituída pela versão do mentor (Thales) por inteiro** — traz a leva de endurecimento das Fases 2A/4/6/7/8/9 (busca em tiers, realidade do plano Cloudflare, `Falha se:`, `Recursos nomeados`, correção serial com auditoria de costuras, `prova` no features.json + portão `validar-features.js`) e a expansão de `auth-multitenancy.md`. Consequência: sai o caminho de design **Claude Design** (a versão do mentor tem só `design-lab` e `design-taste-frontend`) e as referências `codex-revisor.md`/`descoberta-prior-art.md`, que não existem na versão dele. O `evals/evals.json` foi mantido, mas é da versão anterior.

## 2.2.0 — 2026-09-15

Adiciona a `implementar` como executor alternativo. Aditivo, sem quebra.

- **`implementar` — skill nova.** Constrói uma spec já decidida com o **próprio Claude** (TDD nas junções pré-combinadas, checklist com prova por item, commits em pedaços coerentes na branch atual) — a alternativa à `gpt-builder`, que delega a construção ao Codex. O fluxo público passa a ser `spec-plan` → **`/implementar` ou `/gpt-builder`** → `build-review`.
- Ponteiros alinhados: `spec-plan` oferece as duas; `build-review` entra depois de qualquer uma das duas.

## 2.1.0 — 2026-09-15

Adiciona a `build-review` e liga o fluxo entre as skills. Aditivo, sem quebra.

- **`build-review` — skill nova.** Maestro que dispara três revisores independentes sobre o mesmo diff — Standards (padrões da casa) + Spec (aderência ao pedido) + Fiscal (prova cada item da checklist rodando os testes e injetando defeito). Consome a checklist `.checks/<feature>.md` e o diff que a `gpt-builder` já deixa.
- **Fluxo wired (ponteiro de "próximo passo", edição mínima):** `spec-plan` → `gpt-builder` → `build-review`. A `gpt-builder` passa a oferecer `/build-review` como pente-fino após a construção (complementar ao fiscal interno dela, que só prova aderência à spec).

## 2.0.0 — 2026-09-15

Troca do executor e duas skills novas de especificação e pesquisa. **Quebra** (mudança de nome de skill): quem instalou a `auto-gptworker` precisa passar a chamar a `gpt-builder`.

- **Executor trocado: `auto-gptworker` removida, `gpt-builder` no lugar.** A `gpt-builder` é a versão white-label da `codex-build` local: recebe uma **spec congelada** (ex.: `PLAN.md`), entrega pro Codex construir com acesso total (`--yolo`), o **Claude revisa o diff inteiro** como um PR, um **fiscal independente** prova cada item do checklist no HEAD, fix-loop limitado (2 rodadas) e **portão humano** antes de qualquer commit. É spec-driven — difere do protocolo graduado por risco da antiga `auto-gptworker`. Traz suas próprias referências em `references/` (`checklist.md`, `contrato.md`, `fiscal.md`, `relatorio.md`); não usa o `_shared`.
- **`spec-plan` — skill nova.** Grelha um plano/decisão/ideia até o entendimento comum e produz uma **spec congelada** pra construir com IA. Fecha o ciclo com a `gpt-builder`: no fim da spec, oferece encaminhar pra `/gpt-builder` construir; e a `gpt-builder`, sem spec, aponta de volta pra `/spec-plan`.
- **`search` — skill nova.** Pesquisa profunda via **Exa** com procedência: cada número volta com a página, a frase e a data em que foi lido. Requer conta Exa (OAuth ou `EXA_API_KEY`). O destino de arquivamento é uma pasta local `search-findings/` na pasta de trabalho.
- **`auto-think` — confronto de volta pro Codex/GPT.** A v1.8.0 tinha trocado o confronto pra Opus (portabilidade); volta pro **Codex/GPT** (mecânica da fonte local), mantendo a trava de mascarar dado real antes de qualquer coisa sair pra fora.
- **`gpt-optimizer`** — sem mudança de modelo (segue `gpt-5.6-sol`).
- **`planejar` e `handoff`** — inalteradas, exceto a referência ao executor, que passou de `auto-gptworker` pra `gpt-builder`.
- **Limpeza:** `_shared/codex-constroi.md` removido (só a `auto-gptworker` usava); referências cruzadas religadas.

## 1.9.0 — 2026-07-15

Remove a skill `auto-worker` (Claude executa sozinho) — o plugin passa a ter **uma única skill executora**, a `auto-gptworker` (Codex constrói, Claude revisa o diff).

- **`auto-worker` removida.** O contrato de segurança/verificação que ela trazia (`references/protocolo.md`) e o verificador de selo (`scripts/verify-selo.sh`) foram movidos pra `_shared/` — continuam usados por `auto-gptworker` e `auto-think`, agora como propriedade compartilhada do plugin, não de uma skill específica.
- **Referências reescritas** em `auto-gptworker`, `auto-think`, `_shared/confronto-codex.md`, `gpt-optimizer` e `planejar` (a "ponte de execução" do fim do plano agora oferece `/auto-gptworker`, com a linguagem ajustada pro modelo invertido: Codex constrói, Claude audita o diff — não é mais "Claude executa sozinho").
- **README.md e FLUXOGRAMA.md atualizados** (tabela de comandos, texto e os dois diagramas Mermaid) pra refletir `auto-gptworker` como a skill executora.
- **Limite honesto:** os dois diagramas Mermaid (README e FLUXOGRAMA) já divergiam um pouco um do outro antes desta mudança (drift pré-existente, não introduzido aqui); ambos foram corrigidos de forma independente, mas não foram reconciliados entre si.

## 1.8.0 — 2026-07-15

Sincroniza mecânica que estava só na fonte local desde a publicação da 1.7.0, e inclui uma skill nova (branch pública de uma skill interna, adaptada e renomeada).

- **auto-gptworker — skill nova.** Modo largar-e-esquecer invertido: o Claude planeja/orquestra/revisa e o **Codex constrói** (mão na massa, acesso total de escrita); Codex só é solto no trabalho reversível/local, a borda sensível fica com o Claude. Traz o motor compartilhado `_shared/codex-constroi.md` (contrato GOAL/SPEC/KEY PATHS/CONSTRAINTS/NON-GOALS/PROOF/OUTPUT, classificação de risco, fix-loop de 2 rodadas).
- **auto-think — confrontador trocado de Codex pra Opus** nas 2 rodadas de confronto (os ângulos/síntese continuam via GPT-5.6); documenta uma decisão de risco aceito sobre o Codex ler o diretório de trabalho real nos ângulos/síntese; ajustado onde o `.md` de detalhe da entrega é salvo.
- **gpt-optimizer — modelo bump pra GPT-5.6** (`gpt-5.6-sol`, era GPT-5.5); revisor ganhou memória de sessão (`THREAD_FILE`/`thread_id`) — a rodada 2 retoma a MESMA sessão do Codex em vez de simular histórico.
- **auto-worker — esforço do revisor Codex ajustado** (herda o `medium` global em vez de forçar `high`, já que é revisão de trabalho rotineiro, não estudo de vários ângulos).
- **handoff — script `cold-read.sh` também no modelo GPT-5.6.**

## 1.7.0 — 2026-07-01

Versiona melhorias que já estavam na fonte local (pós-25/06) mas sem número de versão, e publica no repo público `cassianodiniz/Titan` (lá em versão neutralizada/white-label).

- **handoff — teste do "leitor cego" (Codex)** + script `skills/handoff/scripts/cold-read.sh`, âncora de validade/HEAD, ficha de decisão (ADR) pra decisão de chat, primeira ação obrigatória de conferência, e entrega como prompt colável.
- **auto-worker — carimbo de versão (sha256)** do pacote revisado, ligado ao motor compartilhado.
- **auto-think — trava de entrada** (espelha o pedido, confirma o alvo antes de cavar).
- **_shared — motor do Codex com variantes por skill** (fonte única) + `planejar` trocando Perplexity→Exa.

> Nota: a versão local mantém as menções pessoais (nome, `/zaprepair`); no repo público esses trechos foram neutralizados. Local e público ficam no mesmo número (1.7.0), conteúdo idêntico exceto pela personalização.

## 1.6.1 — 2026-06-24

### Mudado (auditoria do `gpt-optimizer`)
- **Passo 5 (Apresentar) reescrito — a dor real do Cassiano.** O passo mandava "apresente curto / veredito numa linha / traduzido", o que fabricava a saída abstrata que ele não conseguia decidir. Agora o contrato é **decisão primeiro, concreto sempre**: a decisão em jogo + veredito com efeito prático + cada furo com a evidência específica e o "na prática" + decisão A/B quando é dele. Tamanho passa a servir o entendimento, não o aperto. Reforçado também no prompt do GPT: cada ponto exige QUAL premissa/linha/valor, proibido "premissa frágil" solto.
- **Selo (impressão digital sha256) removido.** Era trava contra "GPT leu versão velha", mas o manifesto é escrito e enviado no mesmo fôlego — não há versão velha; o selo só pedia o GPT devolver uma string que a gente entregou. Removidos os passos de selar/conferir e o `scripts/verify-selo.sh`. (auto-worker mantém o selo no fluxo dele, com cópia própria.)
- **Revisor agora é só-leitura.** `run-gpt.sh` trocou `--sandbox workspace-write` por `--sandbox read-only` — uma revisão recebe o alvo via stdin, não precisa nem pode escrever no workspace. Smoke-testado com codex real (read-only, exit 0).
- **Erro do Codex não é mais escondido.** `run-gpt.sh` parou de mandar stderr pra `/dev/null`; agora **tenta 2x** (1ª falha costuma ser transitória) e, se falhar de vez, devolve `CODEX_FAILED` com o motivo real — pra avisar o usuário em vez de cair calado pro fallback fingindo que o GPT rodou.
- **Gatilhos enxugados.** A descrição tinha ~17 frases-gatilho (várias genéricas como "reflete isso"/"contraponto" que disparavam em conversa normal e pisavam no `auto-think`). Agora a skill é **só sob invocação explícita** (comando `/gpt-optimizer` ou chamar pelo nome) — pedido do Cassiano: "essa skill não precisa de gatilhos, eu só uso pela barra".
- **Fricção de setup limpa.** Tirada a cerimônia de `export TMP/GPT` e os caminhos de exemplo que nem existiam no Mac (`~/.claude/skills/Titan/...` minúsculo→maiúsculo).
- **`_shared/confronto-codex.md`:** corrigido o ponteiro "reusa os scripts do gpt-optimizer" — agora avisa que o `run-gpt.sh` de lá é read-only/sem selo, e que o helper de selo vive em `auto-worker/scripts/`.
- **NÃO mexido (decisão do Cassiano):** lentidão `xhigh + flex + 2 rodadas` fica como está.
- **Item aberto:** `gpt-workspace/skill-snapshot/` na raiz do repo é artefato de uma rodada antiga de skill-creator — pode ser limpo numa passada futura.

## 1.6.0 — 2026-06-19

### Mudado
- **Skill `gpt-refletir` renomeada para `gpt-optimizer`.** Acionamento agora `/Titan:gpt-optimizer` (gatilhos novos: "chama o optimizer", "roda o optimizer") — os de função seguem iguais ("reflete isso", "advogado do diabo", "contraponto", "acha o furo", "/gpt"). A função não mudou (o GPT continua tentando derrubar a decisão); só o nome mudou.
- **Skill `auto-prompt` renomeada para `auto-worker`.** Acionamento agora `/Titan:auto-worker` (gatilhos novos: "liga o worker", "chama o worker", "manda o worker") — os de função seguem ("modo largar", "larga isso pros agentes", "roda isso sozinho"). Comportamento idêntico; só o nome mudou.
- **Referências cruzadas atualizadas:** `auto-think` e `planejar` agora apontam pra `/Titan:auto-worker`; `gpt-optimizer` oferece execução via `/Titan:auto-worker`; `auto-think` cita `/Titan:gpt-optimizer` como a porta de parecer rápido. Manifesto (`plugin.json`), README, FLUXOGRAMA, INSTALL e install.sh refletem os nomes novos.

## 1.5.0 — 2026-06-18

### Mudado
- **Skill `gpt-blindagem` renomeada para `gpt-refletir`.** Acionamento agora `/Titan:gpt-refletir` (gatilhos novos: "reflete sobre isso", "reflete essa decisão") — os de função seguem ("advogado do diabo", "contraponto", "acha o furo", "/gpt"). A função não mudou (o GPT continua tentando derrubar a decisão); só o nome/enquadramento passou de "blindar" para "refletir".
- **Veredito SEGUIR agora oferece execução.** Quando o confronto fecha em SEGUIR, a skill oferece levar a decisão pra `/Titan:auto-prompt` executar (opcional, só com OK). Antes parava no veredito.
- **`auto-think` perdeu o "modo rápido/leve".** Agora é sempre fundo — parecer rápido sobre uma decisão pronta é papel da `gpt-refletir`. Isso deixa as duas distintas: auto-think parte de um problema SEM resposta (gera opções); gpt-refletir parte de uma decisão que você JÁ tem (testa ela).
- **Fluxograma:** gpt-refletir como 5ª porta com cor própria; flecha do veredito SEGUIR → auto-prompt; as 5 portas alinhadas lado a lado no topo, cada uma definindo a intenção (construir / estudar / executar / retomar / testar uma decisão). Embutido no README (no fim).
- **Autoinstall de verdade:** `install.sh` agora instala tudo via CLI `claude plugin install` + `npx` + `npm` (o próprio Titan, superpowers, cloudflare, as skills npx e o Codex CLI), com bootstrap por `curl ... | bash`. Antes só lembrava de colar os `/plugin` na mão.

## 1.4.0 — 2026-06-18

### Mudado
- **Plugin renomeado de `dev` para `Titan`.** Acionamento agora é `Titan:planejar`, `Titan:auto-prompt`, `Titan:auto-think`, `Titan:handoff`, `Titan:gpt-blindagem`. Caminho do `$GPT` no `gpt-blindagem` passou a resolver pela própria pasta da skill (não mais cravado em `dev/`), pra funcionar em qualquer instalação.

## 1.3.0 — 2026-06-16

### Adicionado
- **5ª skill: `gpt-blindagem`** — o revisor adversarial via Codex GPT-5.5, que era skill standalone na raiz (`~/.claude/skills/gpt-blindagem`), passou a viver **dentro do plugin** (`Titan/skills/gpt-blindagem`). Acionamento por barra agora é `/Titan:gpt-blindagem`; os gatilhos falados ("blinda isso", "chama o gpt", "advogado do diabo") seguem iguais. Manifesto: descrição atualizada (quatro → cinco skills).

### Mudado
- **Reapontado o `$GPT`** no `gpt-blindagem/SKILL.md` pro novo caminho (`~/.claude/skills/Titan/skills/gpt-blindagem` no Mac, `D:/skills/Titan/skills/gpt-blindagem` no Windows) — senão a skill não acha os próprios `run-gpt.sh`/`verify-selo.sh`.
- **Ponteiros pro nome novo:** `auto-think/SKILL.md` ("mesmo mecanismo do `/Titan:gpt-blindagem`") e `_shared/confronto-codex.md` (atalho de reusar os scripts da skill irmã) passaram a citar `/Titan:gpt-blindagem`.

## 1.2.4 — 2026-06-16

### Mudado
- **Ponteiros pro revisor adversarial:** `/gpt` → `/gpt-blindagem` (a skill standalone foi renomeada — nome mais claro e tranquilizador pra quem é novo em IA: "blinda sua decisão" em vez de "inimigo"). Atualizado em `auto-think/SKILL.md` (o "mesmo mecanismo do /gpt-blindagem") e `_shared/confronto-codex.md` (o atalho de reusar `run-gpt.sh`/`verify-selo.sh`).

## 1.2.3 — 2026-06-16

### Mudado
- **auto-think (confronto):** passou a rodar **sempre em `gpt-5.5` · `xhigh` · `service_tier="fast"`** — esforço máximo de raciocínio na via rápida do gpt-5.5. O `fast` vai explícito no comando porque o confronto roda com `--ignore-user-config` (ignora o tier do config global do Codex). Antes era `high` "salvo quando pesado"; agora é xhigh fixo. Sincronizado no motor `_shared/confronto-codex.md`, no `auto-think/SKILL.md` e no `auto-think/references/confronto.md`.
- **_shared/confronto-codex.md:** `--full-auto` (deprecado pelo Codex 0.130) trocado por `--sandbox workspace-write` equivalente. `planejar` mantém seu próprio esforço (high na checagem leve, xhigh na sanidade) — não herda o xhigh fixo do auto-think.

## 1.2.2 — 2026-06-16

### Mudado
- **auto-think:** o "modo freado" (escondido numa frase) virou **modo LEVE de primeira classe** — o usuário liga dizendo "rápido/leve/só o essencial" ou `/auto-think rápido <problema>`, e a skill encolhe de propósito (≥2 ângulos, 1 confronto, sem re-cavar). É seguro porque a escolha é do **usuário**, não um chute do modelo (o modelo decidir sozinho "isso é pequeno" continua proibido). Adicionada a **trava de impacto**: mesmo no leve, decisão **sem-volta / de produto / alto impacto / com incerteza que muda a decisão** puxa fundo automático (ou pergunta antes) — o eixo é reversível/baixo impacto vs sem-volta/alto impacto, nunca "pequeno vs grande". A trava está fiada no passo 1 (enquadramento), não só declarada.
- **auto-think (gatilho):** descrição afinada pra não disparar sozinha em coisa pequena — removido o gatilho largo "qual o melhor jeito de" (virou "qual o melhor caminho pra <algo que exige estudo>") e adicionado o anti-gatilho "decisão pequena e reversível que dá pra responder direto". Fecha o vazamento de abrir o canhão em decisão trivial.
- **auto-think (reforço da cura):** em **decisão de produto/estratégica**, dois ângulos que eram opcionais viraram **obrigatórios** — o **Contrário** (confrontar a premissa e o PLANO QUE O USUÁRIO TROUXE em vez de assumir que está certo) e o **Precedente** (pesquisar o que **outras empresas** já fazem, a visão de fora). Ataca direto o problema que originou a skill: estudar de menos e aceitar o plano do usuário sem questionar.

## 1.2.1 — 2026-06-16

### Corrigido
- **auto-think:** removidos os dois blocos de comando do Codex que estavam **copiados inline** no `SKILL.md` (passo 3 e trava #4). Eles divergiam do motor: usavam três nomes de arquivo temporário diferentes (`/tmp/autothink-confronto.md`, `/tmp/autothink-input.md`) contra o `/tmp/confronto-input.md` que o motor sela com hash, e estavam sem as flags `--ignore-user-config --full-auto`. Seguindo o inline ao pé da letra, o selo (hash) podia nunca bater. Agora o comando mora num lugar só (`_shared/confronto-codex.md`) e o `SKILL.md` só aponta pra ele. Também: typo "régra"→"regra" e corte da repetição da regra de mascarar dado.
- **auto-prompt:** o comando do crítico (Codex) ganhou o **teto de 15 min** (`perl -e 'alarm 900'`) que faltava — era o único da família rodando `codex exec` cru, sem nada que matasse um Codex travado. Alinha com auto-think/planejar/_shared.
- **_shared/confronto-codex.md:** o cálculo do selo usava `sha256sum` cru, que **não existe no Mac de fábrica** (só `shasum -a 256`) — o passo do selo do auto-think e do planejar quebraria numa máquina sem ele. Agora testa e cai pro `shasum`, igual o `verify-selo.sh` já fazia.

## 1.2.0 — 2026-06-15

### Adicionado
- **auto-think:** o ângulo **Precedente** agora prioriza a **fonte oficial do domínio** antes da web aberta. Quando o problema é claramente de uma tecnologia com dono (Cloudflare, Supabase, React, Postgres…), o agente do ângulo puxa a **documentação oficial via `context7`** (sempre disponível, independente do Perplexity — segura o estudo mesmo se a busca web tropeçar) e, se houver, consulta uma **skill de boas práticas instalada** daquele domínio (match FORTE por fornecedor/framework + tarefa, no máx. 1 por domínio, rodando em subagente isolado pra não inchar a thread). É **condicional** ao enquadramento (passo 1) marcar o problema como "domínio técnico com dono claro" — não vira survey de skill em todo problema. Skill útil **não instalada → nunca para o ciclo**: segue com doc oficial + boas práticas gerais (a falta vira *achado*, não parada). **Aviso de skill faltante graduado:** se só poliria → nota `🅿️ opcional` com oferta de instalar+refazer; se mudaria a resposta → recomendação cai pra 🟡 Hipótese, diagnóstico não fecha como certeza e o aviso sobe pro topo da entrega (na dúvida, rebaixa por criticidade do domínio). Refazer declara o custo (ciclo inteiro de novo), lista todas as faltantes de uma vez, teto de 1 refação. Desenhado e confrontado pelo próprio `/auto-think` (4 ângulos paralelos + 2 rodadas de Codex).

### Mudado
- **planejar + auto-think:** o mecanismo de **confronto com o Codex** foi extraído pra um motor compartilhado único — `skills/_shared/confronto-codex.md` — usado pelas duas skills (espelha o padrão de "uma fonte da verdade só"). Some a duplicação: como invocar sem travar, mascarar dado antes, **selo de versão** (hash anti-versão-velha), regra de ouro de filtrar com prova e o fallback se o Codex cair moram num lugar só. Cada skill mantém apenas o que é dela (a `planejar` as duas chamadas de sanidade; a `auto-think` o manifesto e os prompts adversariais das 2 rodadas) e aponta pro motor. Efeito colateral bom: a `planejar` herdou o teto de 15 min e o selo de versão que só a `auto-think` tinha. Comportamento idêntico; só a fiação mudou.
- **docs (FLUXOGRAMA + README):** sincronizados pra refletir as **4 skills**. O `auto-think` (adicionado na 1.1.0) não aparecia no fluxograma nem no README, que ainda diziam "três skills". Agora o `auto-think` é a 4ª porta do fluxograma, ao lado do `planejar` (os dois "pensadores" que alimentam o executor `auto-prompt`), com o ciclo dele (enquadra → ângulos em paralelo → 2 rodadas de Codex → soluções com veredito → oferece executar). Estilo/cores do mermaid preservados. README passou a listar as 4 skills, a relação pensadores→executor e o motor de confronto compartilhado.

## 1.1.0 — 2026-06-14

### Adicionado
- **auto-think:** nova skill — modo larga-e-some pra **estudar um problema difícil até o fim** (não pra executar nem pra planejar produto). Pesquisa (web via `/pesquisa`/`deep-research` e/ou o próprio sistema do usuário), estuda de vários ângulos em paralelo, **confronta os próprios achados com o Codex** (mesmo mecanismo do `/gpt`), verifica o que se sustenta, re-cava só o que ficou aberto (loop com teto), e entrega **uma ou mais soluções com veredito** — a recomendada + alternativas viáveis + "o que o confronto matou". Para na recomendação; quem executa a escolhida é o `/auto-prompt`. Reusa o `protocolo.md` do `auto-prompt` (prova ou silêncio, fato se confere/intenção se pergunta, PROVEI vs ASSUMI). **Trava própria:** antes de qualquer coisa sair pro Codex (OpenAI) ou pra web, mascara dado real de pessoa e credencial — vai o raciocínio, não a identidade. Detalhe do confronto + selo de versão em `references/confronto.md`. Esforço (fundura/rodadas) é do usuário, a skill nunca escala sozinha.

## 1.0.3 — 2026-06-14

### Mudado
- **Titan:** plugin **neutralizado (white-label)** — qualquer pessoa instala e adota como próprio. Removidas as menções ao Praxios e ao claudex (manifesto, README, `auto-prompt`, referências da `planejar`); o nome do marketplace `cassiano-local` virou instrução genérica no README e no `INSTALL.md`; referência a `smart-claudex:findbugs` virou exemplo genérico. **Autoria preservada:** Cassiano Diniz (autor) + Thales Laray (co-autor, novo campo `contributors` no manifesto e crédito no README). Nenhum caminho de máquina, credencial ou dado pessoal embutido — confirmado por varredura.

## 1.0.2 — 2026-06-14

### Adicionado
- **planejar:** nova etapa na Fase 1 — **"Como já resolveram isso" (prior art)**. Antes de desenhar, usa a skill `/pesquisa` pra descobrir como o problema já foi resolvido lá fora e trazer ângulos que o usuário não estava vendo. Recomendada, mas pulável. Método em `references/descoberta-prior-art.md`, com 3 travas contra "visão diferente porém pior": o jeito simples sempre na mesa (baseline) · filtro da realidade do usuário (dá pra uma pessoa só, não-programador, construir e manter?) · confronto adversarial do Codex GPT. A pesquisa informa, o usuário decide. Salva a comparação em `docs/<nome>-prior-art.md`. Fecha o gap: a `/pesquisa` estava instalada mas não era usada por nenhuma skill.
- **Titan:** novo **`INSTALL.md`** — arquivo de auto-instalação que reúne todas as dependências externas do plugin (superpowers, taste-skill, find-skills, cloudflare, `/pesquisa`+Perplexity, gemini-api-dev, Stitch MCP, context7, firecrawl, Codex CLI) com os comandos exatos, agrupadas por crítica/com-fallback. Confirmado por investigação: tudo que o professor listou está instalado e em uso pela `planejar` — a `/pesquisa` era a única peça parada.
- **Titan:** novo **`install.sh`** — instalador guiado pra quem não curte terminal. Roda sozinho a parte automatizável (skills via `npx` + MCP do Stitch se a chave for passada) e, no fim, lista o pouco que só o usuário pode fazer (colar as linhas de `/plugin` e dar as chaves). O `INSTALL.md` ganhou uma seção "Jeito rápido" no topo separando "o script instala" × "só você faz".

## 1.0.1 — 2026-06-14

### Corrigido
- **auto-prompt:** removidas todas as menções ao "ultracode". A descrição do plugin (vitrine do `/plugin`) dizia que a skill "liga o ultracode sozinha e calibra o esforço pelo tamanho da tarefa" — o oposto da regra interna, que deixa o esforço inteiramente na mão do usuário. Texto realinhado no manifesto, README, frontmatter, corpo da skill e `protocolo.md`. Keyword `ultracode`/`multi-agente` saiu do manifesto.
- **planejar:** as fases agora salvam os dois pareceres do Codex que a tabela final prometia mas o passo a passo não gerava — `docs/<nome>-revisao-problema.md` (Fase 1) e `docs/<nome>-revisao-sanidade.md` (Fase 6).
- **planejar:** removido o manual de instalação antigo (`README-install.md`, jeito `.tar.gz`). A instalação oficial é via `/plugin` → marketplace do plugin, já documentada no README.

### Mudado
- **handoff:** em vez de despejar o documento inteiro no chat, agora **salva o `.md`**, **abre na tela** (`open` no Mac / `start` no Windows Git Bash) e **avisa o caminho** em uma linha. Só cai pro despejo no chat se não houver nenhum local gravável.

## 1.0.0

- Versão inicial: três skills — `planejar` (metodologia de 8 fases), `auto-prompt` (executor Claude + crítico Codex com protocolo de segurança) e `handoff` (passagem de bastão entre sessões).
