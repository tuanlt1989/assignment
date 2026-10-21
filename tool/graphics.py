"""Icons and store graphics, drawn from an app's config. No design tool needed.

Every app gets: an adaptive launcher icon (foreground + background color), a
legacy launcher icon, the 512x512 Play icon and the 1024x500 feature graphic.
"""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
FONT_BOLD = ROOT / "assets/fonts/Roboto-Bold.ttf"
FONT_REG = ROOT / "assets/fonts/Roboto-Regular.ttf"


def hex_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def shade(rgb, f: float):
    """f < 1 darkens, f > 1 lightens."""
    if f < 1:
        return tuple(int(c * f) for c in rgb)
    return tuple(int(c + (255 - c) * (f - 1)) for c in rgb)


def font(size: int, bold: bool = True):
    return ImageFont.truetype(str(FONT_BOLD if bold else FONT_REG), size)


def gradient(size, top, bottom) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size, top)
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


def _glyph(d: ImageDraw.ImageDraw, kind: str, cx: float, cy: float, s: float, fg, accent):
    """Draw a simple white glyph centered at (cx, cy) with scale s (~ half size)."""
    if kind == "nail":
        # Nail-polish bottle: cap + neck + rounded body + shine.
        d.rounded_rectangle([cx - s * 0.28, cy - s * 1.0, cx + s * 0.28, cy - s * 0.25], radius=s * 0.08, fill=fg)
        d.rectangle([cx - s * 0.36, cy - s * 0.3, cx + s * 0.36, cy - s * 0.12], fill=fg)
        d.rounded_rectangle([cx - s * 0.7, cy - s * 0.12, cx + s * 0.7, cy + s * 1.0], radius=s * 0.28, fill=fg)
        d.rounded_rectangle([cx - s * 0.5, cy + s * 0.08, cx + s * 0.5, cy + s * 0.8], radius=s * 0.2, fill=accent)
        d.rounded_rectangle([cx - s * 0.4, cy + s * 0.16, cx - s * 0.24, cy + s * 0.6], radius=s * 0.08, fill=fg)
    elif kind == "comb":
        # Comb: spine + teeth.
        d.rounded_rectangle([cx - s * 1.0, cy - s * 0.7, cx + s * 1.0, cy - s * 0.25], radius=s * 0.15, fill=fg)
        n = 9
        for i in range(n):
            x = cx - s * 0.9 + i * (s * 1.8 / (n - 1))
            d.rounded_rectangle([x - s * 0.06, cy - s * 0.3, x + s * 0.06, cy + (0.85 if i % 2 == 0 else 0.6) * s], radius=s * 0.05, fill=fg)
    elif kind == "shield":
        pts = [
            (cx, cy - s * 1.0),
            (cx + s * 0.85, cy - s * 0.65),
            (cx + s * 0.75, cy + s * 0.35),
            (cx, cy + s * 1.0),
            (cx - s * 0.75, cy + s * 0.35),
            (cx - s * 0.85, cy - s * 0.65),
        ]
        d.polygon(pts, fill=fg)
        w = max(4, int(s * 0.18))
        d.line([(cx - s * 0.4, cy), (cx - s * 0.08, cy + s * 0.32), (cx + s * 0.45, cy - s * 0.3)], fill=accent, width=w, joint="curve")
    elif kind == "cross":
        # Medical cross inside a rounded badge.
        w = s * 0.34
        d.rounded_rectangle([cx - w, cy - s * 0.95, cx + w, cy + s * 0.95], radius=s * 0.1, fill=fg)
        d.rounded_rectangle([cx - s * 0.95, cy - w, cx + s * 0.95, cy + w], radius=s * 0.1, fill=fg)
    elif kind == "helmet":
        # Hard hat: dome + brim + ridge.
        d.pieslice([cx - s * 0.85, cy - s * 0.95, cx + s * 0.85, cy + s * 0.75], 180, 360, fill=fg)
        d.rounded_rectangle([cx - s * 1.05, cy - s * 0.15, cx + s * 1.05, cy + s * 0.12], radius=s * 0.08, fill=fg)
        d.rectangle([cx - s * 0.12, cy - s * 0.95, cx + s * 0.12, cy - s * 0.25], fill=accent)
    elif kind == "columns":
        # Government building: roof, columns, base.
        d.polygon([(cx, cy - s * 1.0), (cx + s * 1.0, cy - s * 0.5), (cx - s * 1.0, cy - s * 0.5)], fill=fg)
        for i in range(4):
            x = cx - s * 0.72 + i * s * 0.48
            d.rectangle([x - s * 0.1, cy - s * 0.38, x + s * 0.1, cy + s * 0.55], fill=fg)
        d.rectangle([cx - s * 1.0, cy + s * 0.62, cx + s * 1.0, cy + s * 0.82], fill=fg)
    elif kind == "arrow":
        w = s * 0.28
        d.rectangle([cx - w, cy - s * 0.2, cx + w, cy + s * 1.0], fill=fg)
        d.polygon([(cx, cy - s * 1.0), (cx + s * 0.85, cy - s * 0.1), (cx - s * 0.85, cy - s * 0.1)], fill=fg)
    elif kind == "sunmoon":
        # Sun (with rays) on the upper left, crescent moon on the lower right.
        sx, sy, r = cx - s * 0.38, cy - s * 0.38, s * 0.42
        for k in range(8):
            a = math.pi * k / 4
            d.line([(sx + math.cos(a) * r * 1.3, sy + math.sin(a) * r * 1.3),
                    (sx + math.cos(a) * r * 1.75, sy + math.sin(a) * r * 1.75)], fill=fg, width=max(2, int(s * 0.1)))
        d.ellipse([sx - r, sy - r, sx + r, sy + r], fill=fg)
        mx, my, mr = cx + s * 0.42, cy + s * 0.42, s * 0.55
        d.ellipse([mx - mr, my - mr, mx + mr, my + mr], fill=fg)
        d.ellipse([mx - mr * 0.35, my - mr * 1.05, mx + mr * 1.25, my + mr * 0.55], fill=accent)
    elif kind == "magnifier":
        # Magnifying glass with a question mark in the lens.
        r = s * 0.62
        lx, ly = cx - s * 0.2, cy - s * 0.2
        w = max(3, int(s * 0.2))
        a = math.pi / 4
        d.line([(lx + math.cos(a) * r * 0.95, ly + math.sin(a) * r * 0.95),
                (cx + s * 0.95, cy + s * 0.95)], fill=fg, width=int(s * 0.32))
        d.ellipse([lx - r, ly - r, lx + r, ly + r], outline=fg, width=w)
        f = font(int(s * 0.9))
        d.text((lx, ly + s * 0.02), "?", font=f, fill=fg, anchor="mm")
    elif kind == "cat":
        # Cat head with ears and eyes.
        d.ellipse([cx - s * 0.9, cy - s * 0.6, cx + s * 0.9, cy + s * 0.95], fill=fg)
        d.polygon([(cx - s * 0.85, cy - s * 0.2), (cx - s * 0.75, cy - s * 1.0), (cx - s * 0.2, cy - s * 0.55)], fill=fg)
        d.polygon([(cx + s * 0.85, cy - s * 0.2), (cx + s * 0.75, cy - s * 1.0), (cx + s * 0.2, cy - s * 0.55)], fill=fg)
        for ex in (-0.35, 0.35):
            d.ellipse([cx + s * ex - s * 0.13, cy - s * 0.05, cx + s * ex + s * 0.13, cy + s * 0.25], fill=accent)
        d.polygon([(cx - s * 0.1, cy + s * 0.38), (cx + s * 0.1, cy + s * 0.38), (cx, cy + s * 0.5)], fill=accent)
    elif kind == "blocks":
        g = s * 0.62
        for (i, j) in [(-1, -1), (0, -1), (-1, 0), (0, 0), (1, 0), (0, 1)]:
            x, y = cx + i * g - g / 2 + g * 0.5 * 0, cy + j * g - g / 2
            d.rounded_rectangle([x + g * 0.06, y + g * 0.06, x + g * 0.94, y + g * 0.94], radius=g * 0.18, fill=fg)
    elif kind == "pixel":
        g = s * 0.5
        heart = [".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..."]
        for j, row in enumerate(heart):
            for i, ch in enumerate(row):
                if ch == "X":
                    x, y = cx + (i - 3.5) * g * 0.6, cy + (j - 3) * g * 0.6
                    d.rectangle([x, y, x + g * 0.55, y + g * 0.55], fill=fg)
    elif kind == "bus":
        d.rounded_rectangle([cx - s * 0.85, cy - s * 0.95, cx + s * 0.85, cy + s * 0.75], radius=s * 0.25, fill=fg)
        d.rounded_rectangle([cx - s * 0.65, cy - s * 0.7, cx + s * 0.65, cy - s * 0.1], radius=s * 0.1, fill=accent)
        for wx in (-0.5, 0.5):
            d.ellipse([cx + s * wx - s * 0.2, cy + s * 0.6, cx + s * wx + s * 0.2, cy + s * 1.0], fill=fg)
            d.ellipse([cx + s * wx - s * 0.1, cy + s * 0.3, cx + s * wx + s * 0.1, cy + s * 0.5], fill=accent)
    elif kind == "domino":
        # Upright domino: two halves with pips (3 and 5).
        d.rounded_rectangle([cx - s * 0.55, cy - s * 1.0, cx + s * 0.55, cy + s * 1.0], radius=s * 0.16, fill=fg)
        d.rectangle([cx - s * 0.4, cy - s * 0.04, cx + s * 0.4, cy + s * 0.04], fill=accent)
        r = s * 0.11
        top = [(-0.25, -0.75), (0, -0.5), (0.25, -0.25)]
        bottom = [(-0.25, 0.25), (0.25, 0.25), (0, 0.5), (-0.25, 0.75), (0.25, 0.75)]
        for px, py in top + bottom:
            d.ellipse([cx + s * px - r, cy + s * py - r, cx + s * px + r, cy + s * py + r], fill=accent)
    elif kind == "patches":
        # Grid split into rectangles, one with an area clue.
        g = s * 0.06
        rects = [(-1, -1, 0.15, -0.15), (0.15, -1, 1, 0.3), (-1, -0.15, 0.15, 1), (0.15, 0.3, 1, 1)]
        for x0, y0, x1, y1 in rects:
            d.rounded_rectangle([cx + s * x0 + g, cy + s * y0 + g, cx + s * x1 - g, cy + s * y1 - g], radius=s * 0.12, fill=fg)
        d.text((cx - s * 0.42, cy - s * 0.58), "4", fill=accent, font=font(int(s * 0.55)), anchor="mm")
    elif kind == "weave":
        # 3x3 letter tiles with a traced path.
        g = s * 0.62
        for j in range(3):
            for i in range(3):
                x, y = cx + (i - 1) * g, cy + (j - 1) * g
                d.rounded_rectangle([x - g * 0.42, y - g * 0.42, x + g * 0.42, y + g * 0.42], radius=g * 0.14, fill=fg)
        path = [(-1, -1), (0, -1), (0, 0), (1, 0), (1, 1)]
        w = max(4, int(s * 0.16))
        d.line([(cx + i * g, cy + j * g) for i, j in path], fill=accent, width=w, joint="curve")
        for i, j in path:
            d.ellipse([cx + i * g - w, cy + j * g - w, cx + i * g + w, cy + j * g + w], fill=accent)
    elif kind == "golf":
        # Flag on a green with a ball.
        d.ellipse([cx - s * 0.95, cy + s * 0.45, cx + s * 0.95, cy + s * 1.0], fill=fg)
        d.rectangle([cx - s * 0.05, cy - s * 1.0, cx + s * 0.07, cy + s * 0.72], fill=fg)
        d.polygon([(cx + s * 0.07, cy - s * 1.0), (cx + s * 0.8, cy - s * 0.72), (cx + s * 0.07, cy - s * 0.42)], fill=fg)
        d.ellipse([cx - s * 0.12, cy + s * 0.62, cx + s * 0.12, cy + s * 0.8], fill=accent)
        d.ellipse([cx - s * 0.75, cy + s * 0.1, cx - s * 0.4, cy + s * 0.45], fill=fg)
    else:
        d.ellipse([cx - s, cy - s, cx + s, cy + s], fill=fg)


