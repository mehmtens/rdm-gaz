"""Kostüm aksesuarları: kare başına baş çapası + dört piksel başlık.

Kostümler yalnız giysi paletini değiştiriyordu (`shaders/player_costume.gdshader`);
siluet aynı kalıyordu. Bu araç iki şey üretir:

1. `assets/anim/redmount/head_anchors.json`: her sayfanın her 200×240 hücresi için
   `[cx, top, brow]` — saç lekesinin ortası (x), saçın tepesi (y) ve alnın üstü (y),
   hücre pikseli. Saç doygun koyu kahve, ten doygun açık turuncudur; ceket/pantolon
   doygunluğu düşüktür. En büyük saç lekesi baştır (kol/silah ahşabı küçük kalır).
2. `assets/anim/costume_acc/<id>.png`: başlıklar, 1 sanat pikseli = 1 hücre pikseli
   (sayfalarla aynı yoğunluk; oyunda rig ölçeği 0,6 ile birlikte küçülür). Karakter
   sağa bakar; siper/düğüm yönü buna göre. Her görüntünün pivotu (PIVOT) çapaya oturur:
   başlıklar saç tepesinin TOP_DROP altına, bandana alnın BROW_LIFT üstüne.

  python tools/gen_costume_accessory.py            # tablo + başlıklar
  python tools/gen_costume_accessory.py --preview  # scratch için kontrol görüntüsü
"""
import glob
import json
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, os.path.dirname(__file__))
from pixelart import Canvas, P  # noqa: E402

HERE = os.path.dirname(__file__)
SHEETS = os.path.join(HERE, "..", "assets", "anim", "redmount")
OUT_DIR = os.path.join(HERE, "..", "assets", "anim", "costume_acc")
CELL_W, CELL_H = 200, 240
ACC_W, ACC_H = 72, 44
PIVOT = (36, 30)        # görüntüde çapaya oturan nokta (ortası, başlığın alt çizgisi)


# --- 1. baş çapaları -------------------------------------------------------

def _masks(rgba: np.ndarray):
	rgb = rgba[..., :3].astype(np.float32)
	a = rgba[..., 3]
	mx = rgb.max(axis=2)
	mn = rgb.min(axis=2)
	sat = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	warm = (a >= 128) & (r >= g) & (g >= b) & (sat > 0.28) & (r - b > 14)
	# saç doygun koyu kahve (doygunluk ≥ ~0,52); sopa ahşabı grimsi kahve (≤ ~0,41).
	# Eşik olmadan baş üstü savuruşta sopa saçla tek leke olup çapayı yukarı çekiyordu.
	hair = warm & (mx < 120) & (sat > 0.46)
	skin = warm & (mx >= 150)
	return hair, skin


def cell_anchor(rgba: np.ndarray):
	hair, skin = _masks(rgba)
	if not hair.any():
		return None
	# tel tel saç tek leke olsun: önce kapanış
	joined = ndimage.binary_closing(hair, np.ones((5, 5)))
	lab, n = ndimage.label(joined)
	if n == 0:
		return None
	sizes = ndimage.sum(hair, lab, index=np.arange(1, n + 1))
	k = int(np.argmax(sizes)) + 1
	if sizes[k - 1] < 150:
		return None
	blob = (lab == k) & hair
	ys, xs = np.nonzero(blob)
	top = int(ys.min())
	# tek sivri tutam tepeyi yukarı çekmesin: en üstteki 3 satırda en az 4 piksel
	rows = np.bincount(ys - top)
	for i, c in enumerate(rows):
		if c >= 4:
			top += i
			break
	band = (ys >= top + 8) & (ys <= top + 16)
	cx = int(round((xs[band].min() + xs[band].max()) / 2)) if band.any() else int(round(xs.mean()))
	# alın: saç kutusunun içindeki en üst ten pikseli (ön yarıda)
	x0, x1 = xs.min(), xs.max()
	sk = skin.copy()
	sk[:, : max(cx - 4, 0)] = False
	sk[:, x1 + 6:] = False
	sk[: top + 6, :] = False
	sk[top + 46:, :] = False
	sy, _ = np.nonzero(sk)
	brow = int(sy.min()) if sy.size else top + 22
	return [cx, top, brow]


