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

Çıktı: assets/environment/pixel/{varil,patlayici,parmaklik,parmaklik_tepe,tup,
fener,fener_hale,asma_lamba,on_kolon,on_kolon_bas,on_kolon_kaide,on_sarmasik,zincir,halat,kum_torbasi,tas_blok,raf,kaset,cerceve}.png
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
ORANGE = [(34, 12, 24), (62, 20, 28), (96, 32, 30), (132, 48, 32), (168, 70, 36),
          (196, 96, 44), (222, 132, 62), (240, 176, 96)]
CREAM = [(40, 30, 40), (78, 62, 62), (120, 100, 84), (168, 146, 112), (214, 196, 150)]
BRASS = [(44, 26, 22), (92, 60, 30), (150, 106, 44), (204, 160, 72), (240, 210, 120)]
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


def make_tup(rnd):
    """Mahalle gaz tüpü: boyalı çelik gövde, kaynak dikişi, soluk etiket kuşağı,
    tepede tutamaklı koruma tacı içinde pirinç vana, altta çelik ayak halkası."""
    w, h = 17, 27
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = (w - 1) / 2.0

    def half_at(y):
        if y <= 5:
            return 4.6  # taç
        if y <= 9:
            return 5.6 + (8.5 - 5.6) * math.sin((y - 5) / 4.0 * math.pi / 2)  # omuz
        if y <= 22:
            return 8.5
        if y <= 23:
            return 8.0
        return 7.4  # ayak halkası

    for y in range(h):
        half = half_at(y)
        for x in range(w):
            dx = x - cx
            if abs(dx) > half:
                continue
            u = dx / half
            lv = light(u)
            if y <= 5:
                # Koruma tacı: içi gölgede, yanlarda tutamak deliği, dudağı ışık yakalar.
                if 1 <= y <= 3 and abs(dx) < 2.6:
                    c = pick(IRON, 0.05 + (0.12 if y == 3 else 0.0), rnd, 0.2)
                elif y == 3 and 2.6 <= abs(dx) <= 3.6:
                    c = IRON[0]  # tutamak deliği
                else:
                    c = pick(IRON, lv * 0.75 + 0.3 + (0.3 if y <= 1 else 0.0), rnd, 0.3)
            elif y >= 24:
                c = pick(IRON, lv * 0.7 + 0.12 - (y - 24) * 0.1 + (0.3 if y == 24 else 0.0), rnd, 0.3)
            else:
                # Omuz kubbesi üstten ışık alır; altta AO.
                top = max(0.0, (9 - y) * 0.09)
                ao = max(0.0, (y - 19) * 0.07)
                c = pick(ORANGE, lv + top - ao, rnd, 0.55)
                if 12 <= y <= 15:
                    c = pick(CREAM, lv * 0.85 + (0.12 if y == 12 else 0.0), rnd, 0.4)
                    if y == 13 and -5 <= dx <= 2 and x % 4 != 0:
                        c = CREAM[1]  # damgalı yazı satırı
                    elif y == 14 and -5 <= dx <= -1:
                        c = CREAM[1]
                elif y == 18:
                    c = pick(ORANGE, lv - 0.35, rnd, 0.2)  # kaynak dikişi
                elif y == 19:
                    c = pick(ORANGE, lv + 0.22, rnd, 0.2)  # dikişin alt dudağı
                elif rnd.random() < 0.06:
                    c = pick(ORANGE, lv - 0.2, rnd, 0.1)  # boya ezikleri
            if u > 0.78:
                c = mix(c, MOON, 0.3)
            px[x, y] = c + (255,)
    # Pirinç vana tacın içinde: gövde + volan.
    for y in range(1, 4):
        for x in range(int(cx) - 1, int(cx) + 2):
            u = (x - cx) / 1.5
            px[x, y] = pick(BRASS, light(u) + (0.3 if y == 1 else 0.0), rnd, 0.3) + (255,)
    for x in range(int(cx) - 2, int(cx) + 3):
        px[x, 2] = pick(BRASS, light((x - cx) / 2.5) + 0.25, rnd, 0.2) + (255,)
    # Boya kalkması ve pas akıntıları: kaynak dikişinden ve omuzdan aşağı.
    for _ in range(14):
        x, y = rnd.randrange(2, w - 2), rnd.randrange(7, 23)
        if px[x, y][3] and not (12 <= y <= 15):
            px[x, y] = RUST[rnd.randrange(len(RUST))] + (255,)
    for x in (4, 11, 13):
        for y in range(19, 19 + rnd.randrange(2, 5)):
            if px[x, y][3]:
                px[x, y] = RUST[y % 3] + (255,)
    for y in range(8, 11):
        px[3, y] = RUST[1 + y % 2] + (255,)
    outline(img)
    return img


