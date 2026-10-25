"""ChatGPT temel sanatının çizim tarzında prop üretici.

Kural seti (assets/backgrounds ve book03_final_* sayfalarından ölçüldü):
- Her malzeme 8-10 tonluk rampa; gölge mor/laciverte kayar, ışık turuncu-altına.
- Genel ton karanlık ve dramatik: orta tonlar rampanın alt yarısında, en açık tonlar
  yalnız ışığa bakan dar şeritte.
- Kontur siyah değil koyu mor (12,7,18); dış hatta tek piksel.
- Ana ışık sol üstten sıcak fener ışığı; sağ kenarda soğuk ay ışığı kenar parlaması.
- Doku: geniş tahta + derin oluk, kalın koyu demir çember üstünde altın parlama,
  pas akıntısı, boya kalkması; düz renk alan yok.
- Silüet hacimli (fıçı göbekli), zemine temas eden altta ortam kapanması (AO).

Çıktı: assets/environment/pixel/{varil,patlayici,parmaklik,parmaklik_tepe}.png
Oyunda 2x NEAREST ölçeklenir (1 sanat pikseli = 2 ekran pikseli).
"""
import math
import random
from PIL import Image

OUT = "assets/environment/pixel/"
OUTLINE = (12, 7, 18, 255)

# Ölçülen rampalar (koyudan açığa).
WOOD = [(34, 22, 37), (54, 31, 42), (73, 40, 43), (89, 51, 46), (103, 54, 43),
        (120, 65, 45), (134, 74, 45), (166, 108, 66), (196, 132, 74)]
IRON = [(8, 5, 11), (22, 15, 26), (36, 23, 36), (52, 39, 53), (70, 52, 60),
        (96, 70, 65), (144, 110, 88), (206, 166, 106)]
RED = [(34, 10, 24), (56, 14, 28), (82, 20, 30), (110, 26, 32), (138, 34, 34),
       (166, 50, 38), (196, 82, 48), (226, 128, 70)]
HAZARD = [(54, 32, 22), (108, 72, 26), (162, 116, 34), (204, 156, 50), (236, 200, 96)]
RUST = [(56, 27, 27), (92, 44, 30), (132, 66, 34), (168, 96, 46)]
MOON = (110, 116, 170)


def pick(ramp, v, rnd, jitter=0.6):
    """0..1 ışık değerini rampaya oturt; küçük titreşim GPT'nin doku gürültüsünü verir."""
    v = min(max(v + (rnd.random() - 0.5) * jitter / len(ramp), 0.0), 0.999)
    return ramp[int(v * len(ramp))]


def light(u):
    """u: -1 sol .. 1 sağ (silindir yüzeyi). Sol-orta sıcak ışık, karanlık orta ton."""
    nz = math.sqrt(max(0.0, 1.0 - u * u))
    key = max(0.0, -u * 0.6 + nz * 0.7)
    return 0.04 + (key ** 1.7) * 0.9


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def outline(img):
    px = img.load()
    w, h = img.size
    edge = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] == 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if nx < 0 or ny < 0 or nx >= w or ny >= h or px[nx, ny][3] == 0:
                    edge.append((x, y))
                    break
    for x, y in edge:
        px[x, y] = OUTLINE


def barrel(w, h, body, bands, rnd, staves):
    """Göbekli fıçı. bands: (y0, y1) demir çember satırları. staves: tahta genişliği (0 = metal)."""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = (w - 1) / 2.0
    for y in range(h):
        t = y / (h - 1)
        # Göbek: ortada tam genişlik, uçlarda ~%84.
        half = (w / 2.0) * (0.84 + 0.16 * math.sin(math.pi * t))
        band = next(((b0, b1) for b0, b1 in bands if b0 <= y <= b1), None)
        if band:
            half += 0.6  # çember gövdeden taşar
        for x in range(w):
            dx = x - cx
            if abs(dx) > half:
                continue
            u = dx / half
            lv = light(u) - max(0.0, t - 0.78) * 1.0  # AO
            if band:
                top = y == band[0]
                c = pick(IRON, lv * 0.7 + (0.42 if top else 0.0), rnd, 0.35)
            elif staves:
                # Tahtalar silindir üstünde: yüzey açısına göre eşit aralık.
                a = math.asin(max(-1.0, min(1.0, u)))
                s = (a + math.pi / 2) / math.pi * (w / staves)
                f = s - math.floor(s)
                if f < 0.2:
                    c = body[0]  # derin oluk
                elif f < 0.36:
                    c = pick(body, lv + 0.2, rnd, 0.25)  # tahta kenarı ışığı
                else:
                    c = pick(body, lv, rnd, 0.55)
                    if rnd.random() < 0.09:
                        c = pick(body, lv - 0.18, rnd, 0.1)  # damar
            else:
                c = pick(body, lv, rnd, 0.45)
            if u > 0.82:
                c = mix(c, MOON, 0.3)
            px[x, y] = c + (255,)
    # Kapak dudağı: tahta uçları turuncu ışık yakalar.
    for x in range(w):
        if px[x, 1][3]:
            u = (x - cx) / (w / 2.0)
            px[x, 1] = pick(body, light(u) + 0.4, rnd, 0.2) + (255,)
            px[x, 2] = pick(body, light(u) - 0.15, rnd, 0.2) + (255,)
    return img