def _check_badge(d, cx, cy, r, color):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255))
    w = max(3, int(r * 0.28))
    d.line([(cx - r * 0.45, cy + r * 0.02), (cx - r * 0.1, cy + r * 0.38), (cx + r * 0.5, cy - r * 0.35)], fill=color, width=w, joint="curve")


def draw_mark(size: int, app: dict, transparent: bool, safe: float = 1.0) -> Image.Image:
    """The icon artwork. `safe` < 1 shrinks content into the adaptive-icon safe zone."""
    base = hex_rgb(app["color"])
    if transparent:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        img = gradient((size, size), shade(base, 1.15), shade(base, 0.75)).convert("RGBA")
    d = ImageDraw.Draw(img)
    c = size / 2
    k = size * safe
    icon = app["icon"]
    label = icon.get("label", "")
    glyph_cy = c - k * 0.1 if label else c
    _glyph(d, icon.get("glyph", ""), c, glyph_cy, k * (0.24 if label else 0.3), (255, 255, 255), shade(base, 0.85))
    # No check-mark badge: Play (Metadata policy) reads it as a "verified/award" claim.
    if label:
        f = font(int(k * 0.13))
        tw = d.textlength(label, font=f)
        while tw > k * 0.8:
            f = font(f.size - 2)
            tw = d.textlength(label, font=f)
        d.text((c - tw / 2, c + k * 0.2), label, font=f, fill=(255, 255, 255))
    badge = icon.get("badge", "")
    if badge:
        r = k * 0.11
        bx, by = c + k * 0.27, c - k * 0.3
        d.ellipse([bx - r, by - r, bx + r, by + r], fill=(255, 255, 255))
        f = font(int(r * 0.95))
        tw = d.textlength(badge, font=f)
        d.text((bx - tw / 2, by - r * 0.62), badge, font=f, fill=shade(base, 0.8))
    return img


