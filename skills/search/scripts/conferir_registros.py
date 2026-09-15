#!/usr/bin/env python3
"""Confere os registros que os subagentes devolveram — sem ter executado a busca.

    python3 scripts/conferir_registros.py registros.json

Por que existe
--------------
Item 7 do checklist da auditoria: *"existe algum passo que confira o relato do
subagente contra a fonte, feito por quem não executou?"* Até 30/07/2026 não havia
— o Step 3 deduplicava, mesclava e checava lacunas, mas nada conferia o que o
subagente afirmou. Quem executou era a única testemunha (evidência E10, classe D1).

Por que um script, e não um segundo modelo
------------------------------------------
A pesquisa de 30/07 mediu que revisor mais fraco que o autor **piora** o resultado
(Claude revisando Codex: 71,6%→89,7%; Codex revisando Claude: 91,4%→82,8%), e que
revisores correlacionados param de ajudar depois de ~3. Um revisor forte custa
caro; um fraco estraga.

Mas boa parte do que precisa ser conferido **não exige julgamento nenhum**: é
consistência interna do próprio registro. O número afirmado aparece no trecho
citado? A contagem de origens bate com a lista? Um `supports` convive com um
`not found`? Nada disso precisa de modelo — precisa de aritmética. O que sobra
depois, que é semântico, fica para o orquestrador, com o material já filtrado.

O que ele NÃO faz
-----------------
Não abre página, não julga se a fonte é boa, não decide se o trecho *sustenta*
a afirmação no sentido semântico. Ele pega **contradição dentro do relato** — que
é a classe de erro que passa despercebida justamente por parecer bem-formada.

Entrada: JSON, lista de registros (ou objeto com a chave `records`).
Saída: relatório legível. Códigos: 0 sem problema · 1 achou problema · 2 entrada inválida.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

OBRIGATORIOS_CLAIM = ["claim", "support_status", "independent_sources", "sources"]
OBRIGATORIOS_FONTE = ["url", "evidence_quote", "credited_origin", "published"]
MEASURED = ["measured_model", "measured_task", "measured_n", "measured_window"]


def numeros(texto: str) -> set[str]:
    """Números de um texto, normalizados: '80,4' e '80.40' viram '80.4'; '100' fica '100'.

    Só corta zero à direita quando há parte decimal — senão `100` viraria `1`.
    """
    saida = set()
    for a in re.findall(r"\d+(?:[.,]\d+)?", str(texto)):
        n = a.replace(",", ".")
        if "." in n:
            n = n.rstrip("0").rstrip(".")
        saida.add(n or "0")
    return saida


def confere(reg: dict, i: int) -> list[str]:
    problemas: list[str] = []
    rot = f"registro {i}" + (f" ({str(reg.get('claim',''))[:50]}…)" if reg.get("claim") else "")

    faltando = [c for c in OBRIGATORIOS_CLAIM if c not in reg]
    if faltando:
        return [f"{rot}: campo omitido — {', '.join(faltando)}. "
                "Campo ausente não é 'não declarado': é informação que sumiu sem deixar rastro."]

    fontes = reg.get("sources") or []
    if not isinstance(fontes, list):
        return [f"{rot}: `sources` não é lista — o formato de fonte única voltou."]

    # 1. afirmação com número e nenhuma fonte
    if not fontes:
        problemas.append(f"{rot}: nenhuma fonte. Afirmação com número e zero páginas abertas.")

    # 2. campos omitidos dentro de cada fonte
    for k, f in enumerate(fontes, 1):
        falta = [c for c in OBRIGATORIOS_FONTE if c not in f]
        if falta:
            problemas.append(f"{rot}, fonte {k}: campo omitido — {', '.join(falta)}.")

    # 3. `supports` convivendo com trecho não encontrado
    achou_algum = any(str(f.get("evidence_quote", "")).strip().lower() not in ("", "not found")
                      for f in fontes)
    if reg.get("support_status") == "supports" and not achou_algum:
        problemas.append(
            f"{rot}: `support_status: supports` mas nenhuma fonte tem trecho ("
            "todas `not found`). Sustentação afirmada sem nada que a sustente.")

    # 4. o número da afirmação aparece em algum trecho citado?
    #    Arredondar é legítimo ("~80%" a partir de 80,4%), então a comparação tolera
    #    diferença menor que 1 — o alvo é o número trocado, não o número arredondado.
    n_claim = numeros(reg.get("claim", ""))
    if n_claim:
        n_quotes = set()
        for f in fontes:
            q = str(f.get("evidence_quote", ""))
            if q.strip().lower() != "not found":
                n_quotes |= numeros(q)
        if n_quotes:
            def bate(a: str) -> bool:
                try:
                    va = float(a)
                except ValueError:
                    return False
                for b in n_quotes:
                    try:
                        if abs(va - float(b)) < 1:
                            return True
                    except ValueError:
                        continue
                return False
            orfaos = [a for a in sorted(n_claim) if not bate(a)]
            if len(orfaos) == len(n_claim):
                problemas.append(
                    f"{rot}: o número da afirmação ({', '.join(orfaos)}) não aparece em "
                    f"nenhum trecho citado ({', '.join(sorted(n_quotes))}), nem arredondado. "
                    "Ou o trecho é de outra coisa, ou o número foi reescrito no caminho.")

    # 5. independent_sources bate com as origens distintas da lista?
    origens = set()
    proprias = 0
    for f in fontes:
        cred = str(f.get("credited_origin", "")).strip()
        if cred.lower() in ("none", ""):
            proprias += 1
        else:
            origens.add(cred.lower())
    esperado = proprias + len(origens)
    declarado = reg.get("independent_sources")
    if isinstance(declarado, int) and esperado and declarado != esperado:
        problemas.append(
            f"{rot}: `independent_sources: {declarado}` mas a lista tem {esperado} origem(ns) "
            f"distinta(s) ({proprias} própria(s) + {len(origens)} creditada(s)). "
            "Se o declarado for maior, ecos estão sendo contados como confirmações.")

    # 6. mesma URL repetida na lista
    urls = [str(f.get("url", "")).strip().rstrip("/") for f in fontes]
    dup = {u for u in urls if u and urls.count(u) > 1}
    if dup:
        problemas.append(f"{rot}: a mesma página aparece {urls.count(list(dup)[0])}x na lista "
                         f"({list(dup)[0][:60]}) — uma fonte contada mais de uma vez.")

    # 7. todos os measured_* em branco: não é erro, é aviso
    if all(str(reg.get(m, "not stated")).strip().lower() == "not stated" for m in MEASURED):
        problemas.append(
            f"{rot}: AVISO — os quatro campos de medição estão `not stated`. "
            "O número não é transferível para caso nenhum; considere reportá-lo como "
            "afirmação sem procedência, não como achado.")

    return problemas


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("uso: conferir_registros.py <arquivo.json>", file=sys.stderr)
        return 2
    caminho = Path(argv[1])
    try:
        dados = json.loads(caminho.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"ERRO: nao consegui ler {caminho}: {e}", file=sys.stderr)
        return 2

    registros = dados.get("records", dados) if isinstance(dados, dict) else dados
    if not isinstance(registros, list):
        print("ERRO: esperava uma lista de registros (ou objeto com a chave 'records').",
              file=sys.stderr)
        return 2

    print(f"\nConferindo {len(registros)} registro(s) — {caminho.name}\n" + "-" * 62)
    todos: list[str] = []
    for i, reg in enumerate(registros, 1):
        if not isinstance(reg, dict):
            todos.append(f"registro {i}: não é um objeto.")
            continue
        todos += confere(reg, i)

    avisos = [p for p in todos if "AVISO" in p]
    erros = [p for p in todos if "AVISO" not in p]

    for e in erros:
        print(f"  ✗ {e}")
    for a in avisos:
        print(f"  ! {a}")

    print("-" * 62)
    if erros:
        print(f"\n{len(erros)} problema(s) no relato dos subagentes"
              + (f", {len(avisos)} aviso(s)" if avisos else "") + ".")
        print("Nenhum deles exigiu abrir a página: são contradições dentro do próprio registro.")
        return 1
    print(f"\nOK — nenhuma contradição interna"
          + (f" ({len(avisos)} aviso(s))" if avisos else "") + ".")
    print("Isto não diz que as afirmações são verdadeiras — só que o relato é consistente.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
