#!/usr/bin/env python3
"""Builds assets/banks/<bank>.json from the human-editable files in content/<bank>/.

content/<bank>/meta.json   version + categories (with names in every language)
content/<bank>/en.txt      master file: category + correct answer live here
content/<bank>/<lang>.txt  translations, same ids, same option order

Question format (blank line between questions, '#' starts a comment):

    [n001] infection
    Which agency registers disinfectants used in salons?
    - OSHA
    * EPA
    - FDA
    > The EPA registers disinfectants ...

'*' marks the correct option (required in en.txt; optional in translations,
but if present it must match). '>' lines are the explanation.

    python3 tool/build_banks.py          # build all banks, report problems
    python3 tool/build_banks.py nail     # build and check one bank only
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HEADER = re.compile(r"^\[([a-z0-9_]+)\](?:\s+([a-z0-9_]+))?\s*$")


def parse(path: Path) -> dict[str, dict]:
    out: dict[str, dict] = {}
    cur = None
    for n, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = HEADER.match(line)
        if m:
            qid = m.group(1)
            if qid in out:
                sys.exit(f"{path}:{n}: duplicate id {qid}")
            cur = out[qid] = {"cat": m.group(2), "q": [], "o": [], "star": None, "e": [], "line": n}
            continue
        if cur is None:
            sys.exit(f"{path}:{n}: text before the first [id]")
        if line.startswith(("- ", "* ")):
            if line.startswith("* "):
                if cur["star"] is not None:
                    sys.exit(f"{path}:{n}: two correct answers")
                cur["star"] = len(cur["o"])
            cur["o"].append(line[2:].strip())
        elif line.startswith(">"):
            cur["e"].append(line[1:].strip())
        else:
            if cur["o"]:
                sys.exit(f"{path}:{n}: question text after options (missing '- '?)")
            cur["q"].append(line)
    return out


def build(bank_dir: Path) -> list[str]:
    meta = json.loads((bank_dir / "meta.json").read_text())
    cats = [c["id"] for c in meta["categories"]]
    master = parse(bank_dir / "en.txt")
    problems: list[str] = []
    langs = {"en": master}
    for p in sorted(bank_dir.glob("*.txt")):
        if p.stem != "en":
            langs[p.stem] = parse(p)

    questions = []
    for qid, m in master.items():
        if m["cat"] not in cats:
            problems.append(f"en {qid}: unknown category '{m['cat']}'")
        if m["star"] is None:
            problems.append(f"en {qid}: no correct answer marked with '*'")
        if len(m["o"]) < 2 or not m["q"] or not m["e"]:
            problems.append(f"en {qid}: needs question, 2+ options and an explanation")
        texts = {}
        for lang, data in langs.items():
            t = data.get(qid)
            if t is None:
                if lang != "en":
                    problems.append(f"{lang} {qid}: missing translation")
                continue
            if len(t["o"]) != len(m["o"]):
                problems.append(f"{lang} {qid}: {len(t['o'])} options, en has {len(m['o'])}")
            if t["star"] is not None and t["star"] != m["star"]:
                problems.append(f"{lang} {qid}: '*' on a different option than en")
            texts[lang] = {"q": " ".join(t["q"]), "o": t["o"], "e": " ".join(t["e"])}
        questions.append({"id": qid, "cat": m["cat"], "a": m["star"] or 0, "t": texts})
    for lang, data in langs.items():
        for qid in data.keys() - master.keys():
            problems.append(f"{lang} {qid}: not in en.txt")

    for c in meta["categories"]:
        for lang in langs:
            if lang not in c["name"]:
                problems.append(f"meta: category {c['id']} has no {lang} name")

    out = {
        "id": bank_dir.name,
        "version": meta["version"],
        "languages": list(langs),
        "categories": meta["categories"],
        "questions": questions,
    }
    dest = ROOT / f"assets/banks/{bank_dir.name}.json"
    dest.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")))
    per_cat = {c: sum(q["cat"] == c for q in questions) for c in cats}
    print(f"{bank_dir.name:<14} {len(questions):>4} questions  langs={','.join(langs)}  {per_cat}")
    return problems


def main() -> None:
    problems = []
    only = set(sys.argv[1:])
    for d in sorted((ROOT / "content").iterdir()):
        if (d / "meta.json").exists() and (not only or d.name in only):
            problems += [f"{d.name}: {p}" for p in build(d)]
    if problems:
        print("\n".join(problems))
        sys.exit(f"\n{len(problems)} problem(s)")


if __name__ == "__main__":
    main()
