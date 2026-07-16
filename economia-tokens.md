# Economia de tokens no Claude Code — instalador

*Orientações e configuração de **Cassiano Diniz**.*

**Como usar** — abra o Claude Code e cole isto:

> Leia https://raw.githubusercontent.com/cassianodiniz/Titan/main/economia-tokens.md e execute tudo.

Pronto. O Claude faz o resto sozinho. (Se você já tem o arquivo na mão, também dá: arraste ele pro Claude Code e escreva *"leia este arquivo e execute tudo"*.)

Durante a instalação ele vai te pedir permissão 2 ou 3 vezes (aparece um "permitir?" na tela). **Clique em sim.** Isso é a trava de segurança do seu computador perguntando se pode continuar. É normal, e ela existe justamente pra te proteger.

No fim, o Claude te entrega um relatório dizendo o que ficou pronto. Você só precisa fechar e abrir o Claude Code.

Funciona em **Mac** e em **Windows**. Instala no **Claude Code** e no **Codex** (se você tiver os dois).

---

# INSTRUÇÕES PARA O CLAUDE — leia tudo antes de começar, depois execute na ordem

Você vai instalar duas ferramentas de economia de token **na máquina de outra pessoa**. Não presuma que ela mexe com terminal, nem que vai saber consertar se você quebrar alguma coisa. Aja de acordo: prove cada passo, e quando não der, pare e explique — não improvise.

