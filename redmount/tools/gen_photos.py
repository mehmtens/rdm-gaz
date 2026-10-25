"""Kanıt Arşivi fotoğrafları: her bölümün boyalı arka planından 3 kare.

    python tools/gen_photos.py  -> assets/ui/photos/bNN_k.png (72x48, piksel art)
                                   assets/ui/photos/gun_N.png (Günün Dalgası seri kareleri)

Her bölümün gökyüzü atlasından (2x2 hücre) üç hücre kırpılır, kutu filtresiyle
küçültülür, 20 renge indirilir ve hafif sepya-sıcak tona çekilir: Gazelle'in
analog fotoğraf makinesiyle çektiği kanıt kareleri gibi okunur.
"""
import re
from pathlib import Path
from PIL import Image, ImageOps

INK = (12, 7, 18)  # ChatGPT temel tarzı kontur (koyu mor)
# Mühür mürekkebi rampası (gen_gpt_style_props.RED): gölge mora, ışık turuncuya.
STAMP = [(34, 10, 24), (56, 14, 28), (82, 20, 30), (110, 26, 32), (138, 34, 34),
         (166, 50, 38), (196, 82, 48), (226, 128, 70)]

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "ui" / "photos"
DEFAULT = "assets/backgrounds/book02_suleymaniye_streets_atlas.png"


def atlas_of(n):
    src = (ROOT / "scripts" / "systems" / ("bolum%02d.gd" % n)).read_text(encoding="utf-8")
    m = re.search(r'res://(assets/backgrounds/[^"]+\.png)', src)
    return m.group(1) if m else DEFAULT


def photo(img, cell, n, k):
    w, h = img.size
    cx, cy = (cell % 2) * w // 2, (cell // 2) * h // 2
    q = img.crop((cx + w // 10, cy + h // 12, cx + w // 2 - w // 10, cy + h // 2 - h // 6))
    q = q.convert("RGB").resize((72, 48), Image.BOX)
    q = q.quantize(colors=20, method=Image.Quantize.MEDIANCUT).convert("RGB")
    # sıcak, hafif soluk analog ton
    r, g, b = q.split()
    r = r.point(lambda v: min(255, int(v * 1.06 + 10)))
    b = b.point(lambda v: int(v * 0.86))
    q = Image.merge("RGB", (r, g, b))
    q = ImageOps.expand(q, border=1, fill=INK)
    q.save(OUT / ("b%02d_%d.png" % (n, k)))


# Günün Dalgası arenası (survival.gd sky_atlas) ve seri günleri (DailyWave.ARCHIVE_DAYS).
DAILY_ATLAS = "assets/backgrounds/level06_backstreets_atlas.png"
DAILY_DAYS = (3, 7, 14)
# 3x5 piksel rakamlar: köşedeki "N. GÜN" mühür damgası için.
DIGITS = {
    "0": ("111", "101", "101", "101", "111"), "1": ("010", "110", "010", "010", "111"),
    "2": ("111", "001", "111", "100", "111"), "3": ("111", "001", "011", "001", "111"),
    "4": ("101", "101", "111", "001", "001"), "5": ("111", "100", "111", "001", "111"),
    "6": ("111", "100", "111", "101", "111"), "7": ("111", "001", "010", "010", "010"),
    "8": ("111", "101", "111", "101", "111"), "9": ("111", "101", "111", "001", "111"),
}


def daily_photo(img, cell, day):
    """Seri karesi: aynı kırpma, akşamüstü mor-turuncu tonu ve sağ altta kırmızı gün damgası."""
    w, h = img.size
    cx, cy = (cell % 2) * w // 2, (cell // 2) * h // 2
    q = img.crop((cx + w // 8, cy + h // 10, cx + w // 2 - w // 12, cy + h // 2 - h // 7))
    q = q.convert("RGB").resize((72, 48), Image.BOX)
    q = q.quantize(colors=18, method=Image.Quantize.MEDIANCUT).convert("RGB")
    r, g, b = q.split()
    r = r.point(lambda v: min(255, int(v * 1.10 + 14)))
    g = g.point(lambda v: int(v * 0.90))
    b = b.point(lambda v: min(255, int(v * 0.95 + 8)))
    q = Image.merge("RGB", (r, g, b))
    px = q.load()
    text = str(day)
    sw = len(text) * 4 + 3
    x0, y0 = 72 - sw - 2, 48 - 9 - 2
    for y in range(9):
        for x in range(sw):
            edge = x in (0, sw - 1) or y in (0, 8)
            # Basılmış mühür: üstte mürekkep dolu, altta incelir; kenar koyu, yer yer
            # kâğıda tutmamış piksel (fotoğraf alttan görünür).
            v = 3 if edge else 6 - y // 3 - (1 if (x * 7 + y * 3) % 11 == 0 else 0)
            if not edge and (x * 5 + y * 9) % 23 == 0:
                continue
            px[x0 + x, y0 + y] = STAMP[max(0, min(7, v))]
    for i, ch in enumerate(text):
        for y, row in enumerate(DIGITS[ch]):
            for x, bit in enumerate(row):
                if bit == "1":
                    px[x0 + 2 + i * 4 + x, y0 + 2 + y] = (246, 226, 188)
    q = ImageOps.expand(q, border=1, fill=INK)
    q.save(OUT / ("gun_%d.png" % day))


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for n in range(1, 37):
        img = Image.open(ROOT / atlas_of(n))
        for k, cell in enumerate((0, 1, 2)):
            photo(img, cell, n, k)
    daily = Image.open(ROOT / DAILY_ATLAS)
    for cell, day in zip((0, 1, 3), DAILY_DAYS):
        daily_photo(daily, cell, day)
    print("ok")
