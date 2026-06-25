# Confronto via Codex GPT-5.5 — motor compartilhado

Usado por `/planejar` e `/auto-think`. Este arquivo é o ÚNICO lugar onde mora a mecânica de
chamar o Codex como segundo par de olhos: como invocar sem travar, como não mandar dado real
pra fora, como garantir que ele leu a versão certa, e a regra de ouro de filtrar o parecer.
Cada skill mantém só o que é dela (o que mandar e o que fazer com a resposta) e aponta pra cá.

> **Por que existe.** O Codex é um modelo DIFERENTE do que conduz o trabalho. A graça é a
> divergência de opinião, não a confirmação — um segundo cérebro que tenta derrubar o
> raciocínio antes de ele virar verdade. Não é auditoria técnica linha a linha; a lente é
> única: *isso faz sentido / resolve o problema declarado?*

## 1. Trava de dado pra fora (antes de montar QUALQUER input)

Antes de escrever uma linha no arquivo que vai pro Codex, troque dado real de pessoa e
credencial (nome, CPF, telefone, e-mail, token, chave) por etiqueta estável (`PACIENTE_A`,
`TELEFONE_1`). Cada skill tem a sua "TRAVA DE DADO PRA FORA" no SKILL.md — siga-a. Se o ponto
só faz sentido com o dado real exposto, **PARA e pede autorização** — não manda mesmo assim.
Releia o input montado e confirme que nenhum campo cru passou.

## 2. Selo de versão (pega "confrontou versão velha")

O erro clássico do confronto é o Codex revisar uma versão antiga do material. O selo resolve:
calcule o hash do que vai ser confrontado e exija que o Codex o repita de volta.

```bash
# sha256sum existe no Linux; o Mac de fábrica só tem `shasum -a 256` (sem sha256sum)
H=$( { command -v sha256sum >/dev/null 2>&1 && sha256sum /tmp/confronto-input.md || shasum -a 256 /tmp/confronto-input.md; } | cut -d' ' -f1 ); echo "$H"
```

Monte o input final = **prompt + a linha do selo com `H` + o material**. Peça ao Codex pra
repetir o hash `H` como primeira seção (`## Selo`) da resposta. Ao receber, **confira que o
hash bate**. Não bateu → o Codex leu versão velha → descarta o parecer e re-roda só esta
chamada.

## 3. Como invocar (canônico — vale pras duas skills)

O padrão é: o prompt vai por **stdin** (não como argumento), com **teto de 15 minutos**, e a
resposta cai num arquivo de saída.

```bash
perl -e 'alarm 900; exec @ARGV' codex exec --model gpt-5.5 \
  -c model_reasoning_effort="xhigh" \
  -c service_tier="fast" \
  --skip-git-repo-check --ignore-user-config --sandbox workspace-write \
  - < /tmp/confronto-input.md > /tmp/confronto-review.md 2>/dev/null
```

- **`-` lê o prompt do stdin** (o `< arquivo`). Como o stdin já está redirecionado pro
  arquivo, NÃO precisa do `< /dev/null`. Só precisa dele se algum dia passar o prompt como
  ARGUMENTO em vez de stdin — aí termine a chamada com `< /dev/null` ou o `codex exec` trava
  esperando stdin (reproduzido empiricamente).
- **`alarm 900` é o teto.** GPT que roda mais de 15 min travou; o SO mata (SIGALRM). Refaz uma
  vez; travou de novo → "Codex fora" (seção 5). Usa `perl` porque o `timeout` puro não existe
  no Mac; no Linux dá pra trocar por `timeout 900`.
- **Esforço e tier:** o comando acima já vem em `xhigh` + `service_tier="fast"` (o padrão do
  `auto-think`: máximo de raciocínio na via rápida do gpt-5.5). O `fast` precisa ser explícito
  porque `--ignore-user-config` ignora o tier do config global. Uma skill que queira esforço
  menor numa checagem leve (ex: `planejar` na 1ª chamada) troca `xhigh` por `high` no comando dela.
- **Atalho:** a skill irmã `/Titan:gpt-optimizer` (no mesmo plugin) traz o `run-gpt.sh`,
  mas hoje ele roda afinado pro fluxo dela (**`--sandbox read-only`**, sem selo) — se o seu
  confronto precisa de outro sandbox ou da trava de selo, monte a chamada inline (acima). O
  helper de selo continua em `auto-worker/scripts/verify-selo.sh`.

## 4. Regra de ouro — o Claude filtra antes, COM PROVA

O parecer do Codex NUNCA é aplicado cego — é insumo, não ordem. Pra CADA ponto que ele
levantar, o Claude decide com prova, confrontando o material real:

- **Não procede** → descarta, **mas a refutação tem que ser provada**: aponte o `arquivo:linha`
  ou a seção que contradiz o ponto. Proibido refutar com opinião ("não acho que se aplica") —
  sem evidência concreta, o ponto NÃO pode ser descartado; na dúvida, trata como procede.
- **Procede e é grave** (problema mal formulado, plano/solução não resolve, caminho muito mais
  simples, premissa falsa) → é decisão do dono: **PARA e sobe pro usuário em A/B**, na
  linguagem de diretor, nunca decide sozinho.
- **Procede e é menor** → entra na lista de achados normal e é corrigido no fluxo da skill.

### Registro obrigatório — tudo documentado, aceito ou refutado

Todo ponto do Codex vira uma linha de registro, com a prova ao lado. Sem isso vira "ele falou,
eu ignorei" sem rastro. Onde salvar o registro é específico de cada skill (ver o arquivo dela).
Formato:

```markdown
## Veredito do Claude (cada ponto do Codex, com prova)

| # | Ponto do Codex (resumo) | Veredito | Prova (arquivo:linha / seção) | Destino |
|---|--------------------------|----------|-------------------------------|---------|
| 1 | <o que o Codex disse>    | PROCEDE  | §Backend não cobre o caso Y   | Ajuste aplicado |
| 2 | <...>                    | REFUTADO | `src/api/auth.ts:42` já trata | Descartado |
| 3 | <...>                    | PROCEDE/GRAVE | §Arquitetura — não resolve | Subiu pro usuário (A/B) |
```

- **Uma linha por ponto** — nenhum fica de fora.
- Coluna **Prova** nunca vazia. "Subjetivo / a meu ver" não é prova.
- **Destino** fecha o ciclo: `Descartado`, `Ajuste aplicado`, ou `Subiu pro usuário (A/B)`.

## 5. Fallback se o Codex estiver fora

CLI ausente, erro, ou timeout repetido → o confronto NÃO trava o fluxo. O Claude faz o papel do
revisor por conta própria como um agente SEPARADO e adversarial (advogado do diabo, NUNCA o
mesmo raciocínio que produziu o material), com a MESMA lente crítica e a mesma regra de ouro. A
entrega final informa que rodou sem o Codex — crítica do mesmo modelo que produziu vale menos.
