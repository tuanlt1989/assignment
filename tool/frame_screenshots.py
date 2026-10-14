#!/usr/bin/env python3
"""Turns raw demo screenshots (build/raw_screenshots/<app>_<scene>.png, made by
tool/screenshots/shoot.js) into 1080x1920 Play Store phone screenshots with a
caption, for every listing locale in apps/<id>.json "screenshotCaptions".

Output: store/<id>/metadata/android/<locale>/images/phoneScreenshots/N.png
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
import graphics  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
if "--root" in sys.argv:
    ROOT = (ROOT / sys.argv[sys.argv.index("--root") + 1]).resolve()
RAW = ROOT / "build/raw_screenshots"
SCENES = ["home", "practice", "exam", "result"]
if "--scenes" in sys.argv:
    SCENES = sys.argv[sys.argv.index("--scenes") + 1].split(",")
W, H = 1080, 1920


def frame(app: dict, raw: Path, caption: str) -> Image.Image:
    base = graphics.hex_rgb(app["color"])
    img = graphics.gradient((W, H), graphics.shade(base, 1.1), graphics.shade(base, 0.7)).convert("RGBA")
    d = ImageDraw.Draw(img)
    f = graphics.font(74)
    lines = graphics._wrap(d, caption, f, W - 140)
    while len(lines) > 2:
        f = graphics.font(f.size - 6)
        lines = graphics._wrap(d, caption, f, W - 140)
    y = 110 if len(lines) == 2 else 150
    for ln in lines:
        tw = d.textlength(ln, font=f)
        d.text(((W - tw) / 2, y), ln, font=f, fill=(255, 255, 255))
        y += f.size * 1.2
    shot = Image.open(raw).convert("RGB")
    sw = 860
    sh = int(shot.height * sw / shot.width)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    top = 380
    x = (W - sw) // 2
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([x, top + 16, x + sw, top + sh + 16], radius=48, fill=(0, 0, 0, 110))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(22)))
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw - 1, sh - 1], radius=48, fill=255)
    img.paste(shot, (x, top), mask)
    return img.convert("RGB")


def main() -> None:
    made = 0
    for p in sorted((ROOT / "apps").glob("*.json")):
        app = json.loads(p.read_text())
        for locale, captions in app.get("screenshotCaptions", {}).items():
            out = ROOT / f"store/{app['id']}/metadata/android/{locale}/images/phoneScreenshots"
            out.mkdir(parents=True, exist_ok=True)
            for i, (scene, cap) in enumerate(zip(SCENES, captions), 1):
                raw = RAW / f"{app['id']}_{scene}.png"
                if not raw.exists():
                    sys.exit(f"missing {raw} — run tool/screenshots/shoot.js first")
                frame(app, raw, cap).save(out / f"{i}.png", optimize=True)
                made += 1
    print(f"{made} screenshots written")


if __name__ == "__main__":
    main()
