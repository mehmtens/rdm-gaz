"""REDMOUNT dokunmatik düğmeleri: piksel art daire düğme + ikonlar.

    python tools/gen_pixel_touch.py  -> assets/ui/pixel/touch_*.png

Düğmeler 1x sanat pikseli olarak kaydedilir; oyunda NEAREST filtreyle ~4x
ölçeklenir (TouchControls). Dil: yarı saydam koyu mürdüm gövde, koyu kontur,
sol üstte altın ışık, sağ altta koyu altın gölge — menü düğmeleriyle aynı aile.
Basılı hâl: sıcak ateş dolgusu, parlak altın halka, ışık ters (içe gömülme).

ChatGPT temel tarzı (gen_gpt_style_props, 26 Ekim): gövde ve halka 8 tonluk rampalarla
açıya göre gölgelenir (gölge mora, ışık turuncu-altına), sağ altta soğuk ay ışığı,
kontur koyu mor; ikonlar krem rampa.
"""
import math
import random
from pathlib import Path

from pixelart import Canvas
from gen_gpt_style_props import BRASS, MOON, ORANGE, OUTLINE, mix, pick

PLUM = [(10, 6, 14), (18, 11, 22), (26, 16, 30), (34, 22, 37), (44, 29, 44), (56, 37, 52),
        (72, 48, 62), (96, 66, 74)]
CREAM = [(150, 132, 112), (186, 170, 144), (214, 200, 172), (236, 226, 202), (250, 244, 226)]
WARM = (240, 200, 140)

OUT = Path(__file__).resolve().parent.parent / "assets" / "ui" / "pixel"

# (ad, sanat çapı) — oyundaki yarıçap * 2 / 4 ile eşleşir.
SIZES = {"buyuk": 34, "kucuk": 23, "mini": 18, "genis": 40}


def _disc_button(d, pressed):
    c = Canvas(d, d)
    rnd = random.Random(d * 7 + int(pressed))
    r = d / 2.0 - 1.0
    cx = cy = (d - 1) / 2.0
    for y in range(d):
        for x in range(d):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist > r:
                continue
            # -1 sağ alt (gölge) … 1 sol üst (ışık); basılıyken ters (içe gömülme).
            lit = -(dx + dy) / (r * 1.414)
            if pressed:
                lit = -lit
            if dist > r - 1.6:
                v = 0.5 + lit * 0.42
                col = pick(BRASS, v, rnd, 0.35)
                if lit > 0.5:
                    col = mix(col, WARM, 0.3)
                elif lit < -0.5 and dx > 0:
                    col = mix(col, MOON, 0.3)
                c.put(x, y, col + (255,))
            elif dist > r - 2.6 and not pressed:
                c.put(x, y, PLUM[0] + (160,))  # iç gölge şeridi: kabarıklık
            else:
                k = dist / max(r, 1.0)
                if pressed:
                    col = pick(ORANGE, 0.72 - k * 0.3 + lit * 0.12, rnd, 0.3)
                    c.put(x, y, col + (220,))
                else:
                    col = pick(PLUM, 0.42 + lit * 0.18 - k * 0.1, rnd, 0.4)
                    c.put(x, y, col + (130,))
    c.outline(OUTLINE)
    return c


def _icon(rows):
    ## Krem rampa: üstte fener ışığı, altta gölge.
    h = len(rows)
    w = len(rows[0])
    c = Canvas(w + 2, h + 2)
    rnd = random.Random(w * 31 + h)
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == "#":
                col = pick(CREAM, 0.95 - y / max(1, h - 1) * 0.6, rnd, 0.2)
                c.put(x + 1, y + 1, col + (255,))
            elif ch == "+":
                c.put(x + 1, y + 1, BRASS[3] + (255,))
    c.outline(OUTLINE)
    return c


ICONS = {
    "sol": [
        "......#",
        ".....##",
        "....###",
        "...####",
        "..#####",
        ".######",
        "#######",
        ".######",
        "..#####",
        "...####",
        "....###",
        ".....##",
        "......#",
    ],
    "asagi": [
        "###########",
        ".#########.",
        "..#######..",
        "...#####...",
        "....###....",
        ".....#.....",
    ],
    "durdur": [
        "##.##",
        "##.##",
        "##.##",
        "##.##",
        "##.##",
        "##.##",
    ],
}


def _mirror(c):
    m = Canvas(c.w, c.h)
    for y in range(c.h):
        for x in range(c.w):
            m.put(c.w - 1 - x, y, c.get(x, y))
    return m


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for name, d in SIZES.items():
        _disc_button(d, False).im.save(OUT / f"touch_{name}.png")
        _disc_button(d, True).im.save(OUT / f"touch_{name}_basili.png")
    icons = {k: _icon(v) for k, v in ICONS.items()}
    icons["sag"] = _mirror(icons["sol"])
    for k, c in icons.items():
        c.im.save(OUT / f"touch_ikon_{k}.png")
    print("ok")
