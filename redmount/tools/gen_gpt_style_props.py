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
fener,fener_hale,asma_lamba,on_kolon,on_kolon_bas,on_kolon_kaide,on_sarmasik,zincir,halat,kum_torbasi,tas_blok,raf,kaset,cerceve,
diken,alev_izgara,kablo,bomba,bomba_ikaz,alev,kivilcim,patlama,
tugla,sivali_tugla,ic_duvar,hatil,ic_pencere,fabrika_pencere,cephe_pencereleri,kat_silmesi,saldiri_uyari,dukkan,tavan,han_kapisi,
pres,pres_kol,ray,su_govde,su_yuzey,anten,kule_ayak,kule_kulube,ahsap_kat,
kalkan,kalkan_kirik,sancak,catlak,kiymik,depo_rafi,baca_tahta,kule_tugla,baca_tugla}.png
ve assets/pickups/placeholder_rifle.png
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


FIRE = [(34, 10, 24), (74, 18, 30), (124, 30, 32), (172, 52, 34), (210, 88, 40),
        (234, 132, 56), (246, 182, 92), (252, 226, 160)]
SMOKE = [(14, 9, 20), (30, 22, 34), (48, 38, 50), (68, 58, 68), (92, 82, 88)]
ARC = [(30, 26, 70), (56, 64, 132), (96, 130, 196), (160, 206, 240), (232, 246, 255)]
OLIVE = [(12, 14, 16), (24, 30, 26), (38, 48, 34), (56, 68, 42), (80, 92, 52), (118, 124, 70)]


