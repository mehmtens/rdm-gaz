"""REDMOUNT piksel art sahne parçaları üreticisi.

    python tools/gen_pixel_props.py          # hepsi -> assets/environment/pixel/
    python tools/gen_pixel_props.py sancak   # tek parça

Her parça düşük çözünürlükte (1 sanat pikseli = oyunda 3 px) çizilir.
"""
import math
import sys
from pathlib import Path

from pixelart import Canvas, strip

OUT = Path(__file__).resolve().parent.parent / "assets" / "environment" / "pixel"


# --- Kontrol noktası sancağı -------------------------------------------------

def _sancak_frame(active, phase):
    w, h = 30, 82
    c = Canvas(w, h)
    pole_x = 5
    # Taş kaide
    c.rect(1, 74, 11, 79, "stone1")
    c.hline(1, 11, 74, "stone3")
    c.hline(2, 10, 75, "stone2")
    c.vline(11, 75, 79, "stone0")
    c.rect(0, 79, 12, 80, "stone0")
    # Ahşap direk (3 px: koyu / orta / parlak)
    c.rect(pole_x - 1, 9, pole_x - 1, 74, "wood1")
    c.rect(pole_x, 9, pole_x, 74, "wood2")
    c.rect(pole_x + 1, 9, pole_x + 1, 74, "wood0")
    for y in range(14, 74, 9):
        c.put(pole_x, y, "wood3")
    # Pirinç bilezik
    c.hline(pole_x - 1, pole_x + 1, 44, "gold1")
    c.put(pole_x, 44, "gold3")
    # Alem: altın top + hilal
    c.disc(pole_x, 6, 2.3, "gold1")
    c.put(pole_x - 1, 5, "gold3")
    c.put(pole_x, 5, "gold2")
    c.vline(pole_x, 8, 9, "gold0")
    for (x, y) in [(pole_x - 2, 0), (pole_x - 3, 1), (pole_x - 3, 2), (pole_x - 2, 3),
                   (pole_x + 2, 0), (pole_x + 3, 1), (pole_x + 3, 2), (pole_x + 2, 3)]:
        c.put(x, y, "gold2")
    # Sancak
    top, bh, bw = 11, 26, 22
    if not active:
        # Sarkık, katlanmış gri bez: direğin dibine dökülür.
        for y in range(top, top + 34):
            width = 3 + int(2 * math.sin(y * 0.6)) + (y - top) // 10
            for x in range(pole_x + 2, pole_x + 2 + width):
                tone = "grey1" if (x + y // 3) % 3 else "grey2"
                if x == pole_x + 2:
                    tone = "grey0"
                c.put(x, y, tone)
        c.hline(pole_x + 2, pole_x + 6, top, "grey3")
    else:
        for col in range(bw):
            x = pole_x + 2 + col
            wave = int(round(math.sin(col * 0.42 - phase * math.pi / 2) * 2.0 * (col / bw)))
            y0 = top + wave
            y1 = top + bh + wave
            # Kırlangıç kuyruğu: son 6 sütunda ortası oyuk
            notch = max(0, col - (bw - 7))
            for y in range(y0, y1):
                rel = y - y0
                if notch and (bh // 2 - notch) < rel < (bh // 2 + notch):
                    continue
                shade = math.sin(col * 0.42 - phase * math.pi / 2)
                tone = "red2" if shade > 0.3 else ("red1" if shade > -0.4 else "red0")
                if rel <= 1 or rel >= bh - 2:
                    tone = "gold1" if rel in (1, bh - 2) else "gold0"
                c.put(x, y, tone)
            # Altın kenar parıltısı
            c.put(x, y0, "gold2" if col % 4 else "gold3")
        # Hilal + yıldız (beyaz), sancağın ortasına yakın
        cx, cy = pole_x + 9, top + bh // 2 + int(round(math.sin(7 * 0.42 - phase * math.pi / 2) * 1.0))
        for y in range(-4, 5):
            for x in range(-4, 5):
                d_out = x * x + y * y
                d_in = (x - 1.6) ** 2 + y * y
                if d_out <= 16 and d_in > 9:
                    c.put(cx + x, cy + y, "white")
        for (x, y) in [(5, -2), (3, -1), (4, -1), (5, -1), (6, -1), (7, -1), (4, 0), (5, 0), (6, 0), (4, 1), (6, 1)]:
            c.put(cx + x, cy + y, "white")
        # Püskül
        c.vline(pole_x + 2, top + bh, top + bh + 3, "gold1")
        c.put(pole_x + 2, top + bh + 4, "gold3")
    c.outline()
    return c


def sancak():
    frames = [_sancak_frame(False, 0)] + [_sancak_frame(True, k) for k in range(4)]
    strip(frames).save(OUT / "sancak.png")


# --- Kum torbası (yatay döşenir: 32x24, üç sıra şaşırtmalı torba) -------------

def _bag(c, x0, y0, w=10, h=7):
    c.rect(x0 + 1, y0, x0 + w - 2, y0 + h - 1, "sand1")
    c.rect(x0, y0 + 1, x0 + w - 1, y0 + h - 2, "sand1")
    c.hline(x0 + 2, x0 + w - 3, y0 + 1, "sand3")
    c.hline(x0 + 1, x0 + w - 2, y0 + 2, "sand2")
    c.hline(x0 + 1, x0 + w - 2, y0 + h - 2, "sand0")
    c.put(x0 + w // 2, y0 + 3, "sand0")
    c.put(x0 + 2, y0 + 3, "sand2")


def kum_torbasi():
    c = Canvas(32, 24)
    for row in range(3):
        off = 0 if row % 2 == 0 else -5
        for k in range(-1, 4):
            _bag(c, off + k * 11, 24 - (row + 1) * 8)
    for y in range(24):
        for x in range(32):
            if c.get(x, y)[3] == 0:
                c.put(x, y, "sand0")
    c.im.save(OUT / "kum_torbasi.png")


# --- Gözetleme kulesi: kulübe + çelik ayak döşemesi -----------------------------

def kule():
    cab = Canvas(40, 30)
    for y in range(0, 6):
        cab.hline(3 - y // 2 + 2, 36 + y // 2 - 2, y, "red1" if y % 2 else "red2")
    cab.hline(1, 38, 6, "wood0")
    cab.rect(4, 7, 35, 27, "wood1")
    for x in range(4, 36, 4):
        cab.vline(x, 7, 27, "wood0")
        cab.vline(x + 1, 7, 27, "wood2")
    cab.rect(10, 11, 29, 19, "glow1")
    cab.rect(11, 12, 28, 18, "glow2")
    cab.hline(11, 28, 12, "glow3")
    cab.vline(19, 11, 19, "wood0")
    cab.hline(10, 29, 15, "wood0")
    cab.hline(2, 37, 26, "iron2")
    cab.hline(2, 37, 27, "iron1")
    for x in range(3, 37, 5):
        cab.vline(x, 22, 27, "iron1")
    cab.outline()
    cab.im.save(OUT / "kule_kulube.png")
    leg = Canvas(40, 20)
    for x0 in (4, 33):
        leg.rect(x0, 0, x0 + 2, 19, "iron1")
        leg.vline(x0, 0, 19, "iron2")
    for t in range(20):
        x = 7 + int(t * 26 / 19)
        leg.put(x, t, "iron2")
        leg.put(x, t - 1, "iron1")
        x2 = 32 - int(t * 26 / 19)
        leg.put(x2, t, "iron1")
    leg.hline(4, 35, 0, "iron3")
    leg.im.save(OUT / "kule_ayak.png")


# --- Fener: direk + cam fener; hale (dither) -------------------------------------

def fener():
    c = Canvas(13, 60)
    c.rect(5, 12, 7, 59, "iron1")
    c.vline(5, 12, 59, "iron2")
    c.rect(3, 56, 9, 59, "iron1")
    c.hline(3, 9, 56, "iron2")
    c.rect(2, 1, 10, 2, "iron1")
    c.put(6, 0, "iron2")
    c.rect(3, 3, 9, 10, "iron0")
    c.rect(4, 4, 8, 9, "glow2")
    c.rect(5, 5, 7, 8, "glow3")
    c.hline(2, 10, 11, "iron1")
    c.outline()
    c.im.save(OUT / "fener.png")
    halo = Canvas(48, 48)
    for y in range(48):
        for x in range(48):
            d = math.hypot(x - 23.5, y - 23.5)
            if d < 7:
                halo.put(x, y, (255, 206, 120, 120))
            elif d < 13 and (x + y) % 2 == 0:
                halo.put(x, y, (255, 180, 90, 90))
            elif d < 20 and (x % 2 == 0 and y % 2 == 0):
                halo.put(x, y, (255, 160, 70, 70))
            elif d < 24 and (x % 4 == 0 and y % 4 == 0):
                halo.put(x, y, (255, 150, 60, 60))
    halo.im.save(OUT / "fener_hale.png")


# --- Kanal suyu: 3 kare dalga (32x12 yüzey) + gövde ------------------------------

def su():
    frames = []
    for f in range(3):
        c = Canvas(32, 12)
        c.rect(0, 2, 31, 11, "water1")
        for x in range(32):
            y = 1 + int(round(math.sin((x + f * 4) * 0.4)))
            c.put(x, y, "water3")
            c.put(x, y + 1, "water2")
        for k in range(3):
            x = (k * 11 + f * 3) % 32
            c.hline(x, min(31, x + 3), 6 + k, "water2")
        frames.append(c)
    strip(frames).save(OUT / "su_yuzey.png")
    body = Canvas(32, 16)
    body.dither(0, 0, 31, 15, "water1", "water0")
    body.im.save(OUT / "su_govde.png")


# --- Ray hattı (16x6: travers + ray) ---------------------------------------------

def ray():
    c = Canvas(16, 6)
    c.rect(1, 2, 6, 5, "wood1")
    c.hline(1, 6, 2, "wood2")
    c.rect(9, 2, 14, 5, "wood1")
    c.hline(9, 14, 2, "wood2")
    c.hline(0, 15, 0, "iron3")
    c.hline(0, 15, 1, "iron1")
    c.im.save(OUT / "ray.png")


# --- Kaya tavan (48x30, alt kenarda sarkıtlar) -----------------------------------

def tavan():
    """Kaya tavan: düzensiz, gölgeli taş blokları + alt kenarda sarkıtlar (48x30)."""
    import random
    rnd = random.Random(7)
    c = Canvas(48, 30)
    c.rect(0, 0, 47, 21, "stone0")
    # Düzensiz taşlar: her biri üst kenarı parlak, alt kenarı koyu.
    for _ in range(26):
        w = rnd.randint(5, 11)
        h = rnd.randint(3, 6)
        x = rnd.randint(-3, 47)
        y = rnd.randint(-2, 18)
        tone = rnd.choice(["stone1", "stone1", "stone2"])
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if (xx - x in (0, w - 1)) and (yy - y in (0, h - 1)):
                    continue  # köşeleri yuvarla
                c.put(xx % 48, yy, tone)
        for xx in range(x + 1, x + w - 1):
            c.put(xx % 48, y, "stone3" if tone == "stone2" else "stone2")
            c.put(xx % 48, y + h - 1, "stone0")
    for x0, ln in [(2, 7), (11, 4), (18, 8), (27, 5), (34, 9), (42, 4)]:
        for t in range(ln):
            w = max(0, 2 - t // 3)
            c.rect(x0 - w, 22 + t, x0 + w, 22 + t, "stone1" if t < ln - 1 else "stone2")
        c.put(x0 - 1, 22, "stone2")
    c.hline(0, 47, 21, "stone0")
    c.im.save(OUT / "tavan.png")


# --- Fabrika: tuğla döşemesi + kemerli yanan pencere -----------------------------

def fabrika():
    b = Canvas(16, 16)
    b.rect(0, 0, 15, 15, "brick1")
    for row in range(4):
        y = row * 4
        b.hline(0, 15, y, "brick0")
        off = 0 if row % 2 == 0 else 4
        for x in range(off, 16, 8):
            b.vline(x, y, y + 3, "brick0")
            b.put(x + 1, y + 1, "brick3")
            b.hline(x + 2, min(15, x + 5), y + 1, "brick2")
    b.im.save(OUT / "tugla.png")
    w = Canvas(14, 20)
    w.rect(1, 6, 12, 19, "iron0")
    w.disc(6.5, 6, 5.5, "iron0")
    w.rect(2, 7, 11, 18, "glow1")
    w.disc(6.5, 6.5, 4.5, "glow1")
    w.rect(3, 8, 10, 17, "glow2")
    w.vline(6, 2, 18, "iron0")
    w.hline(2, 11, 12, "iron0")
    w.put(4, 9, "glow3")
    w.put(9, 14, "glow3")
    w.hline(0, 13, 19, "stone2")
    w.outline()
    w.im.save(OUT / "fabrika_pencere.png")


# --- Kemerli han kapısı (86x100) -------------------------------------------------

def han_kapisi():
    c = Canvas(86, 100)
    for y in range(8, 100, 7):
        off = 0 if (y // 7) % 2 == 0 else 6
        for x in range(-off, 86, 12):
            c.rect(max(0, x), y, min(85, x + 11), min(99, y + 6), "stone1")
            c.hline(max(0, x), min(85, x + 11), y, "stone3")
            c.vline(max(0, x), y, min(99, y + 6), "stone0")
            c.put(max(0, x) + 2, y + 2, "stone2")
    for y in range(0, 8):
        c.hline(0, 85, y, "red1" if y % 2 else "red2")
    c.hline(0, 85, 7, "wood0")
    cx, top, bot, rw = 43, 34, 99, 22
    for y in range(top - rw, bot + 1):
        for x in range(cx - rw, cx + rw + 1):
            inside = (y >= top and abs(x - cx) <= rw) or (y < top and (x - cx) ** 2 + (y - top) ** 2 <= rw * rw)
            if inside:
                c.put(x, y, "wood0")
    for y in range(top - rw + 3, bot + 1):
        for x in range(cx - rw + 3, cx + rw - 2):
            inside = (y >= top and abs(x - cx) <= rw - 3) or (y < top and (x - cx) ** 2 + (y - top) ** 2 <= (rw - 3) ** 2)
            if inside:
                c.put(x, y, "wood1" if (x // 5) % 2 else "wood2")
    c.vline(cx, top - rw + 3, bot, "wood0")
    for y in (50, 75):
        c.hline(cx - rw + 3, cx + rw - 3, y, "iron1")
    c.disc(cx - 4, 68, 1.2, "gold2")
    c.disc(cx + 4, 68, 1.2, "gold2")
    for a in range(0, 181, 12):
        r = math.radians(a)
        x = int(cx + math.cos(r) * (rw + 2))
        y = int(top - math.sin(r) * (rw + 2))
        c.rect(x - 1, y - 1, x + 1, y + 1, "white" if (a // 12) % 2 else "red1")
    c.outline()
    c.im.save(OUT / "han_kapisi.png")


# --- Pres başlığı + piston kolu ---------------------------------------------------

def pres():
    c = Canvas(34, 22)
    c.rect(1, 0, 32, 15, "iron1")
    c.hline(1, 32, 0, "iron3")
    c.hline(1, 32, 1, "iron2")
    for x in (4, 29):
        c.disc(x, 6, 1.3, "iron3")
    for x in range(1, 33):
        c.vline(x, 16, 19, "gold2" if (x // 3) % 2 == 0 else "ink")
    for x in range(2, 32, 4):
        c.put(x, 20, "iron2")
        c.put(x + 1, 20, "iron1")
        c.put(x + 1, 21, "iron1")
    c.outline()
    c.im.save(OUT / "pres.png")
    rod = Canvas(8, 16)
    rod.rect(1, 0, 6, 15, "iron2")
    rod.vline(2, 0, 15, "iron3")
    rod.vline(6, 0, 15, "iron1")
    rod.hline(1, 6, 15, "iron1")
    rod.im.save(OUT / "pres_kol.png")


# --- Alev bacası: ızgara + 4 kare alev ---------------------------------------------

def alev():
    frames = []
    for f in range(4):
        c = Canvas(16, 46)
        for y in range(46):
            t = y / 45.0
            width = 2 + int((1 - abs(t - 0.75) * 1.6) * 5)
            sway = int(round(math.sin(y * 0.35 + f * 1.6) * 2 * (1 - t)))
            for x in range(8 - width + sway, 8 + width + sway):
                d = abs(x - 8 - sway) / max(1, width)
                tone = "fire3" if d < 0.3 and t > 0.4 else ("fire2" if d < 0.6 else ("fire1" if d < 0.9 else "fire0"))
                if (x + y + f) % 7 == 0 and t < 0.5:
                    continue
                c.put(x, y, tone)
        frames.append(c)
    strip(frames).save(OUT / "alev.png")
    g = Canvas(22, 6)
    g.rect(0, 1, 21, 5, "iron1")
    g.hline(0, 21, 1, "iron3")
    for x in range(2, 21, 3):
        g.vline(x, 2, 4, "ink")
    g.outline()
    g.im.save(OUT / "alev_izgara.png")


# --- Varil ve tüp (kırılabilir) ----------------------------------------------------

def varil():
    c = Canvas(16, 21)
    c.rect(1, 1, 14, 19, "iron1")
    c.rect(0, 3, 15, 17, "iron1")
    c.vline(3, 1, 19, "iron2")
    c.vline(4, 2, 18, "iron3")
    c.vline(13, 1, 19, "iron0")
    for y in (4, 10, 16):
        c.hline(0, 15, y, "red1")
        c.hline(1, 14, y + 1, "red0")
    c.hline(2, 13, 1, "iron3")
    c.outline()
    c.im.save(OUT / "varil.png")
    t = Canvas(11, 20)
    t.rect(1, 4, 9, 19, "red1")
    t.vline(2, 4, 19, "red2")
    t.vline(3, 5, 18, "red3")
    t.vline(9, 4, 19, "red0")
    t.disc(5, 4, 4, "red1")
    t.rect(4, 0, 6, 2, "iron2")
    t.put(4, 0, "iron3")
    t.hline(1, 9, 12, "white")
    t.outline()
    t.im.save(OUT / "tup.png")


# --- Vinç halatı (döşenir), projektör huzmesi, gölge ------------------------------

def halat():
    c = Canvas(3, 8)
    for y in range(8):
        c.put(0, y, "wood1" if y % 4 < 2 else "wood2")
        c.put(1, y, "wood2" if y % 4 < 2 else "wood3")
        c.put(2, y, "wood0")
    c.im.save(OUT / "halat.png")


def huzme():
    c = Canvas(60, 170)
    for y in range(170):
        half = 2 + y * 28 / 169
        for x in range(60):
            d = abs(x - 29.5)
            if d > half:
                continue
            fade = 1 - y / 170
            core = d < half * 0.45
            if core and (x + y) % 2 == 0:
                c.put(x, y, (255, 246, 200, int(60 * fade + 10)))
            elif x % 2 == 0 and y % 2 == 0:
                c.put(x, y, (255, 240, 190, int(44 * fade + 6)))
    c.im.save(OUT / "huzme.png")


def golge():
    c = Canvas(24, 6)
    for y in range(6):
        for x in range(24):
            d = ((x - 11.5) / 12) ** 2 + ((y - 2.5) / 3) ** 2
            if d < 0.55:
                c.put(x, y, (8, 6, 12, 110))
            elif d < 1.0 and (x + y) % 2 == 0:
                c.put(x, y, (8, 6, 12, 80))
    c.im.save(OUT / "golge.png")


def parmaklik():
    """Arena kapısı: dikey döşenen demir parmaklık (12x24), tepe parçası sivri uçlu."""
    c = Canvas(12, 24)
    for x in (1, 5, 9):
        c.vline(x, 0, 23, "iron1")
        c.vline(x + 1, 0, 23, "iron2")
    c.hline(0, 11, 11, "iron0")
    c.hline(0, 11, 12, "iron3")
    c.hline(0, 11, 13, "iron1")
    for x in (2, 6, 10):
        c.put(x, 12, "gold2")
    c.im.save(OUT / "parmaklik.png")
    t = Canvas(12, 10)
    for x in (1, 5, 9):
        c2 = x
        t.vline(c2, 4, 9, "iron1")
        t.vline(c2 + 1, 4, 9, "iron2")
        t.put(c2, 3, "iron2")
        t.put(c2 + 1, 3, "iron3")
        t.put(c2, 2, "iron3")
        t.put(c2 + 1, 1, "iron3")
    t.hline(0, 11, 8, "iron0")
    t.outline()
    t.im.save(OUT / "parmaklik_tepe.png")


def kaset():
    """İpucu kaseti (diyalog tetikleyici süsü)."""
    c = Canvas(16, 11)
    c.rect(0, 0, 15, 10, "ink")
    c.rect(1, 1, 14, 9, "cream")
    c.rect(2, 2, 13, 3, (67, 215, 194, 255))
    c.rect(3, 5, 12, 8, "grey1")
    for x in (5, 10):
        c.rect(x - 1, 6, x + 1, 7, "gold2")
    c.hline(6, 9, 6, "wood1")
    c.im.save(OUT / "kaset.png")


def tas_blok():
    """Oyma mermer/taş blok (30x30): parlak üst, koyu yan, ortada kabartma motif."""
    c = Canvas(30, 30)
    c.rect(0, 0, 29, 29, "stone2")
    c.rect(0, 0, 29, 2, "stone3")
    c.rect(26, 0, 29, 29, "stone1")
    c.rect(0, 27, 29, 29, "stone1")
    c.hline(0, 29, 3, "cream")
    import random
    rnd = random.Random(3)
    for _ in range(40):
        x, y = rnd.randint(1, 25), rnd.randint(4, 26)
        c.put(x, y, rnd.choice(["stone1", "stone3", "sand2"]))
    c.vline(2, 4, 26, "stone3")
    # kabartma: küçük çarkıfelek
    c.rect(10, 11, 18, 19, "stone1")
    c.rect(11, 12, 17, 18, "stone3")
    c.put(14, 13, "stone1"); c.put(14, 17, "stone1"); c.put(12, 15, "stone1"); c.put(16, 15, "stone1")
    c.put(14, 15, "stone0")
    c.outline()
    c.im.save(OUT / "tas_blok.png")


def diken():
    """Diken şeridi (20x10 döşeme): paslı demir çiviler, koyu taban, uçta parlama."""
    c = Canvas(20, 10)
    c.rect(0, 8, 19, 9, "iron0")
    c.hline(0, 19, 7, "iron1")
    for k, x0 in enumerate((1, 6, 11, 16)):
        h = 6 if k % 2 == 0 else 5
        for i in range(h):
            y = 7 - i
            half = max(0, (h - i) // 2)
            c.hline(x0 - half, x0 + half, y, "iron2" if i < h - 2 else "iron3")
            c.put(x0 - half, y, "iron1")
        c.put(x0, 7 - h, "red3")
        c.put(x0, 7 - h + 1, "red2")
    c.outline()
    c.im.save(OUT / "diken.png")



def ahsap_kat():
    """Kat döşemesi (32x8): kalın tahta, alt kirişler; üst kenar aydınlık."""
    c = Canvas(32, 8)
    c.rect(0, 0, 31, 3, "wood2")
    c.hline(0, 31, 0, "wood3")
    for x in (7, 15, 23, 31):
        c.vline(x, 0, 3, "wood0")
    c.rect(0, 4, 31, 4, "wood0")
    for x0 in (2, 18):
        c.rect(x0, 5, x0 + 4, 7, "wood1")
        c.put(x0, 5, "wood2")
    c.im.save(OUT / "ahsap_kat.png")



def on_sarmasik():
    """Ön plan sarkan sarmaşık (40x48): koyu yapraklar, birkaç yaprak ışık alır."""
    import random
    rnd = random.Random(11)
    c = Canvas(40, 48)
    dark = (16, 28, 22, 255)
    mid = (28, 48, 34, 255)
    lit = (64, 96, 54, 255)
    c.rect(0, 0, 39, 3, dark)
    for k in range(9):
        x = 2 + k * 4 + rnd.randint(-1, 1)
        ln = rnd.randint(14, 46)
        for y in range(2, ln):
            xx = x + (1 if (y // 6) % 2 else 0)
            c.put(xx, y, dark)
            if y % 4 == 0:
                c.rect(xx - 1, y, xx + 1, y + 1, mid)
                if rnd.random() < 0.25:
                    c.put(xx + 1, y, lit)
    c.im.save(OUT / "on_sarmasik.png")


def zincir():
    """Sarkan zincir halkası (6x8 dikey döşeme)."""
    c = Canvas(6, 8)
    c.rect(1, 0, 4, 3, "iron2")
    c.rect(2, 1, 3, 2, "clear")
    c.put(1, 0, "iron3")
    c.rect(2, 4, 3, 7, "iron1")
    c.put(2, 4, "iron3")
    c.outline()
    c.im.save(OUT / "zincir.png")


def anten():
    """Radyo anten direği (24x96): kafes direk, tepede kırmızı ikaz lambası, izolatörler."""
    c = Canvas(24, 96)
    for y in range(8, 96):
        w = 2 + (y - 8) * 9 // 88
        l, r = 12 - w, 11 + w
        c.put(l, y, "iron2")
        c.put(r, y, "iron1")
        if (y - 8) % 8 == 0:
            c.hline(l, r, y, "iron1")
        if (y - 8) % 8 < 8:
            d = (y - 8) % 8
            span = r - l
            c.put(l + d * span // 8, y, "iron0")
            c.put(r - d * span // 8, y, "iron0")
    c.rect(10, 2, 13, 7, "iron1")
    c.rect(10, 0, 13, 2, "red2")
    c.put(11, 0, "red3")
    for y in (30, 60):
        c.rect(9, y, 14, y + 1, "white")
    c.outline()
    c.im.save(OUT / "anten.png")


def ic_duvar():
    """Kireç sıva (48x32): yumuşak lekeli, sıcak; desen tekrarı göze batmasın diye düşük kontrast."""
    import random
    rnd = random.Random(5)
    c = Canvas(48, 32)
    base = (150, 128, 108, 255)
    c.rect(0, 0, 47, 31, base)
    for _ in range(140):
        x, y = rnd.randint(0, 47), rnd.randint(0, 31)
        c.put(x, y, rnd.choice([(140, 118, 100, 255), (160, 138, 116, 255), (144, 124, 104, 255)]))
    # birkaç ince çatlak
    x, y = 30, 4
    for _ in range(7):
        c.put(x, y, (112, 92, 80, 255))
        x += rnd.choice([0, 1]); y += 1
    c.im.save(OUT / "ic_duvar.png")


def hatil():
    """Hımış ahşap çatkı kirişi (8x8 döşeme): koyu meşe, üstte ışık çizgisi."""
    c = Canvas(8, 8)
    c.rect(0, 0, 7, 7, "wood1")
    c.hline(0, 7, 0, "wood2")
    c.hline(0, 7, 7, "wood0")
    c.put(3, 3, "wood0"); c.put(4, 4, "wood0")
    c.im.save(OUT / "hatil.png")


def sivali_tugla():
    """Sıvası dökülmüş yama (24x14): görünen tuğlalar, süs olarak seyrek kullanılır."""
    c = Canvas(24, 14)
    for row, y in enumerate(range(1, 13, 4)):
        off = 0 if row % 2 == 0 else 3
        for x in range(off + 1, 22, 6):
            c.rect(x, y, x + 4, y + 2, "brick1")
            c.hline(x, x + 4, y, "brick2")
    c.im.save(OUT / "sivali_tugla.png")


def on_kolon():
    """Ön plan sütunu: başlık (18x10), gövde döşemesi (18x16), kaide (18x10). Koyu, kenar ışıklı."""
    dark, mid, rim, rim2 = (40, 30, 38, 255), (60, 44, 50, 255), (96, 60, 42, 255), (150, 98, 58, 255)
    cap = Canvas(18, 10)
    cap.rect(0, 2, 17, 9, dark); cap.rect(2, 0, 15, 2, dark)
    cap.hline(0, 17, 9, rim); cap.hline(2, 15, 0, mid)
    cap.vline(17, 2, 9, rim2)
    cap.im.save(OUT / "on_kolon_bas.png")
    body = Canvas(18, 16)
    body.rect(2, 0, 15, 15, dark)
    for x in (5, 9, 13):
        body.vline(x, 0, 15, mid)
    body.vline(15, 0, 15, rim)
    body.vline(16, 0, 15, rim2)
    body.im.save(OUT / "on_kolon.png")
    base = Canvas(18, 10)
    base.rect(0, 0, 17, 9, dark); base.hline(0, 17, 0, rim); base.vline(17, 0, 9, rim2)
    base.hline(1, 16, 4, mid)
    base.im.save(OUT / "on_kolon_kaide.png")


def raf():
    """İç mekân rafı (30x22): ahşap raf, kavanoz, dosya, kitap sırtları."""
    import random
    rnd = random.Random(21)
    c = Canvas(30, 22)
    for y in (6, 14, 21):
        c.hline(0, 29, y, "wood2")
        c.hline(0, 29, y - 1 if y == 21 else y + 1, "wood0")
    c.vline(0, 0, 21, "wood1"); c.vline(29, 0, 21, "wood1")
    for shelf_y in (5, 13, 20):
        x = 2
        while x < 27:
            kind = rnd.choice(["book", "book", "jar", "file", "gap"])
            if kind == "book":
                h = rnd.randint(3, 5)
                col = rnd.choice(["red1", "red2", "wood2", "grey2", "gold1", "water2"])
                c.rect(x, shelf_y - h + 1, x, shelf_y, col)
                c.put(x, shelf_y - h + 1, "cream")
                x += 1
            elif kind == "jar":
                c.rect(x, shelf_y - 3, x + 2, shelf_y, "water1")
                c.hline(x, x + 2, shelf_y - 3, "stone3")
                c.put(x, shelf_y - 2, "water3")
                x += 4
            elif kind == "file":
                c.rect(x, shelf_y - 2, x + 3, shelf_y, "cream")
                c.hline(x, x + 3, shelf_y - 2, "sand2")
                x += 5
            else:
                x += 2
    c.outline()
    c.im.save(OUT / "raf.png")


def asma_lamba():
    """Asma lamba (12x14): zincirden sarkan pirinç gövde, sıcak cam (zincir ayrı döşenir)."""
    c = Canvas(12, 14)
    c.rect(4, 0, 7, 2, "gold0")
    c.rect(2, 3, 9, 4, "gold1")
    c.hline(2, 9, 3, "gold2")
    c.rect(3, 5, 8, 10, "glow2")
    c.rect(4, 6, 7, 9, "glow3")
    c.vline(3, 5, 10, "glow1")
    c.rect(2, 11, 9, 12, "gold1")
    c.rect(5, 13, 6, 13, "gold0")
    c.outline()
    c.im.save(OUT / "asma_lamba.png")


def cerceve():
    """Duvar çerçevesi (16x12): yaldız çerçeve içinde Boğaz manzarası."""
    c = Canvas(16, 12)
    c.rect(0, 0, 15, 11, "gold1")
    c.hline(0, 15, 0, "gold2"); c.vline(0, 0, 11, "gold2")
    c.rect(2, 2, 13, 9, "water2")
    c.rect(2, 2, 13, 4, (150, 120, 120, 255))
    c.hline(2, 13, 5, "water3")
    c.rect(4, 4, 6, 5, "stone1"); c.put(5, 3, "stone1")
    c.rect(9, 6, 12, 7, "white")
    c.outline()
    c.im.save(OUT / "cerceve.png")


def ic_pencere():
    """İç mekân kemerli pencere (18x26): gece mavisi cam, kafes, taş söve."""
    c = Canvas(18, 26)
    c.rect(0, 6, 17, 25, "stone2")
    for y in range(0, 7):
        half = 9 - max(0, 6 - y) * 9 // 7
        c.hline(9 - half, 8 + half, y, "stone2")
    c.rect(2, 7, 15, 23, (34, 46, 84, 255))
    for y in range(2, 8):
        half = 7 - max(0, 7 - y) * 7 // 6
        c.hline(9 - half, 8 + half, y, (34, 46, 84, 255))
    c.vline(8, 2, 23, "iron1"); c.vline(9, 2, 23, "iron1")
    c.hline(2, 15, 14, "iron1")
    c.put(5, 10, (210, 220, 255, 255)); c.put(12, 18, (210, 220, 255, 255)); c.put(4, 19, (150, 170, 220, 255))
    c.rect(0, 24, 17, 25, "stone3")
    c.outline()
    c.im.save(OUT / "ic_pencere.png")


GENERATORS = {
    "raf": raf, "asma_lamba": asma_lamba, "cerceve": cerceve, "ic_pencere": ic_pencere,
    "hatil": hatil, "sivali_tugla": sivali_tugla,
    "diken": diken, "ic_duvar": ic_duvar, "ahsap_kat": ahsap_kat, "on_kolon": on_kolon,
    "on_sarmasik": on_sarmasik, "zincir": zincir, "anten": anten,
    "tas_blok": tas_blok,
    "kaset": kaset,
    "parmaklik": parmaklik,
    "sancak": sancak, "kum_torbasi": kum_torbasi, "kule": kule, "fener": fener, "su": su,
    "ray": ray, "tavan": tavan, "fabrika": fabrika, "han_kapisi": han_kapisi, "pres": pres,
    "alev": alev, "varil": varil, "halat": halat, "huzme": huzme, "golge": golge,
}

if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for name in (sys.argv[1:] or GENERATORS.keys()):
        GENERATORS[name]()
        print("ok", name)
