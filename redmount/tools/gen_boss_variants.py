"""Ana Vana Muhafızı ve Yayın Şefi için kendi zırh sayfaları.

İkisi de kampanyada ve Survival boss sırasında Ağır Zırhlı'nın (mini_boss) karelerini
kullanıyordu; yalnız `self_modulate` tonu farklıydı. Karelerin gövde iskeleti (ChatGPT
temel çizimi) korunur, malzeme yeniden boyanır — gen_gpt_style_props.py kuralları:
malzeme başına 8-10 tonluk rampa, gölge mor/laciverte, ışık turuncu-altına kayar.

    python tools/gen_boss_variants.py
      -> assets/anim/waterworks_chief/*.png   (paslı bakır + yeşil pas, su mavisi tüy/göz)
      -> assets/anim/broadcast_director/*.png (lacivert lake + altın, sinyal sarısı tüy, mor pelerin,
                                                 miğferde anten — ayrı silüet)

Sınıflandırma (her piksel, HLS):
  zırh   : düşük doygunluk koyu/orta (siyah çelik)     -> malzeme rampası (parlaklık bandı)
  kırmızı: ton 0-14° / 340-360°, doygun (tüy, göz, pelerin, mücevher) -> vurgu rampası
  diğer  : altın süs, toz/kum, kontur                   -> korunur
"""
import colorsys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "anim" / "mini_boss"
OUT = ROOT / "assets" / "anim"
CELL = (200, 240)

## Paslı bakır: gölge mor-kahve -> bakır -> sıcak altın şerit (10 ton).
COPPER = [(12, 7, 18), (30, 16, 26), (48, 24, 28), (70, 34, 30), (96, 48, 34),
	(122, 64, 40), (148, 84, 50), (172, 108, 66), (198, 138, 86), (220, 172, 112)]
## Yeşil pas (patina) lekeleri — bakırın koyu bantlarında, deterministik desenle.
PATINA = [(20, 34, 38), (30, 58, 56), (48, 88, 78), (76, 120, 100)]
## Su vurgusu (tüy, göz, mücevher): lacivert gölgeden camgöbeği parlamaya.
WATER = [(12, 10, 30), (18, 26, 58), (24, 50, 92), (34, 84, 128), (52, 124, 160),
	(84, 168, 192), (140, 210, 220), (206, 242, 240)]

## Lacivert lake: mor gölge -> çelik mavisi -> soğuk ay kenarı (10 ton).
NAVY = [(12, 7, 18), (18, 14, 34), (24, 22, 50), (30, 32, 68), (40, 44, 88),
	(54, 60, 110), (72, 80, 132), (96, 104, 156), (128, 136, 178), (170, 176, 204)]
## Sinyal sarısı (tüy, göz): turuncu gölgeden beyazımsı sarıya.
SIGNAL = [(34, 14, 18), (78, 34, 22), (130, 66, 24), (182, 108, 30), (222, 156, 44),
	(242, 198, 74), (250, 228, 128), (255, 246, 200)]
## Mor pelerin.
PURPLE = [(12, 7, 18), (30, 12, 34), (50, 18, 56), (72, 26, 80), (96, 38, 104),
	(122, 54, 128), (150, 76, 150), (180, 108, 172)]

CAPE_SAT = 0.55  # Pelerin kırmızısı daha koyu/donuk; tüy ve göz daha parlak.


def ramp(pal, l, lo=0.0, hi=1.0):
	t = 0.0 if hi <= lo else min(1.0, max(0.0, (l - lo) / (hi - lo)))
	return pal[min(len(pal) - 1, int(t * len(pal)))]