def make_diken(rnd):
    """Çivi şeridi (20×10, yatay döşenir): ikaz boyalı paslı taban lama üstünde dört dövme kazık.
    Kazığın sol yüzü fener ışığında (uca doğru parlar), sağ yüzü ayda; diplerde pas."""
    w, h = 20, 10
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    # Kazıklar konturlu çizilirse 5 piksellik genişlikte şişe gibi okunur: kontur yalnız
    # gölgedeki sağ kenarda, sol yüz ışıkta; uç tek parlak piksel.
    for cx in (2, 7, 12, 17):
        for y in range(0, 7):
            half = min(2, (y + 1) // 3)
            for x in range(cx - half, cx + half + 1):
                if x == cx + half and half == 2:
                    c = OUTLINE[:3]
                elif x < cx:
                    c = IRON[7] if y <= 3 else pick(IRON, 0.86 - y * 0.04, rnd, 0.15)
                elif x == cx:
                    c = IRON[7] if y <= 1 else pick(IRON, 0.7 - y * 0.05, rnd, 0.15)
                else:
                    c = mix(pick(IRON, 0.3, rnd, 0.2), MOON, 0.4)
                if y >= 6 and x != cx + half and rnd.random() < 0.3:
                    c = pick(RUST, 0.4 + (0.3 if x < cx else 0.0), rnd, 0.2)
                px[x % w, y] = c + (255,)
    # Taban lama: aşınmış sarı-siyah ikaz şeridi (koyu zeminde tehlike okunsun).
    for y in (7, 8, 9):
        for x in range(w):
            stripe = (x + y) // 3 % 2 == 0
            lv = {7: 0.8, 8: 0.5, 9: 0.2}[y]
            c = pick(HAZARD, lv, rnd, 0.4) if stripe else pick(IRON, lv * 0.45, rnd, 0.3)
            if rnd.random() < 0.22:
                c = pick(RUST, 0.45, rnd, 0.4)  # boya kalkması
            if x >= w - 3 and y < 9:
                c = mix(c, MOON, 0.15)
            px[x, y] = c + (255,)
    for x in range(w):
        px[x, 9] = OUTLINE
    return img


def make_alev_izgara(rnd):
    """Alev bacası ızgarası (22×6): kalın demir çerçeve, aralıkta közün turuncu ışığı."""
    w, h = 22, 6
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(1, h):
        for x in range(w):
            lv = {1: 0.75, 2: 0.5, 3: 0.35, 4: 0.25, 5: 0.1}[y]
            c = pick(IRON, lv, rnd, 0.4)
            if 2 <= y <= 4 and 2 <= x <= w - 3 and x % 3 != 1:
                c = pick(FIRE, 0.75 - (y - 2) * 0.22, rnd, 0.4)  # yarıktan sızan kor
            elif rnd.random() < 0.18:
                c = pick(RUST, 0.45, rnd, 0.4)
            if x >= w - 2:
                c = mix(c, MOON, 0.2)
            px[x, y] = c + (255,)
    outline(img)
    return img


def make_kablo(rnd):
    """Kopuk kablo (16×6, yatay döşenir): bükülü iki damarlı kauçuk, bant sargısı, sıyrık bakır."""
    w, h = 16, 6
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for x in range(w):
        for y in range(1, 5):
            strand = (x + (y - 1) * 2) // 4 % 2
            lv = {1: 0.7, 2: 0.45, 3: 0.3, 4: 0.12}[y] - strand * 0.12
            c = pick(IRON, lv, rnd, 0.3)
            if x in (6, 7) and y in (1, 2, 3, 4):
                c = pick(HAZARD, 0.55 if y <= 2 else 0.25, rnd, 0.3)  # izole bant
            if x == 12 and y == 1:
                c = pick(BRASS, 0.8, rnd, 0.1)  # sıyrıkta bakır parlaması
            if x == 13 and y == 1:
                c = pick(RUST, 0.7, rnd, 0.1)
            px[x, y] = c + (255,)
    for x in range(w):
        px[x, 0] = OUTLINE
        px[x, 5] = OUTLINE
    return img


def grenade(rnd, lit):
    """El bombası (8×9): zeytin dökme gövde, oluk dilimleri, pirinç tapa; ikazda kırmızı kor."""
    w, h = 8, 9
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(2, 9):
        ny = (y - 5.3) / 3.4
        for x in range(w):
            nx = (x - 3.5) / 3.6
            if nx * nx + ny * ny > 1.0:
                continue
            lv = light(nx) * 0.85 + (0.1 if ny < -0.3 else 0.0)
            if y in (4, 6) or x == 3:
                lv -= 0.18  # dilim olukları
            c = pick(RED if lit else OLIVE, lv, rnd, 0.25)
            if nx > 0.55:
                c = mix(c, MOON, 0.25)
            px[x, y] = c + (255,)
    for x in (3, 4):
        px[x, 1] = pick(BRASS, 0.75 if x == 3 else 0.4, rnd, 0.1) + (255,)
        px[x, 2] = pick(BRASS, 0.5 if x == 3 else 0.25, rnd, 0.1) + (255,)
    px[5, 1] = IRON[4] + (255,)  # mandal
    outline(img)
    if lit:
        px[4, 0] = FIRE[7] + (255,)
        px[5, 0] = FIRE[5] + (255,)
        px[3, 0] = FIRE[4] + (255,)
    return img


def make_alev(rnd):
    """Alev sütunu (4 kare × 16×46): dalgalanan dil; kenar koyu bordo-mor, içe doğru
    turuncu, çekirdek krem. Kontur yok (ışık kaynağı); dipte ızgaraya oturan kalın gövde."""
    frames = []
    for f in range(4):
        img = Image.new("RGBA", (16, 46), (0, 0, 0, 0))
        px = img.load()
        for y in range(46):
            t = y / 45.0  # 0 tepe, 1 dip
            half = 1.0 + (1.0 - abs(t - 0.78) * 1.5) * 5.5
            half += math.sin(y * 0.55 + f * 1.7) * 0.8 * (1 - t)
            sway = math.sin(y * 0.3 + f * 1.57) * 2.2 * (1 - t) ** 1.3
            cx = 7.5 + sway
            for x in range(16):
                d = abs(x - cx) / max(half, 0.6)
                if d > 1.0:
                    continue
                lv = (1.0 - d) * 0.75 + t * 0.35 - 0.05
                if (x * 5 + y * 3 + f * 7) % 13 == 0 and t < 0.6:
                    lv -= 0.25  # yırtık dil
                if lv < 0.08:
                    continue
                px[x, y] = pick(FIRE, lv, rnd, 0.5) + (255,)
        # Kopan alev parçacıkları.
        for _ in range(3):
            x, y = rnd.randrange(3, 13), rnd.randrange(0, 12)
            if px[x, y][3] == 0:
                px[x, y] = FIRE[3 + rnd.randrange(3)] + (255,)
        frames.append(img)
    return strip_frames(frames)


def make_kivilcim(rnd):
    """Elektrik arkı (3 kare × 16×14): kırık zikzak; dış hale mor-lacivert, çekirdek beyaz-mavi."""
    frames = []
    for f in range(3):
        img = Image.new("RGBA", (16, 14), (0, 0, 0, 0))
        px = img.load()
        pts = [(rnd.randrange(2, 6), 13)]
        while pts[-1][1] > 1:
            x, y = pts[-1]
            pts.append((min(14, max(1, x + rnd.choice((-2, -1, 1, 2, 2)))), y - rnd.randrange(2, 4)))
        path = []
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for i in range(n + 1):
                path.append((round(x0 + (x1 - x0) * i / n), max(0, round(y0 + (y1 - y0) * i / n))))
        for x, y in path:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < 16 and 0 <= ny < 14 and px[nx, ny][3] == 0:
                    px[nx, ny] = ARC[1] + (200,)
        for i, (x, y) in enumerate(path):
            px[x, y] = (ARC[4] if i % 3 else ARC[3]) + (255,)
        # Dal ve sıçrayan noktalar.
        for _ in range(4):
            x, y = rnd.randrange(16), rnd.randrange(14)
            if px[x, y][3] == 0:
                px[x, y] = ARC[2 + rnd.randrange(2)] + (255,)
        frames.append(img)
    return strip_frames(frames)


def make_patlama(rnd):
    """Patlama (6 kare × 40×40): beyaz-krem parlama → turuncu ateş topu (alt-sağı bordo-mor
    gölgede) → içi sönen kor → mor-gri duman halkası. Düz renk yok: her halka titreşimli."""
    frames = []
    radii = [6, 11, 16, 18, 17, 18]
    for f in range(6):
        img = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
        px = img.load()
        r = radii[f]
        for y in range(40):
            for x in range(40):
                dx, dy = x - 19.5, y - 19.5
                ang = math.atan2(dy, dx)
                rr = r + (math.sin(ang * 3 + f) * 0.9 + math.sin(ang * 5 + 2.1 + f * 0.7) * 0.8
                           + math.sin(ang * 11 + f * 2.3) * 0.5) + (rnd.random() - 0.5) * 1.4
                d = math.hypot(dx, dy) / rr
                if d > 1.0:
                    continue
                shade = (-dx - dy) / (rr * 1.6)  # sol üst ışıklı, sağ alt gölgede
                if f <= 2:
                    lv = (1.0 - d) * 0.9 + 0.3 - f * 0.08 + shade * 0.25
                    c = pick(FIRE, lv, rnd, 0.6)
                elif f == 3:
                    if d < 0.45:
                        c = pick(FIRE, 0.45 + (rnd.random() * 0.15), rnd, 0.4)
                    elif d < 0.75:
                        c = pick(FIRE, 0.7 + shade * 0.2, rnd, 0.5)
                    else:
                        c = pick(SMOKE, 0.5 + shade * 0.4, rnd, 0.6)
                elif f == 4:
                    if d < 0.55:
                        c = pick(FIRE, 0.18 + (1 - d) * 0.25, rnd, 0.6)
                    else:
                        c = pick(SMOKE, 0.45 + shade * 0.5, rnd, 0.6)
                else:
                    if d < 0.62 or rnd.random() < 0.25:
                        continue
                    c = pick(SMOKE, 0.4 + shade * 0.5, rnd, 0.6)
                a = 255 if f < 5 else 210
                px[x, y] = c + (a,)
        if f >= 1:
            # Uçuşan kıvılcım parçaları.
            for _ in range(6 + f * 2):
                ang = rnd.random() * math.tau
                dd = r + 1 + rnd.random() * 3
                x, y = int(19.5 + math.cos(ang) * dd), int(19.5 + math.sin(ang) * dd)
                if 0 <= x < 40 and 0 <= y < 40 and px[x, y][3] == 0:
                    px[x, y] = (FIRE[5 + rnd.randrange(3)] if f < 4 else SMOKE[3]) + (255,)
        frames.append(img)
    return strip_frames(frames)


def strip_frames(frames):
    w, h = frames[0].size
    out = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        out.paste(f, (i * w, 0))
    return out


BRICK = [(20, 10, 22), (40, 18, 28), (62, 28, 32), (84, 38, 36), (106, 52, 42),
         (128, 68, 50), (152, 90, 62), (182, 122, 82)]
PLASTER = [(30, 22, 32), (56, 44, 50), (84, 70, 70), (112, 96, 88), (140, 122, 104),
           (166, 148, 122), (190, 172, 140), (214, 198, 160)]
WARM_GLASS = [(62, 20, 28), (120, 52, 32), (176, 92, 40), (218, 140, 58), (240, 190, 100),
              (252, 230, 160)]


def make_tugla(rnd):
    """Fabrika tuğlası (16×16, iki yönde döşenir): şaşırtmalı 4 sıra; her tuğlanın üst
    kenarı fener ışığında, alt kenarı mor gölgede; derz koyu mor; yer yer is ve kırık."""
    n = 16
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = img.load()
    soot = {(rnd.randrange(4), rnd.randrange(2)) for _ in range(2)}
    for y in range(n):
        row, ly = y // 4, y % 4
        off = 4 if row % 2 else 0
        for x in range(n):
            lx = (x + off) % 8
            bi = ((x + off) // 8 % 2, row)
            if ly == 3 or lx == 7:
                px[x, y] = pick(BRICK, 0.05, rnd, 0.3) + (255,)  # derz
                continue
            lv = {0: 0.5, 1: 0.36, 2: 0.24}[ly]
            lv += ((bi[0] * 7 + row * 3) % 5 - 2) * 0.04  # tuğla başına ton farkı
            if lx == 0:
                lv += 0.08
            if lx == 6:
                lv -= 0.1
            if (bi[0] * 2 + row % 2, row // 2) in soot:
                lv -= 0.18  # is lekesi
            px[x, y] = pick(BRICK, lv, rnd, 0.5) + (255,)
    # Kırık köşeler.
    for x, y in ((5, 4), (12, 9), (2, 13)):
        px[x, y] = BRICK[1] + (255,)
    return img


def make_sivali_tugla(rnd):
    """Sıvası dökülmüş yama (24×14): düzensiz kenarlı kireç kırığı, içinde tuğla, alt
    kenarında sıva kalınlığı ışık yakalar, üst iç kenar gölgede."""
    w, h = 24, 14
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    bricks = make_tugla(random.Random(rnd.random()))
    bp = bricks.load()
    for y in range(h):
        for x in range(w):
            nx, ny = (x - 11.5) / 12.0, (y - 6.5) / 7.0
            r = nx * nx + ny * ny + math.sin(x * 1.3 + y * 0.7) * 0.12 + (rnd.random() - 0.5) * 0.1
            if r > 1.0:
                continue
            if r > 0.72:
                # Sıva kırık kenarı: altta/sağda kalınlık ışıkta, üstte gölgede.
                c = pick(PLASTER, 0.75 if ny > 0 else 0.3, rnd, 0.3)
            else:
                c = bp[x % 16, y % 16][:3]
                if ny < -0.4:
                    c = mix(c, (20, 10, 22), 0.35)  # üst iç kenar gölgesi
            px[x, y] = c + (255,)
    return img


def make_ic_duvar(rnd):
    """Kireç sıvalı iç duvar (48×32, döşenir; oyunda koyu tonlanır): bulutlu sıva ve
    yumuşak rutubet lekesi. Keskin çatlak/kabarma yok: 144 ekran pikselinde bir tekrar
    edip desen gibi okunuyordu (çatlak hissini sıvası dökülmüş yamalar verir)."""
    w, h = 48, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            # Periyodik bulut: döşeme dikişinde süreksizlik olmasın.
            cloud = (math.sin(x / w * math.tau * 2 + y / h * math.tau)
                     + math.sin(x / w * math.tau - y / h * math.tau * 2 + 1.3)) * 0.06
            lv = 0.58 + cloud + (rnd.random() - 0.5) * 0.08
            px[x, y] = pick(PLASTER, lv, rnd, 0.4) + (255,)
    # Rutubet lekesi (yumuşak koyu halka).
    cx, cy = 34, 20
    for y in range(h):
        for x in range(w):
            d = math.hypot((x - cx) / 7.0, (y - cy) / 5.0)
            if d < 1.0 and rnd.random() < 0.8:
                px[x, y] = pick(PLASTER, 0.46 + d * 0.1, rnd, 0.3) + (255,)
    return img


def make_hatil(rnd):
    """Ahşap hatıl (8×8; yatayda üst 4 satır, dikeyde sol 4–5 sütun kullanılır):
    koyu meşe, dağınık damar, sol üst kenar ışıkta."""
    n = 8
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = img.load()
    for y in range(n):
        for x in range(n):
            lv = 0.32 + (rnd.random() - 0.5) * 0.12
            if y == 0 or x == 0:
                lv = 0.62
            elif y == 3 or x == 4:
                lv = 0.14  # kirişin alt / dikmenin sağ kenarı gölgede
            if (x * 3 + y * 5) % 7 == 0 and 0 < x < 4 and 0 < y < 3:
                lv -= 0.12  # damar
            px[x, y] = pick(WOOD, lv, rnd, 0.3) + (255,)
    px[2, 1] = WOOD[1] + (255,)  # budak
    px[2, 6] = WOOD[1] + (255,)
    return img


def arch_window(w, h, rnd, glass):
    """Kemerli pencere ortak gövdesi: taş söve (sol üstte ışık, sağda ay), kemer, demir kayıt."""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = (w - 1) / 2.0
    r = w / 2.0
    for y in range(h):
        for x in range(w):
            if y < r:
                d = math.hypot(x - cx, y - r + 0.5) / r
                if d > 1.0:
                    continue
                frame = d > 0.72
            else:
                d = abs(x - cx) / r
                frame = d > 0.72 or y >= h - 3
            if frame:
                lv = 0.7 if (x < cx and y < h - 2) else 0.32
                if y >= h - 3:
                    lv = 0.8 if y == h - 3 else 0.25  # denizlik
                c = pick(STONE, lv, rnd, 0.4)
                if x > w - 3:
                    c = mix(c, MOON, 0.25)
            else:
                c = glass(x, y, d)
            px[x, y] = c + (255,)
    outline(img)
    return img


def make_ic_pencere(rnd):
    """İç mekân penceresi (18×26): taş söveli kemer, dışarıda gece gökyüzü + ay hâlesi,
    demir kayıt; camın sağ üstünde soğuk yansıma."""
    w, h = 18, 26

    def glass(x, y, d):
        if x == 8 or x == 9 or y == 13:
            return IRON[2]  # kayıt
        t = y / h
        c = pick(SEA, 0.7 - t * 0.6, rnd, 0.3)
        if math.hypot(x - 12, y - 7) < 2.2:
            c = mix(c, (200, 206, 220), 0.6)  # ay
        elif rnd.random() < 0.04 and y < 12:
            c = (200, 206, 220)  # yıldız
        if x == 11 and 15 <= y <= 19:
            c = mix(c, MOON, 0.6)  # yansıma
        return c
    return arch_window(w, h, rnd, glass)


def make_fabrika_pencere(rnd):
    """Fabrika penceresi (14×20): içeriden yanan sıcak ışık, demir kayıtlar, çatlak cam."""
    w, h = 14, 20

    def glass(x, y, d):
        if x in (4, 9) or y in (8, 13):
            return IRON[1]  # demir kayıt
        lv = 0.85 - d * 0.35 - (y / h) * 0.25 + (rnd.random() - 0.5) * 0.12
        return pick(WARM_GLASS, lv, rnd, 0.3)
    img = arch_window(w, h, rnd, glass)
    px = img.load()
    for x, y in ((2, 11), (3, 12)):
        px[x, y] = WARM_GLASS[1] + (255,)  # kırık cam
    return img


def make_cephe_pencereleri(rnd):
    """Tuğla cephe pencere çeşitleri (5 × 14×20 yan yana şerit): 0 yanan, 1 karanlık
    (sağ üstte ay yansıması), 2 kapalı ahşap kepenk (boya kalkmış), 3 kırık cam üstüne
    çakılmış tahta, 4 yanan + denizlikte sardunya saksısı. Aynı pencerenin cephede
    ızgara gibi tekrarını kırar; söve aynı kemer gövdesi (arch_window)."""
    w, h = 14, 20
    strip = Image.new("RGBA", (w * 5, h), (0, 0, 0, 0))

    def lit(x, y, d):
        if x in (4, 9) or y in (8, 13):
            return IRON[1]
        lv = 0.85 - d * 0.35 - (y / h) * 0.25 + (rnd.random() - 0.5) * 0.12
        return pick(WARM_GLASS, lv, rnd, 0.3)

    def dark(x, y, d):
        if x in (4, 9) or y in (8, 13):
            return IRON[1]
        c = pick(SEA, 0.28 - (y / h) * 0.22, rnd, 0.3)
        if x == 10 and 2 <= y <= 6 or x == 11 and 3 <= y <= 5:
            c = mix(c, MOON, 0.55)  # ay yansıması
        return mix(c, (20, 10, 22), 0.35)

    def shutter(x, y, d):
        # İki kanat, yatay panjur çıtaları; sol kanat fener ışığında.
        if x == 6 or x == 7:
            return WOOD[0]  # kanat arası
        if y % 3 == 0:
            return WOOD[1]  # çıta gölgesi
        lv = (0.5 if x < 6 else 0.3) - (y / h) * 0.15
        if (x * 7 + y * 3) % 11 == 0:
            lv -= 0.15  # damar
        c = pick(WOOD, lv, rnd, 0.4)
        # Eski yeşil boyanın kalıntısı (kalkmış, yer yer).
        if (x + y * 2) % 5 < 2 and rnd.random() < 0.55:
            c = mix(c, pick(OLIVE, lv + 0.1, rnd, 0.3), 0.7)
        return c

    def boarded(x, y, d):
        c = dark(x, y, d)
        if x in (4, 9) and not (5 <= y <= 15):
            return IRON[1]
        # Çapraz iki tahta + yatay bir tahta.
        if abs((x - 1) - (y - 4) * 0.75) < 1.4 and 4 <= y <= 17:
            return pick(WOOD, 0.66 - y * 0.02, rnd, 0.3)
        if 11 <= y <= 12:
            return pick(WOOD, 0.5 if y == 11 else 0.24, rnd, 0.3)
        if abs((12 - x) - (y - 3) * 0.75) < 1.2 and 3 <= y <= 10:
            return pick(WOOD, 0.4, rnd, 0.3)  # arkadaki tahta gölgede
        return c

    variants = [lit, dark, shutter, boarded, lit]
    for i, glass in enumerate(variants):
        win = arch_window(w, h, rnd, glass)
        wp = win.load()
        if i == 1:
            for x, y in ((3, 12), (2, 13)):
                wp[x, y] = SEA[0] + (255,)
        if i == 3:
            # Çivi başları ve kırık cam kenarı.
            for x, y in ((2, 6), (10, 10), (3, 10)):
                wp[x, y] = IRON[6] + (255,)
            for x, y in ((10, 15), (11, 14), (10, 16)):
                wp[x, y] = (200, 206, 220, 255)
        if i == 4:
            # Denizlikte toprak saksı + sardunya (kırmızı çiçek, koyu yaprak).
            for y in range(13, 17):
                for x in range(3, 11):
                    lv = 0.55 - (x - 3) * 0.05 if y > 13 else 0.75
                    if y == 16:
                        lv = 0.2  # saksı tabanı gölgede
                    wp[x, y] = pick(ORANGE, lv, rnd, 0.3) + (255,)
            for y in range(9, 13):
                for x in range(2, 12):
                    if rnd.random() < 0.85 - abs(x - 6.5) * 0.08:
                        wp[x, y] = pick(LEAF, 0.55 - (y - 9) * 0.1 + (0.15 if x < 6 else 0.0), rnd, 0.4) + (255,)
            for x, y in ((3, 9), (6, 8), (9, 9), (4, 10), (8, 8), (10, 10)):
                wp[x, y] = pick(RED, 0.75, rnd, 0.3) + (255,)
                if y + 1 < 13:
                    wp[x, y + 1] = RED[3] + (255,)
            for x in range(3, 11):
                wp[x, 13] = pick(ORANGE, 0.85, rnd, 0.2) + (255,)  # saksı ağzı ışıkta
            wp[2, 13], wp[11, 13] = OUTLINE, OUTLINE
        strip.paste(win, (i * w, 0))
    return strip


def make_saldiri_uyari(rnd):
    """Düşman saldırı uyarısı (2 × 10×18 şerit: 0 normal kehribar, 1 ağır kızıl): kalın,
    aşağı incelen ünlem gövdesi + nokta. Sol üstten fener ışığı (dar açık şerit), sağ
    kenarda ay kenar parlaması, gövde altı koyu; mor kontur. Düz renk yok: kenar ve
    orta tonlar rampa üzerinde titreşir, gövdede bir çatlak."""
    w, h = 10, 18
    strip = Image.new("RGBA", (w * 2, h), (0, 0, 0, 0))
    for i, ramp in enumerate((HAZARD + [(250, 226, 150)], RED + [(246, 170, 104)])):
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        px = img.load()
        for y in range(1, 12):
            half = 3.2 - (y - 1) * 0.16  # üstte geniş, alta incelir
            for x in range(w):
                u = (x - 4.5) / half
                if abs(u) > 1.0:
                    continue
                # Uyarı sahnede parlamalı: rampanın üst yarısı (karanlık tarz kuralının
                # bilinçli istisnası; ışık yine sol üstte, gölge sağ altta).
                lv = 0.38 + light(u) * 0.6 + (0.12 if y < 4 else 0.0) - (y - 1) * 0.02
                c = pick(ramp, lv, rnd, 0.5)
                if u > 0.6:
                    c = mix(c, MOON, 0.3)
                px[x, y] = c + (255,)
        for y in range(13, 17):
            for x in range(3, 7):
                u = (x - 4.5) / 1.6
                lv = 0.36 + light(u) * 0.6 + (0.1 if y == 13 else -0.04 * (y - 13))
                c = pick(ramp, lv, rnd, 0.4)
                if x == 6:
                    c = mix(c, MOON, 0.3)
                px[x, y] = c + (255,)
        px[3, 2] = ramp[-1] + (255,)  # parlama
        px[4, 7] = ramp[1] + (255,)  # çatlak
        px[5, 8] = ramp[1] + (255,)
        outline(img)
        strip.paste(img, (i * w, 0))
    return strip


def make_dukkan(rnd):
    """Mahalle dükkânı (40×32, tuğla cephenin zemin katına): üstte ahşap tabela (pirinç
    harf lekeleri, okunur yazı yok), altında kırmızı-krem çizgili tente (kumaş kıvrımı,
    sarkan saçak), altta yarıya kadar inmiş oluklu demir kepenk (pas akıntısı) ve
    altından sızan sıcak dükkân ışığı + vitrin. Satır 14–31 (kepenk + ışık) tek başına
    fabrika yükleme kapısı olarak da kullanılır."""
    w, h = 40, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    # Tabela (satır 0–5).
    for y in range(0, 6):
        for x in range(4, 36):
            lv = 0.34 + (0.25 if y == 0 else 0.0) - (0.16 if y == 5 else 0.0) + (rnd.random() - 0.5) * 0.08
            c = pick(WOOD, lv, rnd, 0.3)
            if 1 <= y <= 4 and 7 <= x <= 32 and (x * 3 + y) % 4 != 0 and (x // 3) % 3 != 2:
                c = pick(BRASS, 0.55 + (0.2 if y == 1 else 0.0) - (x - 7) * 0.008, rnd, 0.3)  # harf lekeleri
            if x > 33:
                c = mix(c, MOON, 0.25)
            px[x, y] = c + (255,)
    # Tente (satır 6–13): yukarıdan öne eğim, 4 px çizgi, alt saçak dalgalı.
    for y in range(6, 14):
        for x in range(0, w):
            if y == 13 and (x % 4 == 3):
                continue  # saçak dişi
            stripe = (x // 4) % 2 == 0
            ramp = RED if stripe else CREAM
            lv = 0.3 + (y - 6) * 0.07 - (x / w) * 0.18  # öne doğru ışığa açılır, sağa kararır
            if (x % 4) == 0:
                lv += 0.08  # kıvrım sırtı
            if y == 12:
                lv -= 0.15  # saçak gölgesi
            c = pick(ramp, lv, rnd, 0.4)
            if x >= w - 2:
                c = mix(c, MOON, 0.3)
            px[x, y] = c + (255,)
    # Kepenk kasası + oluklu kepenk (satır 14–24), ışık aralığı (25–27), vitrin altı (28–31).
    for y in range(14, h):
        for x in range(2, w - 2):
            if x in (2, 3) or x in (w - 4, w - 3):
                lv = 0.5 if x == 2 else 0.22  # demir kasa
                c = pick(IRON, lv, rnd, 0.3)
            elif y <= 24:
                lv = 0.32 + (0.2 if y % 2 == 0 else -0.06) - (y - 14) * 0.012 - (x / w) * 0.1
                c = pick(STEEL, lv, rnd, 0.35)
                for rx, ry, rl in ((9, 15, 4), (22, 18, 3), (31, 15, 6)):
                    if x == rx and ry <= y < ry + rl:
                        c = mix(c, RUST[2 if y < ry + rl - 1 else 1], 0.55)  # perçinden pas akıntısı
                if y == 24:
                    c = IRON[2]  # kepenk alt çıtası
            elif y <= 27:
                lv = 0.75 - (y - 25) * 0.12 + (rnd.random() - 0.5) * 0.1
                c = pick(WARM_GLASS, lv, rnd, 0.3)  # içeriden sızan ışık
                if (x // 5) % 2 == 0 and y == 27:
                    c = WARM_GLASS[1]  # raf/kasa gölgeleri
            else:
                lv = 0.3 if y == 28 else 0.16
                c = pick(STONE, lv, rnd, 0.3)  # eşik taşı
                if y == 28 and x < 20:
                    c = mix(c, WARM_GLASS[3], 0.35)  # eşiğe vuran ışık
            px[x, y] = c + (255,)
    outline(img)
    return img


def make_kat_silmesi(rnd):
    """Kat silmesi (16×6, yatay döşenir): taş korniş; üst yüz fener ışığında, altta
    çıkıntının düşürdüğü mor gölge ve tuğlaya inen is akıntısı."""
    w, h = 16, 6
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            lv = {0: 0.78, 1: 0.6, 2: 0.46, 3: 0.36, 4: 0.18, 5: 0.06}[y]
            if x % 8 == 7 and 1 <= y <= 3:
                lv = 0.12  # taş blok derzi
            if y == 2 and (x * 5) % 13 == 0:
                lv -= 0.12  # aşınma
            px[x, y] = pick(STONE, lv, rnd, 0.35) + (255,)
    for x in (3, 12):
        px[x, 5] = (20, 10, 22, 200)  # is akıntısı başlangıcı
    return img


def bx_seed(x, y):
    return x * 0.7 + y * 1.3


def make_tavan(rnd):
    """Mağara/sarnıç tavanı (48×30): üst 20 satır iki yönde döşenen kaya dolgu (yuvarlak
    taş kütleleri, alt kenarları gölgede), alt 10 satır sarkıtlı şerit."""
    w, h = 48, 30
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    blobs = []
    # Çok sayıda, farklı boyda kütle: 48 piksellik döşeme tekrarı ızgara gibi okunmasın.
    for _ in range(24):
        blobs.append((rnd.uniform(0, w), rnd.uniform(0, 20), rnd.uniform(3, 9), rnd.uniform(2.5, 5)))
    for y in range(20):
        for x in range(w):
            best, by = 9.0, 0.0
            for bx, byc, rx, ry in blobs:
                for ox in (-w, 0, w):
                    for oy in (-20, 0, 20):
                        d = ((x - bx - ox) / rx) ** 2 + ((y - byc - oy) / ry) ** 2
                        if d < best:
                            best, by = d, (y - byc - oy) / ry
            if best > 1.15:
                c = pick(STONE, 0.1, rnd, 0.3)  # kütleler arası derin çatlak
            else:
                lv = 0.42 - by * 0.16 - best * 0.1 + math.sin(bx_seed(x, y)) * 0.04
                c = pick(STONE, lv, rnd, 0.5)
            px[x, y] = c + (255,)
    # Sarkıt şeridi: kalın dolgu, aşağı inen sivri sarkıtlar, uçlarda nem parıltısı.
    tips = [(x, rnd.randrange(6, 11)) for x in range(3, w, 6)]
    for y in range(20, h):
        for x in range(w):
            on = y < 22
            side = 0.0
            for tx, tl in tips:
                half = 3.0 * max(0.0, 1 - (y - 20) / max(tl, 1)) ** 0.8
                if abs(x - tx) <= half and y < 20 + tl:
                    on = True
                    side = 0.14 if x < tx else (0.02 if x == tx else -0.12)
            if on:
                lv = 0.36 - (y - 20) * 0.02 + side
                px[x, y] = pick(STONE, lv, rnd, 0.4) + (255,)
    for tx, tl in tips:
        if 20 + tl - 1 < h:
            px[tx, 20 + tl - 1] = mix(STONE[5], MOON, 0.5) + (255,)
    # Kontur yalnız sarkıtların alt hattında.
    edge = []
    for y in range(20, h):
        for x in range(w):
            if px[x, y][3] and (y == h - 1 or px[x, y + 1][3] == 0):
                edge.append((x, y))
    for x, y in edge:
        if px[x, y][:3] != mix(STONE[5], MOON, 0.5):
            px[x, y] = OUTLINE
    return img


def make_han_kapisi(rnd):
    """Han kapısı (86×100): kesme taş cephe, kırmızı-krem almaşık taşlı (ablak) yuvarlak
    kemer, çift kanatlı ahşap kapı (çivili demir lamalar, pirinç tokmak), üstte kiremit
    saçak. Işık sol üstten; kemerin içi derin gölge, eşikte AO."""
    w, h = 86, 100
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    roof_h = 7
    cx = (w - 1) / 2.0
    r_out, r_in = 34.0, 27.0
    spring = 46  # kemer üzengi satırı
    for y in range(h):
        for x in range(w):
            if y < roof_h:
                # Kiremit saçak: oluklu sıra, alt kenarda koyu gölge şeridi.
                lv = 0.75 - y * 0.08 + (0.12 if x % 6 < 3 else -0.08)
                c = pick(RED, lv, rnd, 0.4)
                if y == roof_h - 1:
                    c = RED[0]
                px[x, y] = c + (255,)
                continue
            dy = y - spring
            d = math.hypot(x - cx, dy) if dy < 0 else abs(x - cx)
            if d <= r_in:
                continue  # kapı boşluğu: aşağıda doldurulur
            if d <= r_out and dy < 0:
                # Almaşık kemer taşları: açıya göre dilim, kırmızı/krem sırayla.
                ang = math.atan2(-dy, x - cx)
                k = int(ang / math.pi * 11)
                ramp = RED if k % 2 else CREAM
                lv = 0.62 - (d - r_in) / (r_out - r_in) * 0.25
                if x > cx:
                    lv -= 0.15
                if abs((ang / math.pi * 11) - round(ang / math.pi * 11)) < 0.08:
                    c = OUTLINE[:3]  # taş derzi
                else:
                    c = pick(ramp, lv, rnd, 0.4)
                px[x, y] = c + (255,)
                continue
            if abs(x - cx) <= r_out and dy >= 0 and abs(x - cx) > r_in:
                # Söve ayakları.
                lv = 0.6 if x < cx else 0.3
                if (y - spring) % 9 == 0:
                    c = OUTLINE[:3]
                else:
                    c = pick(STONE, lv, rnd, 0.4)
                px[x, y] = c + (255,)
                continue
            # Kesme taş cephe: 9 satırlık şaşırtmalı sıralar.
            row, ly = (y - roof_h) // 9, (y - roof_h) % 9
            lx = (x + (7 if row % 2 else 0)) % 14
            if ly == 8 or lx == 13:
                c = STONE[1]
            else:
                lv = 0.42 + (0.12 if ly == 0 or lx == 0 else 0.0) - (0.1 if ly == 7 else 0.0)
                lv -= (y / h) * 0.12
                c = pick(STONE, lv, rnd, 0.5)
                if x > w - 6:
                    c = mix(c, MOON, 0.15)
            px[x, y] = c + (255,)
    # Kapı kanatları: dikey tahta, iki yatay demir lama, çiviler; ortada derz, tokmaklar.
    for y in range(roof_h, h):
        for x in range(w):
            if px[x, y][3]:
                continue
            dy = y - spring
            d = math.hypot(x - cx, dy) if dy < 0 else abs(x - cx)
            if d > r_in:
                continue
            u = (x - cx) / r_in
            plank = int(x - cx + 100) % 5
            lv = 0.36 + (0.12 if plank == 0 else -0.06 if plank == 4 else 0.0) - abs(u) * 0.1
            if d > r_in - 1.5 and dy < 0:
                lv -= 0.25  # kemerin iç kenarı gölgede
            if y < spring - 18:
                lv -= 0.15  # tepe gölgesi
            c = pick(WOOD, lv, rnd, 0.5)
            if abs(x - cx) < 0.6:
                c = OUTLINE[:3]
            if y in (spring + 2, spring + 3, h - 14, h - 13):
                c = pick(IRON, 0.35 if y % 2 == 0 else 0.15, rnd, 0.2)
                if (x - 3) % 6 == 0 and y in (spring + 2, h - 14):
                    c = IRON[6]  # çivi başı
            if y >= h - 3:
                c = mix(c, (12, 7, 18), 0.5)  # eşik AO
            px[x, y] = c + (255,)
    # Pirinç tokmaklar.
    ky = spring + 14
    for kx in (int(cx) - 4, int(cx) + 5):
        for ox, oy, lv in ((0, -1, 0.8), (-1, 0, 0.7), (1, 0, 0.35), (0, 1, 0.25)):
            px[kx + ox, ky + oy] = pick(BRASS, lv, rnd, 0.1) + (255,)
        px[kx, ky] = OUTLINE
    # Eşik taşı.
    for x in range(int(cx - r_out), int(cx + r_out) + 1):
        px[x, h - 2] = pick(STONE, 0.7 if x < cx else 0.45, rnd, 0.2) + (255,)
        px[x, h - 1] = STONE[1] + (255,)
    return img


STEEL = [(10, 8, 16), (24, 20, 32), (38, 34, 48), (54, 50, 64), (72, 68, 80), (96, 90, 98),
         (128, 118, 116), (170, 152, 130), (214, 190, 150)]
WATER = [(8, 14, 26), (12, 22, 38), (16, 32, 50), (22, 44, 62), (30, 58, 74), (44, 78, 88),
         (70, 108, 110), (120, 150, 140), (186, 196, 170)]


def make_pres(rnd):
    """Pres başlığı (34×22): perçinli dövme çelik blok, sarı-siyah ikaz bandı, altta
    dişli ezme yüzü. Üst kenar fener ışığında, sağ kenarda ay, alt dişler gölgede."""
    w, h = 34, 22
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h - 3):
        for x in range(w):
            u = (x - 16.5) / 17.0
            lv = 0.5 - y * 0.018 - max(0.0, u) * 0.18
            if y <= 1:
                lv = 0.82 if y == 0 else 0.62  # üst pah
            if x <= 1:
                lv += 0.12
            c = pick(STEEL, lv, rnd, 0.4)
            if 12 <= y <= 15:
                stripe = (x + y) // 3 % 2 == 0  # ikaz bandı
                c = pick(HAZARD, 0.75 - (y - 12) * 0.12, rnd, 0.3) if stripe else pick(STEEL, 0.1, rnd, 0.2)
                if rnd.random() < 0.12:
                    c = pick(RUST, 0.5, rnd, 0.3)  # boya kalkması
            if y in (11, 16):
                c = STEEL[1]
            if x >= w - 3:
                c = mix(c, MOON, 0.25)
            if y > 2 and rnd.random() < 0.05:
                c = pick(RUST, 0.4, rnd, 0.3)
            px[x, y] = c + (255,)
    # Perçinler ve yağ akıntısı.
    for x in (4, 12, 21, 29):
        px[x, 4] = STEEL[7] + (255,)
        px[x + 1, 5] = STEEL[1] + (255,)
    for y in range(6, 11):
        px[8, y] = mix(px[8, y][:3], (16, 12, 20), 0.5) + (255,)
    # Ezme dişleri.
    for y in range(h - 3, h):
        for x in range(w):
            k = x % 4
            if (y - (h - 3)) > (1 if k in (1, 2) else 0) + (0 if k in (1, 2) else -1) + 1:
                continue
            if y == h - 1 and k not in (1, 2):
                continue
            px[x, y] = pick(STEEL, 0.55 if k == 1 else 0.22, rnd, 0.2) + (255,)
    outline(img)
    return img


def make_pres_kol(rnd):
    """Pres pistonu (8×16, dikey döşenir): parlatılmış çelik silindir, ince yağ izi."""
    w, h = 8, 16
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(1, w - 1):
            u = (x - 3.5) / 3.0
            lv = light(u) * 0.95 + 0.05
            c = pick(STEEL, lv, rnd, 0.2)
            if u > 0.6:
                c = mix(c, MOON, 0.35)
            if x == 4 and y in (5, 6, 7, 12):
                c = mix(c, (30, 22, 20), 0.5)  # yağ izi
            px[x, y] = c + (255,)
    for y in (0, 1):
        for x in range(1, w - 1):
            px[x, y] = mix(px[x, y][:3], STEEL[2], 0.4) + (255,)  # bilezik gölgesi
    outline_sides(img)
    return img


def make_ray(rnd):
    """Ray (16×6, yatay döşenir; üst 2 satır korniş olarak da kullanılır): parlak çelik
    mantar, gövde, altta katranlı ahşap travers ve çivisi."""
    w, h = 16, 6
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for x in range(w):
        px[x, 0] = mix(pick(STEEL, 0.9, rnd, 0.2), (240, 200, 140), 0.25) + (255,)  # ışık
        px[x, 1] = pick(STEEL, 0.5, rnd, 0.3) + (255,)
        px[x, 2] = pick(STEEL, 0.15, rnd, 0.2) + (255,)
    for x in range(2, 14):
        for y in (3, 4, 5):
            lv = {3: 0.45, 4: 0.28, 5: 0.12}[y]
            c = pick(WOOD, lv, rnd, 0.5)
            if x in (2, 13) and y > 3:
                c = OUTLINE[:3]
            px[x, y] = c + (255,)
    for x in (4, 11):
        px[x, 3] = STEEL[6] + (255,)  # travers çivisi
    for x in range(2, 14):
        px[x, 5] = OUTLINE
    return img


def make_su_govde(rnd):
    """Su gövdesi (32×16, iki yönde döşenir): derin bulanık su; periyodik dalgalı ışık
    şeritleri (dikişsiz) ve dağınık askıda tortu."""
    w, h = 32, 16
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            wave = math.sin((x / w) * math.tau * 2 + (y / h) * math.tau) * 0.5 + \
                math.sin((x / w) * math.tau - (y / h) * math.tau * 2 + 1.0) * 0.5
            lv = 0.24 + wave * 0.06
            if (x + y * 3) % 7 == 0:
                lv -= 0.05
            px[x, y] = pick(WATER, lv, rnd, 0.3) + (255,)
    for _ in range(6):
        x, y = rnd.randrange(w), rnd.randrange(h)
        px[x, y] = WATER[4] + (255,)  # tortu
    return img


def make_su_yuzey(rnd):
    """Su yüzeyi (3 kare × 32×12, yatay döşenir): dalga sırtında köpük ve sıcak fener
    yansıması, altında gövdeye karışan koyu su. Kareler dalgayı kaydırır."""
    frames = []
    for f in range(3):
        img = Image.new("RGBA", (32, 12), (0, 0, 0, 0))
        px = img.load()
        ph = f / 3.0 * math.tau
        for x in range(32):
            crest = 2.5 + math.sin(x / 32 * math.tau * 2 + ph) * 1.5 + math.sin(x / 32 * math.tau * 3 - ph) * 0.6
            for y in range(12):
                if y < crest:
                    continue
                dy = y - crest
                if dy < 1:
                    c = WATER[8] if math.sin(x * 0.9 + ph) > 0.2 else WATER[7]  # köpük
                elif dy < 2:
                    c = WATER[6]
                else:
                    lv = 0.55 - dy * 0.05
                    c = pick(WATER, lv, rnd, 0.3)
                    if (y == 6 and (x + f * 4) % 13 < 3) or (y == 9 and (x + 7 - f * 3) % 16 < 2):
                        c = mix(c, (220, 150, 80), 0.4)  # fener yansıması: yatay kısa parıltı
                px[x, y] = c + (255,)
        frames.append(img)
    return strip_frames(frames)


def make_anten(rnd):
    """Radyo anteni (24×96): incelen çelik kafes direk, çapraz örgü, iki ara platform,
    tepede kırmızı ikaz lambası. Sol bacak ışıkta, sağ bacak ay kenarında."""
    w, h = 24, 96
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    cx = 11.5
    top = 6

    def half_at(y):
        return 1.5 + (y - top) / (h - top) * 9.0

    def put(x, y, c):
        if 0 <= x < w and 0 <= y < h:
            px[x, y] = c + (255,)
    for y in range(top, h):
        hw_ = half_at(y)
        lx, rx = int(round(cx - hw_)), int(round(cx + hw_))
        put(lx, y, pick(STEEL, 0.7, rnd, 0.2))
        put(rx, y, mix(pick(STEEL, 0.35, rnd, 0.2), MOON, 0.35))
        # Çapraz örgü: her bölmede X.
        seg = 8
        t = (y - top) % seg / seg
        for xx in (int(round(lx + (rx - lx) * t)), int(round(rx - (rx - lx) * t))):
            put(xx, y, pick(STEEL, 0.3, rnd, 0.3))
        if (y - top) % seg == 0:
            for xx in range(lx, rx + 1):
                put(xx, y, pick(STEEL, 0.45, rnd, 0.2))
    for py in (34, 62):
        hw_ = half_at(py) + 2
        for xx in range(int(cx - hw_), int(cx + hw_) + 1):
            put(xx, py, pick(STEEL, 0.6, rnd, 0.2))
            put(xx, py + 1, STEEL[1])
    # Tepe direği ve ikaz lambası (hâle).
    for y in range(1, top + 1):
        put(11, y, STEEL[5])
        put(12, y, STEEL[3])
    for dx, dy, c in ((0, 0, RED[7]), (1, 0, RED[5]), (0, 1, RED[4]), (1, 1, RED[3])):
        put(11 + dx, dy, c)
    outline(img)
    px[11, 0] = (255, 190, 150, 255)
    return img


def make_kule_ayak(rnd):
    """Gözetleme kulesi ayağı (40×20, dikey döşenir): iki perçinli çelik bacak + X kuşak."""
    w, h = 40, 20
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            if x in (1, 2, 3) or x in (36, 37, 38):
                u = -0.6 if x in (1, 36) else (0.0 if x in (2, 37) else 0.7)
                c = pick(STEEL, light(u) * 0.75 + 0.05, rnd, 0.2)
                if x >= 36:
                    c = mix(c, MOON, 0.2)
                if y in (0, 19) and x in (2, 37):
                    c = STEEL[7]  # perçin
                px[x, y] = c + (255,)
    for i in range(h):
        t = i / (h - 1)
        for xx in (int(4 + t * 31), int(35 - t * 31)):
            for d in (0, 1):
                if 4 <= xx + d <= 35:
                    px[xx + d, i] = pick(STEEL, 0.4 if d == 0 else 0.15, rnd, 0.2) + (255,)
    for x in range(4, 36):
        px[x, 0] = pick(STEEL, 0.55, rnd, 0.2) + (255,)
        px[x, 1] = STEEL[1] + (255,)
    outline_sides(img)
    return img


def make_kule_kulube(rnd):
    """Kule kulübesi (40×30): paslı kırmızı teneke çatı, dikey tahta duvar, içeriden
    yanan pencere, önde korkuluk; altında döşeme kirişi."""
    w, h = 40, 30
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            if y < 6:
                inset = max(0, 5 - y) // 2
                if x < inset or x >= w - inset:
                    continue
                lv = 0.75 - y * 0.08 + (0.1 if x % 4 == 0 else 0.0)
                c = pick(RED, lv, rnd, 0.4)
                if rnd.random() < 0.15:
                    c = pick(RUST, 0.5, rnd, 0.3)
                if y == 5:
                    c = RED[0]
            elif y < 25:
                if x < 2 or x >= w - 2:
                    continue
                plank = x % 4
                lv = 0.38 + (0.12 if plank == 0 else -0.08 if plank == 3 else 0.0) - (y - 6) * 0.008
                if y < 9:
                    lv -= 0.18  # saçak gölgesi
                c = pick(WOOD, lv, rnd, 0.5)
                if 9 <= y <= 16 and 8 <= x <= 31:
                    if x in (8, 31, 19, 20) or y in (9, 16, 12):
                        c = pick(WOOD, 0.2, rnd, 0.2)  # pencere kasası
                    else:
                        c = pick(WARM_GLASS, 0.8 - (y - 9) * 0.06, rnd, 0.3)
                if x >= w - 5:
                    c = mix(c, MOON, 0.2)
                if 19 <= y <= 24 and (y == 19 or x % 6 == 2):
                    c = pick(WOOD, 0.55, rnd, 0.3)  # korkuluk
            else:
                lv = 0.5 if y == 25 else 0.2
                c = pick(WOOD, lv, rnd, 0.3)
                if y >= 27 and x % 10 not in (1, 2, 3):
                    continue  # kiriş uçları
            px[x, y] = c + (255,)
    outline(img)
    return img


def make_ahsap_kat(rnd):
    """Ahşap kat döşemesi (32×8, yatay döşenir): üst yüz ışıkta, uç uca tahtalar ve
    çivileri, altta iki kiriş başı."""
    w, h = 32, 8
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(5):
        for x in range(w):
            lv = {0: 0.8, 1: 0.5, 2: 0.4, 3: 0.3, 4: 0.12}[y]
            if x % 16 == 15:
                lv = 0.08  # tahta eki
            c = pick(WOOD, lv, rnd, 0.5)
            px[x, y] = c + (255,)
    for x in (2, 13, 18, 29):
        px[x, 2] = IRON[5] + (255,)  # çivi
    for bx in (5, 21):
        for y in range(5, 8):
            for x in range(bx, bx + 5):
                px[x, y] = pick(WOOD, 0.35 if x == bx else 0.15, rnd, 0.3) + (255,)
            px[bx + 4, y] = OUTLINE
        for x in range(bx, bx + 5):
            px[x, 7] = OUTLINE
    for x in range(w):
        px[x, 4] = OUTLINE if not any(bx <= x < bx + 5 for bx in (5, 21)) else px[x, 4]
    return img


POLY = [(10, 10, 20), (20, 22, 36), (32, 36, 52), (46, 52, 68), (62, 70, 86), (82, 92, 106),
        (110, 118, 128), (150, 150, 146), (198, 186, 160)]


def riot_shield(rnd, broken):
    """Çevik kuvvet kalkanı (14×34): kavisli füme polikarbon, kauçuk kenar, üstte gözetleme
    camı, ortada kırmızı zabıta bandı, çizik ve kir. Işık sol üstten (dikey parlama
    şeridi), sağ kenarda ay. Kırık sürümde darbe noktasından yayılan çatlaklar, kopmuş
    sağ üst köşe ve sarkık bant."""
    w, h = 14, 34
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            corner = (x in (0, w - 1)) and (y in (0, h - 1))
            if corner:
                continue
            u = (x - 6.5) / 6.5
            lv = light(u) * 0.7 + 0.12 - y * 0.004
            c = pick(POLY, lv, rnd, 0.3)
            if x == 3 and 2 <= y <= h - 4:
                c = pick(POLY, 0.85 - y * 0.008, rnd, 0.1)  # kavis parlaması
            if 4 <= y <= 8 and 2 <= x <= w - 3:
                # Gözetleme camı: koyu, çapraz soğuk yansıma.
                c = pick(POLY, 0.12, rnd, 0.2)
                if x - 2 == y - 4 or x - 3 == y - 4:
                    c = mix(c, MOON, 0.55)
                if y == 4:
                    c = POLY[1]
            if 15 <= y <= 18:
                lv2 = {15: 0.8, 16: 0.6, 17: 0.45, 18: 0.25}[y] - max(0.0, u) * 0.2
                c = pick(RED, lv2, rnd, 0.3)
                if y == 15 and x % 3 == 0:
                    c = CREAM[3]  # yansıtıcı şerit
            if x >= w - 2:
                c = mix(c, MOON, 0.3)
            if x in (0, w - 1) or y in (0, h - 1):
                c = pick(IRON, 0.18 if x != 0 else 0.3, rnd, 0.2)  # kauçuk kenar
            if 20 <= y <= h - 3 and rnd.random() < 0.06:
                c = pick(POLY, lv + 0.2, rnd, 0.2)  # çizik
            if y >= h - 5 and 1 <= x <= w - 2 and rnd.random() < 0.4:
                c = mix(c, (60, 40, 34), 0.4)  # dipte çamur
            px[x, y] = c + (255,)
    if broken:
        # Kopmuş sağ üst köşe (tırtıklı).
        for y in range(0, 7):
            for x in range(w - 1 - max(0, 5 - y) - (y % 2), w):
                px[x, y] = (0, 0, 0, 0)
        # Darbe noktası ve yayılan çatlaklar: koyu çizgi + alt yanında ışık.
        ix, iy = 6, 22
        for dx, dy, n in ((1, -1, 7), (-1, -1, 5), (1, 1, 5), (-1, 1, 4), (0, -1, 6)):
            x, y = ix, iy
            for i in range(n):
                x += dx if i % 2 == 0 else 0
                y += dy
                if 1 <= x < w - 1 and 1 <= y < h - 1 and px[x, y][3]:
                    px[x, y] = POLY[0] + (255,)
                    if px[x + 1, y][3] and x + 1 < w - 1:
                        px[x + 1, y] = POLY[5] + (255,)
        px[ix, iy] = POLY[8] + (255,)
        # Bant ucu kopup sarkıyor.
        for y in range(18, 22):
            px[w - 3, y] = pick(RED, 0.5 - (y - 18) * 0.1, rnd, 0.2) + (255,)
    outline(img)
    return img


DUSK_CLOTH = [(14, 10, 22), (26, 22, 36), (40, 36, 52), (56, 52, 66), (76, 72, 84), (100, 94, 102)]


def _sancak_frame(rnd, active, phase):
    """Kontrol noktası sancağı karesi (30×82). Direk x=5, taş kaide 74–80, bez y=11'den.
    Pasif: direğe sarılı, iple bağlı soluk bez. Aktif: dalgalanan kırlangıç kuyruklu
    kırmızı sancak; kıvrımın ışığa bakan yüzü sıcak, çukuru bordo-mor; ay-yıldız krem,
    kıvrımla birlikte gölgelenir; altın saçak ve püskül."""
    w, h = 30, 82
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    pole_x = 5

    def put(x, y, c):
        if 0 <= x < w and 0 <= y < h:
            px[x, y] = c + (255,)
    # Taş kaide: üst pah ışıkta, sağ yüz ayda, dipte AO.
    for y in range(74, 81):
        for x in range(0, 13):
            if y == 74 and x in (0, 12):
                continue
            lv = 0.75 if y == 74 else (0.5 if y == 75 else 0.36 - (y - 76) * 0.05)
            c = pick(STONE, lv, rnd, 0.4)
            if x >= 11:
                c = mix(c, MOON, 0.25)
            if y == 80:
                c = STONE[1]
            put(x, y, c)
    # Ahşap direk: silindir ışığı, budak.
    for y in range(9, 74):
        for i, x in enumerate((pole_x - 1, pole_x, pole_x + 1)):
            lv = (0.82, 0.5, 0.2)[i] + (-0.12 if (y * 7) % 11 == 0 else 0.0)
            put(x, y, pick(WOOD, lv, rnd, 0.3))
    for x, lv in ((pole_x - 1, 0.8), (pole_x, 0.55), (pole_x + 1, 0.25)):
        put(x, 44, pick(BRASS, lv, rnd, 0.1))  # pirinç bilezik
        put(x, 73, pick(BRASS, lv - 0.1, rnd, 0.1))
    # Alem: pirinç top + hilal kolları.
    for y in range(3, 10):
        for x in range(pole_x - 3, pole_x + 4):
            d = math.hypot(x - pole_x, y - 6)
            if d <= 2.4:
                u = (x - pole_x) / 2.4
                put(x, y, pick(BRASS, light(u) * 0.9 + 0.1 - max(0, y - 6) * 0.08, rnd, 0.2))
    for (x, y) in [(pole_x - 2, 0), (pole_x - 3, 1), (pole_x - 3, 2), (pole_x - 2, 3)]:
        put(x, y, BRASS[3])
    for (x, y) in [(pole_x + 2, 0), (pole_x + 3, 1), (pole_x + 3, 2), (pole_x + 2, 3)]:
        put(x, y, BRASS[2])
    put(pole_x - 1, 5, BRASS[4])
    top, bh, bw = 11, 26, 22
    if not active:
        # Direğe sarılı soluk bez: kat kat sarım, aralarda gölge, iki ip bağı.
        for y in range(top, top + 34):
            width = 3 + int(round(1.5 * math.sin(y * 0.55))) + (y - top) // 12
            for k, x in enumerate(range(pole_x + 2, pole_x + 2 + width)):
                fold = math.sin(y * 0.9 + k * 0.6)
                lv = 0.45 + fold * 0.22 - k * 0.06
                c = pick(DUSK_CLOTH, lv, rnd, 0.3)
                if k == width - 1:
                    c = mix(c, MOON, 0.25)
                put(x, y, c)
        for ry in (top + 8, top + 22):
            for x in range(pole_x + 2, pole_x + 7):
                put(x, ry, pick(HEMP, 0.6 if x == pole_x + 2 else 0.35, rnd, 0.2))
    else:
        ph = phase * math.pi / 2
        crest = {}
        for col in range(bw):
            x = pole_x + 2 + col
            amp = 2.0 * (col / bw) + 0.3
            wave = int(round(math.sin(col * 0.42 - ph) * amp))
            slope = math.cos(col * 0.42 - ph)  # >0: kıvrım ışığa bakıyor
            y0 = top + wave
            crest[col] = (y0, slope)
            notch = max(0, col - (bw - 7))
            for y in range(y0, y0 + bh):
                rel = y - y0
                if notch and (bh // 2 - notch) < rel < (bh // 2 + notch):
                    continue
                lv = 0.64 + slope * 0.22 - rel * 0.005 - (0.1 if col == 0 else 0.0)
                c = pick(RED, lv, rnd, 0.35)
                if rel <= 1 or rel >= bh - 2:
                    c = pick(BRASS, (0.8 if rel in (0, bh - 2) else 0.45) + slope * 0.15, rnd, 0.2)
                if col >= bw - 3 and 1 < rel < bh - 2:
                    c = mix(c, MOON, 0.18)
                put(x, y, c)
        # Ay-yıldız: kıvrımla birlikte gölgelenen krem.
        mc = 7
        cx, cy = pole_x + 2 + mc, top + bh // 2 + int(round(math.sin(mc * 0.42 - ph)))
        sl = crest[mc][1]
        moon = CREAM[4] if sl > -0.3 else CREAM[3]
        moon_dark = CREAM[3] if sl > -0.3 else CREAM[2]
        for y in range(-4, 5):
            for x in range(-4, 5):
                if x * x + y * y <= 16 and (x - 1.6) ** 2 + y * y > 9:
                    put(cx + x, cy + y, moon if y < 1 else moon_dark)
        for (x, y) in [(5, -2), (3, -1), (4, -1), (5, -1), (6, -1), (7, -1), (4, 0), (5, 0), (6, 0), (4, 1), (6, 1)]:
            put(cx + x, cy + y, moon if y < 0 else moon_dark)
        # Püskül.
        for y in range(top + bh, top + bh + 4):
            put(pole_x + 2, y, BRASS[2] if y % 2 else BRASS[3])
        put(pole_x + 2, top + bh + 4, BRASS[4])
    outline(img)
    return img


def make_sancak(rnd):
    frames = [_sancak_frame(rnd, False, 0)] + [_sancak_frame(rnd, True, k) for k in range(4)]
    return strip_frames(frames)


def make_tufek_ikon(rnd):
    """Tüfek toplanabilir ikonu (48×48, tabanca/bıçak ikonlarıyla aynı yoğunluk): sol altta
    ceviz dipçik, çelik mekanizma, kavisli şarjör, ahşap el kundağı, ileri uzanan namlu.
    Şekil tüfeğin kendi ekseninde (s boyunca, t dik) tanımlanır ve çapraz rasterlenir;
    ekseninin üst yüzü (t<0) sol üstten gelen fener ışığına bakar."""
    n = 48
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    px = img.load()
    ox, oy = 3.0, 43.5
    ang = math.radians(-38)
    ca, sa = math.cos(ang), math.sin(ang)

    def part(s, t):
        """(malzeme, ışık) ya da None."""
        if 0 <= s < 14:
            half = 4.2 - s * 0.12
            if -half <= t <= half * 0.9:
                return WOOD, 0.62 - (t + half) / (2 * half) * 0.5 + (0.1 if s < 1.5 else 0.0)
        if 12 <= s < 16.5 and 1 <= t <= 8 - (s - 12) * 0.3:
            return WOOD, 0.3 - (t - 1) * 0.03  # tabanca kabzası
        if 14 <= s < 29 and -3.2 <= t <= 2.2:
            lv = 0.78 - (t + 3.2) / 5.4 * 0.6
            if abs(s - 21) < 0.6:
                lv -= 0.2  # gövde eki
            return STEEL, lv
        if 22 <= s - (t - 2) * 0.35 < 26 and 2 <= t <= 9:
            return STEEL, 0.32 - (t - 2) * 0.02  # kavisli şarjör
        if 29 <= s < 38 and -2.2 <= t <= 2.2:
            ridge = 0.12 if int(s) % 3 == 0 else 0.0
            return WOOD, 0.56 - (t + 2.2) / 4.4 * 0.45 - ridge
        if 38 <= s < 51 and -1.2 <= t <= 0.6:
            return STEEL, 0.85 if t < -0.4 else 0.4
        if 47.5 <= s < 49 and -3 <= t < -1.2:
            return STEEL, 0.5  # arpacık
        if 18 <= s < 21 and -5 <= t < -3.2:
            return STEEL, 0.55  # gez
        return None
    for y in range(n):
        for x in range(n):
            dx, dy = x + 0.5 - ox, y + 0.5 - oy
            # Eksen ölçeği: ikon kutusunu tabanca/bıçak gibi doldursun.
            s = (dx * ca + dy * sa) / 1.12
            t = (-dx * sa + dy * ca) / 1.55
            p = part(s, t)
            if p is None:
                continue
            ramp, lv = p
            c = pick(ramp, lv, rnd, 0.35)
            if ramp is WOOD and (int(s * 1.7 + t) % 5 == 0):
                c = pick(WOOD, lv - 0.15, rnd, 0.2)  # ceviz damarı
            px[x, y] = c + (255,)
    # Namlu ağzı parlaması ve mekanizma perçinleri (eksen üzerinde noktalar).
    for s, t, c in ((50.2, -0.6, STEEL[8]), (24.0, -1.0, BRASS[3]), (17.0, -1.2, STEEL[7]),
                    (2.0, -2.5, WOOD[8])):
        x = int(ox + s * 1.12 * ca - t * 1.55 * sa)
        y = int(oy + s * 1.12 * sa + t * 1.55 * ca)
        if px[x, y][3]:
            px[x, y] = c + (255,)
    outline(img)
    return img


SHARD = [(40, 30, 40), (92, 80, 84), (150, 138, 128), (200, 190, 172), (240, 232, 214)]


def make_catlak(rnd):
    """Hasar çatlağı (3 aşama × 12×16, kabın gövdesine bindirilir; oyunda 3x): koyu mor
    çatlak çizgisi, alt-sağ kenarında kırık yüzeyin yakaladığı sıcak ışık; son aşamada
    dallanma ve kopmuş parça çukuru. Aşamalar birikimli: önceki çatlak kalır, uzar."""
    w, h = 12, 16
    frames = []
    # Ana çatlak yolu (üstten aşağı zikzak) + dallar; aşama başına kaç adım çizileceği.
    main = [(5, 1), (6, 2), (6, 3), (5, 4), (5, 5), (6, 6), (7, 7), (7, 8), (6, 9), (6, 10),
            (5, 11), (5, 12), (4, 13), (4, 14)]
    branch1 = [(6, 6), (4, 7), (3, 8), (2, 8)]
    branch2 = [(6, 10), (8, 11), (9, 12), (10, 12)]
    branch3 = [(5, 4), (3, 3), (2, 2)]
    stages = [(main[:6], []), (main[:11], [branch1]), (main, [branch1, branch2, branch3])]
    for path, branches in stages:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        px = img.load()
        lines = [path] + branches
        for line in lines:
            for x, y in line:
                px[x, y] = OUTLINE[:3] + (235,)
        for line in lines:
            for x, y in line:
                if x + 1 < w and px[x + 1, y][3] == 0:
                    px[x + 1, y] = (206, 166, 106, 120)  # kırık kenar ışığı
        if len(branches) == 3:
            # Kopmuş parça çukuru: koyu iç, üst kenarı gölgede, alt kenarı ışıkta.
            for x, y, a in ((6, 7, 235), (7, 6, 235), (6, 8, 235), (8, 7, 200), (7, 9, 200)):
                px[x, y] = (34, 22, 37, a)
            px[8, 8] = (206, 166, 106, 140)
            px[7, 10] = (206, 166, 106, 140)
        frames.append(img)
    return strip_frames(frames)


def make_kiymik(rnd):
    """Kırılma kıymıkları (4 parça × 7×7): rastgele köşeli kırık parça, nötr açık rampada;
    oyunda malzeme rengiyle çarpılır (modulate), ışık/gölge malzemenin tonunda kalır.
    Işık sol üst yüzde, kontur koyu mor."""
    n = 7
    frames = []
    for f in range(4):
        img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
        px = img.load()
        base = rnd.random() * math.tau
        pts = []
        for k in range(5):
            an = base + k * math.tau / 5 + (rnd.random() - 0.5) * 0.7
            r = 2.4 + rnd.random() * 0.9
            pts.append((3.0 + math.cos(an) * r, 3.0 + math.sin(an) * r))
        for y in range(n):
            for x in range(n):
                cx, cy = x + 0.0, y + 0.0
                inside = all((bx - ax) * (cy - ay) - (by - ay) * (cx - ax) >= -0.2
                             for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]))
                if inside:
                    lv = 0.95 - (x + y) * 0.07
                    px[x, y] = pick(SHARD, lv, rnd, 0.2) + (255,)
        outline(img)
        frames.append(img)
    return strip_frames(frames)



def make_depo_rafi(rnd):
    """Depo rafı (20×90, dikey döşenir; iç mekân resmindeki baca kulesinin duvarı): ahşap
    dikmeler, beş raf tahtası (18 piksel aralık: raflar dolu okunsun), raflarda çuval, demir köşeli kasa, defter yığını, pirinç
    kavanoz. Arka pano koyu dikey tahta; ışık sol üstten, sağ dikmede ay parlaması.
    Üst/alt kenarda kontur yok: üst üste döşenince dikiş görünmesin."""
    w, h = 20, 90
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    item = [[False] * h for _ in range(w)]
    # Arka pano: 5 piksellik dikey tahtalar, aralarında derin oluk.
    for y in range(h):
        for x in range(3, 17):
            lv = 0.03 if (x - 3) % 5 == 4 else 0.09 + 0.05 * ((x - 3) % 5 == 0)
            px[x, y] = pick(WOOD, lv, rnd, 0.35) + (255,)
    # Dikmeler: sol ışıkta, sağ gölgede; dış kenarda kontur / ay kenarı.
    for y in range(h):
        px[0, y] = OUTLINE
        px[1, y] = pick(WOOD, 0.72, rnd, 0.4) + (255,)
        px[2, y] = pick(WOOD, 0.42, rnd, 0.4) + (255,)
        px[17, y] = pick(WOOD, 0.22, rnd, 0.3) + (255,)
        px[18, y] = mix(pick(WOOD, 0.3, rnd, 0.3), MOON, 0.45) + (255,)
        px[19, y] = OUTLINE
        if y % 18 == 8:
            px[1, y] = IRON[6] + (255,)  # dikme cıvatası
            px[2, y] = IRON[3] + (255,)
    for shelf in range(5):
        base = shelf * 18 + 15   # raf tahtasının üst yüzü
        # Raf tahtası: üst yüz sıcak ışık, ön yüz orta, altta pano üstüne AO.
        for x in range(1, 19):
            px[x, base] = pick(WOOD, 0.82 if x < 12 else 0.6, rnd, 0.4) + (255,)
            px[x, base + 1] = pick(WOOD, 0.36, rnd, 0.4) + (255,)
            px[x, base + 2] = OUTLINE
            if 3 <= x <= 16 and base + 3 < h:
                px[x, base + 3] = pick(WOOD, 0.01, rnd, 0.1) + (255,)
        px[18, base] = mix(px[18, base][:3], MOON, 0.5) + (255,)
        x = 3
        while x < 16:
            # Rafın ilk eşyası rafa göre sabit (kasa, defter, çuval...): tekrar kırılır.
            kind = [0.45, 0.75, 0.1, 0.5, 0.8][shelf] if x == 3 else rnd.random()
            room = 16 - x
            if kind < 0.3 and room >= 6:
                # Çuval: yuvarlak gövde, bağlı boyun, sol üstten ışık.
                cw = min(rnd.choice((6, 7)), room)
                ch = rnd.randrange(9, 13)
                for bx in range(cw):
                    for by in range(ch):
                        u = (bx + 0.5) / cw * 2 - 1
                        v = by / ch
                        if by == 0 and abs(u) > 0.4:
                            continue  # bağlı ağız
                        if (by == 1 or v > 0.88) and abs(u) > 0.75:
                            continue  # yuvarlak omuz / taban
                        lv = light(u) * (0.75 + 0.25 * (1 - v)) - (0.15 if by == ch - 1 else 0)
                        if by == 1 and abs(u) <= 0.4:
                            c = pick(HEMP, 0.75, rnd, 0.3)  # ip
                        else:
                            c = pick(BURLAP, lv, rnd, 0.5)
                        X, Y = x + bx, base - ch + by
                        px[X, Y] = c + (255,)
                        item[X][Y] = True
                x += cw
            elif kind < 0.6 and room >= 5:
                # Kasa: tahta kapak, demir köşe, üstüne bazen defter.
                cw = min(rnd.choice((5, 6, 7)), room)
                ch = rnd.randrange(7, 12)
                for bx in range(cw):
                    for by in range(ch):
                        lv = 0.55 - bx / cw * 0.35
                        if by == 0:
                            lv += 0.25
                        if by == ch // 2:
                            lv = 0.08  # tahta eki
                        c = pick(WOOD, lv, rnd, 0.45)
                        if (bx in (0, cw - 1)) and (by in (0, ch - 1)):
                            c = IRON[5] if bx == 0 else IRON[2]
                        X, Y = x + bx, base - ch + by
                        px[X, Y] = c + (255,)
                        item[X][Y] = True
                if rnd.random() < 0.5 and ch < 10:
                    ramp = [BOOK_RED, BOOK_TEAL, CREAM][rnd.randrange(3)]
                    for bx in range(1, cw - 1):
                        for by in range(2):
                            X, Y = x + bx, base - ch - 2 + by
                            px[X, Y] = pick(ramp, 0.62 if by == 0 else 0.32, rnd, 0.3) + (255,)
                            item[X][Y] = True
                x += cw
            elif kind < 0.9 and room >= 5:
                # Defter yığını: yatay ciltler, sırtlarda yaldız.
                cw = min(rnd.choice((5, 6)), room)
                layers = rnd.randrange(4, 9)
                y0 = base - 1
                for i in range(layers):
                    ramp = [BOOK_RED, BOOK_TEAL, CREAM, WOOD][rnd.randrange(4)]
                    off = rnd.choice((0, 0, 1))
                    for bx in range(off, min(cw, cw - 1 + off)):
                        lv = 0.6 if i == layers - 1 else 0.38
                        if bx == off:
                            lv += 0.2
                        X, Y = x + bx, y0 - i
                        px[X, Y] = pick(ramp, lv, rnd, 0.3) + (255,)
                        item[X][Y] = True
                x += cw
            elif room >= 3 and rnd.random() < 0.4:
                # Pirinç kavanoz: koyu kapak, sol kenarda tek parlama.
                for bx in range(3):
                    for by in range(5):
                        X, Y = x + bx, base - 5 + by
                        if by == 0:
                            c = IRON[3 if bx == 0 else 2]
                        else:
                            c = pick(BRASS, 0.55 if bx == 0 else 0.3 if bx == 1 else 0.12, rnd, 0.3)
                        px[X, Y] = c + (255,)
                        item[X][Y] = True
                x += 4
            elif room >= 2:
                # Dik cilt sırtları: dar boşluğu doldurur.
                for bx in range(min(room, rnd.choice((2, 3)))):
                    ramp = [BOOK_RED, BOOK_TEAL, CREAM, WOOD][rnd.randrange(4)]
                    bh = rnd.randrange(5, 9)
                    for by in range(bh):
                        lv = (0.55 if bx == 0 else 0.32) + (0.25 if by == 1 else 0.0)
                        X, Y = x + bx, base - bh + by
                        px[X, Y] = pick(ramp, lv, rnd, 0.3) + (255,)
                        item[X][Y] = True
                x += 3
            else:
                x += 1
    # Eşyaların panoyla sınırında tek piksel koyu mor kontur.
    edge = []
    for y in range(h):
        for x in range(3, 17):
            if item[x][y]:
                continue
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h and item[nx][ny]:
                    edge.append((x, y))
                    break
    for x, y in edge:
        if y % 18 not in (15, 16):
            px[x, y] = OUTLINE
    return img


def make_baca_tahta(rnd):
    """Baca içi tahta pano (24×32, döşenir; iç mekân resmindeki baca kulesinin içi):
    is kararmış dikey tahtalar, derin oluk, çivi, bir yatay kuşak; sol kenarda soluk
    sıcak sızıntı ışığı."""
    w, h = 24, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            k = x % 6
            lv = 0.02 if k == 5 else 0.1 + (0.06 if k == 0 else 0.0)
            if 20 <= y <= 22:
                lv = {20: 0.3, 21: 0.18, 22: 0.05}[y]  # kuşak
            px[x, y] = pick(WOOD, lv, rnd, 0.12) + (255,)
    for x in range(0, w, 6):
        px[x + 2, 21] = IRON[5] + (255,)
        px[x + 2, 4] = IRON[3] + (255,)
    for y in range(h):
        if rnd.random() < 0.18:
            px[1, y] = pick(ORANGE, 0.35, rnd, 0.3) + (255,)
    return img


# Gar tuğlası (Sirkeci/Haydarpaşa resimlerindeki kırmızı-krem kuşaklı cephe): doygun kırmızı,
# gölge mora, ışık turuncuya kayar.
GAR_BRICK = [(34, 12, 24), (62, 20, 30), (92, 30, 34), (122, 42, 38), (150, 58, 44),
             (176, 80, 54), (204, 112, 72), (228, 150, 96)]


def make_kule_tugla(rnd):
    """Gar tuğlası kule duvarı (20×48, dikey döşenir; gün ışığındaki baca kulesinin duvarı):
    dört sıra şaşırtmalı kırmızı tuğla + bir sıra krem kesme taş kuşak (gar cephesinin
    ablak şeridi), her 24 pikselde bir. Sol yüz sıcak ışıkta, sağ kenarda ay parlaması,
    iki yan kenarda koyu mor kontur; üst/alt kenarda kontur yok (dikişsiz döşeme)."""
    w, h = 20, 48
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        band = y % 24
        for x in range(1, w - 1):
            side = 0.12 - (x - 1) / (w - 3) * 0.2  # sol ışık -> sağ gölge
            if band >= 18:
                # Krem taş kuşak: üst kenar ışıkta, alt kenar gölgede, taş derzleri.
                ly = band - 18
                lv = {0: 0.86, 1: 0.7, 2: 0.62, 3: 0.56, 4: 0.44, 5: 0.12}[ly] + side
                if (x + (band // 6) * 3) % 9 == 0 and ly < 5:
                    lv = 0.3
                px[x, y] = pick(PLASTER, lv, rnd, 0.35) + (255,)
                continue
            row, ly = band // 4, band % 4
            off = 3 if row % 2 else 0
            lx = (x + off) % 7
            if ly == 3 or lx == 6:
                px[x, y] = pick(GAR_BRICK, 0.06, rnd, 0.3) + (255,)  # derz
                continue
            lv = {0: 0.62, 1: 0.48, 2: 0.36}[ly] + side
            lv += (((x + off) // 7 * 5 + row * 3) % 5 - 2) * 0.035  # tuğla başına ton
            if lx == 0:
                lv += 0.06
            px[x, y] = pick(GAR_BRICK, lv, rnd, 0.5) + (255,)
    # Kuşağın altında is/yağmur izi: iki sıra boyunca koyulaşan dar akıntılar.
    for sx in (5, 13):
        for y in range(24, 24 + 6):
            if px[sx, y % h][3]:
                c = px[sx, y % h][:3]
                px[sx, y % h] = mix(c, (34, 12, 24), 0.4 - (y - 24) * 0.06) + (255,)
    for y in range(h):
        px[0, y] = OUTLINE
        px[w - 1, y] = OUTLINE
        px[w - 2, y] = mix(px[w - 2, y][:3], MOON, 0.4) + (255,)
        px[1, y] = mix(px[1, y][:3], (240, 176, 96), 0.18) + (255,)
    return img


def make_baca_tugla(rnd):
    """Tuğla baca içi (24×32, döşenir; gar kulesinin içi): duvardan iki-üç ton koyu (oyuk
    okunsun) şaşırtmalı tuğla, is kararmış ama derzi okunur; sol kenardan sızan soluk sıcak ışık, yer yer kırık."""
    w, h = 24, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        row, ly = y // 4, y % 4
        off = 3 if row % 2 else 0
        for x in range(w):
            lx = (x + off) % 7
            if ly == 3 or lx == 6:
                px[x, y] = pick(GAR_BRICK, 0.02, rnd, 0.2) + (255,)
                continue
            lv = {0: 0.2, 1: 0.14, 2: 0.08}[ly] + max(0.0, 0.14 - x * 0.025)
            lv += (((x + off) // 7 * 3 + row) % 4 - 1.5) * 0.03
            px[x, y] = pick(GAR_BRICK, lv, rnd, 0.4) + (255,)
    for x, y in ((9, 5), (17, 18), (4, 26)):
        px[x, y] = GAR_BRICK[0] + (255,)
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
    make_diken(random.Random(59)).save(OUT + "diken.png")
    make_alev_izgara(random.Random(61)).save(OUT + "alev_izgara.png")
    make_kablo(random.Random(67)).save(OUT + "kablo.png")
    grenade(random.Random(71), False).save(OUT + "bomba.png")
    grenade(random.Random(71), True).save(OUT + "bomba_ikaz.png")
    make_alev(random.Random(73)).save(OUT + "alev.png")
    make_kivilcim(random.Random(79)).save(OUT + "kivilcim.png")
    make_patlama(random.Random(83)).save(OUT + "patlama.png")
    make_tugla(random.Random(89)).save(OUT + "tugla.png")
    make_sivali_tugla(random.Random(97)).save(OUT + "sivali_tugla.png")
    make_ic_duvar(random.Random(101)).save(OUT + "ic_duvar.png")
    make_hatil(random.Random(103)).save(OUT + "hatil.png")
    make_ic_pencere(random.Random(107)).save(OUT + "ic_pencere.png")
    make_fabrika_pencere(random.Random(109)).save(OUT + "fabrika_pencere.png")
    make_cephe_pencereleri(random.Random(223)).save(OUT + "cephe_pencereleri.png")
    make_kat_silmesi(random.Random(227)).save(OUT + "kat_silmesi.png")
    make_saldiri_uyari(random.Random(229)).save(OUT + "saldiri_uyari.png")
    make_dukkan(random.Random(233)).save(OUT + "dukkan.png")
    make_tavan(random.Random(113)).save(OUT + "tavan.png")
    make_han_kapisi(random.Random(127)).save(OUT + "han_kapisi.png")
    make_pres(random.Random(131)).save(OUT + "pres.png")
    make_pres_kol(random.Random(137)).save(OUT + "pres_kol.png")
    make_ray(random.Random(139)).save(OUT + "ray.png")
    make_su_govde(random.Random(149)).save(OUT + "su_govde.png")
    make_su_yuzey(random.Random(151)).save(OUT + "su_yuzey.png")
    make_anten(random.Random(157)).save(OUT + "anten.png")
    make_kule_ayak(random.Random(163)).save(OUT + "kule_ayak.png")
    make_kule_kulube(random.Random(167)).save(OUT + "kule_kulube.png")
    make_ahsap_kat(random.Random(173)).save(OUT + "ahsap_kat.png")
    riot_shield(random.Random(181), False).save(OUT + "kalkan.png")
    riot_shield(random.Random(181), True).save(OUT + "kalkan_kirik.png")
    make_sancak(random.Random(191)).save(OUT + "sancak.png")
    make_tufek_ikon(random.Random(197)).save("assets/pickups/placeholder_rifle.png")
    make_catlak(random.Random(199)).save(OUT + "catlak.png")
    make_kiymik(random.Random(211)).save(OUT + "kiymik.png")
    make_depo_rafi(random.Random(239)).save(OUT + "depo_rafi.png")
    make_baca_tahta(random.Random(241)).save(OUT + "baca_tahta.png")
    make_kule_tugla(random.Random(251)).save(OUT + "kule_tugla.png")
    make_baca_tugla(random.Random(257)).save(OUT + "baca_tugla.png")


if __name__ == "__main__":
    main()
