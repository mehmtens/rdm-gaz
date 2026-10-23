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
	hair = warm & (mx < 120)
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


def build_anchors() -> dict:
	out = {}
	for path in sorted(glob.glob(os.path.join(SHEETS, "*.png"))):
		name = os.path.splitext(os.path.basename(path))[0]
		im = np.array(Image.open(path).convert("RGBA"))
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
		out[name] = cells
	return out


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
	anchors = build_anchors()
	with open(os.path.join(SHEETS, "head_anchors.json"), "w", encoding="utf-8") as f:
		json.dump({"cell": [CELL_W, CELL_H], "sheets": anchors}, f, separators=(",", ":"))
	os.makedirs(OUT_DIR, exist_ok=True)
	for acc_id, fn in ACCESSORIES.items():
		fn().im.save(os.path.join(OUT_DIR, acc_id + ".png"))
	print("çapa:", sum(len(v) for v in anchors.values()), "hücre,", len(anchors), "sayfa")
	if "--preview" in sys.argv:
		dst = sys.argv[sys.argv.index("--preview") + 1] if len(sys.argv) > sys.argv.index("--preview") + 1 else "acc_preview.png"
		preview(anchors, dst)


if __name__ == "__main__":
	main()