def play_icon(app: dict) -> Image.Image:
    return draw_mark(512, app, transparent=False).convert("RGB")


def legacy_icon(app: dict, px: int) -> Image.Image:
    art = draw_mark(px * 4, app, transparent=False)
    mask = Image.new("L", art.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, art.size[0] - 1, art.size[1] - 1], radius=art.size[0] * 0.22, fill=255)
    out = Image.new("RGBA", art.size, (0, 0, 0, 0))
    out.paste(art, (0, 0), mask)
    return out.resize((px, px), Image.LANCZOS)


def adaptive_foreground(app: dict, px: int) -> Image.Image:
    # 108dp canvas, 66dp safe zone -> content scale ~0.61.
    return draw_mark(px * 4, app, transparent=True, safe=0.61).resize((px, px), Image.LANCZOS)


def _wrap(d, text, f, max_w):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if d.textlength(t, font=f) <= max_w:
            cur = t
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def feature_graphic(app: dict, title: str, tagline: str) -> Image.Image:
    base = hex_rgb(app["color"])
    img = gradient((1024, 500), shade(base, 1.1), shade(base, 0.7)).convert("RGBA")
    d = ImageDraw.Draw(img)
    # Soft decorative circles.
    deco = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dd = ImageDraw.Draw(deco)
    dd.ellipse([700, -160, 1180, 320], fill=(255, 255, 255, 28))
    dd.ellipse([-120, 330, 260, 710], fill=(255, 255, 255, 22))
    img = Image.alpha_composite(img, deco.filter(ImageFilter.GaussianBlur(2)))
    d = ImageDraw.Draw(img)
    icon = legacy_icon(app, 280)
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([70, 122, 350, 402], radius=62, fill=(0, 0, 0, 90))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(14)))
    img.alpha_composite(icon, (60, 110))
    d = ImageDraw.Draw(img)
    x, max_w = 390, 600
    f = font(58)
    lines = _wrap(d, title, f, max_w)
    while len(lines) > 2 and f.size > 36:
        f = font(f.size - 4)
        lines = _wrap(d, title, f, max_w)
    ft = font(30, bold=False)
    tlines = _wrap(d, tagline, ft, max_w)[:3]
    h = len(lines) * f.size * 1.15 + 24 + len(tlines) * 40
    y = (500 - h) / 2
    for ln in lines:
        d.text((x, y), ln, font=f, fill=(255, 255, 255))
        y += f.size * 1.15
    y += 24
    for ln in tlines:
        d.text((x, y), ln, font=ft, fill=(255, 255, 255, 235))
        y += 40
    return img.convert("RGB")


