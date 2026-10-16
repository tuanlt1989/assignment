#!/usr/bin/env python3
"""Gathers everything needed for Play Console into one folder, one subfolder per app:

    play-upload/
      README.md                  common steps (Part A of docs/STORE-GUIDE.md) + index
      01-civilserviceph/
        app-civilserviceph-release.aab     (when --aab-dir has it)
        UPLOAD.md                this app's sheet: texts, product, App content…
        listing/<locale>/title.txt, short_description.txt, full_description.txt
        listing/<locale>/images/icon.png, featureGraphic.png, phoneScreenshots/1-4.png
        product/premium_lifetime.png       in-app product icon
      …

    python3 tool/pack_upload.py --out play-upload [--aab-dir DIR] [--zip]

--aab-dir is searched recursively for app-<id>-release.aab (e.g. the unpacked
CI artifacts). --zip also writes play-upload/<id>.zip per app (for Releases).
"""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import store_guide  # noqa: E402

REPO = store_guide.REPO


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="play-upload")
    ap.add_argument("--aab-dir", help="folder searched for app-<id>-release.aab")
    ap.add_argument("--zip", action="store_true", help="also zip each app folder")
    a = ap.parse_args()

    out = Path(a.out).resolve()
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    aabs = {p.name: p for p in Path(a.aab_dir).rglob("app-*-release.aab")} if a.aab_dir else {}

    apps = store_guide.load_apps()
    index = []
    missing = []
    for i, (cfg, root) in enumerate(apps, 1):
        aid = cfg["id"]
        d = out / f"{i:02d}-{aid}"
        shutil.copytree(root / "store" / aid / "metadata/android", d / "listing")
        shutil.copytree(root / "store" / aid / "product_icons", d / "product")
        aab = aabs.get(f"app-{aid}-release.aab")
        if aab:
            shutil.copy2(aab, d / aab.name)
        else:
            missing.append(aid)
        sheet = store_guide.app_section(i, cfg, root, local=True)
        sheet = sheet.replace("Phần A, mục", "`../README.md`, mục")
        (d / "UPLOAD.md").write_text(f"# {store_guide.heading(i, cfg, root)}\n\n" + sheet.split("\n", 1)[1])
        index.append(f"| {i} | [`{d.name}/`]({d.name}/UPLOAD.md) | `{cfg['applicationId']}` | "
                     f"{'✅' if aab else '—'} |")
        if a.zip:
            shutil.make_archive(str(out / aid), "zip", root_dir=out, base_dir=d.name)

    common = store_guide.common_part(apps)
    (out / "README.md").write_text(
        "# Play upload: 15 app\n\n"
        "Mỗi thư mục con là 1 app: mở `UPLOAD.md` trong đó và làm theo từ trên xuống. "
        "File AAB, ảnh, chữ store và icon sản phẩm đều nằm sẵn trong thư mục của app.\n\n"
        "| # | Thư mục | Mã app | AAB |\n|---|---|---|---|\n" + "\n".join(index) + "\n\n" + common
    )
    print(f"{out}: {len(apps)} apps, AAB for {len(apps) - len(missing)}")
    if missing and a.aab_dir:
        print("no AAB for: " + ", ".join(missing))


if __name__ == "__main__":
    main()
