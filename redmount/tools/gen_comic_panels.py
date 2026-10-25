"""Kitap geçiş sinematikleri: kitap sonlarında 4 karelik piksel çizgi roman paneli.

    python tools/gen_comic_panels.py  -> assets/ui/comic/kK_P.png (100x60, piksel art)
                                         + kK_P_bg.png (yalnız sahne) + kK_P_on.png (ön katman 96x56)

Her kare: bölümün boyalı arka plan atlasından bir kesit (kutu filtresiyle 96x56'ya
küçültülür, 22 renge indirilir) + oyunun 48x48 piksel portreleri (yakın plan) veya
elle boyanmış küçük nesne (defter, not kâğıdı, simit, film rulosu). Çevrede 1 px mürekkep
+ 1 px krem çizgi: oyunda 4x NEAREST, çizgi roman karesi gibi okunur.
"""
from pathlib import Path

from PIL import Image

from pixelart import P

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "ui" / "comic"
PIX = ROOT / "assets" / "ui" / "pixel"
BG = ROOT / "assets" / "backgrounds"
W, H = 96, 56

# Elle boyanmış nesneler ('.' boş, harf -> palet).
LEDGER = [
    "..kkkkkkkkkkkkkkkkkk..",
    ".kbbbbbbbbbbbbbbbbbbk.",
    "kbBBBBBBBBBBBBBBBBBBbk",
    "kbBwwwwwwwwkwwwwwwwBbk",
    "kbBwiiiiwwwkwiiiiiwBbk",
    "kbBwwwwwwwwkwwwwwwwBbk",
    "kbBwiiiwiiwkwiiwiiwBbk",
    "kbBwwwwwwwwkwwwwwwwBbk",
    "kbBwiiiiiwwkwiiiiwwBbk",
    "kbBwwwwwwwwkwwwwwwwBbk",
    "kbBwiiwiiiwkwirrrwwBbk",
    "kbBwwwwwwwwkwrrrrwwBbk",
    "kbBwiiiiwwwkwwrrwwwBbk",
    "kbBwwwwwwwwkwwwwwwwBbk",
    "kbBBBBBBBBBBBBBBBBBBbk",
    ".kbbbbbbbbbbbbbbbbbbk.",
    "..kkkkkkkkkkkkkkkkkk..",
]
NOTE = [
    "kkkkkkkkkkkkkkkkk",
    "kwwwwwwwwwwwwwwck",
    "kwiiiiwiiiiiwwwck",
    "kwwwwwwwwwwwwwwck",
    "kwiiiwiiiiwiiwwck",
    "kwwwwwwwwwwwwwwck",
    "kwiiiiiwiiiwwwwck",
    "kwwwwwwwwwwwwwwck",
    "kwiiwwwwwwwwiiwck",
    "kwwwwwwwwwwwiiwck",
    "kwwwwwwwwwwwwwwck",
    "kcccccccccccccckk",
    "kkkkkkkkkkkkkkkk.",
]
SIMIT = [
    ".....kkkkkkkkk.....",
    "...kkgGsGGgGsGkk...",
    "..kgGGGsGGGsGGGgk..",
    ".kgGsGGGGGGGGGsGgk.",
    "kgGGGGgkkkkkgGGGsgk",
    "kgsGGgk.....kgGGGgk",
    "kgGGGgk.....kgGsGgk",
    "kgGGsGgkkkkkgGGGGgk",
    ".kgGGGGsGGGsGGGGgk.",
    "..kggGGGGGGGGGggk..",
    "...kkgggggggggkk...",
    ".....kkkkkkkkk.....",
]
SHADES = {
    "k": P["ink"], "b": P["red0"], "B": P["red1"], "w": P["cream"], "i": P["stone0"],
    "r": P["red2"], "c": P["sand2"],
    "g": P["brick1"], "G": P["wood3"], "s": P["white"],
}


