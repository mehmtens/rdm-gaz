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

Şarjör değiştirme sayfalarında (`RELOADS`) silah döndüğü için her karenin kendi çokgeni
vardır; takip yapılmaz, aynı bileşen kuralı kare kare uygulanır.

Araç tekrar çalıştırılabilir: önce eski işaretleri (252) siler. Pantolon işaretini
(254) yalnız silahın üstünde ezer; `gen_costume_mask.py` yalnız alfa 255'e yazdığı için
sonradan çalışsa da silah işaretine dokunmaz.

Yakın silahlar çokgen istemez (savuruşta döner, iz gövdeden kopuk):
  - Sopa: `anahtar_*` sayfaları `bat_*`'tan `gen_pixel_weapons.py` ile türetildi; iki
    sayfanın RGB farkı tam olarak sopa (ve savuruş izi) pikselleridir.
  - Anahtar / şemsiye: aynı fark + üreticinin rampalarıyla birebir aynı renkli pikseller
    (anahtarın sonradan eklenen çenesi). Bu renkler çıplak sayfalarda yok (≤ 2 px).
  - Bıçak: ağız ve savuruş izi açık gridir (giysi eşiğinin üstü), boyanan yalnız
    kenarlarındaki orta gri. Ağız/iz bileşenlerinin (açık, doygunluğu düşük, ≥ BLADE_MIN
    px, ayakkabı hizasının üstünde) BLADE_REACH px yakınındaki küçük giysi bileşenleri
    (≤ BLADE_PART px, en az yarısı ağza yakın) işaretlenir; ceket ve pantolon büyük bileşen olduğu için dışarıda kalır.
    Kuralın kaçırdığı birkaç karede (`KNIFE_POLYS`) bıçak elle çizilmiş çokgendir.

  python tools/gen_weapon_mask.py                 # REGIONS'taki sayfalar + yakın silahlar
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