1. **Ponytail** — plugin que faz o assistente escrever menos código inútil (https://github.com/DietrichGebert/ponytail)
2. **RTK** — programa que corta o excesso de texto que os comandos cospem de volta (https://www.rtk-ai.app)

## Regras que valem para a execução inteira

- **Nunca declare pronto sem prova na tela.** Cada etapa tem uma verificação. Se a verificação não passou, o item é FALHOU. Não escreva OK em item que você não viu passar.
- **Falhou = pare e reporte.** Mostre o erro cru e o que ele significa em português simples. Não invente contorno, não tente outro caminho por conta própria.
- **Nunca desligue trava de segurança.** Se o Claude Code ou o Codex pedirem aprovação, deixe a pessoa aprovar. É proibido usar `--dangerously-bypass-hook-trust`, editar `trusted_hash` na mão, ou qualquer atalho que pule a confirmação do dono da máquina. Isto não é negociável.
- **Nunca sobrescreva arquivo de configuração que já existe** sem antes fazer cópia de segurança e avisar no relatório.
- **Falar como gente.** Nada de jargão nas mensagens pra ela — explique o que está acontecendo em português simples.

---

## ETAPA 0 — Descobrir o terreno

Descubra o sistema e o que já existe. No Mac/Linux:

```bash
uname -s
node -v 2>/dev/null || echo "SEM_NODE"
command -v claude >/dev/null && claude plugin list >/dev/null 2>&1 && echo "TEM_CLAUDE"
command -v codex  >/dev/null && echo "TEM_CODEX"
command -v rtk    >/dev/null && rtk --version || echo "SEM_RTK"
```

No Windows (você provavelmente está no Git Bash — chame o PowerShell para as tarefas de Windows):

```bash
powershell.exe -NoProfile -Command "[System.Environment]::OSVersion.VersionString"
```

Anote: **sistema**, **tem Node?**, **tem Claude Code?**, **tem Codex?**, **tem RTK?**. Isso decide o resto.

Se não achar nem `claude` nem `codex` → PARE. Diga: "não encontrei o Claude Code nem o Codex nesta máquina — não tenho onde instalar."

---

## ETAPA 1 — Node (faça antes de tudo, não pule)

**Por que isso importa:** os ganchos do Ponytail rodam com Node. O arquivo de ganchos dele termina em `; exit 0` no Mac e em `if (Get-Command node ...)` no Windows — ou seja, **sem Node o Ponytail instala, aparece na lista como instalado, e não funciona.** Falha silenciosa. Se você não checar isso, entrega um falso sucesso.

Se `node -v` respondeu com uma versão → siga para a etapa 2.

Se **não** respondeu, instale:

- **Mac**, se tiver Homebrew: `brew install node`
- **Mac**, sem Homebrew: PARE e diga à pessoa: *"Falta um programa chamado Node no seu computador. Baixe o instalador em https://nodejs.org (botão verde da esquerda, versão LTS), instale clicando next-next-next, feche e abra o Claude Code, e me chame de novo com este mesmo arquivo."*
- **Windows**: tente `winget install OpenJS.NodeJS.LTS`. Se o `winget` não existir ou falhar, PARE e dê a mesma orientação do https://nodejs.org acima.

Depois de instalar, confirme com `node -v`. Se ainda não responder → PARE e reporte. **Não siga sem Node.**

---

## ETAPA 2 — Ponytail no Claude Code

O README do Ponytail só mostra os comandos como `/plugin marketplace add ...`. Aqueles são de digitar na tela — **você não consegue executar aqueles**. Use os equivalentes de terminal:

```bash
claude plugin marketplace add DietrichGebert/ponytail
claude plugin install ponytail@ponytail
```

Se disser que o marketplace já existe, tudo bem, siga.

**Verificar (obrigatório):**

```bash
claude plugin marketplace list
claude plugin list
```

Tem que aparecer `ponytail` nos marketplaces **e** `ponytail@ponytail` nos plugins. Se não apareceu, é FALHOU.

---

## ETAPA 3 — Ponytail no Codex

Só faça se a etapa 0 achou `codex`. Se não achou, marque "não se aplica" e pule.

```bash
codex plugin marketplace add DietrichGebert/ponytail
codex plugin add ponytail@ponytail
```

**Verificar:**

```bash
codex plugin list
```

> O mesmo arquivo de ganchos (`hooks/claude-codex-hooks.json`) serve o Claude e o Codex — é o próprio plugin que declara isso no `plugin.json`. Não há nada extra a configurar.

**Restou uma coisa que só a pessoa faz** (isso vai para o relatório, não tente automatizar): na primeira vez que ela abrir o `codex`, precisa digitar `/hooks` e confiar nos ganchos do ponytail. É a trava de segurança do Codex perguntando se aquele plugin baixado da internet pode rodar. **Não pule por ela.**

---

## ETAPA 4 — Instalar o RTK

Se a etapa 0 já achou `rtk` com versão → pule para a etapa 5.

### Mac

Com Homebrew (preferido):

```bash
brew update && brew install rtk
```

Sem Homebrew:

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

### Windows

⚠️ **Não use o `install.sh` no Windows.** Ele checa o `uname` e recusa qualquer coisa que não seja Linux ou Mac — no Git Bash ele falha. Não use `brew`, `winget` nem `scoop`: o RTK não está em nenhum deles.

⚠️ **Nunca use o comando `setx` para mexer no PATH.** Ele corta a lista de programas do sistema se ela passar de 1024 caracteres — isso estraga a máquina da pessoa, não só a instalação. Use o método .NET abaixo, que não tem esse limite.

Rode via PowerShell, este bloco inteiro:

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command @'
$ErrorActionPreference = "Stop"
$dest = Join-Path $env:LOCALAPPDATA "rtk\bin"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$tmp = Join-Path $env:TEMP "rtk-win.zip"
$base = "https://github.com/rtk-ai/rtk/releases/latest/download"

Invoke-WebRequest -Uri "$base/rtk-x86_64-pc-windows-msvc.zip" -OutFile $tmp
Invoke-WebRequest -Uri "$base/checksums.txt" -OutFile "$env:TEMP\rtk-checksums.txt"

$esperado = (Select-String -Path "$env:TEMP\rtk-checksums.txt" -Pattern "rtk-x86_64-pc-windows-msvc.zip").Line.Split()[0]
$real = (Get-FileHash $tmp -Algorithm SHA256).Hash.ToLower()
if ($real -ne $esperado.ToLower()) { throw "ASSINATURA NAO CONFERE - download corrompido ou adulterado. Abortado." }

Expand-Archive -Path $tmp -DestinationPath $dest -Force
$u = [Environment]::GetEnvironmentVariable("Path","User")
if ($u -notlike "*$dest*") { [Environment]::SetEnvironmentVariable("Path", ($u.TrimEnd(";") + ";" + $dest), "User") }
Write-Output "RTK_OK $dest"
'@
```

O que esse bloco faz, em português: cria uma pasta, baixa o RTK, **confere a assinatura do arquivo** (se não bater, aborta — protege contra download adulterado), descompacta e registra no sistema. O zip tem um arquivo só dentro: `rtk.exe`.

**Verificar:**

⚠️ **Cuidado com o caminho aqui.** No Git Bash, `$LOCALAPPDATA` vem no formato do Windows (`C:\Users\...`). Se você jogar isso direto no PATH, o `C:` vira uma entrada separada e **quebra a lista inteira de programas** da sessão — aí o `rtk` "some" e você vai achar que a instalação falhou. Converta antes com `cygpath`:

```bash
RTK_BIN="$(cygpath -u "$LOCALAPPDATA")/rtk/bin"
"$RTK_BIN/rtk.exe" --version
export PATH="$PATH:$RTK_BIN"   # só pra esta sessão, já convertido
```

Se a assinatura não conferir → PARE. Não instale mesmo assim.

> O PATH definitivo só vale em janela nova. Se `rtk` sozinho não responder ainda, use `$RTK_BIN/rtk.exe` até a pessoa reiniciar — e diga isso no relatório.

### Verificar (os dois sistemas)

```bash
rtk --version
rtk gain
```

Se `rtk gain` responder, é o RTK certo. (Existe outro programa chamado "rtk" por aí que não é este.)

---

## ETAPA 5 — Gravar a configuração

### ⛔ BLOCO CONGELADO — esta é a configuração do Cassiano Diniz. Grave byte a byte, sem alterar, sem "melhorar", sem adaptar.

```toml
[tracking]
enabled = true
history_days = 90

[display]
colors = true
emoji = true
max_width = 120

[filters]
ignore_dirs = [
  ".git",
  "node_modules",
  "target",
  "__pycache__",
  ".venv",
  "vendor",
]

ignore_files = [
  "*.lock",
  "*.min.js",
  "*.min.css",
]

[tee]
enabled = true
mode = "failures"
max_files = 20
max_file_size = 1048576

[telemetry]
enabled = false

[hooks]
exclude_commands = [
  "git diff",
  "git show",
  "git blame",
  "gh pr view",
  "gh pr diff",
  "terraform plan",
  "terraform apply",
  "kubectl apply",
  "kubectl delete",
  "helm upgrade",
  "psql",
  "mysql",
  "sqlite3",
  "cat",
  "sed",
  "awk",
]

[limits]
grep_max_results = 200
grep_max_per_file = 25
status_max_files = 15
status_max_untracked = 10
passthrough_max_chars = 2000
```

**Identidade obrigatória deste bloco:** 775 bytes · SHA-256 `14059ffbb9f6ae7155e570669b6bd2a292bfe492f61df6908750300d7a94b1b4`

> O `[tee]` precisa de `max_files` e `max_file_size`. Sem eles o arquivo quebra. Não remova.

### Como gravar

**Não** crave o caminho do Mac. O caminho muda por sistema e não está documentado no Windows. Descubra pelo próprio RTK — a primeira linha de `rtk config` imprime o caminho, e funciona mesmo antes do arquivo existir:

```bash
rtk config | head -1
# Config: /Users/<nome>/Library/Application Support/rtk/config.toml
```

Passos — **nesta ordem, que não é à toa:**

1. Pegue o caminho dessa primeira linha (tudo depois de `Config: `). Chame de `<caminho>`.
2. **Grave o bloco congelado num arquivo TEMPORÁRIO primeiro** (ex.: `<caminho>.novo`), **usando a sua ferramenta de escrever arquivo** (a Write), não pelo PowerShell.
3. **Confira a assinatura do temporário** (comando abaixo). Se não bater → **PARE**, apague o temporário e reporte. A config que a pessoa já tinha continua intacta e funcionando.
4. Só se bateu: se já existia config, copie a antiga pra `<caminho>.bak` e **confirme que a cópia existe**. Registre esse caminho no relatório.
5. Só então mova o temporário por cima do `<caminho>`.

> **Por que essa ordem:** o jeito óbvio — gravar por cima e conferir depois — destrói a config boa da pessoa antes de descobrir que deu errado. Aí ela fica sem a nova (que falhou) e sem a antiga (que você já apagou). Gravando no temporário, se algo falhar, nada foi perdido.

> **Por que a Write e não o PowerShell:** `Set-Content` e `Out-File` metem uma marca invisível no começo do arquivo e trocam as quebras de linha. Isso muda os bytes e o SHA-256 não bate mais — ou seja, você teria alterado a configuração que era pra ficar intacta. A Write grava exato.

### Verificar (obrigatório — é a prova de que a config chegou intacta)

```bash
# Mac
shasum -a 256 "<caminho>.novo"
# Windows
powershell.exe -NoProfile -Command "(Get-FileHash '<caminho>.novo' -Algorithm SHA256).Hash.ToLower()"
```

Tem que dar exatamente `14059ffbb9f6ae7155e570669b6bd2a292bfe492f61df6908750300d7a94b1b4`.

**Se não bater, é FALHOU** — não conserte no olho, não "ajuste", e **não mova o temporário por cima**. Reporte que a config não gravou idêntica.

Depois:

```bash
rtk config
```

Tem que aparecer sem erro. **Se der erro de TOML, PARE** e mostre o erro cru — não conserte a config por conta própria.

> Nota de versão: o tutorial original foi escrito para o RTK 0.39.0 e hoje o Homebrew entrega mais novo (0.43.0 na data desta escrita). Isso é normal — **não force uma versão velha**, não trave se `rtk --version` mostrar outro número. Quem decide é o `rtk config` validar limpo.

---

## ETAPA 6 — Ligar o RTK no Claude Code

```bash
rtk init -g --auto-patch
```

**Verificar:**

```bash
rtk init --show
```

Esperado — quatro linhas com `[ok]`:

```
[ok] Hook: rtk hook claude (native binary command)
[ok] RTK.md: /Users/<nome>/.claude/RTK.md
[ok] Global (~/.claude/CLAUDE.md): @RTK.md reference
[ok] settings.json: RTK hook configured
```

O caminho vai ter o nome da pessoa, não o do exemplo. Isso é esperado, não é erro.

Confirme que o gancho certo entrou:

```bash
grep -n "rtk hook claude" "$HOME/.claude/settings.json"
```

Tem que achar `"command": "rtk hook claude"`.

---

## ETAPA 7 — Ligar o RTK no Codex

Só se a etapa 0 achou `codex`.

⚠️ **Não use `rtk init --codex`.** Ele só escreve texto de recomendação (AGENTS.md), pedindo pro modelo lembrar de digitar `rtk`. O próprio help dele diz: *"no Claude hook patching"*. Isso não é o que a gente quer — a gente quer o mecanismo, que não depende do modelo lembrar.

O Codex tem o mesmo sistema de ganchos do Claude e aceita o **mesmo comando**. Isso foi testado de ponta a ponta: o Codex pediu `git status` e o gancho entregou `rtk git status`. Não precisa de nenhuma peça intermediária.

Grave em `~/.codex/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|shell",
        "hooks": [
          { "type": "command", "command": "rtk hook claude", "timeout": 10 }
        ]
      }
    ]
  }
}
```

⚠️ **Se `~/.codex/hooks.json` já existir, NÃO sobrescreva.** Leia o que tem lá, faça cópia `.bak`, e **acrescente** o `PreToolUse` ao que já existe. Se você não conseguir juntar com segurança, PARE e reporte — melhor não instalar do que apagar a configuração da pessoa.

**Verificar o comportamento (não só o arquivo):**

```bash
printf '%s\n' '{"tool_name":"Bash","tool_input":{"command":"git status"}}' | rtk hook claude
printf '%s\n' '{"tool_name":"Bash","tool_input":{"command":"git diff"}}' | rtk hook claude
```

- `git status` tem que devolver `"updatedInput":{"command":"rtk git status"}`
- `git diff` tem que devolver **vazio** (não reescreve — comando onde cada linha importa)

**Restou uma coisa que só a pessoa faz:** abrir o `codex`, digitar `/hooks` e confiar no gancho novo. Vai para o relatório.

---

## ETAPA 8 — A política de bom senso

Isso não é o que faz o mecanismo funcionar — o gancho já funciona sozinho. Isso orienta o assistente a usar o RTK com bom senso: usar onde o texto é descartável, e **não** usar onde cada linha importa.

Acrescente ao fim de `~/.claude/CLAUDE.md` (crie o arquivo se não existir). Se os marcadores `<!-- RTK_POLICY_START -->` / `<!-- RTK_POLICY_END -->` já estiverem lá, **substitua só o miolo entre eles** — não duplique o bloco.

```markdown
<!-- RTK_POLICY_START -->
## RTK policy

