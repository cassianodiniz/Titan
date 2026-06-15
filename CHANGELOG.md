# Changelog — dev

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
