"""REDMOUNT dokunmatik düğmeleri: piksel art daire düğme + ikonlar.

    python tools/gen_pixel_touch.py  -> assets/ui/pixel/touch_*.png

Düğmeler 1x sanat pikseli olarak kaydedilir; oyunda NEAREST filtreyle ~4x
ölçeklenir (TouchControls). Dil: yarı saydam koyu mürdüm gövde, koyu kontur,
sol üstte altın ışık, sağ altta koyu altın gölge — menü düğmeleriyle aynı aile.
Basılı hâl: sıcak ateş dolgusu, parlak altın halka, ışık ters (içe gömülme).
"""
from pathlib import Path

from pixelart import Canvas

OUT = Path(__file__).resolve().parent.parent / "assets" / "ui" / "pixel"

# (ad, sanat çapı) — oyundaki yarıçap * 2 / 4 ile eşleşir.
SIZES = {"buyuk": 34, "kucuk": 23, "mini": 18, "genis": 40}


def _disc_button(d, pressed):
    c = Canvas(d, d)
    r = d / 2.0 - 1.0
    cx = cy = (d - 1) / 2.0
    fill = (196, 92, 30, 215) if pressed else (30, 22, 34, 120)
    inner = (230, 130, 40, 225) if pressed else (44, 32, 48, 135)
    c.disc(cx, cy, r, fill)
    c.disc(cx, cy, r - 3, inner)
    # Halka: sol üst ışık, sağ alt gölge (basılıyken ters).
    for y in range(d):
        for x in range(d):
            dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if r - 1.6 < dist <= r:
                lit = (x - cx) + (y - cy) < 0
                if pressed:
                    col = "gold3" if not lit else "gold2"
                else:
                    col = "gold2" if lit else "gold0"
                c.put(x, y, col)
            elif r - 2.6 < dist <= r - 1.6 and not pressed:
                # İnce iç gölge şeridi: düğmeye kabarıklık verir.
                c.put(x, y, (18, 12, 20, 150))
    c.outline("ink")
    return c


def _icon(rows, color="white"):
    h = len(rows)
    w = len(rows[0])
    c = Canvas(w + 2, h + 2)
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == "#":
                c.put(x + 1, y + 1, color)
            elif ch == "+":
                c.put(x + 1, y + 1, "gold2")
    c.outline("ink")
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