def build_anchors(front: dict | None = None) -> dict:
	"""Çapalar; `front` verilirse kare başına başlığın ÖNÜNE çizilecek parçaları da toplar."""
	out = {}
	footprint = _footprint() if front is not None else None
	for path in sorted(glob.glob(os.path.join(SHEETS, "*.png"))):
		name = os.path.splitext(os.path.basename(path))[0]
		im = np.array(Image.open(path).convert("RGBA"))
		# ön parçalar saç işaretsiz kesilir (araç ikinci kez çalışınca da aynı atlas)
		clear_hair_marks(im)
		cols, rows = im.shape[1] // CELL_W, im.shape[0] // CELL_H
		cells = []
		last = [100, 40, 62]
		for r in range(rows):
			for c in range(cols):
				cell = im[r * CELL_H:(r + 1) * CELL_H, c * CELL_W:(c + 1) * CELL_W]
				a = cell_anchor(cell)
				if a is None:
					a = list(last)
				cells.append(a)
				last = a
				if front is not None:
					piece = front_piece(cell, a, footprint)
					if piece is not None:
						front.setdefault(name, {})[str(len(cells) - 1)] = piece
		out[name] = cells
	return out


# --- 1b. başlığın önündeki parçalar ---------------------------------------
#
# Baş üstü savuruşta (sopa/şemsiye/anahtar ikinci vuruşu) kol ve silah başın ÖNÜNDEN
# geçer; tek katmanlı başlık bunların üstüne çizilince şapka silahı "yutuyordu". Her
# hücrede başlık izdüşümüne düşen, başa (saç + yüz) ait olmayan opak pikseller ayrı bir
# atlasa kesilir; oyunda başlığın üstüne, rig'in kostüm malzemesiyle çizilir.

FRONT_PAD = 1
FRONT_MIN = 30          # bundan küçük kırıntılar (saç tutamı ucu, kontur) atlanır


def _footprint():
	"""Dört başlığın birleşik opak maskesi, pivot (36,30) merkezli; (maske, kayma)."""
	m = np.zeros((ACC_H, ACC_W), bool)
	for fn in ACCESSORIES.values():
		m |= np.array(fn().im)[..., 3] > 0
	return m


def front_piece(cell: np.ndarray, a: list, footprint: np.ndarray):
	"""[x, y, w, h, rgba] (hücre pikseli) ya da None."""
	keep = front_mask(cell, a, footprint)
	if keep is None:
		return None
	ys, xs = np.nonzero(keep)
	x0, y0 = xs.min() - FRONT_PAD, ys.min() - FRONT_PAD
	x1, y1 = xs.max() + 1 + FRONT_PAD, ys.max() + 1 + FRONT_PAD
	crop = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
	sub = keep[max(y0, 0):y1, max(x0, 0):x1]
	src = cell[max(y0, 0):y1, max(x0, 0):x1]
	dst = crop[max(0, -y0):max(0, -y0) + sub.shape[0], max(0, -x0):max(0, -x0) + sub.shape[1]]
	dst[sub] = src[sub]
	return [int(x0), int(y0), int(x1 - x0), int(y1 - y0), crop]


def front_mask(cell: np.ndarray, a: list, footprint: np.ndarray):
	"""Başlığın önüne çizilecek pikseller (hücre maskesi) ya da None."""
	cx, top, brow = a
	hair, skin = _masks(cell)
	opaque = cell[..., 3] >= 128
	# başlık izdüşümü: taç başlıklar tepeye, bandana alına oturur
	fp = np.zeros(opaque.shape, bool)
	for ay in (top + 16, brow - 2):
		x0, y0 = cx - PIVOT[0], ay - PIVOT[1]
		ys, xs = np.nonzero(footprint)
		ys, xs = ys + y0, xs + x0
		ok = (ys >= 0) & (ys < fp.shape[0]) & (xs >= 0) & (xs < fp.shape[1])
		fp[ys[ok], xs[ok]] = True
	# baş: çapadaki saç lekesi + ona değen en büyük ten lekesi (yüz), delikleri (göz,
	# kaş) dolu, kontur ve tutam uçları için 4 px genişletilmiş
	lab, n = ndimage.label(ndimage.binary_closing(hair, np.ones((5, 5))))
	head = np.zeros(opaque.shape, bool)
	if n:
		sizes = ndimage.sum(hair, lab, index=np.arange(1, n + 1))
		head = (lab == int(np.argmax(sizes)) + 1) & hair
	near = ndimage.binary_dilation(head, iterations=3)
	sl, sn = ndimage.label(skin)
	if sn:
		ids = np.unique(sl[near & skin])
		ids = ids[ids > 0]
		if ids.size:
			sizes = ndimage.sum(skin, sl, index=ids)
			head |= sl == ids[int(np.argmax(sizes))]
	head = ndimage.binary_dilation(ndimage.binary_fill_holes(head), iterations=4)
	front = opaque & fp & ~head
	fl, fn_ = ndimage.label(front)
	if fn_ == 0:
		return None
	sizes = ndimage.sum(front, fl, index=np.arange(1, fn_ + 1))
	keep = np.isin(fl, np.nonzero(sizes >= FRONT_MIN)[0] + 1)
	if not keep.any():
		return None
	return keep