# Fener camının içi: kenarda kızıl-kahve, alevin çevresinde altın, çekirdekte krem.
GLOW = [(62, 20, 28), (110, 40, 30), (166, 72, 36), (210, 112, 48), (236, 156, 70),
        (248, 196, 110), (255, 228, 160), (255, 244, 206)]


def cage(img, rows, half, rnd, posts):
    """Fener kafesi: sıcak ışıklı cam + koyu demir/pirinç dikmeler. posts: dikme dx'leri.
    Cam ortadan (alev) dışa doğru söner; sağ kenarda ay ışığı karışmaz (iç ışık baskın)."""
    px = img.load()
    w = img.size[0]
    cx = (w - 1) / 2.0
    y0, y1 = rows
    for y in range(y0, y1 + 1):
        for x in range(w):
            dx = x - cx
            if abs(dx) > half:
                continue
            if any(abs(dx - p) < 0.6 for p in posts):
                u = dx / half
                c = pick(BRASS, light(u) * 0.8 + 0.08, rnd, 0.3)
                if u > 0.7:
                    c = mix(c, MOON, 0.3)
            else:
                # Alev camın alt-ortasında: ışık oradan yukarı-dışa yayılır.
                fy = y0 + (y1 - y0) * 0.62
                d = math.hypot(dx / (half * 0.9), (y - fy) / ((y1 - y0) * 0.75))
                c = pick(GLOW, 1.0 - d * 0.85, rnd, 0.7)
            px[x, y] = c + (255,)


def make_fener(rnd):
    """Sokak feneri (13×60): pirinç kafesli cam başlık, piramit dövme çatı, süslü yaka,
    ince demir direk, halkalı ayak. Fener başı (sanat y≈6) DtmLevel'de node konumudur."""
    w, h = 13, 60
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = (w - 1) / 2.0

    def half_at(y):
        if y <= 1:
            return 0.6  # tepe topuzu
        if y <= 3:
            return 1.6 + (y - 2) * 2.0  # piramit çatı
        if y == 4:
            return 6.5  # çatı saçağı
        if y <= 10:
            return 5.0  # kafes
        if y == 11:
            return 5.6  # alt tabla
        if y <= 13:
            return 3.6 - (y - 12) * 1.2  # huni
        if y <= 15:
            return 2.6 if y == 14 else 1.6  # yaka
        if y <= 50:
            return 2.6 if y in (30, 31) else 1.6  # direk + bilezik
        if y <= 52:
            return 2.6  # ayak üst halkası
        if y <= 55:
            return 3.2 + (y - 53) * 0.7  # ayak gövdesi
        return 5.6 if y <= 57 else 6.5  # kaide

    for y in range(h):
        half = half_at(y)
        if 5 <= y <= 10:
            continue  # kafes ayrıca
        for x in range(w):
            dx = x - cx
            if abs(dx) > half:
                continue
            u = dx / max(half, 0.6)
            lv = light(u)
            if y <= 4:
                # Çatı: üstten sıcak, saçak dudağı parlar, saçağın altı içten aydınlık.
                c = pick(IRON, lv * 0.75 + (0.35 if y in (0, 4) else 0.12), rnd, 0.35)
            elif y <= 15:
                # Tabla ve huni: camın ışığını alttan yakalar (pirinç).
                c = pick(BRASS, lv * 0.7 + (0.3 if y == 11 else 0.0) - (y - 11) * 0.06, rnd, 0.35)
            else:
                # Direk: fenere yakın üst kısım sıcak ışık alır; aşağı indikçe kararır, dipte AO.
                glow = max(0.0, (24 - y) * 0.03)
                ao = max(0.0, (y - 55) * 0.09)
                ring = y in (30, 52, 56)
                c = pick(IRON, lv * 0.8 + glow - ao + (0.32 if ring else 0.0), rnd, 0.4)
                if y in (31, 53, 57):
                    c = pick(IRON, lv * 0.5 - 0.05, rnd, 0.2)  # halka altı gölge
                elif rnd.random() < 0.05 and 18 <= y <= 50:
                    c = RUST[rnd.randrange(3)]
            if u > 0.6 and y > 4:
                c = mix(c, MOON, 0.3)
            px[x, y] = c + (255,)
    cage(img, (5, 10), 5.0, rnd, (-4.0, 0.0, 4.0))
    # Pas akıntısı: bilezik ve ayak halkasından aşağı.
    for x, y0 in ((5, 32), (7, 32), (5, 54)):
        for y in range(y0, y0 + rnd.randrange(2, 6)):
            if px[x, y][3]:
                px[x, y] = RUST[y % 3] + (255,)
    outline(img)
    return img


