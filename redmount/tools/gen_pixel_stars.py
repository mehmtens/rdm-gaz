"""REDMOUNT bölüm sonu yıldızları: dolu (altın) ve boş (koyu yuva) piksel yıldız.

    python tools/gen_pixel_stars.py  -> assets/ui/pixel/yildiz_{dolu,bos}[_kucuk].png

Büyük yıldız sonuç kartında ~4x, küçük yıldız bölüm seçme kartında ~2x NEAREST
ölçeklenir. Dil: koyu kontur, sol üstte altın ışık, sağ altta koyu altın gölge;
boş yuva aynı siluetin oyulmuş mürdüm hâli (kazanılmamış yıldız okunur kalsın).
"""
from pathlib import Path

from pixelart import Canvas

OUT = Path(__file__).resolve().parent.parent / "assets" / "ui" / "pixel"

# '#' gövde. Işık/gölge bölgesi koordinattan hesaplanır.
BIG = [
    "......#......",
    ".....###.....",
    ".....###.....",
    "....#####....",
    "#############",
    ".###########.",
    "..#########..",
    "...#######...",
    "...#######...",
    "..####.####..",
    "..###...###..",
    ".##.......##.",
]
SMALL = [
    "...#...",
    "..###..",
    "#######",
    ".#####.",
    ".##.##.",
    "##...##",
]


def _star(rows, full):
    h = len(rows)
    w = len(rows[0])
    c = Canvas(w + 2, h + 2)
    cx = (w - 1) / 2.0
    cy = (h - 1) / 2.0
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != "#":
                continue
            side = (x - cx) + (y - cy) * 1.3
            if full:
                col = "gold3" if side < -2.5 else "gold2" if side < 1.5 else "gold1"
                # alt-sağ kenarı koyu altın: hacim
                if y + 1 < h and x + 1 < w and rows[y + 1][x] != "#" and side > 0:
                    col = "gold0"
            else:
                col = (104, 82, 100, 255) if side < 0 else (74, 56, 72, 255)
            c.put(x + 1, y + 1, col)
    if full:
        # tepe noktasında tek parıltı pikseli
        c.put(int(cx) + 1, 2, "white")
    c.outline("ink")
    return c


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for suffix, rows in (("", BIG), ("_kucuk", SMALL)):
        _star(rows, True).im.save(OUT / f"yildiz_dolu{suffix}.png")
        _star(rows, False).im.save(OUT / f"yildiz_bos{suffix}.png")
    print("ok")
