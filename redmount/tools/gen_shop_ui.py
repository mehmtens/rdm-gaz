"""Mahalle büfesi (LevelShop) arayüz parçaları — ChatGPT temel tarzında.

Eskiden draw_rect ile düz sarı/kırmızı dikdörtgendiler:
- etiket_fiyat / etiket_fiyat_yok (16×14 sanat pikseli, 9 parça, 3x kaydedilir):
  ürün kartındaki perçinli pirinç fiyat levhası; karşılanamıyorsa pas kırmızısı emaye.
- rozet_dokun (14×12, 9 parça, 2x kaydedilir — dünyada çizilir) + rozet_kuyruk (6×4):
  tabelanın üstünde zıplayan "E / DOKUN" pirinç rozeti ve aşağı bakan ucu.
Kurallar gen_gpt_style_props ile aynı: rampa, koyu mor kontur, sol üstten sıcak ışık,
sağ kenarda ay ışığı, altta AO, düz renk alan yok.
"""
import random
from PIL import Image

from gen_gpt_style_props import BRASS, MOON, OUTLINE, RED, RUST, mix, pick

OUT = "assets/ui/pixel/"


def plate(w, h, ramp, rnd, rivets=True):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            corner = (x in (0, w - 1)) and (y in (0, h - 1))
            if corner:
                continue  # köşeler yuvarlatılmış
            if x in (0, w - 1) or y in (0, h - 1):
                px[x, y] = OUTLINE
                continue
            t = (y - 1) / (h - 3)
            # Fırçalanmış levha: satır satır ışık (yazı okunsun diye sakin yüzey).
            lv = 0.74 - t * 0.26 - (x - 1) / (w - 3) * 0.08  # sol üstten sıcak ışık
            if y == 1:
                lv = 0.92  # ışığı yakalayan üst dudak
            elif y == h - 2:
                lv = 0.06  # alt pah gölgesi (AO)
            elif x == 1:
                lv += 0.2
            c = pick(ramp, lv, rnd, 0.25)
            if rnd.random() < 0.25 and y == h - 3:
                c = pick(RUST, 0.4, rnd, 0.3)  # pas lekesi / boya kalkması
            if x == w - 2 and 1 < y < h - 2:
                c = mix(c, MOON, 0.35)  # ay ışığı kenar parlaması
            px[x, y] = c + (255,)
    if rivets:
        for x, y in ((2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)):
            px[x, y] = ramp[-1] + (255,)
            px[x + (1 if x < w / 2 else -1), y + 1] = ramp[0] + (255,)
    return img


def make_kuyruk(rnd):
    w, h = 6, 4
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        a, b = y, w - 1 - y
        for x in range(a, b + 1):
            if x in (a, b) or y == h - 1:
                px[x, y] = OUTLINE
            else:
                px[x, y] = pick(BRASS, 0.3 - y * 0.08, rnd, 0.3) + (255,)
    return img


def up(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)


def main():
    up(plate(16, 14, BRASS, random.Random(263)), 3).save(OUT + "etiket_fiyat.png")
    up(plate(16, 14, RED, random.Random(269)), 3).save(OUT + "etiket_fiyat_yok.png")
    up(plate(14, 12, BRASS, random.Random(271), rivets=False), 2).save(OUT + "rozet_dokun.png")
    up(make_kuyruk(random.Random(277)), 2).save(OUT + "rozet_kuyruk.png")


if __name__ == "__main__":
    main()