def make_asma_lamba(rnd):
    """İç mekân asma lambası (12×14): askı halkası, kubbe kapak, pirinç kafesli cam, alt topuz."""
    w, h = 12, 14
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = (w - 1) / 2.0
    halves = {0: 1.6, 1: 1.6, 2: 2.0, 3: 3.6, 4: 6.0, 11: 5.0, 12: 3.0, 13: 1.0}
    for y, half in halves.items():
        for x in range(w):
            dx = x - cx
            if abs(dx) > half:
                continue
            if y == 1 and abs(dx) < 0.6:
                continue  # halka deliği
            u = dx / half
            lv = light(u)
            if y <= 1:
                c = pick(IRON, lv * 0.7 + 0.25, rnd, 0.3)
            elif y <= 4:
                c = pick(BRASS, lv * 0.75 + (0.3 if y == 4 else 0.05), rnd, 0.35)
            else:
                # Alt tabla camın ışığını alır, topuz kararır.
                c = pick(BRASS, lv * 0.7 + (0.35 if y == 11 else 0.0) - (y - 11) * 0.12, rnd, 0.3)
            if u > 0.6:
                c = mix(c, MOON, 0.3)
            px[x, y] = c + (255,)
    cage(img, (5, 10), 4.5, rnd, (-4.0, 0.5, 4.5))
    outline(img)
    return img


def make_fener_hale(rnd):
    """Fener halesi (48×48, eklemeli karışım): yuvarlak sıcak ışık, 4×4 Bayer dither
    basamakları; merkezde düz disk yok, ışık alevden dışa doğru kademeli söner."""
    n = 48
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = img.load()
    bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    # (renk, alfa): eklemeli; dışta kızıl, içte altın-krem.
    levels = [None, ((210, 96, 48), 34), ((236, 132, 60), 56), ((250, 168, 80), 80),
              ((255, 196, 112), 104), ((255, 218, 150), 124)]
    c = (n - 1) / 2.0
    for y in range(n):
        for x in range(n):
            r = math.hypot(x - c, (y - c) * 1.08) / (n / 2.0)
            i = max(0.0, 1.0 - r) ** 1.5 * (len(levels) - 1)
            base = int(i)
            if i - base > (bayer[y % 4][x % 4] + 0.5) / 16.0:
                base += 1
            base = min(base, len(levels) - 1)
            if levels[base] is not None:
                col, a = levels[base]
                px[x, y] = col + (a,)
    return img


# Ön plan taşı (kamera önü, karanlıkta kalır): mor gölge, sıcak fener kenarı.
STONE = [(12, 7, 18), (26, 20, 28), (40, 32, 38), (56, 46, 50), (74, 62, 62),
         (96, 80, 72), (124, 102, 84), (160, 128, 94), (196, 160, 110)]
