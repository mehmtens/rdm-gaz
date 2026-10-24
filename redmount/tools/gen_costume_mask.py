"""Redmount sayfalarına kostüm için pantolon maskesi gömer.

Kostüm shader'ı (`shaders/player_costume.gdshader`) giysiyi tek rampayla boyuyordu;
ceket ve pantolon aynı renge dönüyordu. Bu araç her karede pantolon piksellerinin
alfasını 255 → 254 yapar: gözle fark edilmez (kostümsüz çizimde değişiklik yok),
shader ise `a < 0.999` olan pikselleri ikinci rampaya (pantolon) eşler.

Ayrım (kare başına):
  1. Giysi pikseli: doygunluğu düşük, kontur ile beyaz arasındaki gri (shader'la aynı eşik).
  2. Pantolon kumaşı düzgün, ceketten açık gridir; siyah deri ceket çok koyu piksellerle
     beneklidir (parlak yamaları kot kadar açık olsa da). 7×7 pencerede yerel ortalama
     PANT_MEAN üstünde ve çok koyu giysi oranı DARK_FRAC altındaysa aday.
  3. Pantolon ayakkabıdan (beyaz, doygunluğu düşük, çok açık) başlayıp adaylar boyunca
     en fazla bacak boyu kadar büyütülür; bele değen ceket yamaları uzakta kalır.
  4. Kontur ve kıvrım gölgeleri pantolon bölgesinin içinde kalıyorsa (kapanış) dahil edilir;
     pantolona değen küçük kırıntılar ve ayakkabının açık gri gölgesi de pantolona katılır.

Araç tekrar çalıştırılabilir: önce eski işaretleri (254) siler.

  python tools/gen_costume_mask.py            # bütün assets/anim/redmount/*.png
  python tools/gen_costume_mask.py --preview  # scratch için kontrol görüntüsü yazar
"""
import glob
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "anim", "redmount")
CELL_W, CELL_H = 200, 240
MARK = 254
PANT_MEAN = 26.0      # yerel ortalama parlaklık (0–255); ceket ~20, pantolon ~30–60
DARK_MAX = 22         # bu parlaklığın altındaki giysi pikseli "çok koyu" (ceket derisi)
DARK_FRAC = 0.2       # 7×7 penceredeki çok koyu giysi oranı; ceket ~0,4–0,8, pantolon ~0–0,1
SHOE_MIN = 170        # ayakkabı: çok açık, doygunluğu düşük
MIN_AREA = 40         # bu kadar pikselden küçük pantolon parçası gürültüdür
SHOE_AREA = 30        # ayakkabı lekesinin en küçük boyu (piksel)
LEG_STEPS = 60        # ayakkabı üstünden bele bacak boyu (kare pikseli, 0,6 ölçekten önce)
CRUMB_AREA = 25       # pantolona değen bundan küçük giysi lekesi kırıntıdır
SHOE_SHADE = 90       # ayakkabıya 2 px yakın bu parlaklıktaki gri, ayakkabı gölgesidir


