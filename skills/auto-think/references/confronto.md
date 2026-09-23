# Mecânica de modelos — específico do /auto-think

**Decisão 12/09/2026 (inversão dos papéis):** a pesquisa e a síntese voltaram pra **sessão atual**
(o próprio Claude que roda o auto-think), e o **confronto adversarial passou a ser o GPT-6-sol**
(via Codex CLI). Antes (12/07/2026) era o contrário: GPT nos ângulos, Opus no confronto.

Por que inverteu (racional do dono, validado numa fatia antes de cravar):
- **Quem pesquisa melhor é a sessão**, porque ela tem as ferramentas certas (a skill `/search`
  com Exa + subagentes de busca + procedência por número; `context7` pra doc oficial; leitura do
  código/banco do usuário). Um `codex exec` isolado não alcança essas ferramentas — ele só "pensa"
  e lê arquivo local. Medido nesta casa: o comando antigo do ângulo nem invocava skill de pesquisa.
- **Quem confronta bem é o GPT-sol**, como advogado do diabo — provado numa fatia: veredito tipado
  (SEGUIR/AJUSTAR/BLOQUEAR), furos reais, aponta o caminho mais simples.
- **O princípio "não se auto-aprova" continua de pé:** quem PRODUZ (sessão = Anthropic) nunca é
  quem CONFRONTA (GPT = OpenAI). São fornecedores diferentes nas duas pontas — só trocou o lado.

**O que isso muda na borda de segurança (importante):** antes o que saía pra fora (Codex) eram os
ângulos/síntese. Agora o que sai pra fora é **o confronto** (as candidatas vão pro GPT) e **a
pesquisa web** (a query vai pro Exa). A trava de mascarar dado real ANTES de sair continua
obrigatória — só mudou QUEM é o destino externo (ver "Trava de dado pra fora" abaixo e no SKILL.md).

---

## Ângulos, pesquisa e síntese (passos 2 e 5) — SESSÃO ATUAL

Não há `codex exec` aqui. A própria sessão que roda o auto-think estuda os ângulos, pesquisa e
sintetiza. O GPT não participa desta parte — ele só entra no confronto (passos 3 e 6).

### Os ângulos (mesmos de sempre)
A sessão ataca os ângulos do passo 2 (técnico, simplicidade, custo/risco, precedente, contexto
interno, contrário). A cobertura contra "pensar tudo na mesma cabeça" **não vem mais de agentes
paralelos cegos** — vem do **confronto GPT forte** nos passos 3 e 6, que é externo e independente.
Se quiser paralelizar ângulos internos de raciocínio, pode usar subagentes **Claude** (Agent tool,
`model: sonnet` ou `opus`) — mas isso é opcional; o essencial é cobrir os ângulos, não a forma.