LEAF = [(8, 14, 20), (14, 26, 28), (20, 40, 34), (30, 56, 38), (44, 74, 42),
        (64, 94, 46), (96, 116, 54), (140, 140, 70)]
HEMP = [(34, 22, 37), (58, 38, 42), (88, 58, 48), (122, 86, 58), (160, 118, 74),
        (200, 160, 100)]


def outline_sides(img):
    """Dikey döşenen parça: yalnız sol/sağ dış hatta kontur (üst/alt dikişte çizgi olmasın)."""
    px = img.load()
    w, h = img.size
    edge = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] and (x == 0 or x == w - 1 or not px[x - 1, y][3] or not px[x + 1, y][3]):
                edge.append((x, y))
    for x, y in edge:
        px[x, y] = OUTLINE


def column_px(rnd, x, w, lv_add=0.0):
    """Ön plan taş kolonunun bir sütun pikseli: yuvarlak gövde, oluklar, sol sıcak kenar."""
    cx = (w - 1) / 2.0
    u = (x - cx) / (w / 2.0)
    lv = light(u) * 0.7 + lv_add
    flute = (x - 1) % 4 == 0 and 1 < x < w - 2
    c = pick(STONE, lv - (0.22 if flute else 0.0), rnd, 0.5)
    if (x - 1) % 4 == 1 and 1 < x < w - 2:
        c = pick(STONE, lv + 0.12, rnd, 0.3)  # oluk kenarı ışığı
    if u > 0.75:
        c = mix(c, MOON, 0.35)
    return c


def make_on_kolon(rnd):
    """Ön plan taş kolon gövdesi (18×16, dikey döşenir): oluklu, çatlak ve yosun lekeli."""
    w, h = 18, 16
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(1, w - 1):
            px[x, y] = column_px(rnd, x, w) + (255,)
    # Çatlak ve yosun (derz yok: 16 satırlık döşemede tuğla yığını gibi tekrar ederdi).
    for y, x in ((3, 6), (4, 6), (5, 7), (6, 7), (7, 8)):
        px[x, y] = STONE[1] + (255,)
    for x, y in ((3, 13), (4, 14), (3, 15), (12, 9), (13, 10)):
        px[x, y] = LEAF[3 + rnd.randrange(2)] + (255,)
    outline_sides(img)
    return img


def make_on_kolon_bas(rnd):
    """Kolon başlığı (18×10): tabla, yuvarlak boğaz, gövdeye inen halka."""
    w, h = 18, 10
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    spans = {0: (0, 18), 1: (0, 18), 2: (0, 18), 3: (1, 17), 4: (2, 16), 5: (2, 16),
             6: (1, 17), 7: (1, 17), 8: (1, 17), 9: (1, 17)}
    for y, (a, b) in spans.items():
        for x in range(a, b):
            if y <= 2:
                lv = 0.5 if y == 0 else 0.3 - y * 0.08  # tabla üstü fenerden ışık alır
                c = pick(STONE, lv + light((x - 8.5) / 9) * 0.25, rnd, 0.4)
                if x > 15:
                    c = mix(c, MOON, 0.35)
            elif y <= 5:
                c = column_px(rnd, x, w, 0.12 - (y - 3) * 0.08)
            elif y == 6:
                c = column_px(rnd, x, w, 0.22)  # halka
            else:
                c = column_px(rnd, x, w, -0.04 if y == 7 else 0.0)
            px[x, y] = c + (255,)
    outline(img)
    # Gövdeyle birleşen alt satırın konturunu kaldır (dikiş görünmesin).
    for x in range(2, 16):
        px[x, 9] = column_px(rnd, x, w) + (255,)
    return img


