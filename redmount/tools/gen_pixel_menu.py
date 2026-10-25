"""REDMOUNT menü piksel art parçaları: logo, kilit, coin, odak çerçevesi, kart.

    python tools/gen_pixel_menu.py  -> assets/ui/pixel/*.png

Logo oyunun piksel yazısından (assets/ui/redmount_pixel.ttf, 12 px ızgara)
türetilir: her yazı pikseli 2x2 sanat pikseli olur, içi kırmızı degrade, üstte
ışık çizgisi, koyu kontur ve altta derinlik gölgesi. Düşük çözünürlükte (1x)
kaydedilir; oyunda NEAREST ile tam sayı katlarla büyütülür. Çerçeveler 3x.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from pixelart import Canvas, P

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "ui" / "pixel"
FONT = ROOT / "assets" / "ui" / "redmount_pixel.ttf"
SCALE = 3


def save3(c, name):
    c.im.resize((c.w * SCALE, c.h * SCALE), Image.NEAREST).save(OUT / name)


def _glyph_mask(text, size=12):
    font = ImageFont.truetype(str(FONT), size)
    l, t, r, b = font.getbbox(text)
    im = Image.new("1", (r - l + 2, b - t + 2), 0)
    d = ImageDraw.Draw(im)
    d.fontmode = "1"
    d.text((1 - l, 1 - t), text, font=font, fill=1)
    return im


def logo(text="REDMOUNT", name="logo.png", top=(255, 170, 70), bottom=(150, 24, 28), k=2):
    m = _glyph_mask(text)
    w, h = m.size
    W, H = w * k + 8, h * k + 10
    c = Canvas(W, H)
    body = set()
    for y in range(h):
        for x in range(w):
            if m.getpixel((x, y)):
                for dy in range(k):
                    for dx in range(k):
                        body.add((x * k + dx + 3, y * k + dy + 3))
    ys = [p[1] for p in body]
    y0, y1 = min(ys), max(ys)
    # derinlik: 3 piksel aşağı koyu kırmızı-mor blok
    for (x, y) in body:
        for d in (1, 2, 3):
            c.put(x, y + d, (52, 10, 20, 255) if d < 3 else (26, 6, 14, 255))
    for (x, y) in body:
        t = (y - y0) / max(1, y1 - y0)
        col = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,)
        # bantlı degrade (piksel art: 4 ton)
        band = int(t * 4) / 4.0
        col = tuple(int(top[i] + (bottom[i] - top[i]) * band) for i in range(3)) + (255,)
        c.put(x, y, col)
    # üst ışık: her harfin üst kenarı
    for (x, y) in body:
        if (x, y - 1) not in body and y <= y0 + 1:
            c.put(x, y, (255, 236, 196, 255))
        elif (x - 1, y) not in body and (x, y - 1) in body:
            c.put(x, y, tuple(min(255, v + 30) for v in c.get(x, y)[:3]) + (255,))
    c.outline()
    c.outline((96, 20, 26, 255))
    c.im.save(OUT / name)


def kilit():
    c = Canvas(11, 13)
    for y in range(1, 6):
        c.put(2, y, "iron2"); c.put(8, y, "iron2")
    c.hline(3, 7, 0, "iron3")
    c.rect(0, 5, 10, 12, "gold1")
    c.hline(0, 10, 5, "gold3")
    c.hline(0, 10, 12, "gold0")
    c.rect(4, 7, 6, 8, "ink")
    c.rect(5, 9, 5, 10, "ink")
    c.outline()
    save3(c, "kilit.png")


def coin():
    c = Canvas(9, 9)
    c.disc(4, 4, 4.2, "gold1")
    c.disc(4, 4, 3.0, "gold2")
    c.vline(4, 2, 6, "gold0")
    c.put(3, 2, "gold3"); c.put(2, 3, "gold3")
    c.outline()
    save3(c, "coin.png")


def odak():
    """Klavye/gamepad odağı: saydam ortalı, köşeleri kalın altın çerçeve (9 parça)."""
    c = Canvas(16, 16)
    for i in range(16):
        for (x, y) in [(i, 0), (0, i), (i, 15), (15, i)]:
            c.put(x, y, "gold2")
        for (x, y) in [(i, 1), (1, i), (i, 14), (14, i)]:
            c.put(x, y, "gold0")
    for (x, y) in [(0, 0), (15, 0), (0, 15), (15, 15)]:
        c.rect(max(0, x - 0), max(0, y - 0), x, y, "gold3")
    for (x0, y0) in [(0, 0), (12, 0), (0, 12), (12, 12)]:
        c.rect(x0, y0, x0 + 3, y0 + 3, "gold3")
        c.rect(x0 + 1, y0 + 1, x0 + 2, y0 + 2, "gold1")
    save3(c, "odak.png")


def kart():
    """Bölüm kartı (9 parça): koyu ahşap, kırmızı üst şerit; kilitli sürümü gri."""
    for name, fill, band, hi in [("kart.png", (40, 28, 30, 245), (120, 32, 30, 255), (88, 60, 54, 255)),
                                 ("kart_kilitli.png", (28, 26, 32, 235), (52, 50, 60, 255), (58, 56, 66, 255))]:
        c = Canvas(24, 24)
        c.rect(1, 1, 22, 22, fill)
        c.rect(0, 1, 0, 22, "ink"); c.rect(23, 1, 23, 22, "ink")
        c.rect(1, 0, 22, 0, "ink"); c.rect(1, 23, 22, 23, "ink")
        c.rect(1, 1, 22, 4, band)
        c.hline(1, 22, 1, hi)
        c.hline(1, 22, 5, "ink")
        c.vline(1, 6, 22, hi)
        c.hline(1, 22, 22, (14, 10, 14, 255))
        save3(c, name)


def sekme():
    """Kitap sekmesi: seçili (altın) ve seçili değil (koyu)."""
    for name, fill, edge in [("sekme_secili.png", (120, 32, 30, 255), "gold2"),
                             ("sekme.png", (44, 32, 40, 255), "wood1")]:
        c = Canvas(18, 14)
        c.rect(1, 1, 16, 13, fill)
        c.hline(1, 16, 0, "ink"); c.vline(0, 1, 13, "ink"); c.vline(17, 1, 13, "ink")
        c.hline(2, 15, 1, edge)
        c.hline(1, 16, 13, "ink")
        save3(c, name)


def pip():
    """Yükseltme kademesi: dolu (altın baklava) / boş (koyu)."""
    for name, a, b in [("pip_dolu.png", "gold2", "gold3"), ("pip_bos.png", (44, 34, 44, 255), (70, 56, 70, 255))]:
        c = Canvas(7, 7)
        for y in range(7):
            half = 3 - abs(3 - y)
            c.hline(3 - half, 3 + half, y, a)
        c.put(3, 1, b); c.put(2, 2, b)
        c.outline()
        save3(c, name)


def ikon_tufek():
    """Tüfek ikonu (16x16, 3x = 48 px; pickup ikonlarıyla aynı boy)."""
    c = Canvas(16, 16)
    # namlu
    c.hline(1, 10, 6, "iron2"); c.hline(1, 10, 7, "iron1")
    c.put(0, 6, "iron3")
    # gövde + şarjör
    c.rect(8, 6, 11, 8, "iron1"); c.hline(8, 11, 6, "iron2")
    c.rect(9, 9, 10, 11, "iron0")
    # dipçik (ahşap)
    c.rect(11, 6, 14, 8, "wood2"); c.rect(13, 8, 15, 10, "wood1")
    c.hline(11, 14, 6, "wood3")
    # tetik
    c.put(11, 9, "iron2")
    c.outline()
    c.im.resize((48, 48), Image.NEAREST).save(OUT / "ikon_tufek.png")


def ikon_yumruk():
    """Yumruk ikonu (16x16): sıkılı yumruk, deri bileklik."""
    skin, shade, hi = (222, 168, 128, 255), (172, 116, 86, 255), (246, 206, 168, 255)
    c = Canvas(16, 16)
    c.rect(3, 4, 12, 10, skin)
    for x in (3, 6, 9):
        c.vline(x + 2, 4, 6, shade)
    c.hline(3, 12, 4, hi)
    c.rect(1, 6, 3, 9, skin); c.put(1, 6, hi)
    c.hline(3, 12, 10, shade)
    c.rect(5, 11, 11, 13, "wood1"); c.hline(5, 11, 11, "wood2")
    c.outline()
    c.im.resize((48, 48), Image.NEAREST).save(OUT / "ikon_yumruk.png")


def portre_telsiz():
    """Kimliği gizli konuşmacı / telsiz portresi (16x16, 3x): el telsizi, anten, ışık."""
    c = Canvas(16, 16)
    c.rect(4, 4, 11, 15, "iron1")
    c.rect(5, 5, 10, 8, (40, 70, 60, 255))
    c.hline(5, 10, 5, (90, 160, 130, 255))
    for y in (10, 12, 14):
        c.hline(5, 10, y, "iron0")
    c.vline(10, 0, 3, "iron2"); c.put(10, 0, "red3")
    c.put(6, 3, "glow2")
    c.outline()
    c.im.resize((48, 48), Image.NEAREST).save(OUT / "portre_telsiz.png")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    logo()
    logo("İSTANBUL'UN SESİ", "logo_alt.png", top=(255, 222, 140), bottom=(190, 120, 40), k=1)
    # kart / sekme artık tools/gen_gpt_style_ui.py'de (ChatGPT tarzı).
    kilit(); coin(); odak(); pip(); ikon_tufek(); ikon_yumruk(); portre_telsiz()
    print("ok")
