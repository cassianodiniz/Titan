# Changelog — dev

## 1.3.0 — 2026-06-16

### Adicionado
- **5ª skill: `gpt-blindagem`** — o revisor adversarial via Codex GPT-5.5, que era skill standalone na raiz (`~/.claude/skills/gpt-blindagem`), passou a viver **dentro do plugin** (`dev/skills/gpt-blindagem`). Acionamento por barra agora é `/dev:gpt-blindagem`; os gatilhos falados ("blinda isso", "chama o gpt", "advogado do diabo") seguem iguais. Manifesto: descrição atualizada (quatro → cinco skills).

### Mudado
- **Reapontado o `$GPT`** no `gpt-blindagem/SKILL.md` pro novo caminho (`~/.claude/skills/dev/skills/gpt-blindagem` no Mac, `D:/skills/dev/skills/gpt-blindagem` no Windows) — senão a skill não acha os próprios `run-gpt.sh`/`verify-selo.sh`.
- **Ponteiros pro nome novo:** `auto-think/SKILL.md` ("mesmo mecanismo do `/dev:gpt-blindagem`") e `_shared/confronto-codex.md` (atalho de reusar os scripts da skill irmã) passaram a citar `/dev:gpt-blindagem`.

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
- **dev:** plugin **neutralizado (white-label)** — qualquer pessoa instala e adota como próprio. Removidas as menções ao Praxios e ao claudex (manifesto, README, `auto-prompt`, referências da `planejar`); o nome do marketplace `cassiano-local` virou instrução genérica no README e no `INSTALL.md`; referência a `smart-claudex:findbugs` virou exemplo genérico. **Autoria preservada:** Cassiano Diniz (autor) + Thales Laray (co-autor, novo campo `contributors` no manifesto e crédito no README). Nenhum caminho de máquina, credencial ou dado pessoal embutido — confirmado por varredura.

## 1.0.2 — 2026-06-14

### Adicionado
- **planejar:** nova etapa na Fase 1 — **"Como já resolveram isso" (prior art)**. Antes de desenhar, usa a skill `/pesquisa` pra descobrir como o problema já foi resolvido lá fora e trazer ângulos que o usuário não estava vendo. Recomendada, mas pulável. Método em `references/descoberta-prior-art.md`, com 3 travas contra "visão diferente porém pior": o jeito simples sempre na mesa (baseline) · filtro da realidade do usuário (dá pra uma pessoa só, não-programador, construir e manter?) · confronto adversarial do Codex GPT. A pesquisa informa, o usuário decide. Salva a comparação em `docs/<nome>-prior-art.md`. Fecha o gap: a `/pesquisa` estava instalada mas não era usada por nenhuma skill.
- **dev:** novo **`INSTALL.md`** — arquivo de auto-instalação que reúne todas as dependências externas do plugin (superpowers, taste-skill, find-skills, cloudflare, `/pesquisa`+Perplexity, gemini-api-dev, Stitch MCP, context7, firecrawl, Codex CLI) com os comandos exatos, agrupadas por crítica/com-fallback. Confirmado por investigação: tudo que o professor listou está instalado e em uso pela `planejar` — a `/pesquisa` era a única peça parada.
- **dev:** novo **`install.sh`** — instalador guiado pra quem não curte terminal. Roda sozinho a parte automatizável (skills via `npx` + MCP do Stitch se a chave for passada) e, no fim, lista o pouco que só o usuário pode fazer (colar as linhas de `/plugin` e dar as chaves). O `INSTALL.md` ganhou uma seção "Jeito rápido" no topo separando "o script instala" × "só você faz".

## 1.0.1 — 2026-06-14

### Corrigido
- **auto-prompt:** removidas todas as menções ao "ultracode". A descrição do plugin (vitrine do `/plugin`) dizia que a skill "liga o ultracode sozinha e calibra o esforço pelo tamanho da tarefa" — o oposto da regra interna, que deixa o esforço inteiramente na mão do usuário. Texto realinhado no manifesto, README, frontmatter, corpo da skill e `protocolo.md`. Keyword `ultracode`/`multi-agente` saiu do manifesto.
- **planejar:** as fases agora salvam os dois pareceres do Codex que a tabela final prometia mas o passo a passo não gerava — `docs/<nome>-revisao-problema.md` (Fase 1) e `docs/<nome>-revisao-sanidade.md` (Fase 6).
- **planejar:** removido o manual de instalação antigo (`README-install.md`, jeito `.tar.gz`). A instalação oficial é via `/plugin` → marketplace do plugin, já documentada no README.

### Mudado
- **handoff:** em vez de despejar o documento inteiro no chat, agora **salva o `.md`**, **abre na tela** (`open` no Mac / `start` no Windows Git Bash) e **avisa o caminho** em uma linha. Só cai pro despejo no chat se não houver nenhum local gravável.

## 1.0.0

- Versão inicial: três skills — `planejar` (metodologia de 8 fases), `auto-prompt` (executor Claude + crítico Codex com protocolo de segurança) e `handoff` (passagem de bastão entre sessões).
