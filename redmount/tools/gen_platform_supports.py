"""Platform destekleri ve kenar şeritleri — ChatGPT temel tarzında (gen_gpt_style_props kuralları).

OneWayPlatform / MovingPlatform eskiden direk, kuşak, makara ve basılacak kenarı
draw_line/draw_circle ile çiziyordu; bunlar artık bu dokular:
- dikme_celik (5×16, dikey döşenir): perçinli çelik iskele borusu, pas akıntısı.
- dikme_ahsap (6×16, dikey döşenir): damarlı ahşap direk, çivi.
- kusak_celik / kusak_ahsap (16×4, yatay döşenir): direkler arası yatay kuşak.
- kenar_tas / kenar_celik (16×3, yatay döşenir): kale ve koridor platformunun ışık
  yakalayan üst dudağı.
- kenar_isik (16×4, yatay; gri, oyunda bölümün edge_light rengiyle boyanır): gece
  sahnesinde ince platformun kenar ışığı + altındaki koyu dudak.
- makara (9×9): ray platformunun tekerleği.
Oyunda 2x NEAREST ölçeklenir.
"""
import random
from PIL import Image

from gen_gpt_style_props import (IRON, MOON, OUTLINE, RUST, STEEL, WOOD, light, mix,
                                 outline, outline_sides, pick)

OUT = "assets/environment/pixel/"
STONE = [(20, 14, 26), (38, 28, 40), (58, 44, 54), (80, 62, 68), (104, 84, 84),
         (132, 108, 98), (166, 136, 112), (204, 170, 128)]


def _post(w, h, ramp, rnd, grain):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(1, w - 1):
            u = (x - (w - 1) / 2.0) / ((w - 2) / 2.0)
            lv = light(u) * 0.8 + 0.06
            if grain and rnd.random() < 0.14:
                lv -= 0.2  # damar
            c = pick(ramp, lv, rnd, 0.35)
            if u > 0.6:
                c = mix(c, MOON, 0.3)  # sağ kenarda ay ışığı
            px[x, y] = c + (255,)
        px[0, y] = OUTLINE
        px[w - 1, y] = OUTLINE
    return img


def make_dikme_celik(rnd):
    img = _post(5, 16, STEEL, rnd, False)
    px = img.load()
    for y in (2, 10):
        px[2, y] = STEEL[8] + (255,)  # perçin başı
        px[2, y + 1] = STEEL[1] + (255,)  # perçin gölgesi
    # Perçinin altından inen pas akıntısı.
    for y in range(12, 16):
        if rnd.random() < 0.8:
            px[2, y] = pick(RUST, 0.5 - (y - 12) * 0.1, rnd, 0.2) + (255,)
    for y in (6, 7):
        px[1, y] = pick(RUST, 0.3, rnd, 0.2) + (255,)
    return img


def make_dikme_ahsap(rnd):
    img = _post(6, 16, WOOD, rnd, True)
    px = img.load()
    for y in range(16):
        px[3, y] = pick(WOOD, 0.12, rnd, 0.1) + (255,) if y % 5 == 2 else px[3, y]  # ek oluğu
    px[2, 4] = IRON[6] + (255,)  # çivi
    px[2, 12] = IRON[5] + (255,)
    return img


def _beam(ramp, rnd, bolts):
    w, h = 16, 4
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for x in range(w):
        px[x, 0] = OUTLINE
        px[x, 1] = pick(ramp, 0.55, rnd, 0.6) + (255,)  # fener ışığı üst yüzde
        px[x, 2] = pick(ramp, 0.2, rnd, 0.5) + (255,)
        px[x, 3] = OUTLINE
    for x in bolts:
        px[x, 2] = ramp[-1] + (255,)
    return img


def make_kusak_celik(rnd):
    img = _beam(STEEL, rnd, (3, 11))
    px = img.load()
    px[12, 2] = pick(RUST, 0.45, rnd, 0.2) + (255,)
    return img


def make_kusak_ahsap(rnd):
    img = _beam(WOOD, rnd, (5,))
    px = img.load()
    px[13, 2] = WOOD[0] + (255,)  # tahta eki
    px[13, 1] = WOOD[2] + (255,)
    return img


def _lip(ramp, rnd):
    w, h = 16, 3
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for x in range(w):
        top = pick(ramp, 0.86, rnd, 0.35)
        if rnd.random() < 0.18:
            top = pick(ramp, 0.6, rnd, 0.2)  # yıpranmış, ışığı kıran çentik
        px[x, 0] = mix(top, (240, 200, 140), 0.2) + (255,)
        px[x, 1] = pick(ramp, 0.48, rnd, 0.35) + (255,)
        px[x, 2] = OUTLINE
    return img


def make_kenar_isik(rnd):
    """Beyaz-gri; oyunda edge_light ile çarpılır. Alt iki satır yarı saydam koyu dudak."""
    w, h = 16, 4
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for x in range(w):
        v = 255 if rnd.random() > 0.2 else 214
        px[x, 0] = (v, v, v, 255)
        px[x, 1] = (150, 146, 156, 255) if (x + 1) % 5 else (120, 116, 128, 255)
        px[x, 2] = OUTLINE[:3] + (110,)
        px[x, 3] = OUTLINE[:3] + (48,)
    return img


def make_makara(rnd):
    w = h = 9
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    c = 4.0
    for y in range(h):
        for x in range(w):
            d = ((x - c) ** 2 + (y - c) ** 2) ** 0.5
            if d > 4.4:
                continue
            u = (x - c) / 4.4
            lv = light(u) * 0.7 - (y - c) / 18.0
            if d > 3.2:
                col = pick(STEEL, lv + 0.35, rnd, 0.25)  # jant
            elif d > 1.4:
                spoke = x == 4 or y == 4
                col = pick(STEEL, lv + 0.2, rnd, 0.2) if spoke else STEEL[1]  # tel
            else:
                col = pick(IRON, 0.95, rnd, 0.05)  # pirinç göbek
            if u > 0.55:
                col = mix(col, MOON, 0.3)
            px[x, y] = col + (255,)
    outline(img)
    return img


def main():
    make_dikme_celik(random.Random(223)).save(OUT + "dikme_celik.png")
    make_dikme_ahsap(random.Random(227)).save(OUT + "dikme_ahsap.png")
    make_kusak_celik(random.Random(229)).save(OUT + "kusak_celik.png")
    make_kusak_ahsap(random.Random(233)).save(OUT + "kusak_ahsap.png")
    _lip(STONE, random.Random(239)).save(OUT + "kenar_tas.png")
    _lip(STEEL, random.Random(241)).save(OUT + "kenar_celik.png")
    make_kenar_isik(random.Random(251)).save(OUT + "kenar_isik.png")
    make_makara(random.Random(257)).save(OUT + "makara.png")


if __name__ == "__main__":
    main()
