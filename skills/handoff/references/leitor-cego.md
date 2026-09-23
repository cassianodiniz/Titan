# Leitor cego — teste de continuação a seco

Detalhe operacional do passo "Teste de continuação a seco" do handoff. O SKILL.md aponta pra cá; o miolo do fluxo (gerar → podar → entregar) fica lá.

**Ideia:** a releitura que você faz do próprio texto é enviesada — você ainda lembra da conversa e tapa buracos de cabeça sem perceber. O teste de verdade é entregar o doc a quem NÃO esteve aqui. Roda enquanto a conversa original ainda existe — é a última janela pra tapar buraco antes da aba morrer.

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
