# Especificacao e Constituicao — templates (Fase 3)

Templates dos dois artefatos da Fase 3. A spec traduz o escopo em requisitos verificaveis; a constituicao registra os principios que governam todas as decisoes seguintes.

## Notacao EARS (criterios de aceite)

Todo criterio de aceite usa um dos 6 padroes EARS (Easy Approach to Requirements Syntax). O valor: um criterio EARS e testavel e nao-ambiguo — o modelo que escreve o plano, o que audita e o que implementa leem a MESMA coisa. Criterio vago ("deve ser rapido", "UX fluida") nao entra: reescreva ate ter condicao + comportamento observavel.

| Padrao | Forma | Exemplo |
|--------|-------|---------|
| Ubiquo | O sistema DEVE `<comportamento>` | O sistema DEVE armazenar senhas com hash argon2id |
| Evento | QUANDO `<evento>`, o sistema DEVE `<resposta>` | QUANDO o cliente confirma o horario, o sistema DEVE enviar confirmacao por WhatsApp em ate 60s |
| Estado | ENQUANTO `<estado>`, o sistema DEVE `<comportamento>` | ENQUANTO o barbeiro estiver com agenda cheia, o sistema DEVE ofertar o proximo dia livre |
| Opcional | ONDE `<feature presente>`, o sistema DEVE `<comportamento>` | ONDE o plano for Pro, o sistema DEVE liberar multiplas unidades |
| Erro | SE `<condicao indesejada>`, ENTAO o sistema DEVE `<resposta>` | SE o pagamento falhar, ENTAO o sistema DEVE manter a reserva por 15 min e avisar o cliente |
| Complexo | combinacao dos anteriores | QUANDO X, SE Y, ENTAO o sistema DEVE Z |

## Template da spec — `docs/<nome>-spec.md`

```markdown
# Spec — <nome do produto>

## Contexto
1 paragrafo. Links: escopo (Fase 1), perfil do cliente (Fase 2, se houve).

## Requisitos
### R1 — <titulo curto>
Como <persona>, quero <acao> para <valor>.
- R1.1: QUANDO <evento>, o sistema DEVE <resposta>
- R1.2: SE <erro>, ENTAO o sistema DEVE <resposta>
### R2 — ...

## Fora de escopo
Explicito, um por linha, com "por enquanto" ou "nunca" — evita escopo furtivo no plano.

## Clarifications
Perguntas feitas e respostas dadas (brainstorm + esta fase). Formato Q/A datado.

## Premissas e gatilhos de replanejamento
| Premissa | Gatilho | O que revisitar |
|----------|---------|-----------------|
| ≤10k usuarios no ano 1 | crescer 5x | camada de DB (D1 → alternativa) |
```

Regras:
- Numeracao estavel: fases seguintes referenciam `R<n>`/`R<n.m>` (tela cobre R2, task implementa R1.1, auditoria rastreia R3). NUNCA renumere — requisito removido fica marcado como "retirado".
- Se sobrou lacuna do brainstorm, pergunte AGORA (poucas perguntas, direcionadas) e registre em Clarifications. Lacuna pequena na spec vira arquitetura errada em dezenas de arquivos no plano.
- Mudou requisito depois da Fase 3? Edite a spec PRIMEIRO, depois propague — nunca so o plano.
- **Produto multi-tenant:** o isolamento vira principio da constituicao, mas a ADMINISTRACAO do tenant vira requisito aqui — gestao de membros, convites, papeis e (se o usuario pode estar em 2+ tenants) troca de tenant. Sem `R<n>` pra isso, a Fase 5 nao desenha as telas e o analyze da Fase 7 nao tem o que rastrear: o furo passa. Escreva tambem o criterio negativo (ex: "SE o usuario nao pertence ao tenant, ENTAO o sistema DEVE negar"), que e o que vira jornada negativa na Fase 9.

## Template da constituicao — `docs/<nome>-constituicao.md`

Principios invioláveis do projeto: curta (1 pagina), lida por TODAS as fases seguintes antes de decidir, e regua dos auditores da Fase 7. Cada principio traz o porque e como auditar.

```markdown
# Constituicao — <nome do produto>

## Principios da metodologia (defaults — riscar so com decisao explicita do usuario)
1. **Cloudflare-first**: toda camada nasce Cloudflare; saida so por cobertura ou custo, justificada por escrito.
   *Auditar:* tabela de decisao da Fase 4 — toda saida tem excecao registrada?
2. **Testes antes da implementacao de cada modulo.**
   *Auditar:* toda task de modulo no plano comeca com teste?
3. **Human-in-the-loop nos gates**: nenhuma fase avanca sem aprovacao.

## Principios do produto (definidos com o usuario nesta fase)
4. ex: Acessibilidade AA em toda UI. *Auditar:* design doc + plano citam contraste/foco/aria.
5. ex: Dados de cliente nunca saem do Brasil (LGPD). *Auditar:* localizacao de storage/DB no plano.

## Excecoes aprovadas
| Principio | Excecao | Justificativa | Data |
|-----------|---------|---------------|------|
| 1 | Stack Next.js+Supabase mantida | projeto ja existente, usuario recusou migracao | 2026-07-11 |
```

Regras:
- A constituicao NAO e wishlist: so entra principio que o usuario topa ter cobrado na auditoria.
- Excecao documentada aqui encerra o assunto — nenhuma fase re-litiga (a oferta unica de Cloudflare da Fase 4 ja aconteceu ou esta registrada).
