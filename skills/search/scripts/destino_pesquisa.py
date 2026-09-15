#!/usr/bin/env python3
"""Resolve E GARANTE a pasta onde uma pesquisa da skill `search` é arquivada.

Por que este script existe
--------------------------
A instrução em prosa dizia "resolva o caminho com o helper, nunca crave" — e isso
deixava três buracos: a skill não sabia onde o helper morava, nada garantia que a
pasta de destino existisse, e uma falha na resolução virava uma pasta criada em
lugar errado, em silêncio. Resolução de caminho é mecânica pura — não exige
julgamento — então vira código, não texto pedindo obediência.

O que ele garante
-----------------
1. Usa uma biblioteca local `search-findings/` na pasta de trabalho atual.
2. Cria `search-findings/` se faltar.
3. Com um tema, cria `<tema>-<AAAA-MM-DD>/referencias/` e imprime o caminho.

Uso
---
    python3 scripts/destino_pesquisa.py                  # raiz do agrupamento
    python3 scripts/destino_pesquisa.py "cot em modelos de raciocinio"
    python3 scripts/destino_pesquisa.py "tema" --data 2026-07-30   # data explícita
    python3 scripts/destino_pesquisa.py --conferir       # só checa, não cria nada

Códigos de saída: 0 pronto.
"""
from __future__ import annotations

import argparse
import datetime
import re
import sys
import unicodedata
from pathlib import Path

AGRUPAMENTO = "search-findings"


def raiz_da_biblioteca() -> Path:
    """Biblioteca local `search-findings/`, relativa à pasta de trabalho atual."""
    return Path.cwd() / AGRUPAMENTO


def slug(texto: str) -> str:
    """Tema legivel -> nome de pasta: sem acento, minusculo, hifens."""
    sem_acento = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode()
    limpo = re.sub(r"[^a-zA-Z0-9]+", "-", sem_acento).strip("-").lower()
    return (limpo or "pesquisa")[:60]


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Resolve e garante o destino de uma pesquisa.")
    ap.add_argument("tema", nargs="?", help="tema da pesquisa (vira o nome da pasta)")
    ap.add_argument("--data", help="data AAAA-MM-DD (padrao: hoje)")
    ap.add_argument("--conferir", action="store_true", help="so confere, nao cria nada")
    args = ap.parse_args(argv)

    agrupamento = raiz_da_biblioteca()

    if args.conferir:
        print(f"agrupamento: {agrupamento}  [{'ok' if agrupamento.is_dir() else 'sera criado no primeiro uso'}]")
        return 0

    agrupamento.mkdir(parents=True, exist_ok=True)

    if not args.tema:
        print(agrupamento)
        return 0

    data = args.data or datetime.date.today().isoformat()
    estudo = agrupamento / f"{slug(args.tema)}-{data}"
    (estudo / "referencias").mkdir(parents=True, exist_ok=True)
    print(estudo)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