def pack_front(front: dict, path: str) -> dict:
	"""Parçaları raf yöntemiyle tek atlasa dizer; {sayfa: {hücre: [ax, ay, w, h, x, y]}}."""
	items = sorted(((s, i, p) for s, d in front.items() for i, p in d.items()),
		key=lambda t: -t[2][3])
	width, x, y, shelf = 512, 0, 0, 0
	placed = []
	for s, i, p in items:
		w, h = p[2], p[3]
		if x + w > width:
			x, y, shelf = 0, y + shelf, 0
		placed.append((s, i, p, x, y))
		x += w
		shelf = max(shelf, h)
	atlas = np.zeros((max(1, y + shelf), width, 4), np.uint8)
	table: dict = {}
	for s, i, p, ax, ay in placed:
		atlas[ay:ay + p[3], ax:ax + p[2]] = p[4]
		table.setdefault(s, {})[i] = [ax, ay, p[2], p[3], p[0], p[1]]
	Image.fromarray(atlas, "RGBA").save(path)
	return table


# --- 1c. başlığın üstünden taşan saç ---------------------------------------
#
# Başlık saç tepesinin TOP_DROP altına oturur; sivri tutamlar şapkanın tepesinden
# dışarı çıkıyor, gece fener konturu da bunları şapkanın üstünde tırtıklı bir hâle
# olarak çiziyordu (şapka saçı delip geçmiş gibi). Her taç başlık için o hücrede
# başlığın tepe çizgisinin üstünde kalan baş pikselleri sayfanın alfasına bit olarak
# gömülür: alfa = 255 - 2·bitler (pantolon işareti 254 tektir, çakışmaz). Kostüm
# shader'ı (`hair_bit`) kendi başlığının bitini taşıyan pikseli saydam sayar.

HAIR_BITS = {"vapurcu": 1, "hamal": 2, "kahveci": 4}
HAIR_MIN_ALPHA = 255 - 2 * 7      # 241: bu aralık (241..253, çift fark) saç işaretidir
HAIR_REACH = 8          # saç lekesinden bu kadar uzaktaki koyu tutam pikselleri de baştır
PROTECT_MIN = 60        # baş dışındaki bu boydan büyük parçalar (el, silah) dokunulmaz


def clear_hair_marks(px: np.ndarray) -> None:
	a = px[..., 3]
	m = (a >= HAIR_MIN_ALPHA) & (a < 254) & ((255 - a.astype(np.int16)) % 2 == 0)
	a[m] = 255


_HAT_MASKS: dict = {}


def _hat_mask(hat_id: str) -> np.ndarray:
	if hat_id not in _HAT_MASKS:
		_HAT_MASKS[hat_id] = np.array(ACCESSORIES[hat_id]().im)[..., 3] > 0
	return _HAT_MASKS[hat_id]


