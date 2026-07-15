# Codex constrói, Claude revisa — motor compartilhado

Usado por `/auto-gptworker`. Este arquivo é o ÚNICO lugar onde mora a
mecânica de mandar o Codex construir com acesso de escrita: como montar o contrato, como
lançar, como retomar pra corrigir, e como o Claude revisa o diff depois. Cada skill mantém só o
que é dela (quando aciona, o que faz com o resultado) e aponta pra cá.

Espelha `titan/skills/_shared/confronto-codex.md` (o motor irmão, pra quando o Codex só
CRITICA). Este aqui é pro caso oposto: o Codex EXECUTA.

> **Por que existe.** Mesmo princípio do confronto: ninguém se auto-aprova. Só que aqui é o
> Claude que audita o trabalho de outro executor (o Codex), em vez do contrário. O ganho não é
> qualidade de código — Codex e Claude escrevem em nível parecido — é ter um segundo par de
> olhos genuinamente independente no diff antes dele virar PR.

## 1. Pré-requisitos (verificar 1x por sessão, rápido)

- `codex --version` ≥ 0.144 (`gpt-5.6-sol` fixado nos comandos é recusado por CLI antiga — HTTP 400).
- Codex autenticado (`codex login` prévio).
- **Árvore de trabalho LIMPA antes de lançar** — `git status -sb`. Suja → PARA, pede pra
  commitar/stashar. Não-negociável: o Codex escreve com acesso total, e árvore suja impede
  isolar/reverter o diff dele com segurança.

## 2. Quem pode receber o Codex construtor — a classificação de risco vem ANTES

`--yolo` executa comandos de verdade sem pedir permissão a cada passo. Por isso o Codex **só
constrói** trabalho de risco **baixo/médio** — local, reversível, sem efeito externo. Toda
ordem de serviço que toca uma trava dura (envio real, dado de pessoa, deploy que afeta
produção sem revisão, credencial, dinheiro, destrutivo real) **NÃO vai pro Codex**: o Claude
assume essa parte, prepara 100% reversível e PARA na borda pedindo autorização — o Codex nunca
cruza essa linha sozinho. Classifique o risco da ordem ANTES de montar o prompt; na dúvida, sobe
um nível (não solta o Codex).

## 3. O contrato (arquivo temporário, nunca inline-quote)

```bash
P=$(mktemp); cat >"$P" <<'EOF'
GOAL: <o que "pronto" significa, 1 parágrafo>
SPEC: <a ordem de serviço — passos concretos e limites>
KEY PATHS: <arquivos que o Codex vai tocar ou ler primeiro>
CONSTRAINTS: <não toque em X; regras de estilo; deps que não podem mudar>
NON-GOALS: <explicitamente fora de escopo>
PROOF: rode `<comando de prova>` e cole a saída inteira no relatório.
OUTPUT: termine com relatório — arquivos mudados (1 linha cada, caminho + o quê/por quê) +
  saída da prova + desvios do contrato, com o motivo.
EOF
```

Preencha completo. Se a ordem vem de um plano já revisado (Fase 1+2 de uma skill de
planejamento), derive os campos das seções do plano — não invente do zero.

## 4. Lançar (sessão nova, capturar `thread_id`)

**Caminho de saída SEMPRE único por run — nunca `/tmp/codex-build-out.txt` fixo** (achado do
confronto `/gpt-optimizer`, 13/07/2026: duas sessões rodando em paralelo de propósito
sobrescrevem o arquivo uma da outra e cada uma lê o relatório da outra).
Se a skill que usa este motor tem `$RUN_DIR`, use
`"${RUN_DIR}/codex-build-out.md"`; sem `$RUN_DIR`, gere um nome único: `OUT=$(mktemp
/tmp/codex-build-XXXXXX.md)`. Nunca hardcode um nome fixo.

```bash
OUT="${RUN_DIR:-}/codex-build-out.md"; [ -z "${RUN_DIR:-}" ] && OUT=$(mktemp /tmp/codex-build-XXXXXX.md)
codex exec --model gpt-5.6-sol --yolo --json -o "$OUT" - <"$P" 2>/dev/null | grep '"type":"thread.started"'
```

- Prompt via stdin (`- <"$P"`) — evita bug de quote e o hang de stdin não-TTY.
- Extraia `THREAD_ID` da linha `{"type":"thread.started","thread_id":"..."}`. O relatório final
  cai em `$OUT` — leia esse arquivo, nunca faça parse do stream JSONL.