def make_on_kolon_kaide(rnd):
    """Kolon kaidesi (18×10): halka + iki basamaklı kaide, zemine temasta AO."""
    w, h = 18, 10
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    spans = {0: (1, 17), 1: (1, 17), 2: (1, 17), 3: (0, 18), 4: (0, 18), 5: (0, 18),
             6: (0, 18), 7: (0, 18), 8: (0, 18), 9: (0, 18)}
    for y, (a, b) in spans.items():
        for x in range(a, b):
            if y <= 2:
                c = column_px(rnd, x, w, 0.2 if y == 2 else 0.0)
            else:
                ao = max(0.0, (y - 6) * 0.1)
                c = pick(STONE, light((x - 8.5) / 9) * 0.5 + (0.3 if y in (3, 6) else 0.0) - ao, rnd, 0.4)
                if y == 5:
                    c = pick(STONE, 0.02, rnd, 0.1)  # basamak gölgesi
                if x > 15:
                    c = mix(c, MOON, 0.3)
                if y >= 7 and rnd.random() < 0.12:
                    c = LEAF[2 + rnd.randrange(2)]  # dipte yosun
            px[x, y] = c + (255,)
    outline(img)
    for x in range(2, 16):
        px[x, 0] = column_px(rnd, x, w) + (255,)
    return img


def make_on_sarmasik(rnd):
    """Ön plan sarmaşık (40×48): üstte yoğun yaprak kümesi, aşağı sarkan dallar.
    Yaprak 2-3 piksel; sol-üst yaprak kenarı sıcak ışık, alt yüz mor-laciverte kayar."""
    w, h = 40, 48
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()

    def leaf(x, y, lv):
        # Baklava yaprak: sol üst ışık, sağ alt mor gölge, altında koyu kontur pikseli.
        for dx, dy, add in ((1, 0, 0.15), (0, 1, 0.05), (1, 1, 0.0), (2, 1, -0.15), (1, 2, -0.25)):
            xx, yy = x + dx, y + dy
            if 0 <= xx < w and 0 <= yy < h:
                px[xx, yy] = pick(LEAF, lv + add, rnd, 0.4) + (255,)
        for xx, yy in ((1 + x, 3 + y), (2 + x, 2 + y)):
            if 0 <= xx < w and 0 <= yy < h and not px[xx, yy][3]:
                px[xx, yy] = OUTLINE

    # Sarkan dallar: farklı uzunluk, hafif salınımlı gövde, sık yaprak.
    for sx in (2, 6, 10, 14, 18, 21, 25, 29, 33, 37):
        ln = rnd.randrange(16, h - 1)
        x = sx
        for y in range(4, ln):
            if rnd.random() < 0.2:
                x += rnd.choice((-1, 1))
            x = min(max(x, 1), w - 2)
            px[x, y] = pick(LEAF, 0.12, rnd, 0.2) + (255,)
            if rnd.random() < 0.42:
                side = rnd.choice((-2, 0))
                leaf(x + side, y, 0.4 - y / h * 0.25 + (0.1 if side < 0 else -0.05))
    # Üst küme: tutunduğu kirişin altını kaplar (dalların üstünde çizilir).
    for _ in range(150):
        x = rnd.randrange(-1, w - 1)
        y = int(rnd.random() ** 1.5 * 10)
        leaf(x, y, 0.5 - y * 0.035 + light((x - 20) / 20) * 0.2)
    return img


def make_zincir(rnd):
    """Zincir (6×8, dikey döşenir): yüzü dönük oval halka + yandan görülen ince halka."""
    w, h = 6, 8
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    ring = {1: (1, 5), 2: (0, 6), 3: (0, 6), 4: (0, 6), 5: (1, 5)}
    for y, (a, b) in ring.items():
        for x in range(a, b):
            if 2 <= x <= 3 and 2 <= y <= 4:
                continue  # halka deliği
            u = (x - 2.5) / 3.0
            lv = light(u) * 0.8 + (0.25 if y == 1 else 0.0) - (0.15 if y == 5 else 0.0)
            c = pick(IRON, lv, rnd, 0.3)
            if u > 0.6:
                c = mix(c, MOON, 0.35)
            px[x, y] = c + (255,)
    # Yandan halka: ortada iki piksel, alttan bir sonraki parçanın tepesine bağlanır.
    for y in (6, 7, 0):
        px[2, y] = pick(IRON, 0.62, rnd, 0.2) + (255,)
        px[3, y] = pick(IRON, 0.22, rnd, 0.2) + (255,)
    px[0, 3] = OUTLINE
    px[5, 3] = OUTLINE
    px[1, 1] = OUTLINE
    px[4, 5] = OUTLINE
    return img