def sprite(rows):
    img = Image.new("RGBA", (len(rows[0]), len(rows)), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != ".":
                img.putpixel((x, y), SHADES[ch])
    return img


def portrait(name, flip=False):
    img = Image.open(PIX / ("portre_%s.png" % name)).convert("RGBA")
    return img.transpose(Image.FLIP_LEFT_RIGHT) if flip else img


def scene(atlas, box, tint=None):
    """Atlas kesiti (kesirli kutu) -> 96x56 piksel art."""
    img = Image.open(BG / atlas).convert("RGB")
    w, h = img.size
    q = img.crop((int(box[0] * w), int(box[1] * h), int(box[2] * w), int(box[3] * h)))
    q = q.resize((W, H), Image.BOX)
    q = q.quantize(colors=22, method=Image.Quantize.MEDIANCUT).convert("RGB")
    if tint:
        q = Image.blend(q, Image.new("RGB", q.size, tint[0]), tint[1])
    return q.convert("RGBA")


def frame(art):
    out = Image.new("RGBA", (W + 4, H + 4), P["ink"])
    out.paste(Image.new("RGBA", (W + 2, H + 2), P["cream"]), (1, 1))
    out.paste(art, (2, 2))
    return out


def panel(atlas, box, layers, tint=None):
    """(birleşik kare, yalnız sahne karesi, ön katman 96x56) — oyun ön katmanı ayrıca
    oynatır (portre kare açılırken yerine oturur, sonra 1 piksel nefes alır)."""
    bg = scene(atlas, box, tint)
    on = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for img, x, y in layers:
        on.alpha_composite(img, (x, y))
    art = bg.copy()
    art.alpha_composite(on)
    return frame(art), frame(bg), on


def scaled(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)


# Portre yakın planı: alt kenara oturur (y = 56 - 48 = 8).
RM = lambda x=2: (portrait("redmount"), x, 8)
GZ = lambda x=46, flip=True: (portrait("gazelle", flip), x, 8)
KH = lambda x=50: (portrait("karahanli", True), x, 8)
TS = lambda x=50: (portrait("telsiz", True), x, 8)
FILM = lambda x, y: (Image.open(PIX / "film.png").convert("RGBA"), x, y)

# Kitap -> 4 kare. Metinler scripts/ui/book_comic.gd içinde.
BOOKS = {
    1: [
        ("level05_throne_hall.png", (0.18, 0.18, 0.82, 0.62), [RM(), KH()]),
        ("level13_last_atlas.png", (0.52, 0.52, 0.98, 0.98), [RM(4), GZ(48)]),
        ("level13_last_atlas.png", (0.02, 0.52, 0.48, 0.98),
                [(scaled(sprite(LEDGER), 2), 4, 12), FILM(54, 14)], ((20, 12, 16), 0.35)),
        ("book02_halij_opening_atlas.png", (0.0, 0.5, 0.5, 1.0), [RM(0), GZ(48)]),
    ],
    2: [
        ("book02_final_aqueduct_atlas.png", (0.0, 0.0, 0.5, 0.5), [RM()]),
        ("book02_final_aqueduct_atlas.png", (0.5, 0.5, 1.0, 1.0), [GZ(48)]),
        ("book02_final_tower_atlas.png", (0.5, 0.0, 1.0, 0.5),
                [(scaled(sprite(NOTE), 2), 30, 14)], ((20, 12, 16), 0.3)),
        ("book03_cagaloglu_press_atlas.png", (0.0, 0.0, 0.5, 0.5), []),
    ],
    3: [
        ("book03_final_broadcast_atlas.png", (0.0, 0.0, 0.5, 0.5), [GZ(2, False), TS(50)]),
        ("book03_final_shore_atlas.png", (0.0, 0.5, 0.5, 1.0), [TS(2), GZ(48)]),
        ("book03_final_dawn_atlas.png", (0.5, 0.5, 1.0, 1.0), [RM(0), GZ(48)]),
        ("book03_cagaloglu_streets_atlas.png", (0.5, 0.0, 1.0, 0.5),
                [(scaled(sprite(SIMIT), 2), 29, 24)]),
    ],
}


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for k, panels in BOOKS.items():
        for p, spec in enumerate(panels):
            full, bg, on = panel(*spec)
            full.save(OUT / ("k%d_%d.png" % (k, p)))
            bg.save(OUT / ("k%d_%d_bg.png" % (k, p)))
            on.save(OUT / ("k%d_%d_on.png" % (k, p)))
    print("ok")
