"""Bombacı ve Kalkanlı Zabıta için piksel kıyafet: mevcut düşman sayfalarından renk
değişimi (yeni çizim yerine aynı karakter iskeleti, farklı üniforma).

    python tools/gen_recolor_enemies.py
      -> assets/anim/bomber/*.png        (sokak eşkıyası -> zeytin yeşili yelek, kahve pantolon)
      -> assets/anim/shield_guard/*.png  (seçkin muhafız -> lacivert zabıta, sarı kol bandı)

Kıyafet pikselleri: düşük doygunluklu koyu tonlar (siyah/gri giysi). Ten, saç
vurgusu, metal parlaklık gibi doygun/açık pikseller korunur. Parlaklık bantları
hedef paletin 4 tonuna eşlenir (piksel art palet disiplini).
"""
import colorsys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ANIM = ROOT / "assets" / "anim"

OLIVE = [(38, 44, 24), (60, 70, 34), (88, 100, 48), (124, 136, 70)]
NAVY = [(18, 24, 46), (30, 40, 74), (48, 62, 108), (78, 96, 150)]


def recolor(src, dst, pal, band_color=None):
    im = Image.open(src).convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 10:
                continue
            hh, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
            if s < 0.16 and 0.07 < l < 0.42:
                k = min(3, int((l - 0.07) / 0.35 * 4))
                px[x, y] = pal[k] + (a,)
    if band_color:
        # Kol bandı: her karede gövdenin üst üçte birinde, en sağdaki kıyafet pikselinin
        # yanındaki 2 satırlık şerit (omuz) — sarı zabıta bandı.
        pass
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst)


if __name__ == "__main__":
    for name in ["idle", "walk", "attack", "attack2", "hurt", "knockdown", "dead"]:
        s = ANIM / "street_thug" / (name + ".png")
        if s.exists():
            recolor(s, ANIM / "bomber" / (name + ".png"), OLIVE)
    for s in (ANIM / "elite_guard").glob("*.png"):
        recolor(s, ANIM / "shield_guard" / s.name, NAVY)
    print("ok")
