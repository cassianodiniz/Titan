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
# (ex.: uma pasta de skills que roda sem git — versão é via cofre
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

   **Origem não é verdade — `[ARQUIVO]` exige ponteiro REPRODUZÍVEL.** Pra marcar algo como `[ARQUIVO]` (ou como RESTRIÇÃO FIRME), você precisa do ponteiro que a sessão nova reabre sozinha e confirma: `arquivo:linha` no HEAD atual, ou comando + saída colada. "Eu revisei e é assim" não conta. Marca composta como `[ARQUIVO+revisão]` é **proibida** — ela já vendeu chute como lei e a sessão nova confiou. Sem ponteiro reproduzível: rebaixa pra `[SUPOSIÇÃO]` ou `[CHAT]`, nunca "limite do sistema". O teste: *se a sessão nova for conferir, ela acha exatamente isto na fonte?* Não acha → não é `[ARQUIVO]`.

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

## VALIDADE DESTE HANDOFF
- Gerado em: [data + hora] · HEAD no momento: [hash do último commit — ou "sem git local: validade ancora só nos arquivos de hoje"]
- ⚠️ Este doc é um RETRATO do momento acima. Se a sessão original CONTINUOU trabalhando depois disto (em planejamento longo isso é comum), partes podem ter sido superadas. A sessão nova trata cada RESTRIÇÃO FIRME / decisão como **válida até conferir contra o estado de hoje** (git quando há; arquivos-chave quando não há — ver "COMO RETOMAR") — não como lei intocável.

## ESTADO DO PROJETO (git)
- Diretório: [pwd]
- Branch: [branch] · Último commit: [hash + mensagem]
- Não commitado: [resumo do git status --short / diff --stat, ou "árvore limpa"]
[É a âncora: a sessão nova confere o resto deste documento contra isto.]

## ESTADO AGORA (o que é verdade neste momento)
[O que já existe / já funciona / já foi feito. Fatos com origem marcada [GIT]/[ARQUIVO]/[CHAT]/[SUPOSIÇÃO]. Sem narrativa de "primeiro fizemos, depois...".]

## DECISÕES TOMADAS (e por quê)
Decisão que JÁ está em arquivo/commit: 1 linha basta — `[decisão literal] — porque [razão] [origem com ponteiro]`.

Decisão que só viveu no CHAT (não virou arquivo) NÃO cabe em 1 linha: a conclusão sem o porquê faz a sessão nova ou reabrir a decisão, ou seguir pelo motivo errado. Pra cada uma, escreva o bloco curto (mini-ADR):
- **Decisão:** [o que ficou decidido, literal]
- **Problema:** [o que ela resolve]
- **Opções consideradas:** [as que estavam na mesa]
- **Por que esta venceu:** [o motivo + o furo que matou as outras]
- **Descartado e por quê:** [o que NÃO fazer, pra ninguém refazer]

[Este bloco é obrigatório pra decisão-de-chat — é o raciocínio que a sessão nova não tem de outro jeito. Decisão trivial/reversível não precisa do bloco; decisão que molda o trabalho, sim.]

## JÁ TENTADO E NÃO DEU
[Caminhos descartados, pra ninguém refazer. 1 linha cada + por que falhou. Se não houver, "Nada relevante".]

