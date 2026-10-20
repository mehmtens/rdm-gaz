"""Kanıt Arşivi fotoğrafları: her bölümün boyalı arka planından 3 kare.

    python tools/gen_photos.py  -> assets/ui/photos/bNN_k.png (72x48, piksel art)

Her bölümün gökyüzü atlasından (2x2 hücre) üç hücre kırpılır, kutu filtresiyle
küçültülür, 20 renge indirilir ve hafif sepya-sıcak tona çekilir: Gazelle'in
analog fotoğraf makinesiyle çektiği kanıt kareleri gibi okunur.
"""
import re
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "ui" / "photos"
DEFAULT = "assets/backgrounds/book02_suleymaniye_streets_atlas.png"


def atlas_of(n):
    src = (ROOT / "scripts" / "systems" / ("bolum%02d.gd" % n)).read_text(encoding="utf-8")
    m = re.search(r'res://(assets/backgrounds/[^"]+\.png)', src)
    return m.group(1) if m else DEFAULT


def photo(img, cell, n, k):
    w, h = img.size
    cx, cy = (cell % 2) * w // 2, (cell // 2) * h // 2
    q = img.crop((cx + w // 10, cy + h // 12, cx + w // 2 - w // 10, cy + h // 2 - h // 6))
    q = q.convert("RGB").resize((72, 48), Image.BOX)
    q = q.quantize(colors=20, method=Image.Quantize.MEDIANCUT).convert("RGB")
    # sıcak, hafif soluk analog ton
    r, g, b = q.split()
    r = r.point(lambda v: min(255, int(v * 1.06 + 10)))
    b = b.point(lambda v: int(v * 0.86))
    q = Image.merge("RGB", (r, g, b))
    q = ImageOps.expand(q, border=1, fill=(26, 18, 24))
    q.save(OUT / ("b%02d_%d.png" % (n, k)))


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for n in range(1, 37):
        img = Image.open(ROOT / atlas_of(n))
        for k, cell in enumerate((0, 1, 2)):
            photo(img, cell, n, k)
    print("ok")