def _frame_mask(rgba: np.ndarray) -> np.ndarray:
	rgb = rgba[..., :3].astype(np.float32)
	a = rgba[..., 3]
	mx = rgb.max(axis=2)
	mn = rgb.min(axis=2)
	sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
	opaque = a >= 128
	cloth = opaque & (sat < 0.25) & (mx > 9) & (mx < 158)
	shoe = opaque & (sat < 0.2) & (mx >= SHOE_MIN)
	# fermuar parıltısı ve göz akı da beyazdır; ayakkabı yalnız büyük beyaz lekedir
	slab, scnt = ndimage.label(shoe, np.ones((3, 3)))
	if scnt:
		ssize = ndimage.sum(np.ones_like(slab), slab, index=np.arange(scnt + 1))
		shoe = (ssize >= SHOE_AREA)[slab] & (slab > 0)
	if not cloth.any() or not shoe.any():
		return np.zeros(a.shape, bool)
	# giysi piksellerinin yerel ortalaması (giysi olmayanlar sayılmaz)
	k = np.ones((7, 7), np.float32)
	s = ndimage.convolve(np.where(cloth, mx, 0), k, mode="constant")
	n = ndimage.convolve(cloth.astype(np.float32), k, mode="constant")
	mean = np.where(n > 0, s / np.maximum(n, 1), 0)
	# siyah deri ceketin kumaşı çok koyu piksellerle beneklidir; kot pantolon (gölgedeki
	# arka bacak dahil) düzgün gridir. Yerel koyu oranı ceketi, parlak yamalarıyla birlikte ayırır.
	dark_n = ndimage.convolve((cloth & (mx <= DARK_MAX)).astype(np.float32), k, mode="constant")
	frac = np.where(n > 0, dark_n / np.maximum(n, 1), 1)
	cand = cloth & (mean >= PANT_MEAN) & (frac <= DARK_FRAC)
	cand = ndimage.binary_closing(cand, np.ones((3, 3)), iterations=2) & cloth
	# ayakkabıdan aday pikseller boyunca en fazla LEG_STEPS adım (bacak boyu) büyü:
	# ceketin parlayan yamaları bele değse bile ayakkabıdan uzakta kaldıkları için girmez.
	pants = ndimage.binary_dilation(shoe, np.ones((5, 5))) & cand
	step = np.ones((3, 3), bool)
	for _ in range(LEG_STEPS):
		grown = ndimage.binary_dilation(pants, step) & cand
		if (grown == pants).all():
			break
		pants = grown
	lab, cnt = ndimage.label(pants)
	if cnt == 0:
		return np.zeros(a.shape, bool)
	sizes = ndimage.sum(np.ones_like(lab), lab, index=np.arange(cnt + 1))
	pants = (sizes >= MIN_AREA)[lab] & (lab > 0)
	# kıvrım gölgeleri/kontur deliklerini doldur; yalnız giysi ve koyu kontur pikselleri
	filled = ndimage.binary_fill_holes(ndimage.binary_closing(pants, np.ones((3, 3)), iterations=2))
	dark = opaque & (mx <= 9)
	pants = filled & (cloth | dark) & ~shoe
	# pantolona değen küçük giysi kırıntıları (dizdeki kıvrım, paçadaki gölge) ve ayakkabının
	# açık gri gölgesi ceket rengine boyanmasın: pantolona katılır
	rest = cloth & ~pants
	rlab, rcnt = ndimage.label(rest, np.ones((3, 3)))
	if rcnt:
		rsize = ndimage.sum(np.ones_like(rlab), rlab, index=np.arange(rcnt + 1))
		touch = np.zeros(rcnt + 1, bool)
		touch[np.unique(rlab[ndimage.binary_dilation(pants, np.ones((3, 3))) & rest])] = True
		pants |= ((rsize < CRUMB_AREA) & touch)[rlab] & (rlab > 0)
	shoe_shade = cloth & (mx >= SHOE_SHADE) & ndimage.binary_dilation(shoe, np.ones((5, 5)))
	return pants | shoe_shade


def process(path: str) -> int:
	im = Image.open(path).convert("RGBA")
	px = np.array(im)
	alpha = px[..., 3]
	alpha[alpha == MARK] = 255
	total = 0
	h, w = alpha.shape
	for y0 in range(0, h, CELL_H):
		for x0 in range(0, w, CELL_W):
			cell = px[y0:y0 + CELL_H, x0:x0 + CELL_W]
			m = _frame_mask(cell)
			cell[..., 3][m & (cell[..., 3] == 255)] = MARK
			total += int(m.sum())
	Image.fromarray(px, "RGBA").save(path)
	return total


def preview(path: str, out: str) -> None:
	px = np.array(Image.open(path).convert("RGBA"))
	vis = px.copy()
	m = px[..., 3] == MARK
	vis[m, 0] = 40
	vis[m, 1] = 200
	vis[m, 2] = 220
	vis[..., 3] = np.where(px[..., 3] > 0, 255, 0)
	bg = Image.new("RGBA", (vis.shape[1], vis.shape[0]), (200, 200, 200, 255))
	bg.alpha_composite(Image.fromarray(vis, "RGBA"))
	bg.save(out)


if __name__ == "__main__":
	files = sorted(glob.glob(os.path.join(ROOT, "*.png")))
	if "--preview" in sys.argv:
		out_dir = sys.argv[sys.argv.index("--preview") + 1]
		for f in files:
			preview(f, os.path.join(out_dir, os.path.basename(f)))
	else:
		for f in files:
			print("%-24s %6d px" % (os.path.basename(f), process(f)))