def make_halat(rnd):
    """Kenevir halat (3×8, dikey döşenir): çapraz bükülmüş üç kol."""
    w, h = 3, 8
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            ph = (y + x) % 4  # çapraz bükülme: kollar sağa yükselen şerit, 8 satırda iki tur
            lv = [0.68, 0.48, 0.26, 0.04][ph] + (0.1 if x == 0 else -0.12 if x == 2 else 0.0)
            px[x, y] = pick(HEMP, lv, rnd, 0.2) + (255,)
    return img


BURLAP = [(26, 16, 28), (46, 32, 38), (70, 50, 46), (98, 72, 54), (126, 96, 64),
          (154, 122, 80), (182, 150, 98), (208, 178, 120)]
BOOK_RED = [(34, 10, 24), (66, 18, 30), (104, 30, 34), (142, 48, 40), (182, 78, 54)]
BOOK_TEAL = [(10, 18, 28), (18, 36, 44), (28, 58, 62), (44, 84, 80), (74, 116, 100)]
SEA = [(16, 20, 42), (24, 38, 66), (34, 58, 88), (52, 86, 110), (90, 124, 132)]


def make_kum_torbasi(rnd):
    """Kum torbası duvarı (32×24, iki yönde döşenir): şaşırtmalı iki sıra yastık torba.
    Çuval dokusu, bağ ucu büzgüsü; üstten fener ışığı, altta ve aralarda mor AO."""
    w, h = 32, 24
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        row = y // 12
        ly = y % 12
        off = 8 if row else 0
        for x in range(w):
            lx = (x + off) % 16
            # Yastık silüeti: köşeler yuvarlak, torbalar arası koyu derz.
            nx = (lx - 7.5) / 8.0
            ny = (ly - 5.5) / 6.0
            if nx ** 4 + ny ** 4 > 0.9:
                px[x, y] = OUTLINE if ly >= 10 or abs(nx) > 0.9 else BURLAP[0] + (255,)
                continue
            u = nx
            lv = light(u) * 0.55 + (0.32 - ly * 0.05)  # üst yüz ışık alır
            lv -= max(0.0, ly - 8) * 0.08  # alt kıvrım AO
            if (x + y) % 2 == 0:
                lv += 0.05  # çuval örgüsü
            c = pick(BURLAP, lv, rnd, 0.5)
            if abs(nx) > 0.72 and ly in (4, 6):
                c = pick(BURLAP, lv - 0.25, rnd, 0.1)  # bağ ucu büzgüsü
            if lx > 13:
                c = mix(c, MOON, 0.2)
            px[x, y] = c + (255,)
    # Sızan kum ve leke.
    for _ in range(10):
        x, y = rnd.randrange(w), rnd.randrange(h)
        if px[x, y][:3] != OUTLINE[:3]:
            px[x, y] = BURLAP[2 + rnd.randrange(2)] + (255,)
    return img


