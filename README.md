# dev — pensar, fazer e passar o bastão

Quatro skills de desenvolvimento, chamáveis individualmente — repo-agnóstico, serve pra qualquer projeto.

**Autoria:** Cassiano Diniz · **Co-autoria:** Thales Laray

## As 4 skills

| Comando | O que faz |
|---|---|
| `/planejar <ideia>` | Metodologia completa pra desenhar um produto/software novo do zero antes de codar (8 fases: brainstorm → escopo → design → plano auditado). No fim, oferece executar com a auto-prompt. |
| `/auto-think <problema>` | Modo "largar e esquecer" pra **estudar um problema difícil a fundo**: ataca de vários ângulos em paralelo, confronta os achados com o Codex em 2 rodadas, e entrega **soluções com veredito** (a recomendada + alternativas). Não executa — para na recomendação; quem executa a escolhida é a auto-prompt. |
| `/auto-prompt <tarefa>` | Modo "largar e esquecer": o Claude executa a tarefa e o crítico (Codex) confronta o trabalho antes de fechar. A verificação obrigatória é calibrada pelo **risco da tarefa** (trivial faz e entrega; sensível liga o protocolo completo). Protocolo de segurança e verificação embutido. |
| `/handoff` | Gera um documento de passagem de bastão pra continuar o trabalho numa sessão nova, do zero. |

A `planejar` e a `auto-think` são os dois **pensadores** — uma desenha um produto novo, a outra
estuda um problema difícil; as duas **entregam pra `auto-prompt` executar** (sempre oferecendo,
nunca disparando sozinhas). A ponte `planejar → auto-prompt` passa um contrato de execução salvo
em arquivo, pra a auto-prompt não replanejar nem perder premissa. A `planejar` e a `auto-think`
confrontam com o Codex pelo **mesmo motor compartilhado** (`skills/_shared/confronto-codex.md`).

## Orquestrador — o que precisa por fora

- **auto-prompt** e **handoff** funcionam sozinhas (só dependem do `codex` CLI pro crítico —
  e a auto-prompt tem fallback se o Codex faltar).
- **auto-think** usa o `codex` CLI (confronto), a `/pesquisa`/`deep-research` + `perplexity`
  (parte web), o `context7` (doc oficial de domínio) e a `Agent`/`Workflow` tool (ângulos em
  paralelo). Se alguma faltar, degrada com aviso — não trava.
- **planejar** é um orquestrador: o pipeline completo usa skills externas (`superpowers:*`,
  `/pesquisa`, `perplexity`, `context7`, `firecrawl`, `taste-skill`, Stitch, `gemini-api-dev`).
  Sem elas, ela roda em modo degradado (pula as fases que dependem do que falta) — não quebra,
  mas entrega menos.

Lista completa de dependências e comandos de instalação: **[INSTALL.md](INSTALL.md)**.

## Compatibilidade Mac / Windows

O source vive no Google Drive e sincroniza entre as máquinas. Os scripts (ex.: `verify-selo.sh`)
são **bash** — rodam nativo no Mac/Linux e, no **Windows, via Git Bash**. Não rodam em
PowerShell/cmd nativo.

## Instalar

Pelo `/plugin`: adicione o marketplace onde o plugin está publicado e instale **dev**.
Roda uma vez por máquina. Depois as skills ficam disponíveis como `dev:planejar`,
`dev:auto-prompt`, `dev:handoff`.

Pra instalar o plugin **e todas as ferramentas que ele usa por fora** (pra você ou pra outra
pessoa), siga o **[INSTALL.md](INSTALL.md)** — tem os comandos exatos de cada dependência.
