---
name: handoff
description: "Gera um documento de handoff (passagem de bastão) pra continuar o trabalho desta conversa numa sessão NOVA, do zero, sem o histórico. Use SEMPRE que o usuário disser /handoff, \"gera um handoff\", \"vou limpar o contexto\", \"passa isso pra uma sessão nova\", \"documento de continuação\", \"resume pra eu continuar depois\", \"to chegando no limite de contexto\", ou quando uma conversa longa está terminando e ele quer retomar o mesmo trabalho mais tarde. O objetivo é capturar ESTADO + PONTEIROS (não um resumo), ancorado em git e arquivos, de forma que a sessão nova não invente regra, não repita o que já foi resolvido, e não omita o que importa."
---

# Handoff — passagem de bastão entre sessões

Você está gerando um documento pra um **você do futuro** que vai abrir uma sessão limpa, sem nada do histórico desta conversa, e precisa continuar este mesmo trabalho sem perder o fio. A saída vira um **arquivo `.md` salvo em disco** — na sessão nova, o usuário só aponta o caminho do arquivo e manda continuar.

O modelo mental que importa: quando a sessão fecha, **a conversa inteira é varrida** — ela não persiste. O que sobrevive é o que está em **disco** (arquivos salvos) e no **git** (branch, commits). Por isso um handoff que se apoia na sua memória da conversa é frágil, e um que se **ancora em git e arquivos** é sólido. Sua primeira tarefa é amarrar o documento à realidade do projeto, não à lembrança do chat.

O segundo erro clássico é tratar handoff como **resumo**. Resumo condensa a conversa e, no caminho, apaga o detalhe exato que a próxima pergunta vai precisar — e preenche os buracos com chute, que vira "regra" inventada na sessão nova. Por isso este handoff **não resume**: captura o **estado** (o que é verdade agora) e aponta **ponteiros** (qual arquivo reler), separando fato de suposição.

A doutrina por trás é o context engineering da Anthropic: o que vale é o **menor conjunto de informação de alto sinal** que faz o trabalho continuar — não o despejo. Contexto inflado "por garantia" piora o desempenho do modelo (*context rot*). Capture tudo que muda o trabalho daqui pra frente, e corte todo o resto.

> **Timing:** o ideal é rodar isto **antes** do contexto encher — por volta de 50-70%, antes de qualquer `/compact`. Rodando cedo, a conversa inteira ainda está disponível e o handoff sai completo. Se você perceber que a sessão já foi compactada, **diga isso no documento** ("parte da conversa pode ter sido perdida na compactação"), pra não passar falsa confiança.

## Passo 0 — Ancore no git antes de escrever

Antes de redigir, levante o estado real do projeto (se houver repositório). Rode e guarde a saída:

```bash
pwd
# Ancora em git SÓ se esta pasta for um repositório. Em pastas SEM git
# (ex.: a pasta de skills do Cassiano, que roda sem git — versão é via cofre
# ~/skills-repo + GitHub), pula silenciosamente, sem cuspir "not a git repository".
if git rev-parse --git-dir >/dev/null 2>&1; then
  git rev-parse --show-toplevel; git branch --show-current
  git log -1 --oneline
  git status --short
  git diff --stat
else
  echo "(sem git nesta pasta — projeto não versionado aqui)"
fi
```

Quando HÁ git, esses dados viram a seção "ESTADO DO PROJETO (git)" — a âncora de realidade: a sessão nova confere o texto contra o estado de verdade. Quando NÃO há git (caso da pasta de skills), pule essa seção e registre só o `pwd`, dizendo que esta pasta não é versionada localmente.

## As 9 regras de geração (é aqui que handoff falha)

1. **Varra a conversa INTEIRA, não só o fim.** Decisão tomada no começo e nunca revertida ainda vale. Faça uma passada de recall máximo primeiro (não perca nada que muda o trabalho futuro), depois corte o supérfluo.

2. **Cite decisão e configuração LITERALMENTE — não parafraseie.** Valor, caminho de arquivo, comando, número, nome de variável, regra de negócio: copie exato. Parafrasear é o mecanismo pelo qual você inventa algo que não foi dito.

3. **Marque a origem de cada afirmação:** `[GIT]` / `[ARQUIVO]` / `[CHAT]` / `[SUPOSIÇÃO]`. `[GIT]`/`[ARQUIVO]` = você confirmou na fonte. `[CHAT]` = o usuário disse na conversa (verdade, mas não está em disco ainda — atenção à regra 6). `[SUPOSIÇÃO]` = inferência sua; se não dá pra confirmar, ou marca assim, ou joga em "O QUE NÃO SEI". Nunca apresente achismo com cara de regra.

4. **Não invente restrição, regra ou requisito que não apareceu na conversa.** Na dúvida: "isso foi dito, ou eu deduzi?". Deduzido vira `[SUPOSIÇÃO]` ou sai.

5. **Corte o que já foi resolvido e fechado.** Bug corrigido, caminho descartado, discussão encerrada — não repita, a não ser que aquilo agora seja uma **restrição** pro que vem (e aí explique o porquê em uma linha). Repetir o resolvido enche o documento e enterra o que importa.