def hair_over_hat(cell: np.ndarray, a: list, footprint: np.ndarray) -> np.ndarray:
	"""Hücre maskesi: her pikselin gizlendiği başlıkların bitleri (0 = görünür)."""
	cx, top, _brow = a
	hair, skin = _masks(cell)
	opaque = cell[..., 3] >= 128
	bits = np.zeros(opaque.shape, np.uint8)
	lab, n = ndimage.label(ndimage.binary_closing(hair, np.ones((5, 5))))
	if n == 0:
		return bits
	sizes = ndimage.sum(hair, lab, index=np.arange(1, n + 1))
	head = (lab == int(np.argmax(sizes)) + 1) & hair
	# saç tutamlarının koyu kontur/gölge pikselleri doygun saç maskesine girmez; baş
	# bölgesi bu yüzden HAIR_REACH kadar genişletilir
	near = ndimage.binary_dilation(ndimage.binary_fill_holes(head), iterations=HAIR_REACH)
	# baştan ayrı büyük parçalar (eller, silah) korunur
	far = opaque & ~near
	fl, fn_ = ndimage.label(far)
	protect = np.zeros(opaque.shape, bool)
	if fn_:
		fs = ndimage.sum(far, fl, index=np.arange(1, fn_ + 1))
		protect = np.isin(fl, np.nonzero(fs >= PROTECT_MIN)[0] + 1)
	if protect.any():
		# el/silah baş bölgesine girdiği yerde de korunur: saç olmayan pikseller boyunca büyüt
		for _ in range(HAIR_REACH + 2):
			protect = ndimage.binary_dilation(protect) & opaque & ~hair
		protect = ndimage.binary_dilation(protect)
	# başlığın önüne çizilen parçalar (el, silah, savuruş izi) ve kenar konturları korunur;
	# yalnız 2 px: daha fazlası izin altındaki saç tutamlarına yayılıyordu
	keep = front_mask(cell, a, footprint)
	if keep is not None:
		protect |= ndimage.binary_dilation(keep, iterations=2)
	cand = opaque & near & ~protect & ~skin
	h, w = opaque.shape
	for hat_id, bit in HAIR_BITS.items():
		hm = _hat_mask(hat_id)
		x0, y0 = cx - PIVOT[0], top + 16 - PIVOT[1]
		for hx in range(ACC_W):
			col = np.nonzero(hm[:, hx])[0]
			x = x0 + hx
			if col.size == 0 or x < 0 or x >= w:
				continue
			y_top = max(0, min(h, y0 + int(col.min())))
			sel = cand[:y_top, x]
			bits[:y_top, x][sel] |= bit
	return bits


def mark_hair(anchors: dict) -> int:
	"""Sayfalara saç işaretlerini gömer (önce eskileri siler); işaretli piksel sayısı."""
	total = 0
	footprint = _footprint()
	for path in sorted(glob.glob(os.path.join(SHEETS, "*.png"))):
		name = os.path.splitext(os.path.basename(path))[0]
		px = np.array(Image.open(path).convert("RGBA"))
		clear_hair_marks(px)
		cols, rows = px.shape[1] // CELL_W, px.shape[0] // CELL_H
		for i, a in enumerate(anchors[name]):
			r, c = divmod(i, cols)
			cell = px[r * CELL_H:(r + 1) * CELL_H, c * CELL_W:(c + 1) * CELL_W]
			bits = hair_over_hat(cell, a, footprint)
			m = (bits > 0) & (cell[..., 3] == 255)
			cell[..., 3][m] = 255 - 2 * bits[m]
			total += int(m.sum())
		Image.fromarray(px, "RGBA").save(path)
	return total


# --- 2. başlıklar ----------------------------------------------------------

def _ramp(c: Canvas, mask, ramp, light_dir=(-0.6, -0.8), dith=True):
	"""Maskeyi 4 tonla boyar: sol üstten ışık, kenara doğru koyulaşan gölge."""
	pts = [(x, y) for y in range(c.h) for x in range(c.w) if mask(x, y)]
	if not pts:
		return
	xs = [p[0] for p in pts]
	ys = [p[1] for p in pts]
	cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
	hw, hh = max((max(xs) - min(xs)) / 2, 1), max((max(ys) - min(ys)) / 2, 1)
	for x, y in pts:
		u, v = (x - cx) / hw, (y - cy) / hh
		t = -(u * light_dir[0] + v * light_dir[1])     # -1 (gölge) … 1 (ışık)
		lv = 1.5 + 1.3 * t
		if dith and (x + y) % 2 == 0:
			lv += 0.35
		c.put(x, y, ramp[int(max(0, min(3, lv)))])


