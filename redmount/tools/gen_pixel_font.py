"""REDMOUNT piksel yazı tipi (TTF) üreticisi.

Büyük harf, rakam ve işaretler oyundaki PixelText (scripts/ui/pixel_text.gd) 5x7
gliflerinden; küçük harfler ve Türkçe karakterler aynı ızgarada elle çizildi.
Hücre 12 satır: 0-1 şapka/nokta, 2-8 gövde, 9-10 alt uzantı/çengel, 11 boşluk.
1 piksel = 100 birim (em 1200). Godot'da antialias kapalı, fixed_size=12, tam
sayı ölçek: hep keskin.

    python tools/gen_pixel_font.py   -> assets/ui/redmount_pixel.ttf
"""
import re
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "ui" / "redmount_pixel.ttf"
UNIT = 100
ROWS = 12
BASE_ROW = 9  # 9. satırın üst kenarı taban çizgisi

B = "....."


def parse_pixeltext():
    """pixel_text.gd'deki _BODY ve _MARKED sözlüklerini okur."""
    src = (ROOT / "scripts" / "ui" / "pixel_text.gd").read_text(encoding="utf-8")
    body = {}
    for m in re.finditer(r'^\t"(.)": \[((?:"[.#]{5}",? ?){7})\]', src, re.M):
        body[m.group(1)] = re.findall(r'"([.#]{5})"', m.group(2))
    marked = {}
    for m in re.finditer(r'^\t"(.)": \["(.)", \["([.#]{5})", "([.#]{5})"\], "([.#]{5})"\]', src, re.M):
        marked[m.group(1)] = (m.group(2), [m.group(3), m.group(4)], m.group(5))
    return body, marked


