"""Tüfekli muhafız şeritlerini Seçkin Muhafız'ın tüfek karelerinden üretir.

Eski tüfekli çizimi chibi orantılıydı (büyük kafa) ve diğer karakterlere uymuyordu.
Seçkin muhafızın kalkansız tüfek kareleri alınır, altın detaylar haki-zeytine boyanır
(iki düşman ayırt edilsin). Kare sayıları resources/anim/rifle_guard_frames.tres ile aynı.

    python tools/gen_rifle_guard.py
"""
import colorsys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "anim" / "elite_guard"
DST = ROOT / "assets" / "anim" / "rifle_guard"
CELL = (200, 240)


def frames(name):
    im = Image.open(SRC / (name + ".png")).convert("RGBA")
    return [im.crop((i * 200, 0, i * 200 + 200, 240)) for i in range(im.width // 200)]


def recolor(img):
    """Altın/turuncu (ton 20-55°) -> haki zeytin; namlu alevi (çok parlak) korunur."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if 20 / 360 <= h <= 55 / 360 and s > 0.35 and v < 0.93:
                nh, ns, nv = 72 / 360, s * 0.45, v * 0.82
                rr, gg, bb = colorsys.hsv_to_rgb(nh, ns, nv)
                px[x, y] = (int(rr * 255), int(gg * 255), int(bb * 255), a)
    return out


def strip(cells):
    out = Image.new("RGBA", (CELL[0] * len(cells), CELL[1]), (0, 0, 0, 0))
    for i, c in enumerate(cells):
        out.alpha_composite(recolor(c), (i * CELL[0], 0))
    return out


def main():
    atk = frames("attack")
    walk = frames("walk")
    dead = frames("dead")
    plan = {
        "idle": [atk[0], atk[0], atk[1], atk[1], atk[0]],
        "walk": walk[:8],
        "aim": [atk[0], atk[1], atk[1], atk[1]],
        "shoot": [atk[2], atk[3], atk[4], atk[5], atk[6]],
        "reload": [atk[6], atk[6], atk[0], atk[0], atk[1], atk[1], atk[1], atk[0], atk[0]],
        "hurt": [atk[0]] * 8,
        "dead": [dead[0], dead[1]],
    }
    for name, cells in plan.items():
        strip(cells).save(DST / (name + ".png"))
        print(name, len(cells))


if __name__ == "__main__":
    main()