def _ell(cx, cy, rx, ry):
	return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0


def kasket() -> Canvas:
	"""KAHVECİ: kahve tonu tüvit kasket; tepe öne doğru basık, kısa siper."""
	c = Canvas(ACC_W, ACC_H)
	px, py = PIVOT
	tweed = ["wood0", "wood1", "wood2", "wood3"]
	crown = lambda x, y: _ell(px - 2, py - 3, 27, 11)(x, y) and y <= py + 1 and \
		y >= py - 13 + max(0, (x - px - 6)) // 5
	_ramp(c, crown, tweed)
	# tüvit beneği
	for y in range(c.h):
		for x in range(c.w):
			if crown(x, y) and (x * 7 + y * 3) % 11 == 0:
				c.put(x, y, "sand2")
	# tepe düğmesi ve dikiş
	c.put(px - 3, py - 14, "wood2")
	c.put(px - 2, py - 14, "wood3")
	for x in range(px - 22, px + 20, 2):
		if crown(x, py - 2):
			c.put(x, py - 2, "wood0")
	# siper: öne uzanan kısa, koyu bant
	for i, x in enumerate(range(px + 18, px + 33)):
		for y in range(py - 2 + i // 6, py + 2):
			c.put(x, y, "wood1" if y < py else "wood0")
	c.outline()
	return c


def bere() -> Canvas:
	"""HAMAL: haki yün bere; kıvrık ağız bandı, üstte örgü izleri."""
	c = Canvas(ACC_W, ACC_H)
	px, py = PIVOT
	khaki = [(52, 54, 26, 255), (84, 86, 44, 255), (116, 116, 64, 255), (150, 148, 92, 255)]
	dome = lambda x, y: _ell(px, py - 4, 26, 17)(x, y) and y <= py - 3
	_ramp(c, dome, khaki)
	for x in range(px - 20, px + 22, 4):
		for y in range(py - 18, py - 3):
			if dome(x, y) and (y % 3) != 0:
				c.put(x, y, khaki[0] if dome(x + 1, y) else khaki[1])
	# kıvrık bant: 5 px, dikey ribler
	for y in range(py - 4, py + 2):
		for x in range(px - 26, px + 27):
			if abs(x - px) <= 26 - max(0, y - py) * 2:
				rib = (x % 3 == 0)
				lv = 2 if y < py - 1 else 1
				c.put(x, y, khaki[lv - 1] if rib else khaki[lv])
	c.outline()
	return c


def kaptan() -> Canvas:
	"""VAPURCU: beyaz tepeli kaptan şapkası, lacivert bant, siyah siper, altın çapa."""
	c = Canvas(ACC_W, ACC_H)
	px, py = PIVOT
	white = ["cream", (226, 220, 204, 255), "white", (255, 252, 240, 255)]
	navy = [(10, 16, 40, 255), (22, 32, 70, 255), (40, 56, 108, 255), (70, 92, 150, 255)]
	# yayvan tepe: bandın üstünde, arkaya taşan
	top = lambda x, y: _ell(px - 3, py - 11, 29, 6)(x, y)
	_ramp(c, top, white, dith=False)
	band = lambda x, y: abs(x - px + 1) <= 23 and py - 7 <= y <= py
	_ramp(c, band, navy, dith=False)
	for x in range(px - 22, px + 23):
		c.put(x, py - 7, navy[3] if x % 2 == 0 else navy[2])
	# altın çapa rozeti (önde)
	ax, ay = px + 13, py - 5
	for dx, dy, col in ((0, 0, "gold3"), (0, 1, "gold2"), (0, 2, "gold2"), (-1, 3, "gold1"),
			(1, 3, "gold1"), (0, 3, "gold2"), (-1, 1, "gold1"), (1, 1, "gold1")):
		c.put(ax + dx, ay + dy, col)
	# siper: önde aşağı eğik, parlak kenar
	for i, x in enumerate(range(px + 16, px + 33)):
		y0 = py - 1 + i // 5
		c.put(x, y0, "iron2" if i < 14 else "iron1")
		c.put(x, y0 + 1, "iron0")
		c.put(x, y0 + 2, "iron0")
	c.outline()
	return c


def bandana() -> Canvas:
	"""KIZIL DAĞ: alına bağlı kırmızı bandana; arkada düğüm ve iki sarkan uç."""
	c = Canvas(ACC_W, ACC_H)
	px, py = PIVOT
	red = ["red0", "red1", "red2", "red3"]
	# başa dolanan bant: önde aşağı, arkada yukarı hafif eğik
	for x in range(px - 24, px + 25):
		yc = py - 3 - (px - x) // 10
		for y in range(yc - 3, yc + 3):
			lv = 3 if y == yc - 3 else (2 if y <= yc else 1)
			if (x + y) % 5 == 0 and lv == 2:
				lv = 1
			c.put(x, y, red[lv])
	# beyaz puantiye (bandana deseni)
	for x in range(px - 20, px + 22, 6):
		yc = py - 3 - (px - x) // 10
		c.put(x, yc - 1, "cream")
	# arka düğüm + sarkan uçlar
	kx, ky = px - 25, py - 6
	c.disc(kx, ky, 3, "red1")
	c.put(kx - 1, ky - 1, "red3")
	for i in range(11):
		c.put(kx - 2 - i // 2, ky + 2 + i, red[1 + (i % 2)])
		c.put(kx - 3 - i // 2, ky + 2 + i, red[1])
	for i in range(8):
		c.put(kx - 5 - i, ky + 1 + i // 2, red[2])
		c.put(kx - 5 - i, ky + 2 + i // 2, red[0])
	c.outline()
	return c


ACCESSORIES = {"kahveci": kasket, "hamal": bere, "vapurcu": kaptan, "kizil": bandana}


def preview(anchors: dict, path: str) -> None:
	"""Her başlık, dört pozda (idle/run/combo_a/kick ilk kare) 2x büyütülmüş."""
	sheets = ["idle", "run", "combo_a", "kick", "jump", "crouch"]
	rows = []
	for acc_id, fn in ACCESSORIES.items():
		acc = Image.open(os.path.join(OUT_DIR, acc_id + ".png"))
		row = Image.new("RGBA", (CELL_W * len(sheets), CELL_H), (200, 230, 200, 255))
		for i, s in enumerate(sheets):
			sheet = Image.open(os.path.join(SHEETS, s + ".png")).convert("RGBA")
			cell = sheet.crop((CELL_W, 0, CELL_W * 2, CELL_H)) if sheet.width >= 2 * CELL_W else sheet.crop((0, 0, CELL_W, CELL_H))
			ai = 1 if sheet.width >= 2 * CELL_W else 0
			cx, top, brow = anchors[s][ai]
			y = brow - 2 if acc_id == "kizil" else top + 16
			row.alpha_composite(cell, (i * CELL_W, 0))
			row.alpha_composite(acc, (i * CELL_W + cx - PIVOT[0], y - PIVOT[1]))
		rows.append(row.crop((0, 0, row.width, 130)))
	out = Image.new("RGBA", (rows[0].width, 130 * len(rows)))
	for i, r in enumerate(rows):
		out.alpha_composite(r, (0, 130 * i))
	out.resize((out.width * 2 // 2, out.height * 2 // 2), Image.NEAREST).save(path)


def main() -> None:
	os.makedirs(OUT_DIR, exist_ok=True)
	front: dict = {}
	anchors = build_anchors(front)
	table = pack_front(front, os.path.join(OUT_DIR, "head_front.png"))
	with open(os.path.join(SHEETS, "head_anchors.json"), "w", encoding="utf-8") as f:
		json.dump({"cell": [CELL_W, CELL_H], "sheets": anchors, "front": table}, f,
			separators=(",", ":"))
	for acc_id, fn in ACCESSORIES.items():
		fn().im.save(os.path.join(OUT_DIR, acc_id + ".png"))
	hidden = mark_hair(anchors)
	print("çapa:", sum(len(v) for v in anchors.values()), "hücre,", len(anchors), "sayfa;",
		"ön parça:", sum(len(v) for v in table.values()), "hücre;",
		"şapka üstü saç:", hidden, "px")
	if "--preview" in sys.argv:
		dst = sys.argv[sys.argv.index("--preview") + 1] if len(sys.argv) > sys.argv.index("--preview") + 1 else "acc_preview.png"
		preview(anchors, dst)


if __name__ == "__main__":
	main()