def make_varil(rnd):
    img = barrel(26, 34, WOOD, [(7, 9), (24, 26)], rnd, staves=3.4)
    outline(img)
    return img


def make_patlayici(rnd):
    w, h = 26, 34
    img = barrel(w, h, RED, [(4, 5), (16, 17), (29, 30)], rnd, staves=0)
    px = img.load()
    cx = (w - 1) / 2.0
    # Sarı-siyah uyarı kuşağı.
    for y in range(8, 13):
        for x in range(w):
            if not px[x, y][3]:
                continue
            lv = light((x - cx) / (w / 2.0))
            stripe = ((x + y) // 2) % 2 == 0
            c = pick(HAZARD, lv + 0.15, rnd, 0.3) if stripe else pick(IRON, lv * 0.5, rnd, 0.2)
            px[x, y] = c + (255,)
    # Alev işareti (sıcak tarafa yakın, hafif perspektif).
    for y in range(19, 27):
        for x in range(8, 16):
            d = abs(x - 11.5)
            if d <= (y - 18) * 0.5 and not (y > 24 and d < 1.2):
                lv = light((x - cx) / (w / 2.0))
                px[x, y] = pick(HAZARD, lv + 0.35, rnd, 0.3) + (255,)
    # Boya kalkması ve pas akıntıları.
    for _ in range(18):
        x, y = rnd.randrange(3, w - 3), rnd.randrange(3, h - 3)
        if px[x, y][3] and not (8 <= y <= 12):
            px[x, y] = RUST[rnd.randrange(len(RUST))] + (255,)
    for x in (6, 18, 20):
        for y in range(18, 18 + rnd.randrange(4, 9)):
            if px[x, y][3]:
                px[x, y] = RUST[y % 3] + (255,)
    outline(img)
    return img


def make_parmaklik(rnd):
    """Dikey dövme demir parmaklık parçası (döşenir): iki yuvarlak çubuk + perçinli kuşak."""
    w, h = 18, 36
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for b0 in (2, 11):
            for x in range(b0, b0 + 5):
                u = (x - b0 - 2) / 2.5
                c = pick(IRON, light(u), rnd, 0.4)
                if rnd.random() < 0.07:
                    c = RUST[rnd.randrange(3)]
                if u > 0.6:
                    c = mix(c, MOON, 0.3)
                px[x, y] = c + (255,)
        if 14 <= y <= 19:
            for x in range(1, 17):
                lv = 0.7 - (y - 14) * 0.13 + (0.25 if y == 14 else 0.0)
                px[x, y] = pick(IRON, lv, rnd, 0.3) + (255,)
    for x in (4, 13):
        px[x, 16] = IRON[7] + (255,)
        px[x, 17] = IRON[1] + (255,)
    for x in (5, 14):
        for y in range(20, 20 + rnd.randrange(3, 8)):
            px[x, y] = RUST[y % 3] + (255,)
    outline(img)
    return img


def make_parmaklik_tepe(rnd):
    """Parmaklık tepesi: iki mızrak ucu + kuşak."""
    w, h = 18, 15
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for cx in (4.5, 13.5):
        for y in range(h):
            half = 2.5 if y >= 10 else 0.6 + y * 0.42 if y < 7 else 3.4 - (y - 7) * 0.5
            for x in range(w):
                d = x + 0.5 - cx
                if abs(d) <= half:
                    px[x, y] = pick(IRON, light(d / max(half, 0.6)), rnd, 0.3) + (255,)
    for x in range(1, 17):
        px[x, 11] = IRON[6] + (255,)
        px[x, 12] = IRON[2] + (255,)
    outline(img)
    return img


def main():
    rnd = random.Random(7)
    make_varil(rnd).save(OUT + "varil.png")
    make_patlayici(rnd).save(OUT + "patlayici.png")
    make_parmaklik(rnd).save(OUT + "parmaklik.png")
    make_parmaklik_tepe(rnd).save(OUT + "parmaklik_tepe.png")


if __name__ == "__main__":
    main()
