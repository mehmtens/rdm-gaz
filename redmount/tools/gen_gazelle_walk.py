"""Gazelle yürüyüş döngüsü: kendi "freed" karesinden (temel sanat) üretilir.

Yan profilde iki bacak üst üste durduğu için bacak bloğu kalçadan iki kopya
olarak makas gibi açılır: öndeki kopya olduğu gibi, arkadaki kopya mor gölge
tonuna kaydırılıp öndekinin arkasına çizilir. Adım uçlarında gövde birkaç
piksel alçalır (yumuşak yürüyüş, sekme yok). Çıktı: 8 karelik yatay şerit.

    python tools/gen_gazelle_walk.py
"""
import math
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/characters/gazelle/placeholder_freed.png"
OUT = ROOT / "assets/characters/gazelle/placeholder_walk.png"

FRAMES = 8
HIP_Y = 158          # şort saçağının altı: bacaklar bu satırdan başlar
FRONT_HIP = (61, 158)
BACK_HIP = (61, 158)
BACK_SHIFT = 7       # arka bacak kalçada biraz geride (sağda) durur
SWING = 14.0         # derece, adım açısı
SHADOW = (34, 22, 37)


def clamp(v, lo, hi):
    return max(lo, min(hi, v))


def lum(p) -> int:
    return p[0] + p[1] + p[2]


def split_legs(src: Image.Image) -> tuple[Image.Image, Image.Image]:
    """Öndeki (açık tenli, solda) bacağı ayır; kalan arka parça döndürülür.

    Her satırda soldan ilk açık ten koşusunun bittiği koyu kontur sütunu sınırdır;
    iç içe duran ayakkabılar birlikte öndeki ayağa verilir."""
    w, h = src.size
    px = src.load()
    front = Image.new("RGBA", (w, h))
    back = Image.new("RGBA", (w, h))
    pf, pb = front.load(), back.load()
    bound = 70
    for y in range(HIP_Y, h):
        xs = [x for x in range(w) if px[x, y][3] > 100]
        if not xs:
            continue
        if y < 226:
            x = xs[0]
            while x < w and px[x, y][3] > 100 and lum(px[x, y]) < 380:
                x += 1       # sol kontur
            while x < w and px[x, y][3] > 100 and lum(px[x, y]) >= 380:
                x += 1       # açık ten koşusu
            while x < w and px[x, y][3] > 100 and 200 <= lum(px[x, y]) < 380:
                x += 1       # gölge kenarı
            # diz kıvrımındaki koyu çizgi sınırı erken bitirir: büyük geri sıçramayı
            # yok say (önceki satırın sınırı kalır)
            bound = x if y == HIP_Y or x >= bound - 2 else bound
        if y >= 226:
            bound = w    # ayakkabılar iç içe: ikisi birlikte öndeki ayak olur
        for x in xs:
            if x > 86 and y < 226:
                continue     # sarkan el gövdede kalır
            (pf if x <= bound else pb)[x, y] = px[x, y]
    return front, back


def shade(img: Image.Image, k: float) -> Image.Image:
    """Arka bacak: tonu mor gölgeye doğru k oranında karıştır."""
    px = img.load()
    out = img.copy()
    po = out.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a:
                po[x, y] = (int(r + (SHADOW[0] - r) * k), int(g + (SHADOW[1] - g) * k),
                            int(b + (SHADOW[2] - b) * k), a)
    return out


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    w, h = src.size
    front, back = split_legs(src)
    body = src.copy()
    bp = body.load()
    for y in range(HIP_Y, h):
        for x in range(w):
            if x <= 86:
                bp[x, y] = (0, 0, 0, 0)
    # arka bacak: öndekinin gölgeli kopyası (ayrılan arka parça çok ince kalıyor)
    back = shade(front, 0.30)
    strip = Image.new("RGBA", (w * FRAMES, h))
    for i in range(FRAMES):
        t = i / FRAMES * math.tau
        ang = SWING * math.sin(t)
        frame = Image.new("RGBA", (w, h))
        # PIL: pozitif açı saat yönünün tersi; yüz sağa bakıyor → +açı ayağı geri atar
        frame.alpha_composite(back.rotate(ang, resample=Image.NEAREST, center=BACK_HIP), (BACK_SHIFT, 0))
        frame.alpha_composite(front.rotate(-ang, resample=Image.NEAREST, center=FRONT_HIP))
        frame.alpha_composite(body)
        # bacak açıldıkça ayak kalkar (cos kısalması): tüm kare o kadar iner,
        # ayak yerde kalır, gövde adım uçlarında alçalır (doğal yürüyüş iniş-çıkışı)
        drop = int(round((1.0 - math.cos(math.radians(ang))) * (h - HIP_Y)))
        strip.paste(frame, (i * w, drop))
    strip.save(OUT)
    print("yazildi:", OUT)


if __name__ == "__main__":
    main()