## RESTRIÇÕES FIRMES
[Regras que não podem ser violadas — só as que o usuário realmente disse ou que estão no código. Cada uma com ponteiro REPRODUZÍVEL (arquivo:linha no HEAD, ou a fala literal do usuário). Regra de engenharia que você "deduziu do código" mas não consegue apontar exatamente onde NÃO entra aqui — vai pra "O QUE NÃO SEI / CONFIRMAR" como item a verificar. Restrição que é andaime temporário de teste (não limite permanente) — diga isso explícito, senão a sessão nova a trata como definitiva.]

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
**Primeira ação OBRIGATÓRIA — conferir antes de confiar (não improvise antes disto):**
1. Confirme o diretório ([pwd]). **Se há git aqui:** rode `git log -1 --oneline` e `git status --short` e **compare com a seção VALIDADE/ESTADO DO PROJETO acima** — se o HEAD de hoje ≠ o HEAD do doc, a sessão original CONTINUOU; anuncie "o doc é de um ponto anterior, vou conferir o que mudou" e trate as restrições como suspeitas até reconfirmar. **Se NÃO há git aqui** (ex.: pasta de skills): não há âncora de commit — a validade depende só dos arquivos de hoje, então pule direto pro passo 2 e confie no que os arquivos-chave disserem, não no que o doc afirma.
2. Leia os ARQUIVOS-CHAVE listados antes de tocar em qualquer coisa. Pra cada RESTRIÇÃO FIRME com ponteiro, **abra o ponteiro e confirme que ainda bate** — se o código não disser o que o doc diz, o ARQUIVO de hoje vence o doc; registre a divergência.
3. Rode [comando que mostra o estado: testes / build / abrir a tela] pra validar onde o trabalho parou.
4. Só depois de 1–3 baterem, comece pelo passo 1 de PRÓXIMOS PASSOS. Achou divergência grave (decisão revogada, restrição que não existe no código)? **Pare e diga ao usuário antes de seguir** — não continue por cima de uma premissa morta.
```

## Antes de entregar — uma releitura

Olhe o que você escreveu com olhos novos e tire qualquer linha que: (a) repete algo já resolvido sem ser restrição, (b) afirma como regra algo que foi só dedução sua, ou (c) aponta um arquivo que não existe (decisão de chat que devia ter sido copiada literal). Confira também que cada afirmação crítica do "ESTADO AGORA" bate com a seção do git — se não bate, marque `[SUPOSIÇÃO]` ou mova pra "O QUE NÃO SEI". Esse passo de poda é o que separa um handoff de alto sinal de um despejo.

## Teste de continuação a seco — o leitor cego (antes de salvar)

A releitura acima é você revendo o próprio texto — e você ainda lembra da conversa, então preenche os buracos de cabeça sem perceber. **O teste de verdade é entregar o doc a quem NÃO esteve aqui.** Esse passo roda enquanto a conversa original ainda existe — é a última janela pra tapar buraco antes da aba morrer.

Por padrão, manda o handoff pronto pra um **leitor cego (Codex)** que só tem o documento e responde uma coisa: *"só com isto, o que você NÃO conseguiria continuar?"*. O que ele apontar volta pro doc.

1. **Trava de dado pra fora:** o doc vai pro Codex (fornecedor externo). Antes de mandar, mascare dado real de pessoa (nome, telefone, CPF, email), credencial (token, chave) e também identificador interno sensível (nome de cliente/aluno/projeto, ID de banco) — troca por etiqueta estável (`ALUNO_A`, `TOKEN_***`, `PROJETO_X`). Vai a ESTRUTURA do trabalho, não a identidade de ninguém. Se algum buraco só fizer sentido com o dado real, trate à parte — não mande o dado cru.

2. **Monta o input** num arquivo temporário: uma instrução curta + o handoff inteiro (já mascarado). A instrução é literal:
   > "Você é um agente que vai continuar este trabalho numa sessão NOVA, sem nenhum histórico além deste documento. NÃO tem acesso à conversa que o gerou. Leia e responda só isto: (a) o que você NÃO conseguiria fazer ou decidir só com este doc? (b) que decisão está sem o porquê, te obrigando a adivinhar ou reabrir? (c) que ponteiro/arquivo citado você não conseguiria localizar? (d) que restrição está sem prova reproduzível? Liste os buracos, do mais grave ao menor. Se conseguiria continuar sem travar, diga isso."

3. **Roda o leitor cego** (script auto-contido na pasta desta skill — use o caminho-base que aparece quando a skill carrega, NÃO um caminho relativo ao cwd; o teto de 15 min e o retry já estão dentro do script):
   ```bash
   bash "<pasta-base-desta-skill>/scripts/cold-read.sh" /tmp/cold-input.md /tmp/cold-out.md high
   ```
   - Saiu OK → para cada buraco que PROCEDE (muda se a sessão nova continua ou não), **corrige o doc**: copia o raciocínio que faltou, conserta o ponteiro, rebaixa a restrição sem prova. Buraco frívolo (estilo, "eu faria diferente") descarta. Uma passada, não vira debate.
   - **Falha graciosa:** Codex ausente/travado (exit 3 ou 5) → NÃO trava o handoff (é fluxo de pressa). Cai pro plano B: você mesmo relê o doc no papel de leitor cego ("esqueça a conversa") e marca no rodapé do handoff `revisão de continuação: menor garantia (sem Codex)`. Risco é só um doc — seguir sem o revisor externo é aceitável, desde que avisado.

4. Um revisor, não dois. Dupla GPT+Gemini num doc curto acha 90% a mesma coisa e dobra o ponto de falha — o ganho é sair do seu viés, e um leitor cego já faz isso.

## Entrega

O handoff é um **arquivo**; a entrega no chat é um **prompt colável** que aponta pra ele — pro usuário copiar e colar num Claude novo (ele não quer abrir o arquivo na tela, quer o prompt pronto). Nesta ordem:

1. **Salve o documento** num local previsível:
   - Se houver repositório git: `<raiz-do-repo>/.claude/handoffs/handoff-<branch>-AAAA-MM-DD-HHMMSS.md` (crie a pasta se não existir; sanitize a branch trocando `/` por `-`).
   - Se não houver git: `~/handoffs/handoff-AAAA-MM-DD-HHMMSS.md`.

2. **Gere um PROMPT COLÁVEL dentro de um bloco de código**, pro usuário copiar e colar em outro Claude. O prompt aponta pro arquivo salvo (o "link" = o **caminho absoluto**) e manda continuar — NÃO repete o conteúdo do handoff (ele está no arquivo). Modelo:
   ```
   Leia o handoff em <caminho ABSOLUTO do .md> e continue o trabalho descrito nele: <objetivo em 1 linha>.

   Antes de tocar em qualquer coisa, execute a "Primeira ação OBRIGATÓRIA" da seção COMO RETOMAR do handoff (conferir git + rodar os testes/checagem de estado). Só depois siga os PRÓXIMOS PASSOS.
   ```
   - O caminho TEM que ser **absoluto** (clicável/colável em qualquer máquina), dentro do bloco de código.
   - **100% colável:** nada pra o usuário editar, preencher ou filtrar.

3. **Avise o caminho salvo em uma linha** abaixo do bloco (ex: "Handoff salvo em `<caminho>` — cole o prompt acima num Claude novo."). NÃO cole o conteúdo inteiro do handoff no chat — ele está no arquivo. No máximo, 1-2 linhas do que o documento cobre.

Se **nenhum** local for gravável, aí sim exiba o handoff completo no chat (dentro de um bloco de código) como último recurso, e avise que não deu pra salvar.

Não narre o processo nem peça permissão pra gerar — ele chamou `/handoff` porque já quer o documento + o prompt colável.