Use RTK for noisy, non-authoritative shell commands:
- tests: `rtk pytest`, `rtk npm test`, `rtk cargo test`, `rtk go test`, `rtk vitest`
- lint/typecheck: `rtk eslint`, `rtk ruff check`, `rtk tsc`
- routine status/logs: `rtk git status`, `rtk docker logs`, `rtk ls`, `rtk find`, `rtk grep`

Do not use RTK for commands where every line may matter:
- `git diff`, `git show`, `git blame`
- PR final review: `gh pr view`, `gh pr diff`
- security review
- final review before commit/merge
- database commands
- infrastructure commands such as `terraform plan/apply`, `kubectl apply/delete`, `helm upgrade`
- critical YAML/JSON/config/data files

For critical commands, run the raw command without `rtk`.
If RTK output says truncated/incomplete or points to a full-output file, inspect the full/raw output before deciding.
<!-- RTK_POLICY_END -->
```

Se a máquina tem Codex, grave **o mesmo bloco** em `~/.codex/AGENTS.md` (mesma regra: não duplique, crie se não existir).

**Verificar:**

```bash
grep -n "RTK policy" ~/.claude/CLAUDE.md
grep -n "@RTK.md"    ~/.claude/CLAUDE.md
```

Os dois têm que aparecer.

---

## ETAPA 9 — Relatório final (obrigatório)

Escreva exatamente este relatório, preenchido com o que **de fato** apareceu na tela. Item que você não viu passar é FALHOU, não OK.

```
INSTALAÇÃO — RESULTADO

