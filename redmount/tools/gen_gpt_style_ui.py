"""Arayüz çerçeveleri — ChatGPT temel tarzında (gen_gpt_style_props kuralları).

Eski çerçeveler (`gen_pixel_ui.py` panel/balon, `gen_pixel_menu.py` kart/sekme) düz
renkli dikdörtgenlerdi. Aynı boyut ve 9 parça payıyla yeniden çizilir:
- panel / panel_hud (24×24, pay 8): koyu mürdüm ahşap zemin (sakin damar — yazı okunsun),
  pirinç pah: sol üst kenar fener ışığında, sağ alt gölgede; köşede perçin + baklava süs.
- kart / kart_kilitli (24×24, pay 6): aynı ahşap, üstte kırmızı lake şerit; kilitlide
  şerit ve pirinç soğuk demire döner.
- sekme / sekme_secili (18×14, pay 3): seçili kırmızı lake + pirinç üst kenar.
- balon / balon_kuyruk (18×18, pay 4; 9×7): sıcak kâğıt, lif gürültüsü, sağ altta gölge.
- balon_ad (12×8): gri tonlu (Godot boyar) bez şerit, üst kenar ışık, alt kenar gölge.
Kontur koyu mor (12,7,18); 3x NEAREST kaydedilir (PixelUI.box ölçeksiz okur).
"""
import random
from pathlib import Path

from PIL import Image

from gen_gpt_style_props import BRASS, IRON, MOON, OUTLINE, RED, mix, pick

OUT = Path(__file__).resolve().parent.parent / "assets" / "ui" / "pixel"
SCALE = 3
PLUM = [(10, 6, 14), (18, 11, 22), (26, 16, 30), (34, 22, 37), (44, 29, 44), (56, 37, 52),
        (72, 48, 62), (96, 66, 74), (130, 92, 90)]
PAPER = [(96, 78, 74), (138, 118, 104), (176, 156, 132), (206, 188, 160), (226, 212, 184),
         (240, 230, 206), (250, 244, 226)]
WARM = (240, 200, 140)


def save(img, name):
    img.resize((img.width * SCALE, img.height * SCALE), Image.NEAREST).save(OUT / name)


def _wood(px, x0, y0, x1, y1, rnd, alpha, ramp=PLUM, base=0.34):
    ## Sakin ahşap: yatay damar şeritleri, düşük kontrast (yazı zemini).
    for y in range(y0, y1 + 1):
        row = base + (0.05 if y % 5 == 0 else 0.0) - (0.04 if y % 5 == 3 else 0.0)
        for x in range(x0, x1 + 1):
            c = pick(ramp, row, rnd, 0.35)
            if rnd.random() < 0.04:
                c = pick(ramp, row - 0.12, rnd, 0.1)  # budak / damar
            px[x, y] = c + (alpha,)


def _brass_bevel(px, w, h, rnd, metal=BRASS, alpha=255):
    ## Kontur + ahşap pah (üst/sol ışıkta, alt/sağ gölgede) + içte 3. halkada ışık-gölgeli
    ## ince altın çizgi (eski arayüzün Osmanlı çerçeve dili, şimdi rampayla).
    for x in range(w):
        for y in range(h):
            if x in (0, w - 1) or y in (0, h - 1):
                corner = x in (0, w - 1) and y in (0, h - 1)
                px[x, y] = (0, 0, 0, 0) if corner else OUTLINE[:3] + (alpha,)
    for i in range(1, w - 1):
        for j in range(1, h - 1):
            ring = min(i, j, w - 1 - i, h - 1 - j)
            lit = (j == ring and i < w - 1 - ring) or (i == ring and j < h - 1 - ring)
            if ring == 1:
                c = pick(PLUM, 0.72 if lit else 0.12, rnd, 0.35)
                if lit and (i < 6 or j < 6):
                    c = mix(c, WARM, 0.2)
            elif ring == 3:
                c = pick(metal, 0.78 if lit else 0.3, rnd, 0.3)
                if lit and (i < 7 or j < 7):
                    c = mix(c, WARM, 0.25)
            else:
                continue
            if i == w - 1 - ring and ring_mid(j, h):
                c = mix(c, MOON, 0.3)  # ay ışığı kenarı
            px[i, j] = c + (alpha,)


def ring_mid(j, h):
    return 2 < j < h - 3


def _corner(px, x, y, metal=BRASS):
    ## Perçin + küçük baklava süs.
    px[x, y] = mix(metal[-1], WARM, 0.3) + (255,)
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
        px[x + dx, y + dy] = metal[1] + (255,)