6. **Aponte o arquivo em vez de colar o conteúdo — MAS só funciona se o conteúdo existe em disco.** Pra coisa que está em arquivo, escreva o caminho + pra que serve (`src/foo.ts` — onde fica a lógica X); quem ler relê na hora. **Exceção crítica:** uma decisão, raciocínio ou plano que só existiu no chat e nunca virou arquivo precisa ser **copiado literal** pro handoff — ponteiro pra arquivo que não existe é informação perdida. Se for algo grande e durável, considere salvar num arquivo de verdade e então apontar.

7. **Liste explicitamente o que você NÃO sabe.** Buraco real vira pergunta concreta na seção "O QUE NÃO SEI / CONFIRMAR". Um gap nomeado é infinitamente melhor que um gap preenchido com chute — porque na sessão nova o chute passa por verdade.

8. **Alto sinal, não volume.** Inclua tudo que muda a decisão futura; corte o resto. Mínimo não quer dizer curto — quer dizer só o que importa.

9. **Comece no verbo.** Sem "esse é o handoff de…", sem preâmbulo. Abra direto com a ação: "Leia X. Depois continue Y." Cada próximo passo é uma ordem no imperativo.

## Estrutura de saída

Use estes títulos, nesta ordem. Pule uma seção só se ela ficaria genuinamente vazia (e aí escreva "Nada relevante" em vez de inventar conteúdo).

```
Leia [os arquivos/seções essenciais primeiro]. Depois continue o trabalho descrito abaixo.

## OBJETIVO
[1-2 frases: o que esse trabalho tem que entregar no fim das contas.]

## ESTADO DO PROJETO (git)
- Diretório: [pwd]
- Branch: [branch] · Último commit: [hash + mensagem]
- Não commitado: [resumo do git status --short / diff --stat, ou "árvore limpa"]
[É a âncora: a sessão nova confere o resto deste documento contra isto.]

## ESTADO AGORA (o que é verdade neste momento)
[O que já existe / já funciona / já foi feito. Fatos com origem marcada [GIT]/[ARQUIVO]/[CHAT]/[SUPOSIÇÃO]. Sem narrativa de "primeiro fizemos, depois...".]

## DECISÕES TOMADAS (e por quê)
- [decisão citada literal] — porque [razão em 1 linha] [origem]
[Inclua aqui decisões que só existiram no chat — copiadas literais, não como ponteiro.]

## JÁ TENTADO E NÃO DEU
[Caminhos descartados, pra ninguém refazer. 1 linha cada + por que falhou. Se não houver, "Nada relevante".]

## RESTRIÇÕES FIRMES
[Regras que não podem ser violadas — só as que o usuário realmente disse ou que estão no código. Cite a origem de cada uma.]

## ARQUIVOS-CHAVE (ponteiros, não conteúdo)
- `caminho/arquivo` — pra que serve / o que mexer aqui

## O QUE NÃO SEI / CONFIRMAR
[Gaps reais como perguntas concretas. Se não houver, "Nada em aberto".]

## PRÓXIMOS PASSOS (imperativo, em ordem)
1. [Verbo + ação concreta e verificável]
2. ...

## COMO SABER QUE DEU CERTO
[Critério objetivo de pronto: o teste que passa, a tela que aparece, o comando que retorna OK.]

## COMO RETOMAR NESTA SESSÃO NOVA
1. Confirme que está no diretório e branch acima ([pwd] / [branch]).
2. Leia os ARQUIVOS-CHAVE listados antes de tocar em qualquer coisa.
3. Rode [comando que mostra o estado: testes / build / abrir a tela] pra validar onde o trabalho parou.
4. Comece pelo passo 1 de PRÓXIMOS PASSOS.
```

## Antes de entregar — uma releitura

Olhe o que você escreveu com olhos novos e tire qualquer linha que: (a) repete algo já resolvido sem ser restrição, (b) afirma como regra algo que foi só dedução sua, ou (c) aponta um arquivo que não existe (decisão de chat que devia ter sido copiada literal). Confira também que cada afirmação crítica do "ESTADO AGORA" bate com a seção do git — se não bate, marque `[SUPOSIÇÃO]` ou mova pra "O QUE NÃO SEI". Esse passo de poda é o que separa um handoff de alto sinal de um despejo.

## Entrega

O handoff é um **arquivo**, não um despejo no chat. Salva, abre e avisa onde está — nesta ordem:

1. **Salve o documento** num local previsível:
   - Se houver repositório git: `<raiz-do-repo>/.claude/handoffs/handoff-<branch>-AAAA-MM-DD-HHMMSS.md` (crie a pasta se não existir; sanitize a branch trocando `/` por `-`).
   - Se não houver git: `~/handoffs/handoff-AAAA-MM-DD-HHMMSS.md`.

2. **Abra o arquivo na tela** com o app padrão do sistema, pra ele bater o olho na hora:
   - Mac: `open "<caminho>"`
   - Windows (Git Bash): `start "" "<caminho>"`
   Se o comando de abrir falhar, não trava o fluxo — segue pro passo 3.

3. **Avise o caminho salvo em uma linha** (ex: "Handoff salvo em `<caminho>` e aberto na tela."). NÃO cole o conteúdo inteiro do handoff no chat — ele está no arquivo, que já abriu. No máximo, um resumo de 1-2 linhas do que o documento cobre.

Se **nenhum** local for gravável, aí sim exiba o handoff completo no chat (dentro de um bloco de código) como último recurso, e avise que não deu pra salvar.

Não narre o processo nem peça permissão pra gerar — ele chamou `/handoff` porque já quer o documento.