def make_tas_blok(rnd):
    """Kesme taş blok (30×30, ızgarada döşenir): pahlı kenar, keski izi, kırık köşe,
    ortada oyma rozet (sekiz kollu yıldız), dipte yosun. Oyunda (0.78,0.7,0.6) tonlanır."""
    n = 30
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = img.load()
    c0 = (n - 1) / 2.0
    for y in range(n):
        for x in range(n):
            if x == n - 1 or y == n - 1:
                px[x, y] = OUTLINE  # derz (sağ/alt; döşemede tek derz)
                continue
            lv = 0.48 + (rnd.random() - 0.5) * 0.08
            if x == 0 or y == 0:
                lv = 0.78  # pah: fener ışığı sol üstte
            elif x == 1 or y == 1:
                lv = 0.62
            elif x == n - 2 or y == n - 2:
                lv = 0.18  # alt/sağ pah gölgede
            elif x == n - 3 or y == n - 3:
                lv = 0.32
            if (x * 3 + y * 7) % 11 == 0 and 2 < x < n - 3 and 2 < y < n - 3:
                lv -= 0.12  # keski izi
            # Çökük oyma pano: üst/sol iç kenar gölgede, alt/sağ iç kenar ışık yakalar;
            # ortada küçük kabartma baklava.
            if 7 <= x <= 21 and 7 <= y <= 21:
                if x == 7 or y == 7:
                    lv = 0.14
                elif x == 21 or y == 21:
                    lv = 0.66
                else:
                    lv -= 0.1
                    d = abs(x - c0) + abs(y - c0)
                    if d <= 3.5:
                        lv = 0.66 if (x - c0) + (y - c0) < 0 else 0.24
            c = pick(STONE, lv, rnd, 0.35)
            if x > n - 6:
                c = mix(c, MOON, 0.18)
            px[x, y] = c + (255,)
    # Kırık köşe (sağ üst) ve çatlak.
    for x, y in ((27, 0), (28, 0), (28, 1), (27, 1)):
        px[x, y] = OUTLINE
    for x, y in ((26, 1), (27, 2)):
        px[x, y] = pick(STONE, 0.2, rnd, 0.1) + (255,)
    for x, y in ((3, 22), (4, 23), (4, 24), (5, 25)):
        px[x, y] = STONE[1] + (255,)
        px[x + 1, y] = pick(STONE, 0.62, rnd, 0.1) + (255,)
    # Dipte yosun.
    for x in range(2, 27):
        if rnd.random() < 0.4:
            px[x, 27] = LEAF[2 + rnd.randrange(3)] + (255,)
            if rnd.random() < 0.4:
                px[x, 26] = LEAF[2 + rnd.randrange(2)] + (255,)
    return img


def make_raf(rnd):
    """Duvar rafı (30×22): koyu ahşap kasa, üç rafta cilt sırtları, kavanoz, pirinç şamdan."""
    w, h = 30, 22
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    # Kasa: arka pano karanlık, yan dikmeler ve raf tahtaları ışık alır.
    for y in range(h):
        for x in range(w):
            if x in (0, 1) or x in (w - 2, w - 1) or y in (0, 7, 14, 21):
                lv = 0.55 if (y in (0, 7, 14) or x == 0) else 0.25
                c = pick(WOOD, lv, rnd, 0.4)
            else:
                c = pick(WOOD, 0.05 + (0.08 if y % 7 == 1 else 0.0), rnd, 0.3)  # arka pano
            px[x, y] = c + (255,)
    # Raf içerikleri: her rafın satırları 1..6.
    for shelf in range(3):
        base = shelf * 7 + 6
        x = 3
        while x < w - 4:
            kind = rnd.random()
            if kind < 0.62:
                ramp = [BOOK_RED, BOOK_TEAL, CREAM, WOOD][rnd.randrange(4)]
                bw = rnd.choice((1, 2, 2))
                bh = rnd.randrange(3, 6)
                for bx in range(x, min(x + bw, w - 3)):
                    for by in range(base - bh + 1, base + 1):
                        lv = 0.62 if bx == x else 0.35
                        if by == base - bh + 2:
                            lv += 0.25  # sırt yaldız şeridi
                        px[bx, by] = pick(ramp, lv, rnd, 0.3) + (255,)
                x += bw
            elif kind < 0.82:
                for bx in range(x, min(x + 2, w - 3)):
                    for by in range(base - 2, base + 1):
                        px[bx, by] = pick(BRASS if rnd.random() < 0.5 else CREAM, 0.6 if bx == x else 0.3, rnd, 0.3) + (255,)
                x += 3
            else:
                x += 1  # boşluk
    outline(img)
    return img