def frame(w, h, rnd, alpha=240, metal=BRASS, wood_base=0.34, corners=True):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    _wood(px, 1, 1, w - 2, h - 2, rnd, alpha, base=wood_base)
    _brass_bevel(px, w, h, rnd, metal)
    if corners:
        for x, y in ((5, 5), (w - 6, 5), (5, h - 6), (w - 6, h - 6)):
            _corner(px, x, y, metal)
    return img


def panels():
    save(frame(24, 24, random.Random(401)), "panel.png")
    save(frame(24, 24, random.Random(409), alpha=205, wood_base=0.28), "panel_hud.png")


def kartlar():
    for name, band, metal, seed in (("kart.png", RED, BRASS, 419),
                                    ("kart_kilitli.png", PLUM, IRON, 421)):
        rnd = random.Random(seed)
        img = frame(24, 24, rnd, alpha=245, metal=metal, corners=False)
        px = img.load()
        # Üst lake şerit (6 piksel pay içinde): üst satır ışıkta, alt satır gölgede.
        for x in range(3, 21):
            for y, v in ((3, 0.78), (4, 0.5)):
                c = pick(band, v if band is RED else v * 0.6, rnd, 0.35)
                if y == 3 and x < 8:
                    c = mix(c, WARM, 0.25)
                px[x, y] = c + (255,)
            px[x, 5] = OUTLINE
        save(img, name)


def sekmeler():
    for name, fill, edge, seed in (("sekme_secili.png", RED, BRASS, 431), ("sekme.png", PLUM, PLUM, 433)):
        rnd = random.Random(seed)
        img = Image.new("RGBA", (18, 14), (0, 0, 0, 0))
        px = img.load()
        for y in range(1, 13):
            for x in range(1, 17):
                v = 0.55 - y * 0.025 if fill is RED else 0.42 - y * 0.015
                c = pick(fill, v, rnd, 0.3)
                if x == 16:
                    c = mix(c, MOON, 0.25)
                px[x, y] = c + (255,)
        for x in range(1, 17):
            px[x, 0] = OUTLINE
            px[x, 13] = OUTLINE
            c = pick(edge, 0.85 if edge is BRASS else 0.62, rnd, 0.3)
            px[x, 1] = (mix(c, WARM, 0.25) if x < 8 else c) + (255,)
            px[x, 2] = pick(edge, 0.4, rnd, 0.2) + (255,) if edge is BRASS else px[x, 2]
        for y in range(1, 13):
            px[0, y] = OUTLINE
            px[17, y] = OUTLINE
        save(img, name)


def balon():
    rnd = random.Random(439)
    img = Image.new("RGBA", (18, 18), (0, 0, 0, 0))
    px = img.load()
    for y in range(1, 17):
        for x in range(1, 17):
            v = 0.86 - (0.12 if x >= 15 or y >= 15 else 0.0)  # sağ alt pah gölgesi
            if y == 1 or x == 1:
                v = 0.97
            c = pick(PAPER, v, rnd, 0.1)
            if rnd.random() < 0.025 and 2 < x < 15 and 2 < y < 15:
                c = pick(PAPER, v - 0.1, rnd, 0.05)  # kâğıt lifi
            px[x, y] = c + (255,)
    for i in range(1, 17):
        px[i, 0] = OUTLINE
        px[i, 17] = OUTLINE
        px[0, i] = OUTLINE
        px[17, i] = OUTLINE
    save(img, "balon.png")
    t = Image.new("RGBA", (9, 7), (0, 0, 0, 0))
    tp = t.load()
    for y in range(6):
        for x in range(y, 9 - y):
            tp[x, y] = pick(PAPER, 0.8 - y * 0.05, rnd, 0.2) + (255,)
    for y in range(6):
        tp[y - 1 if y > 0 else 0, y] = OUTLINE
        tp[min(8, 9 - y), y] = OUTLINE
    tp[4, 6] = OUTLINE
    save(t, "balon_kuyruk.png")
    # Konuşan adı şeridi: gri tonlu bez (renk Godot'da boyanır).
    n = Image.new("RGBA", (12, 8), (0, 0, 0, 0))
    npx = n.load()
    for y in range(8):
        for x in range(12):
            v = 255 if y == 0 else 130 if y == 7 else 200 + int((rnd.random() - 0.5) * 18)
            if y == 6:
                v = 168
            npx[x, y] = (v, v, v, 255)
    save(n, "balon_ad.png")


if __name__ == "__main__":
    panels()
    kartlar()
    sekmeler()
    balon()
    print("ok")
