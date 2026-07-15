# Mecânica de modelos — específico do /auto-think e /fable-autothink

Decisão 12/07/2026: o auto-think passou a usar **dois fornecedores em papéis trocados** — GPT-5.6
(via Codex CLI) faz os ângulos e a síntese (passos 2 e 5); **Opus em `effort: high`** (via Agent
tool, nativo do Claude) faz o confronto adversarial (passos 3 e 6). Antes era o inverso (Claude
nos ângulos, Codex no confronto) — a troca mantém o princípio de "não se auto-aprova": quem
produz e quem confronta continuam sendo fornecedores diferentes, só que na direção oposta.

---

## Ângulos e síntese (passos 2 e 5) — GPT-5.6 via Codex CLI

Mecânica espelhada do `/codex-build` (`grill-codex/skills/codex-build/SKILL.md`): prompt por
stdin, saída em arquivo via `--json -o`, sandbox travado. Diferença chave: aqui é **leitura/
pesquisa**, não escrita de código — por isso `--sandbox read-only` sempre, nunca `--yolo`.

### Trava de dado pra fora (antes de montar QUALQUER input)
Mascare dado real de pessoa e credencial (nome, CPF, telefone, e-mail, token, chave) por
etiqueta estável (`PACIENTE_A`, `TELEFONE_1`) antes de escrever o prompt que vai pro Codex — ver
a "TRAVA DE DADO PRA FORA" no SKILL.md. Só faz sentido expondo o dado real → PARA e pede
autorização, não manda mesmo assim.

### Um ângulo (chamada individual, disparada em paralelo com as outras)

```bash
P=$(mktemp)
cat >"$P" <<'EOF'
ÂNGULO: <nome do ângulo — técnico / simplicidade / custo / precedente / contexto interno / contrário>
PROBLEMA: <o problema em 1 parágrafo, dado real já mascarado>
TAREFA: Estude este ângulo especificamente. Devolva achados + candidata(s) de solução, cada
  uma com a evidência que a sustenta (arquivo:linha, fonte com data, comando+saída). Marque
  ASSUMIDO o que não conseguiu provar.
OUTPUT: lista de achados + candidatas, cada linha com a evidência ao lado.
EOF

perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.6-terra \
  --skip-git-repo-check --ignore-user-config --sandbox read-only --json \
  -o /tmp/auto-think-angulo-<nome>.md \
  - <"$P" 2>/dev/null
```

- Dispare um processo por ângulo via Bash `run_in_background`, até ~5 simultâneos.
- **Teto de 15 min por chamada** (`alarm 900` — o SO mata). Travou → mata e refaz uma vez;
  travou de novo → cai no fallback (SKILL.md, "mecânica de composição").
- Ângulo que não voltou até o ponto de síntese não segura o resto — segue sem ele, marcado.

### Síntese (uma chamada, depois que os ângulos voltam)

```bash
P=$(mktemp)
cat >"$P" <<'EOF'
TAREFA: Junte os achados abaixo (um bloco por ângulo) num leque de candidatas distintas
  (mínimo 3). Para cada candidata: o que é, quais ângulos a sustentam, a evidência mais forte
  que ela tem. Se os ângulos convergiram todos numa só, aponte isso explicitamente.
ACHADOS POR ÂNGULO:
<cole aqui o conteúdo dos /tmp/auto-think-angulo-*.md>
EOF

perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.6-sol \
  --skip-git-repo-check --ignore-user-config --sandbox read-only --json \
  -o /tmp/auto-think-leque.md \
  - <"$P" 2>/dev/null
```

O resultado (`/tmp/auto-think-leque.md`) é o leque de candidatas que segue pro portão de
qualidade (passo 4) e depois pro confronto (passo 3, abaixo).

### Re-cava (passo 5) — mesma mecânica, uma incerteza por vez
Cada re-cava é uma chamada `gpt-5.6-terra` isolada, focada só na incerteza decisiva daquela
rodada (mesmo formato do bloco "um ângulo" acima, trocando ÂNGULO por INCERTEZA). Não reabre
todos os ângulos — só o que fecha a dúvida em aberto.

---

## Confronto (passos 3 e 6) — Opus `effort: high` via Agent tool

Nada de Codex aqui: é um agente Claude nativo, `model: opus`, `effort: high`, jogando o papel de
advogado do diabo contra o leque de candidatas que o GPT-5.6 produziu. Sem processo externo, sem
selo de hash (o agente lê o manifesto que você passa no prompt dele, não um arquivo que pode ter
sido escrito por outra sessão) — a garantia de "leu a versão certa" vem de você montar o prompt
com o material atual, não de um mecanismo de verificação à parte.

### 1ª rodada (passo 3) — derrubar cada candidata

Prompt do agente (via Agent tool, `model: "opus"`, `effort: "high"`):

```
Você é advogado do diabo. Tente DERRUBAR cada candidata abaixo, não validar.
Para cada uma, responda com evidência:
1. Isso resolve MESMO o problema declarado, ou a coisa errada / só um sintoma?
2. Tem furo de raciocínio, premissa frágil vendida como fato, ou risco/caso de erro ignorado?
3. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
4. As fontes/evidências sustentam mesmo as afirmações, ou tem afirmação sem lastro?

## O problema (estado atual)
<critério de sucesso declarado>

## Candidatas
### Candidata A
<o que é + evidência>
### Candidata B
...

Formato de resposta:
## Veredito
- (por candidata) SEGUIR | AJUSTAR | BLOQUEAR
## Pontos
- (curtos, acionáveis, cada um com a evidência que o sustenta)
```

Filtre pela mesma regra de ouro de sempre: o confronto BLOQUEIA uma candidata por furo de mérito
(não resolve, premissa falsa, fonte não sustenta) ou por caminho mais simples que a torna
obsoleta. Melhoria pequena não derruba a candidata — vira nota. Registre o que caiu e por quê,
pra entrega.

### 2ª rodada (passo 6) — escolher entre os sobreviventes

Outro agente Opus `high` (não o mesmo da rodada 1 — sem sessão pra retomar, cada chamada é
independente):

```
Das candidatas que sobraram à 1ª rodada, qual escolher e por quê (critério de sucesso
declarado)? O que AINDA fura na recomendada atual que a 1ª rodada não pegou? Tem combinação
melhor que qualquer uma sozinha?

## As candidatas que aguentaram a 1ª rodada
### A (atual recomendada) — <o que é + evidência>
### B — <o que é + evidência>
```

O resultado afina o veredito da entrega ("por quê A venceu nos dois confrontos") e às vezes troca
a recomendada.

### Regra de ouro — o Claude (thread principal) filtra antes, COM PROVA
Igual sempre: nenhum ponto do agente Opus é aplicado cego.
- **Não procede** → descarta, mas cite o `arquivo:linha` ou seção que contradiz o ponto.
- **Procede e é grave** → decisão do dono: PARA e sobe pro usuário em A/B.
- **Procede e é menor** → entra na lista de achados normal.

Registro obrigatório (mesma tabela de sempre — ver `../../_shared/confronto-codex.md` seção 4
pro formato, que continua valendo como referência de formato mesmo o ator tendo trocado).
