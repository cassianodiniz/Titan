# Relatório final ao usuário

Escrito para quem nunca abriu um terminal. Nesta ordem:

1. **Onde estamos.** Uma frase: o que foi pedido, o que ficou pronto, o que ficou fora.
2. **Como testar** (só se há tela/visual ou comportamento observável pelo usuário). Lista numerada: onde clicar, o que preencher, o que deve aparecer. O link/tela já está aberto pelo passo de prévia; liste o dado de teste criado no banco local (nome `TESTE ...`) com os valores exatos, e diga que pode ser apagado quando quiser.
3. **O que foi verificado.** Tabela curta: comando, resultado (código de saída ou "N testes passaram"). Inclui tipos, provas por item e suíte completa na versão final. Diga quantos itens foram comprovados de N e aponte os que falharam ou não puderam ser verificados. Estas verificações foram rodadas pela mesma sessão que implementou; não as apresente como revisão independente. A revisão independente (`build-review`) ainda não rodou: registre-a como pendente.
4. **Ainda na máquina.** O código está pronto e commitado localmente, mas nada foi pro GitHub ainda — subir e abrir a proposta (PR) espera seu OK. Se veio de uma issue, diga qual e se a proposta vai fechá-la por inteiro (o GitHub fecha sozinho quando mesclar) ou só em parte.
5. **Decisões tomadas** sem perguntar (as que a spec não fixava) e o que ficou fora do escopo.
6. **Próximo passo.** Pergunta única: "Posso rodar a vistoria (`/build-review`) agora?" Ela roda nesta mesma sessão, sobre o que está commitado na máquina. Subir e abrir a proposta (PR) fica para depois dela, com o seu OK.

Não use termo técnico sem comparação com algo do mundo real antes. Sem "R$" mais de uma vez na mesma mensagem sem escapar (`R\$`).