Terreno
  sistema .......................... <Mac / Windows>
  Node ............................. <versão> [instalado agora / já tinha]
  Claude Code ...................... <sim / não>
  Codex ............................ <sim / não>

Ponytail
  Claude Code ...................... [OK / FALHOU / não se aplica]
  Codex ............................ [OK / FALHOU / não se aplica]

RTK
  versão ........................... <versão>
  config gravada ................... <caminho>
  SHA-256 confere (14059ff...) ..... [OK / FALHOU]
  rtk config sem erro .............. [OK / FALHOU]
  ligado no Claude Code ............ [OK / FALHOU]
  ligado no Codex .................. [OK / FALHOU / não se aplica]
  git status → rtk git status ...... [OK / FALHOU]
  git diff → não mexe .............. [OK / FALHOU]
  política de bom senso ............ [OK / FALHOU]

Cópias de segurança que eu fiz: <caminhos, ou "nenhuma — não havia arquivo anterior">

FALTA VOCÊ FAZER:
  1. Feche e abra o Claude Code. (Nada liga na janela que instalou.)
  2. Na janela nova, digite: /ponytail
     Esperado: ele responde qual modo está ativo.
  3. Na janela nova, peça: "rode git status"
     Esperado: o comando sai como `rtk git status`.
  4. Na janela nova, peça: "mostre o diff atual"
     Esperado: sai `git diff` normal, sem rtk. (É de propósito: aqui cada linha importa.)
  [se tem Codex]
  5. Abra o codex, digite /hooks e confie nos ganchos do ponytail e do rtk.
     É a trava de segurança perguntando se pode. Sem isso, os dois não funcionam no Codex.
  [se Windows e o rtk sozinho ainda não respondeu]
  6. Reinicie o computador (ou só feche e abra tudo) pra o Windows enxergar o RTK.

Pra ver quanto economizou, depois de usar uns dias: rtk gain
```

Se algum item deu FALHOU: liste embaixo o comando que falhou, a saída crua do erro, e o que isso significa em português simples. Sem palpite.