GOLD = (255, 200, 61)


def _sparkle(d: ImageDraw.ImageDraw, cx: float, cy: float, r: float, fill) -> None:
    """Four-pointed star."""
    w = r * 0.28
    d.polygon([(cx, cy - r), (cx + w, cy - w), (cx + r, cy), (cx + w, cy + w),
               (cx, cy + r), (cx - w, cy + w), (cx - r, cy), (cx - w, cy - w)], fill=fill)


def product_icon(app: dict, kind: str = "unlock", size: int = 512) -> Image.Image:
    """512x512 in-app product icon: no text, no logo (Play's rules).

    kind "unlock" = open padlock (exam apps), "infinity" = unlimited (games).
    Drawn at 2x and scaled down for smooth curves.
    """
    return _product_icon(app, kind, size * 2).resize((size, size), Image.LANCZOS)


def _product_icon(app: dict, kind: str, size: int) -> Image.Image:
    import math

    base = hex_rgb(app["color"])
    img = gradient((size, size), shade(base, 1.1), shade(base, 0.55)).convert("RGBA")
    d = ImageDraw.Draw(img)
    s = size
    c = s / 2
    # Soft glow behind the symbol.
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([c - s * 0.34, c - s * 0.34, c + s * 0.34, c + s * 0.34], fill=(255, 255, 255, 60))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(s * 0.06)))
    d = ImageDraw.Draw(img)
    white = (255, 255, 255, 255)
    if kind == "infinity":
        pts = []
        for i in range(1441):
            t = math.radians(i / 4)
            den = 1 + math.sin(t) ** 2
            pts.append((c + s * 0.3 * math.cos(t) / den, c + s * 0.3 * math.sin(t) * math.cos(t) / den))
        for w, col in ((s * 0.075, white), (s * 0.03, GOLD + (255,))):
            r = w / 2
            for x, y in pts[::2]:
                d.ellipse([x - r, y - r, x + r, y + r], fill=col)
    else:
        # Open padlock: body + shackle lifted to the left.
        bw, bh = s * 0.38, s * 0.3
        bx0, by0 = c - bw / 2, c - s * 0.02
        lw = int(s * 0.06)
        sx0, sx1 = c - bw * 0.62, c + bw * 0.02
        d.arc([sx0, by0 - s * 0.3, sx1, by0 + s * 0.04], 180, 360, fill=white, width=lw)
        d.line([(sx0 + lw / 2, by0 - s * 0.13), (sx0 + lw / 2, by0 + s * 0.02)], fill=white, width=lw)
        d.rounded_rectangle([bx0, by0, bx0 + bw, by0 + bh], radius=s * 0.05, fill=white)
        kx, ky = c, by0 + bh * 0.45
        d.ellipse([kx - s * 0.035, ky - s * 0.035, kx + s * 0.035, ky + s * 0.035], fill=shade(base, 0.7))
        d.rectangle([kx - s * 0.013, ky, kx + s * 0.013, ky + s * 0.08], fill=shade(base, 0.7))
    for (x, y, r) in [(0.78, 0.22, 0.07), (0.2, 0.74, 0.05), (0.82, 0.7, 0.04)]:
        _sparkle(d, s * x, s * y, s * r, GOLD + (255,))
    return img