def make_kaset(rnd):
    """Kaset (16×11, ipucu): bej plastik gövde, kâğıt etiket, iki makara penceresi, vida."""
    w, h = 16, 11
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            if (x in (0, w - 1)) and (y in (0, h - 1)):
                continue
            u = (x - 7.5) / 8.0
            lv = light(u) * 0.55 + 0.25 - y * 0.02
            c = pick(CREAM, lv, rnd, 0.3)
            if 2 <= x <= 13 and 1 <= y <= 7:
                # Etiket: soluk turuncu üst şerit + krem kâğıt, ortada makara penceresi.
                c = pick(ORANGE, 0.7 if y == 1 else 0.55, rnd, 0.3) if y <= 2 else pick(CREAM, 0.62, rnd, 0.2)
                if 4 <= y <= 6 and 4 <= x <= 11:
                    c = pick(IRON, 0.1, rnd, 0.1)  # pencere
                    if x in (5, 10) and y == 5:
                        c = CREAM[4]  # makara göbeği
                    elif x in (4, 6, 9, 11) and y == 5 or x in (5, 10) and y in (4, 6):
                        c = pick(ORANGE, 0.3, rnd, 0.1)  # sarılı bant
            if y == 9 and 4 <= x <= 11:
                c = pick(CREAM, 0.15, rnd, 0.1)  # alt çıkıntı gölgesi
            if u > 0.75:
                c = mix(c, MOON, 0.25)
            px[x, y] = c + (255,)
    px[2, 9] = IRON[2] + (255,)  # vidalar
    px[13, 9] = IRON[2] + (255,)
    outline(img)
    return img


def make_cerceve(rnd):
    """Duvar tablosu (16×12): yaldızlı oyma çerçeve, içinde gece Boğaz'ı ve vapur silüeti."""
    w, h = 16, 12
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            if x <= 1 or x >= w - 2 or y <= 1 or y >= h - 2:
                lv = 0.75 if (x <= 1 and y < h - 2) or y <= 1 else 0.3
                if (x + y) % 3 == 0:
                    lv -= 0.18  # oyma
                c = pick(BRASS, lv, rnd, 0.3)
            elif y <= 5:
                # Gökyüzü: üstte lacivert, ufka doğru turuncu ışık.
                c = mix(SEA[1], ORANGE[4], max(0.0, (y - 2) / 4.0) * 0.6)
            elif y == 6:
                c = (40, 28, 44)  # karşı kıyı silüeti
                if x in (5, 9, 12):
                    c = BRASS[3]  # kıyıda ışık
            else:
                c = pick(SEA, 0.55 - (y - 7) * 0.12, rnd, 0.6)
            px[x, y] = c + (255,)
    # Vapur: koyu gövde, ışıklı lomboz, baca.
    for x in range(4, 9):
        px[x, 7] = (26, 18, 30, 255)
    px[5, 7] = BRASS[3] + (255,)
    px[7, 7] = BRASS[3] + (255,)
    px[6, 6] = (26, 18, 30, 255)
    px[6, 5] = (26, 18, 30, 255)
    outline(img)
    return img


def main():
    rnd = random.Random(7)
    make_varil(rnd).save(OUT + "varil.png")
    make_patlayici(rnd).save(OUT + "patlayici.png")
    make_parmaklik(rnd).save(OUT + "parmaklik.png")
    make_parmaklik_tepe(rnd).save(OUT + "parmaklik_tepe.png")
    make_tup(random.Random(11)).save(OUT + "tup.png")
    make_fener(random.Random(13)).save(OUT + "fener.png")
    make_fener_hale(random.Random(13)).save(OUT + "fener_hale.png")
    make_asma_lamba(random.Random(17)).save(OUT + "asma_lamba.png")
    make_on_kolon(random.Random(19)).save(OUT + "on_kolon.png")
    make_on_kolon_bas(random.Random(19)).save(OUT + "on_kolon_bas.png")
    make_on_kolon_kaide(random.Random(19)).save(OUT + "on_kolon_kaide.png")
    make_on_sarmasik(random.Random(23)).save(OUT + "on_sarmasik.png")
    make_zincir(random.Random(29)).save(OUT + "zincir.png")
    make_halat(random.Random(31)).save(OUT + "halat.png")
    make_kum_torbasi(random.Random(37)).save(OUT + "kum_torbasi.png")
    make_tas_blok(random.Random(41)).save(OUT + "tas_blok.png")
    make_raf(random.Random(43)).save(OUT + "raf.png")
    make_kaset(random.Random(47)).save(OUT + "kaset.png")
    make_cerceve(random.Random(53)).save(OUT + "cerceve.png")


if __name__ == "__main__":
    main()