- **Timing:** foreground com `timeout: 600000` se a ordem é claramente rápida (<10min).
  Claramente mais lenta (multi-arquivo, migration, geração de imagem) → `run_in_background:
  true`, leia o `-o` quando terminar. Banner obrigatório ao voltar: `🔔 CODEX FINISHED — <o quê>
  (exit ok/fail) — verificando agora` — nunca deixe um build concluído escorregar pra
  verificação em silêncio.

## 5. Claude revisa (sempre, nunca delegado — é o coração do motor)

O relatório do Codex é só indício, não prova:

1. `git status -sb` + ler o diff INTEIRO (`git diff`). Julgar como PR de contribuidor:
   correção, fidelidade ao contrato, estilo consistente com o resto do código, nada fora do
   `KEY PATHS`/escopo.
2. Rodar o `PROOF` você mesmo — a saída colada pelo Codex não conta como prova.
3. Registrar (no diário/log da skill que está usando este motor): resumo do que o Codex
   construiu + veredito do Claude no diff (o que passou/falhou) + rodadas de fix usadas.

## 6. Fix-loop (mesma sessão, teto de 2 rodadas)

Achou problema → retoma a MESMA sessão (Codex mantém contexto; mais barato e melhor que sessão
nova):

```bash
codex exec resume "$THREAD_ID" --model gpt-5.6-sol --dangerously-bypass-approvals-and-sandbox \
  --json -o "$OUT" - <"$P2" 2>/dev/null >/dev/null
```

- `resume` NÃO aceita `--sandbox` nem `-C`; a flag acima (`--dangerously-bypass-approvals-and-sandbox`)
  é a única que o `resume` aceita pra manter escrita — sem ela ele herda o sandbox do config e
  pode virar read-only sem avisar.
- **Nunca `--last`** — sempre o `THREAD_ID` explícito (sessões paralelas fazem `--last` pegar a
  conversa errada, e isso parece um resume bem-sucedido).
- Re-verificar (seção 5) a cada rodada. Depois de **2 rodadas falhas: PARA de delegar** — o
  Claude assume as correções restantes e registra a tomada de controle. Ping-pong sem fim
  queima mais do que economiza.

## 7. Fallback se o Codex-construtor cair

CLI ausente, erro, ou timeout repetido (teto de 15min por chamada, `alarm 900` como no motor de
confronto) → **não trava o fluxo**. O Claude ASSUME a construção diretamente (ele sabe fazer) e
marca a entrega "construído pelo Claude, sem o Codex" — nunca finge que o Codex passou por ali.

## 8. Regras absolutas

- Commits, push, merge: sempre Claude, nunca o Codex — e só depois do humano aprovar o diff.
- O Codex nunca decide sozinho cruzar uma trava dura (seção 2) — se a ordem toca uma, essa
  parte específica NUNCA entra no contrato do Codex; fica com o Claude.
- Árvore suja nunca lança o Codex (seção 1) — sem exceção.

## O que NÃO delegar pro Codex — mesmo dentro do escopo seguro

O Codex roda headless via CLI: não tem acesso às ferramentas de sessão do Claude Code (MCP,
Browser pane, `AskUserQuestion`). Isso NÃO é uma trava de risco (seção 2) — é limite técnico.
Três categorias ficam SEMPRE com o Claude, mesmo em ordem de risco baixo/médio:

1. **Qualquer etapa que dependa de aprovação visual interativa** (mostrar screenshot e esperar
   "sim/não" do humano) — o Codex não tem como pausar e mostrar tela.
2. **Qualquer etapa que dependa de ferramenta MCP da sessão** (Supabase MCP, Google Calendar,
   etc.) — o Codex só tem Bash/arquivo; se existe um caminho CLI equivalente ao MCP (ex.:
   `supabase functions deploy` no lugar de `deploy_edge_function`), esse caminho pode ir no
   contrato; se só existe via MCP, essa parte fica com o Claude.
3. **Qualquer etapa que rode o app pra verificar comportamento** (Browser pane, preview,
   smoke test runtime) — o Codex não tem essas ferramentas; ele escreve o código, o Claude
   roda e confere.

Uma ordem de serviço real quase sempre mistura: partes puramente mecânicas (Codex constrói) +
partes que precisam do humano/das ferramentas de sessão (Claude faz). Divida o contrato assim
em vez de forçar tudo pra um lado só.