def patina_mask(x, y):
	## Kaba, yuvarlak lekeler: iki kafes deseninin çakıştığı yerler (gürültüsüz, kare kare sabit).
	a = ((x * 7 + y * 3) // 9) % 5 == 0
	b = ((x * 2 - y * 5) // 11) % 4 == 0
	return a and b


def classify(r, g, b):
	h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
	hd = h * 360.0
	if (hd <= 14.0 or hd >= 340.0) and s > 0.42 and l > 0.12:
		return "red", l, s
	if s < 0.22 and l < 0.46:
		return "armor", l, s
	return "keep", l, s


def paint_waterworks(img):
	out = img.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a < 10:
				continue
			kind, l, s = classify(r, g, b)
			if kind == "armor":
				c = ramp(COPPER, l, 0.02, 0.5)
				if 0.07 < l < 0.22 and patina_mask(x, y):
					c = ramp(PATINA, l, 0.07, 0.22)
				px[x, y] = c + (a,)
			elif kind == "red":
				px[x, y] = ramp(WATER, l, 0.1, 0.62) + (a,)
	return out


def paint_broadcast(img, top):
	out = img.copy()
	px = out.load()
	for y in range(out.height):
		for x in range(out.width):
			r, g, b, a = px[x, y]
			if a < 10:
				continue
			kind, l, s = classify(r, g, b)
			if kind == "armor":
				px[x, y] = ramp(NAVY, l, 0.02, 0.5) + (a,)
			elif kind == "red":
				# Tüy (anten tepesine yakın) ve parlak göz/mücevher sinyal sarısı; pelerin mor.
				near = top is not None and abs(x - top[0]) < 26 and y - top[1] < 30
				if not near and l < 0.45:
					px[x, y] = ramp(PURPLE, l, 0.08, 0.42) + (a,)
				else:
					px[x, y] = ramp(SIGNAL, l, 0.12, 0.6) + (a,)
	return out


def crest_top(cell):
	## Tüyün (doygun kırmızı) en üst noktası: anten buradan yükselir.
	px = cell.load()
	best = None
	for y in range(cell.height // 2):
		for x in range(cell.width):
			r, g, b, a = px[x, y]
			if a < 200:
				continue
			kind, l, s = classify(r, g, b)
			if kind == "red" and l > 0.3:
				if best is None or y < best[1]:
					best = (x, y)
		if best is not None:
			break
	return best


def draw_antenna(cell, top):
	## Miğferde yayın anteni: 2 px direk, iki yatay çubuk, ucunda sinyal lambası.
	## Kontur koyu mor, sol üst sıcak ışık, sağ kenar soğuk ay ışığı.
	px = cell.load()
	ox, oy = top
	ink = (12, 7, 18, 255)
	mast = [(40, 44, 88), (96, 104, 156)]
	h = 30
	def put(x, y, c):
		if 0 <= x < cell.width and 0 <= y < cell.height:
			px[x, y] = c if len(c) == 4 else c + (255,)
	base = oy + 2
	for i in range(h):
		y = base - i
		put(ox - 2, y, ink)
		put(ox - 1, y, mast[1])
		put(ox, y, mast[0])
		put(ox + 1, y, ink)
	for bar_y, half in ((base - 10, 5), (base - 18, 3)):
		for dx in range(-half - 1, half + 2):
			put(ox + dx, bar_y - 1, ink)
			put(ox + dx, bar_y + 1, ink)
		for dx in range(-half, half + 1):
			put(ox + dx, bar_y, (128, 136, 178) if dx < 0 else (72, 80, 132))
		put(ox - half - 1, bar_y, ink)
		put(ox + half + 1, bar_y, ink)
		put(ox + half, bar_y, (170, 176, 204))  # sağ uç: ay kenarı
	tip = base - h - 3
	lamp = [
		"..kkk..",
		".kSSWk.",
		"kSSWWYk",
		"kOSSSYk",
		".kOOSk.",
		"..kkk..",
	]
	cols = {"k": ink, "S": SIGNAL[4] + (255,), "W": SIGNAL[7] + (255,),
		"Y": SIGNAL[6] + (255,), "O": SIGNAL[2] + (255,)}
	for j, row in enumerate(lamp):
		for i, ch in enumerate(row):
			if ch in cols:
				put(ox - 3 + i, tip + j, cols[ch])


def process(name):
	src = Image.open(SRC / (name + ".png")).convert("RGBA")
	n = src.width // CELL[0]
	ww = Image.new("RGBA", src.size, (0, 0, 0, 0))
	bd = Image.new("RGBA", src.size, (0, 0, 0, 0))
	for i in range(n):
		cell = src.crop((i * CELL[0], 0, (i + 1) * CELL[0], CELL[1]))
		top = crest_top(cell)
		ww.alpha_composite(paint_waterworks(cell), (i * CELL[0], 0))
		b = paint_broadcast(cell, top)
		if top is not None:
			draw_antenna(b, top)
		bd.alpha_composite(b, (i * CELL[0], 0))
	for folder, im in (("waterworks_chief", ww), ("broadcast_director", bd)):
		d = OUT / folder
		d.mkdir(parents=True, exist_ok=True)
		im.save(d / (name + ".png"))


if __name__ == "__main__":
	for p in sorted(SRC.glob("*.png")):
		process(p.stem)
	print("ok")