### A pesquisa web — via skill `/search` (Jeito A: chama a skill)
Sempre que um ângulo precisar de conhecimento externo (o ângulo **precedente**, "como os outros
resolvem", decisão de produto), a sessão **invoca a skill `/search`** (via Skill tool), não um
pesquisador caseiro. O `/search` traz Exa + subagentes de busca + **procedência por número** (a
frase copiada da página, a data, quantas fontes independentes) — que é o padrão de honestidade que
o auto-think exige.

- **Passe a pergunta já específica + a profundidade** pro `/search`. Ele só para pra pedir
  confirmação quando a pergunta está ambígua ([search/SKILL.md] "Confirm when ambiguous"); com
  pergunta específica e profundidade declarada, ele roda direto — o que preserva o "larga-e-some"
  do auto-think.
- **Doc oficial primeiro, quando o domínio tem dono** (Cloudflare, Supabase, React, Postgres…):
  puxe a régua oficial via `context7` antes da web aberta. É a fonte de maior garantia e não
  depende de nada instalado. A web (via `/search`) cobre o que a doc não responde.
- **Fallback se o `/search` falhar** (Exa fora, sem auth, sem resultado): não trava o ciclo —
  degrada com aviso ("pesquisa web indisponível nesta rodada, segui com doc oficial / o que tinha")
  e rebaixa a confiança do que dependia da web. Nunca apresentar como sólido o que não pôde checar.

### A síntese (o leque de candidatas)
A própria sessão junta os achados dos ângulos num leque de **≥ 3 candidatas distintas**, cada uma
com a evidência que a sustenta. Se todos os ângulos convergiram numa só, a sessão ataca mais um
ângulo (contrário ou radical) antes de aceitar que é convergência real, e não falta de imaginação.

### Re-cava (passo 5) — também a sessão
Cada re-cava é conduzida pela sessão, focada só na incerteza decisiva daquela rodada (mesma régua:
pesquisa via `/search` quando for dúvida externa; leitura do sistema quando for interna). Não
reabre todos os ângulos — só o que fecha a dúvida em aberto.

---

## Confronto (passos 3 e 6) — GPT-6-sol como advogado do diabo, via Codex CLI

Aqui é o único ponto do ciclo que usa o Codex. O GPT-sol tenta **DERRUBAR** o leque que a sessão
produziu. Mecânica espelhada do `/gpt-builder` (prompt por stdin, saída em arquivo, sandbox
travado, teto de 15 min): é **leitura/crítica**, não escrita — por isso `--sandbox read-only`
sempre, nunca `--yolo`.

### Trava de dado pra fora (antes de montar QUALQUER input pro GPT)
O confronto vai pro GPT (fornecedor externo). Mascare dado real de pessoa e credencial (nome, CPF,
telefone, e-mail, token, chave) por etiqueta estável (`PACIENTE_A`, `TELEFONE_1`) antes de escrever
o prompt — ver a "TRAVA DE DADO PRA FORA" no SKILL.md. Vai o RACIOCÍNIO das candidatas, nunca a
identidade de quem quer que seja. Só faz sentido expondo o dado real → PARA e pede autorização.

### 1ª rodada (passo 3) — derrubar cada candidata

```bash
P=$(mktemp)
cat >"$P" <<'EOF'
Você é advogado do diabo. Tente DERRUBAR cada candidata abaixo, não validar.
Para cada uma, responda com evidência/raciocínio:
1. Isso resolve MESMO o problema declarado, ou a coisa errada / só um sintoma?
2. Tem furo de raciocínio, premissa frágil vendida como fato, ou risco/caso de erro ignorado?
3. Existe um caminho substancialmente MAIS SIMPLES pro mesmo resultado?
4. As fontes/evidências sustentam mesmo as afirmações, ou tem afirmação sem lastro?

## O problema (critério de sucesso declarado)
<critério de sucesso, dado real já mascarado>

## Candidatas
### Candidata A
<o que é + evidência>
### Candidata B
...

Formato de resposta:
## Veredito
- (por candidata) SEGUIR | AJUSTAR | BLOQUEAR
## Pontos
- (curtos, acionáveis, cada um com a evidência/raciocínio que o sustenta)
EOF

perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-6-sol \
  --skip-git-repo-check --ignore-user-config --sandbox read-only \
  -o /tmp/auto-think-confronto-1.md \
  - <"$P" 2>/dev/null
```

Leia sempre o arquivo `-o` (`/tmp/auto-think-confronto-1.md`), nunca o retorno cru da Bash tool —
o `codex exec` ecoa prompt+banner no stderr e misturaria tudo. Toda chamada Bash longa deste ciclo
precisa de `timeout >= 900000ms` na própria tool.

### 2ª rodada (passo 6) — escolher entre os sobreviventes

Retome a MESMA sessão do Codex (`codex exec resume` com o `thread_id` da 1ª) — assim o GPT lembra o
que já apontou, confere o que foi atendido e não re-litiga ponto morto. O `resume` NÃO aceita
`--sandbox`; force `-c sandbox_mode="read-only"`.

```
Das candidatas que sobraram à 1ª rodada, qual escolher e por quê (critério de sucesso declarado)?
O que AINDA fura na recomendada atual que a 1ª rodada não pegou? Tem combinação melhor que
qualquer uma sozinha?

## As candidatas que aguentaram a 1ª rodada
### A (atual recomendada) — <o que é + evidência>
### B — <o que é + evidência>
```

### Teto de 15 min e indisponibilidade
Cada chamada vai envelopada em `perl -e 'alarm 900'` (o SO mata; `timeout` puro não existe no Mac).
Passou de 15 min = travou: mata e refaz uma vez; travou de novo → o confronto ficou indisponível.
**Confronto indisponível não vira silêncio:** a entrega NUNCA apresenta a candidata como confrontada
— marca explícito "sem confronto independente nesta rodada" no bloco 🗺️, rebaixa pra 🟡 Hipótese
(nunca ✅ Sólido) e diz isso alto. Confronto que falhou e o resultado segue mudo não é degradação
aceitável — é apresentar palpite como verificado.

### Regra de ouro — a sessão filtra o confronto COM PROVA
Nenhum ponto do GPT é aplicado cego (senão o confronto vira o novo dono da decisão):
- **Não procede** → descarta, mas cite o `arquivo:linha` ou a fonte que contradiz o ponto.
- **Procede e é grave** → decisão do dono: PARA e sobe pro usuário em A/B.
- **Procede e é menor** → entra na lista de achados normal.
- **Filtro de frivolidade:** o ponto muda QUAL candidata vence, ou muda se ela funciona? Não (gosto,
  estilo, "eu faria diferente") → descarta na hora, não litiga.

Registro obrigatório (mesma tabela de sempre — ver `../_shared/confronto-codex.md`
seção 4 pro formato, que continua valendo como referência de formato).