## Şarjör değiştirme sayfaları: silah kareden kareye döner, şarjör elden ayrılır; ilk kareden
## taşınamaz, bu yüzden her karenin kendi çokgeni var (birden çok parça: liste listesi).
## Bileşen yöntemi silahın yarısından azını bulursa (gövde önünde konturu ceketle birleşik)
## o parça için çokgenin kendisi kullanılır.
RELOADS = {
	"pistol_reload": [
		[(120, 112), (138, 95), (146, 98), (146, 110), (140, 120), (132, 128), (122, 128)],
		[[(115, 128), (135, 108), (144, 112), (142, 125), (135, 135), (130, 148), (118, 148), (115, 138)],
			[(135, 160), (145, 158), (155, 165), (153, 176), (138, 174)]],
		[(118, 120), (138, 102), (146, 105), (145, 118), (138, 128), (130, 135), (118, 135)],
		[(118, 135), (138, 117), (145, 120), (143, 132), (135, 140), (120, 145)],
		[(115, 140), (140, 130), (146, 135), (144, 143), (130, 145), (125, 160), (115, 160)],
		[(115, 135), (135, 124), (141, 128), (138, 140), (132, 150), (118, 155), (115, 145)],
		[(110, 148), (118, 143), (140, 150), (142, 158), (128, 160), (120, 155), (110, 155)],
		[(108, 138), (140, 133), (152, 135), (152, 145), (132, 146), (128, 155), (115, 158), (108, 150)],
	],
	"rifle_reload": [
		[(80, 135), (115, 133), (135, 126), (150, 117), (162, 120), (160, 128), (140, 138), (130, 145), (127, 160),
			(118, 165), (110, 158), (100, 153), (80, 150)],
		[(85, 140), (110, 135), (135, 120), (150, 105), (160, 108), (155, 118), (135, 135), (125, 150), (112, 160),
			(100, 162), (85, 155)],
		[(85, 138), (115, 132), (140, 120), (155, 113), (163, 118), (158, 126), (135, 145), (133, 165), (132, 178),
			(118, 178), (115, 160), (100, 157), (85, 157)],
		[(135, 158), (150, 152), (158, 156), (156, 175), (145, 180), (135, 175)],
		[(95, 132), (110, 122), (140, 104), (152, 98), (157, 103), (150, 112), (130, 133), (130, 158), (115, 170),
			(100, 165), (95, 150)],
		[(85, 168), (110, 150), (140, 128), (160, 118), (167, 122), (162, 130), (150, 138), (125, 160), (115, 175),
			(113, 192), (95, 192), (85, 182)],
		[(60, 158), (90, 150), (120, 140), (150, 130), (162, 125), (175, 130), (172, 138), (150, 145), (130, 155),
			(110, 165), (103, 188), (88, 190), (84, 172), (60, 172)],
		[(75, 140), (110, 136), (140, 130), (158, 124), (165, 128), (163, 135), (145, 140), (130, 150), (125, 178),
			(110, 178), (105, 163), (75, 160)],
	],
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


def process_reload(name: str, frames) -> list:
	path = os.path.join(ROOT, name + ".png")
	px = np.array(Image.open(path).convert("RGBA"))
	alpha = px[..., 3]
	alpha[alpha == MARK] = 255
	counts = []
	for f, polys in enumerate(frames):
		cell = px[:, f * CELL_W:(f + 1) * CELL_W]
		solid = cell[..., 3] >= 253
		m = np.zeros(solid.shape, bool)
		for poly in (polys if isinstance(polys[0], list) else [polys]):
			part = weapon_mask(cell, poly, 0, 0) & solid
			strict = weapon_mask(cell, poly, 0, 0, True) & solid
			m |= part if part.sum() >= FALLBACK * strict.sum() else strict
		cell[..., 3][m] = MARK
		counts.append(int(m.sum()))
	Image.fromarray(px, "RGBA").save(path)
	return counts


## Yakın silah sayfaları.
MELEE_SHEETS = ["idle", "walk", "attack", "attack2"]
BLADE_MIN = 10    # ağız/iz sayılan açık bileşenin en küçük boyu (göz akı daha küçük)
BLADE_REACH = 2   # ağıza bu kadar yakın giysi pikseli kenar sayılır (px)
BLADE_PART = 150  # bu boyu aşan giysi bileşeni ceket/pantolondur, işaretlenmez
SHOE_Y = 200      # bu satırın altındaki açık pikseller ayakkabıdır

## Bileşen kuralının kaçırdığı bıçak kareleri: yürüyüşte bele inen bıçağın orta gri
## kenarı pantolon/ceket bileşenine yapışık; `attack2` 0'da omuz üstündeki bıçağın ağzı
## açık gri sayılacak kadar büyük değil. Bu karelerde bıçak elle çizilmiş çokgendir,
## işaret çokgenin içindeki giysi pikselleri (RELOADS'taki "strict" gibi).
KNIFE_POLYS = {
	"knife_walk": {
		5: [[(97, 152), (108, 146), (118, 141), (124, 139), (126, 142), (118, 148), (110, 153), (100, 158), (96, 157)],
			[(115, 146), (120, 146), (120, 151), (115, 151)]],
		6: [[(89, 152), (100, 146), (110, 140), (114, 139), (115, 143), (106, 150), (96, 156), (89, 157)]],
		7: [[(105, 152), (115, 147), (125, 142), (128, 143), (127, 148), (118, 153), (108, 158), (105, 157)],
			[(135, 148), (140, 148), (140, 158), (135, 158)]],
	},
	"knife_attack2": {
		0: [[(35, 131), (41, 127), (46, 124), (49, 127), (46, 132), (41, 135), (36, 137), (34, 135)],
			[(58, 112), (64, 112), (64, 119), (59, 119)]],
	},
}


def _load(name: str) -> np.ndarray:
	return np.array(Image.open(os.path.join(ROOT, name + ".png")).convert("RGBA"))


def _mark(name: str, px: np.ndarray, m: np.ndarray) -> int:
	## Eski silah işaretini siler, yenisini yazar (saydam kenar piksellerine dokunmaz).
	alpha = px[..., 3]
	alpha[alpha == MARK] = 255
	m = m & (alpha >= 240)
	alpha[m] = MARK
	Image.fromarray(px, "RGBA").save(os.path.join(ROOT, name + ".png"))
	return int(m.sum())


def _palette_keys() -> list:
	sys.path.insert(0, os.path.dirname(__file__))
	import gen_pixel_weapons as gpw
	cols = set()
	for ramp in (gpw.RED, gpw.STEEL, gpw.BORDO, gpw.GRIP):
		cols |= set(ramp)
	return [r * 65536 + g * 256 + b for r, g, b in cols]


def _key(px: np.ndarray) -> np.ndarray:
	return px[..., 0].astype(np.int32) * 65536 + px[..., 1].astype(np.int32) * 256 + px[..., 2]


def process_melee() -> dict:
	out = {}
	keys = _palette_keys()
	for s in MELEE_SHEETS:
		bat = _load("bat_" + s)
		ref = _load("anahtar_" + s)
		diff = (bat[..., :3] != ref[..., :3]).any(axis=2) & (bat[..., 3] >= 128)
		out["bat_" + s] = _mark("bat_" + s, bat, diff)
		for w in ("anahtar", "semsiye"):
			px = _load(w + "_" + s)
			pal = np.isin(_key(px), keys) & (px[..., 3] >= 128)
			out[w + "_" + s] = _mark(w + "_" + s, px, diff | pal)
		px = _load("knife_" + s)
		m = knife_mask(px)
		cloth = _cloth(px)
		for f, polys in KNIFE_POLYS.get("knife_" + s, {}).items():
			for poly in polys:
				cell = np.zeros(cloth.shape, bool)
				cell[:, f * CELL_W:(f + 1) * CELL_W] = _poly_mask(poly)
				m |= cell & cloth
		out["knife_" + s] = _mark("knife_" + s, px, m)
	return out


def knife_mask(px: np.ndarray) -> np.ndarray:
	rgb = px[..., :3].astype(np.int32)
	mx = rgb.max(axis=2)
	mn = rgb.min(axis=2)
	sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
	bright = (px[..., 3] >= 128) & (sat < 0.25) & (mx >= 158)
	bright[SHOE_Y:] = False
	lab, cnt = ndimage.label(bright, np.ones((3, 3), bool))
	size = ndimage.sum(np.ones_like(lab), lab, index=np.arange(cnt + 1))
	blade = (size >= BLADE_MIN)[lab] & (lab > 0)
	near = ndimage.binary_dilation(blade, np.ones((2 * BLADE_REACH + 1,) * 2, bool))
	cloth = _cloth(px)
	clab, ccnt = ndimage.label(cloth)
	csize = ndimage.sum(np.ones_like(clab), clab, index=np.arange(ccnt + 1))
	small = (csize <= BLADE_PART)[clab] & (clab > 0)
	# Ağız kenarı: küçük bileşenin en az yarısı ağzın yakınında (ceket kırıntısı değil).
	hit = ndimage.sum(near, clab, index=np.arange(ccnt + 1)) >= 0.5 * np.maximum(csize, 1)
	return small & hit[clab]


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
		for n in list(REGIONS) + list(RELOADS):
			preview(n, out)
		for w in ("bat", "anahtar", "semsiye", "knife"):
			for s in MELEE_SHEETS:
				preview(w + "_" + s, out)
	else:
		for n, p in REGIONS.items():
			c = process(n, p)
			print("%-14s %s" % (n, " ".join("%+d,%+d:%d" % t for t in c)))
		for n, fr in RELOADS.items():
			print("%-14s %s" % (n, " ".join(str(k) for k in process_reload(n, fr))))
		for n, k in process_melee().items():
			print("%-16s %d" % (n, k))
