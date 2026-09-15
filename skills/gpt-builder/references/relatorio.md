# Relatório final ao usuário

Escrito para quem nunca abriu um terminal. Nesta ordem:

1. **Onde estamos.** Uma frase: o que foi pedido, o que ficou pronto, o que ficou fora.
2. **Como testar** (só se há tela/visual ou comportamento observável pelo usuário). Lista numerada: onde clicar, o que preencher, o que deve aparecer. O link/tela já está aberto pelo passo de prévia; liste o dado de teste criado no banco local (nome `TESTE ...`) com os valores exatos, e diga que pode ser apagado quando quiser.
3. **O que foi verificado.** Tabela curta: comando, resultado (código de saída ou "N testes passaram"). Inclui tipos, provas por item, suíte completa na versão final, e o veredito do fiscal independente (PASS/FAIL, itens provados de N, quantas rodadas) — explique em uma frase que o fiscal é outro agente que não escreveu o código e conferiu cada item com o próprio comando. Diga "revisão geral pendente" se uma revisão geral externa ainda não rodou.
4. **Ainda na máquina.** O código está pronto e commitado localmente, mas nada foi pro GitHub ainda — subir e abrir a proposta (PR) espera seu OK. Se veio de uma issue, diga qual e se a proposta vai fechá-la por inteiro (o GitHub fecha sozinho quando mesclar) ou só em parte.
5. **Decisões tomadas** sem perguntar (as que a spec não fixava), como o trabalho foi executado (direto, ou delegado — e por quê, marcando "delegado por custo" quando for o caso) e o que ficou fora do escopo.
6. **Próximo passo.** Pergunta única: "Posso subir e abrir a proposta (PR) agora?" (a revisão geral na PR vem depois).

Não use termo técnico sem comparação com algo do mundo real antes. Sem "R$" mais de uma vez na mesma mensagem sem escapar (`R\$`).
