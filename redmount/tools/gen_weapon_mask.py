"""Redmount silah sayfalarına kostüm için "silah" işareti gömer.

Kostüm shader'ı (`shaders/player_costume.gdshader`) doygunluğu düşük gri pikselleri
giysi sayıp kostüm rampasına boyar; tabanca ve tüfek de koyu gri olduğu için ceket
rengine dönüyordu (Kızıl Dağ kostümüyle kırmızı tüfek). Renk tek başına ayırmıyor:
aynı tüfek bir karede ceketten nötr, ötekinde ceket kadar sıcak; kalınlık da ayırmıyor
(gövde kol kadar kalın). Bu yüzden silah her sayfanın ilk karesinde elle çizilmiş bir
çokgenle tanımlanır:

  1. Diğer karelerde çokgen, ilk karedeki silah piksellerine en iyi oturan kaydırmayla
     (±TRACK px, RGB+alfa farkı) taşınır; sayfa içinde silah elle birlikte kayar ama
     dönmez (nişan, bekleme, ateş, yürüme).
  2. Giysi pikselleri (shader'la aynı eşik) 4-komşulu bileşenlere ayrılır: piksel art
     konturu silahı kol/ceketten ayırdığı için bileşen sınırı silahın gerçek kenarıdır.
     Pikselinin en az INSIDE oranı çokgende olan bileşen silahtır (çokgenin birkaç piksel
     taşması ya da eksik kalması sonucu değiştirmez); işaret çokgenin GROW px yakınıyla
     sınırlanır.
  3. İşaretli piksellerin alfası 252 olur (işaret kodu 255 − alfa = 3: pantolon 1, saç
     bitleri çift — çakışmaz). Gözle fark edilmez; shader kod 3'ü boyamaz.

Araç tekrar çalıştırılabilir: önce eski işaretleri (252) siler. Pantolon işaretini
(254) yalnız silahın üstünde ezer; `gen_costume_mask.py` yalnız alfa 255'e yazdığı için
sonradan çalışsa da silah işaretine dokunmaz.

  python tools/gen_weapon_mask.py                 # REGIONS'taki sayfalar
  python tools/gen_weapon_mask.py --preview DIR   # işaretli pikselleri kırmızı gösterir
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "anim", "redmount")
CELL_W, CELL_H = 200, 240
MARK = 252
TRACK = 26     # karelerarası en büyük silah kayması (px)
INSIDE = 0.6   # bileşenin silah sayılması için çokgende kalan en küçük oranı
GROW = 3       # işaretin çokgenden en fazla taşabileceği uzaklık (px)
FALLBACK = 0.5 # oturtma ilk karedeki işaretin bu oranından azını bulursa kare çokgene düşer

## İlk karedeki silah çokgeni (hücre pikseli, saat yönü fark etmez). Kabaca çizilir;
## sınırı bileşenler belirler. Eller ten rengidir, çokgene girmeleri sorun değil.
REGIONS = {
	"pistol_aim": [(128, 120), (160, 120), (160, 131), (150, 132), (148, 137), (140, 140), (128, 140), (125, 133)],
	"pistol_shoot": [(131, 123), (166, 123), (166, 132), (152, 133), (150, 140), (140, 142), (130, 140), (128, 131)],
	"pistol_idle": [(113, 143), (125, 141), (140, 152), (146, 158), (145, 164), (137, 166), (128, 163), (122, 160), (113, 150)],
	"pistol_walk": [(122, 138), (132, 137), (150, 148), (152, 155), (145, 158), (135, 155), (128, 152), (120, 148)],
	"rifle_aim": [(68, 121), (100, 120), (103, 116), (130, 116), (132, 119), (160, 119), (162, 114), (166, 114),
		(167, 122), (177, 124), (178, 132), (166, 133), (150, 137), (140, 141), (133, 141), (134, 165),
		(124, 165), (119, 152), (110, 152), (106, 141), (100, 135), (68, 135)],
	"rifle_shoot": [(70, 142), (97, 140), (98, 136), (127, 136), (128, 139), (152, 139), (152, 134), (156, 134),
		(157, 143), (168, 143), (168, 149), (156, 150), (150, 153), (130, 153), (128, 162), (120, 165),
		(120, 178), (105, 178), (103, 165), (97, 160), (97, 150), (70, 150)],
	"rifle_idle": [(100, 124), (112, 126), (125, 131), (138, 139), (148, 141), (150, 150), (158, 155), (161, 160),
		(157, 164), (150, 163), (140, 157), (133, 157), (123, 156), (115, 152), (111, 157), (100, 157), (97, 142), (93, 134)],
	"rifle_walk": [(100, 122), (117, 123), (130, 128), (140, 133), (146, 133), (152, 135), (155, 145), (166, 147),
		(166, 155), (150, 154), (140, 155), (133, 158), (122, 158), (120, 165), (110, 165), (108, 150), (100, 140), (95, 130)],
}
## Tüfek gövdenin önünde tutulduğu sayfalarda konturu ceketle birleşik: bileşen ayırmaz,
## işaret doğrudan çokgendir (çokgen bu yüzden sıkı çizildi).
STRICT = {"rifle_idle", "rifle_walk"}
## Nişanda dipçik omza dayanır ve ceketle tek bileşendir: bu parça her karede (aynı
## kaydırmayla) doğrudan işaretlenir.
STOCKS = {
	"rifle_aim": [(70, 121), (100, 121), (100, 134), (70, 134)],
	"rifle_shoot": [(70, 142), (97, 142), (97, 149), (70, 149)],
}


def _poly_mask(poly, dx=0, dy=0) -> np.ndarray:
	im = Image.new("L", (CELL_W, CELL_H), 0)
	ImageDraw.Draw(im).polygon([(x + dx, y + dy) for x, y in poly], fill=1, outline=1)
	return np.array(im, bool)


def _cloth(rgba: np.ndarray) -> np.ndarray:
	## Shader'ın boyadığı pikseller: doygunluğu düşük, kontur ile açık gri arası.
	rgb = rgba[..., :3].astype(np.int32)
	mx = rgb.max(axis=2)
	mn = rgb.min(axis=2)
	sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
	return (rgba[..., 3] >= 128) & (sat < 0.25) & (mx > 9) & (mx < 158)


def _track(ref: np.ndarray, cell: np.ndarray, poly) -> tuple:
	## İlk karedeki silah içeriğinin bu karede en iyi oturduğu kaydırma.
	m = _poly_mask(poly)
	ys, xs = np.nonzero(m)
	src = ref[ys, xs].astype(np.int32)
	best, best_d = None, (0, 0)
	for dy in range(-TRACK, TRACK + 1):
		ty = ys + dy
		for dx in range(-TRACK, TRACK + 1):
			tx = xs + dx
			ok = (ty >= 0) & (ty < CELL_H) & (tx >= 0) & (tx < CELL_W)
			dst = np.zeros_like(src)
			dst[ok] = cell[ty[ok], tx[ok]]
			err = np.abs(src - dst).sum(axis=1).mean()
			if best is None or err < best:
				best, best_d = err, (dx, dy)
	return best_d


def weapon_mask(cell: np.ndarray, poly, dx: int, dy: int, strict: bool = False) -> np.ndarray:
	inside = _poly_mask(poly, dx, dy)
	if strict:
		return inside & _cloth(cell)
	near = ndimage.binary_dilation(inside, np.ones((2 * GROW + 1, 2 * GROW + 1), bool))
	cloth = _cloth(cell)
	lab, cnt = ndimage.label(cloth)
	if cnt == 0:
		return np.zeros(cloth.shape, bool)
	idx = np.arange(cnt + 1)
	size = ndimage.sum(np.ones_like(lab), lab, index=idx)
	hit = ndimage.sum(inside, lab, index=idx)
	keep = (hit >= INSIDE * np.maximum(size, 1)) & (idx > 0)
	return keep[lab] & near


def process(name: str, poly) -> list:
	path = os.path.join(ROOT, name + ".png")
	px = np.array(Image.open(path).convert("RGBA"))
	alpha = px[..., 3]
	alpha[alpha == MARK] = 255
	ref = px[:, :CELL_W].copy()
	counts = []
	first = 0
	for x0 in range(0, px.shape[1], CELL_W):
		cell = px[:, x0:x0 + CELL_W]
		dx, dy = _track(ref, cell, poly) if x0 else (0, 0)
		m = weapon_mask(cell, poly, dx, dy, name in STRICT) & (cell[..., 3] >= 253)
		# bu karede silah ceketle aynı bileşene karışmış (kontur yok): çokgenin kendisi
		if x0 and m.sum() < FALLBACK * first:
			m = weapon_mask(cell, poly, dx, dy, True) & (cell[..., 3] >= 253)
		if name in STOCKS:
			m |= weapon_mask(cell, STOCKS[name], dx, dy, True) & (cell[..., 3] >= 253)
		first = first or int(m.sum())
		cell[..., 3][m] = MARK
		counts.append((dx, dy, int(m.sum())))
	Image.fromarray(px, "RGBA").save(path)
	return counts


def preview(name: str, out_dir: str) -> None:
	px = np.array(Image.open(os.path.join(ROOT, name + ".png")).convert("RGBA"))
	vis = px.copy()
	vis[px[..., 3] == MARK] = (255, 40, 40, 255)
	vis[..., 3] = np.where(px[..., 3] > 0, 255, 0)
	bg = Image.new("RGBA", (px.shape[1], px.shape[0]), (230, 230, 210, 255))
	bg.alpha_composite(Image.fromarray(vis, "RGBA"))
	bg.save(os.path.join(out_dir, "weapon_" + name + ".png"))


if __name__ == "__main__":
	if "--preview" in sys.argv:
		out = sys.argv[sys.argv.index("--preview") + 1]
		for n in REGIONS:
			preview(n, out)
	else:
		for n, p in REGIONS.items():
			c = process(n, p)
			print("%-14s %s" % (n, " ".join("%+d,%+d:%d" % t for t in c)))