# Küçük harfler: 7 gövde satırı (2-8) + 2 alt uzantı satırı (9-10).
LOWER = {
    "a": [B, B, ".###.", "....#", ".####", "#...#", ".####"],
    "b": ["#....", "#....", "####.", "#...#", "#...#", "#...#", "####."],
    "c": [B, B, ".###.", "#....", "#....", "#....", ".###."],
    "d": ["....#", "....#", ".####", "#...#", "#...#", "#...#", ".####"],
    "e": [B, B, ".###.", "#...#", "#####", "#....", ".###."],
    "f": ["..##.", ".#...", "####.", ".#...", ".#...", ".#...", ".#..."],
    "g": [B, B, ".####", "#...#", "#...#", "#...#", ".####", "....#", ".###."],
    "h": ["#....", "#....", "####.", "#...#", "#...#", "#...#", "#...#"],
    "i": ["..#..", B, ".##..", "..#..", "..#..", "..#..", ".###."],
    "ı": [B, B, ".##..", "..#..", "..#..", "..#..", ".###."],
    "j": ["...#.", B, "..##.", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."],
    "k": ["#....", "#....", "#..#.", "#.#..", "##...", "#.#..", "#..#."],
    "l": [".##..", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."],
    "m": [B, B, "##.#.", "#.#.#", "#.#.#", "#.#.#", "#...#"],
    "n": [B, B, "####.", "#...#", "#...#", "#...#", "#...#"],
    "o": [B, B, ".###.", "#...#", "#...#", "#...#", ".###."],
    "p": [B, B, "####.", "#...#", "#...#", "#...#", "####.", "#....", "#...."],
    "q": [B, B, ".####", "#...#", "#...#", "#...#", ".####", "....#", "....#"],
    "r": [B, B, "#.##.", "##..#", "#....", "#....", "#...."],
    "s": [B, B, ".####", "#....", ".###.", "....#", "####."],
    "t": [".#...", ".#...", "####.", ".#...", ".#...", ".#..#", "..##."],
    "u": [B, B, "#...#", "#...#", "#...#", "#...#", ".####"],
    "v": [B, B, "#...#", "#...#", "#...#", ".#.#.", "..#.."],
    "w": [B, B, "#...#", "#...#", "#.#.#", "#.#.#", ".#.#."],
    "x": [B, B, "#...#", ".#.#.", "..#..", ".#.#.", "#...#"],
    "y": [B, B, "#...#", "#...#", "#...#", "#...#", ".####", "....#", ".###."],
    "z": [B, B, "#####", "...#.", "..#..", ".#...", "#####"],
}
LOWER_MARKED = {
    # harf: (temel, gövdenin ilk iki satırına konacak işaret, alt satır)
    "ç": ("c", None, "..##."),
    "ş": ("s", None, "..##."),
    "ğ": ("g", ["#...#", ".###."], None),
    "ö": ("o", [".#.#.", B], None),
    "ü": ("u", [".#.#.", B], None),
    "â": ("a", ["..#..", ".#.#."], None),
}
EXTRA = {
    "(": ["...#.", "..#..", ".#...", ".#...", ".#...", "..#..", "...#."],
    ")": [".#...", "..#..", "...#.", "...#.", "...#.", "..#..", ".#..."],
    "[": [".###.", ".#...", ".#...", ".#...", ".#...", ".#...", ".###."],
    "]": [".###.", "...#.", "...#.", "...#.", "...#.", "...#.", ".###."],
    "%": ["##..#", "##.#.", "...#.", "..#..", ".#...", ".#.##", "#..##"],
    '"': [".#.#.", ".#.#.", B, B, B, B, B],
    ";": [B, ".##..", ".##..", B, ".##..", ".##..", ".#..."],
    "=": [B, B, "#####", B, "#####", B, B],
    "<": ["...#.", "..#..", ".#...", "#....", ".#...", "..#..", "...#."],
    ">": [".#...", "..#..", "...#.", "....#", "...#.", "..#..", ".#..."],
    "*": [B, "#.#.#", ".###.", "#####", ".###.", "#.#.#", B],
    "_": [B, B, B, B, B, B, "#####"],
    "#": [".#.#.", ".#.#.", "#####", ".#.#.", "#####", ".#.#.", ".#.#."],
    "&": [".##..", "#..#.", ".##..", ".#...", "#.#.#", "#..#.", ".##.#"],
    "—": [B, B, B, "#####", B, B, B],
    "–": [B, B, B, ".###.", B, B, B],
    "▸": [".#...", ".##..", ".###.", ".####", ".###.", ".##..", ".#..."],
    "…": [B, B, B, B, B, B, "#.#.#"],
    "×": [B, "#...#", ".#.#.", "..#..", ".#.#.", "#...#", B],
    "|": ["..#..", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
}


def rows_for(ch, body, marked):
    rows = [B] * ROWS
    if ch in LOWER:
        g = LOWER[ch]
        for i, r in enumerate(g):
            rows[2 + i] = r
        return rows
    if ch in LOWER_MARKED:
        base, top, bottom = LOWER_MARKED[ch]
        rows = rows_for(base, body, marked)
        if top:
            rows[2], rows[3] = top
        if bottom:
            rows[9] = bottom
        return rows
    if ch in marked:
        base, top, bottom = marked[ch]
        rows[0], rows[1] = top
        for i, r in enumerate(body[base]):
            rows[2 + i] = r
        rows[9] = bottom
        return rows
    src = body.get(ch) or EXTRA.get(ch)
    if src is None:
        return None
    for i, r in enumerate(src):
        rows[2 + i] = r
    return rows


def glyph_from_rows(rows):
    pen = TTGlyphPen(None)
    any_px = False
    for r, line in enumerate(rows):
        x = 0
        while x < len(line):
            if line[x] != "#":
                x += 1
                continue
            start = x
            while x < len(line) and line[x] == "#":
                x += 1
            y0 = (BASE_ROW - 1 - r) * UNIT
            y1 = y0 + UNIT
            x0, x1 = start * UNIT, x * UNIT
            pen.moveTo((x0, y0))
            pen.lineTo((x0, y1))
            pen.lineTo((x1, y1))
            pen.lineTo((x1, y0))
            pen.closePath()
            any_px = True
    if not any_px:
        pen.moveTo((0, 0))
        pen.lineTo((0, 0))
        pen.closePath()
    return pen.glyph()


def main():
    body, marked = parse_pixeltext()
    chars = sorted(set(body) | set(marked) | set(LOWER) | set(LOWER_MARKED) | set(EXTRA))
    order = [".notdef", "space"]
    cmap = {32: "space", 160: "space"}
    glyphs = {".notdef": glyph_from_rows([B] * ROWS), "space": glyph_from_rows([B] * ROWS)}
    metrics = {".notdef": (600, 0), "space": (400, 0)}
    for ch in chars:
        rows = rows_for(ch, body, marked)
        if rows is None:
            continue
        name = "uni%04X" % ord(ch)
        order.append(name)
        glyphs[name] = glyph_from_rows(rows)
        metrics[name] = (600, 0)
        cmap[ord(ch)] = name
    fb = FontBuilder(UNIT * ROWS, isTTF=True)
    fb.setupGlyphOrder(order)
    fb.setupCharacterMap(cmap)
    fb.setupGlyf(glyphs)
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=BASE_ROW * UNIT, descent=-(ROWS - BASE_ROW) * UNIT)
    fb.setupNameTable({"familyName": "Redmount Pixel", "styleName": "Regular"})
    fb.setupOS2(sTypoAscender=BASE_ROW * UNIT, sTypoDescender=-(ROWS - BASE_ROW) * UNIT,
                usWinAscent=BASE_ROW * UNIT, usWinDescent=(ROWS - BASE_ROW) * UNIT)
    fb.setupPost()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fb.save(str(OUT))
    print("ok", OUT.name, len(cmap), "karakter")


if __name__ == "__main__":
    main()
