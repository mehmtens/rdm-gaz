"""REDMOUNT yeni yakın silahları: Boru Anahtarı ve Şemsiye piksel sanatı.

    python tools/gen_pixel_weapons.py

Çıktılar:
  assets/anim/redmount/{anahtar,semsiye}_{idle,walk,attack,attack2}.png
      Redmount'un sopa sayfalarından türetilir: sopa pikselleri renk maskesiyle
      bulunur, sap ucu (elin olduğu uç) tespit edilir ve silah sap→uç boyunca
      yeniden boyanır. Anahtarın ucuna çene eklenir (siluet sopadan ayrılsın).
      Gövde kareleri ve zamanlama sopayla aynı kalır — yeni animasyon seti yok.
  assets/pickups/placeholder_{anahtar,semsiye}.png
      48×48 yerde duran ikon; 24×24 elle yerleştirilmiş piksel, 2x NEAREST.
  assets/pickups/placeholder_tas.png, assets/fx/tas_mermi.png
      Kaldırım taşı: yerde üç taşlık yığın (48×48) ve uçan tek taş (12×10,
      oyunda 2x). Arnavut kaldırımı bazaltı: soğuk gri, üst yüz açık.
  assets/anim/redmount/tas_{idle,walk}.png
      Elde taş: silahsız sayfaların kopyası + yumrukta 2x taş (silah işaretli, alfa
      252). Fırlatma combo_a'nın 2–5. kareleri (player_sprite.gd TAS_SHEETS). Yalnız bunları yeniden üretmek için:
      python -c "import sys; sys.path.insert(0, 'tools'); import gen_pixel_weapons as g; g.main_tas()"
      (tam `main()` anahtar/şemsiye sayfalarını da yeniden yazar; ardından
      `gen_weapon_mask.py` çalıştırılmalı.)
"""
import random
import sys
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ANIM = ROOT / "assets" / "anim" / "redmount"
PICK = ROOT / "assets" / "pickups"
CELL_W = 200
SHEETS = ["idle", "walk", "attack", "attack2"]
OUTLINE = (22, 16, 20, 255)

# Rampalar koyu → açık (4 ton).
RED = [(70, 16, 22), (122, 28, 32), (172, 46, 40), (214, 88, 62)]
STEEL = [(48, 54, 62), (88, 96, 108), (142, 150, 160), (204, 210, 216)]
BORDO = [(46, 14, 30), (88, 22, 46), (132, 38, 64), (178, 70, 92)]
GRIP = [(26, 20, 18), (48, 36, 30), (72, 54, 42), (96, 74, 56)]
BAZALT = [(40, 42, 52), (70, 74, 86), (108, 112, 124), (152, 156, 166)]

# ChatGPT temel tarzı (gen_gpt_style_props): 8–9 tonluk rampalar, gölge mor/laciverte,
# ışık turuncu-altına kayar; kontur koyu mor. Boru anahtarı bunlarla boyanır.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_gpt_style_props as _gpt  # noqa: E402
W_RED = _gpt.RED
W_STEEL = _gpt.STEEL
W_RUST = _gpt.RUST
W_MOON = _gpt.MOON
GPT_OUTLINE = _gpt.OUTLINE
W_WOOD = _gpt.WOOD
## Şemsiye kumaşı: şarap bordosu, gölgesi mora, ışığı gül-altına kayar.
W_BORDO = [(20, 7, 20), (38, 11, 30), (58, 16, 38), (82, 22, 46), (108, 32, 54),
           (136, 46, 64), (166, 68, 78), (200, 104, 96), (228, 150, 118)]
## Arnavut kaldırımı bazaltı: soğuk gri-mor gövde, ışığa bakan üst yüz sıcak.
W_BAZALT = [(14, 10, 20), (28, 24, 36), (44, 40, 54), (62, 58, 72), (82, 78, 90),
            (106, 100, 108), (134, 124, 124), (168, 152, 136), (204, 184, 152)]


def _is_bat(p) -> bool:
	r, g, b, a = p
	if a < 128:
		return False
	mx = max(r, g, b)
	if mx < 30:
		return False
	sat = (mx - min(r, g, b)) / mx
	return r - b >= 6 and sat < 0.42 and not (r > 150 and sat > 0.3)


def _is_skin(p) -> bool:
	r, g, b, a = p
	if a < 128 or r < 140:
		return False
	sat = (r - min(r, g, b)) / r
	return sat > 0.35 and r > g > b


def _components(px, w, h, x0):
	## Hücre içindeki sopa maskesinin bağlı bileşenleri (8-komşu).
	seen = set()
	comps = []
	for y in range(h):
		for x in range(x0, x0 + CELL_W):
			if (x, y) in seen or not _is_bat(px[x, y]):
				continue
			q = deque([(x, y)])
			seen.add((x, y))
			comp = []
			while q:
				cx, cy = q.popleft()
				comp.append((cx, cy))
				for dx in (-1, 0, 1):
					for dy in (-1, 0, 1):
						nx, ny = cx + dx, cy + dy
						if x0 <= nx < x0 + CELL_W and 0 <= ny < h and (nx, ny) not in seen \
								and _is_bat(px[nx, ny]):
							seen.add((nx, ny))
							q.append((nx, ny))
			comps.append(comp)
	return comps


def _axis(comp):
	## Bileşenin ana ekseni (PCA) — birim vektör.
	n = len(comp)
	mx = sum(p[0] for p in comp) / n
	my = sum(p[1] for p in comp) / n
	sxx = sum((p[0] - mx) ** 2 for p in comp)
	syy = sum((p[1] - my) ** 2 for p in comp)
	sxy = sum((p[0] - mx) * (p[1] - my) for p in comp)
	import math
	ang = 0.5 * math.atan2(2 * sxy, sxx - syy)
	return (mx, my), (math.cos(ang), math.sin(ang))


def _ramp(ramp, p):
	lum = (p[0] * 3 + p[1] * 4 + p[2]) / 8
	i = 0 if lum < 50 else 1 if lum < 85 else 2 if lum < 135 else 3
	return ramp[i] + (p[3],)


def _lum01(p):
	return min(max(((p[0] * 3 + p[1] * 4 + p[2]) / 8 - 28) / 170.0, 0.0), 0.999)


def _right_edge(px, p):
	## Sağ komşu saydam/kontur: ay ışığı kenar parlaması alacak piksel.
	q = px[p[0] + 1, p[1]] if p[0] + 1 < 1600 else (0, 0, 0, 0)
	return q[3] < 128 or max(q[:3]) < 30


def _wrench_px(src, head, rnd, edge=False):
	## Sap: kırmızı emaye, yer yer kalkmış boya altından çelik. Baş: dövme çelik + pas.
	v = _lum01(src)
	if head:
		c = _gpt.pick(W_STEEL, v * 0.75 + 0.22, rnd, 0.5)
		if rnd.random() < 0.12:
			c = _gpt.pick(W_RUST, v * 0.8, rnd, 0.3)
	else:
		c = _gpt.pick(W_RED, v * 0.7 + 0.28, rnd, 0.45)
		if rnd.random() < 0.06:
			c = _gpt.pick(W_STEEL, v * 0.6, rnd, 0.2)  # boya kalkması
	if v > 0.8:
		c = _gpt.mix(c, (240, 200, 140), 0.25)  # fener ışığı
	if edge:
		c = _gpt.mix(c, W_MOON, 0.3)
	return c + (src[3],)


def _umbrella_px(src, t, along, rnd, edge=False):
	## Sap: cilalı ahşap. Uç: çelik yüksük. Kumaş: katlı bordo, eksene dik kıvrım
	## oluğu ve kıvrımın ışığı yakalayan sırtı.
	v = _lum01(src)
	if t < 0.13:
		c = _gpt.pick(W_WOOD, v * 0.75 + 0.2, rnd, 0.4)
	elif t > 0.95:
		c = _gpt.pick(W_STEEL, v * 0.75 + 0.25, rnd, 0.4)
	else:
		fold = along % 9
		lv = v * 0.7 + 0.22
		if fold == 0:
			lv = 0.04  # kıvrım oluğu
		elif fold == 1:
			lv += 0.18  # kıvrım sırtı
		c = _gpt.pick(W_BORDO, lv, rnd, 0.45)
	if v > 0.8:
		c = _gpt.mix(c, (240, 200, 140), 0.22)
	if edge:
		c = _gpt.mix(c, W_MOON, 0.3)
	return c + (src[3],)


def _paint(px, comp, skin_px, weapon, rnd=None):
	(cx, cy), (ax, ay) = _axis(comp)
	proj = {p: (p[0] - cx) * ax + (p[1] - cy) * ay for p in comp}
	lo = min(proj.values())
	hi = max(proj.values())
	if hi - lo < 25:
		return []
	end_lo = min(comp, key=lambda p: proj[p])
	end_hi = max(comp, key=lambda p: proj[p])

	def skin_near(e):
		return sum(1 for s in skin_px if abs(s[0] - e[0]) <= 14 and abs(s[1] - e[1]) <= 14)

	rnd = rnd or random.Random(0)
	near_lo, near_hi = skin_near(end_lo), skin_near(end_hi)
	grip_lo = near_lo >= near_hi
	# Elden kopuk bileşen savuruş izidir: yalnız yeniden boyanır, çene almaz.
	streak = near_lo == 0 and near_hi == 0
	added = []
	for p in comp:
		t = (proj[p] - lo) / (hi - lo)
		if not grip_lo:
			t = 1.0 - t
		src = px[p]
		if weapon == "anahtar":
			px[p] = _wrench_px(src, t > 0.7, rnd, edge=_right_edge(px, p))
		else:
			px[p] = _umbrella_px(src, t, int(proj[p]), rnd, edge=_right_edge(px, p))
	if weapon == "anahtar" and not streak:
		# Çene: uca dik, gövdenin "üst" yanına 5 px; ağız boşluğu 2 px.
		nx, ny = -ay, ax
		if ny > 0:
			nx, ny = -nx, -ny
		occupied = set(comp)
		for p in comp:
			t = (proj[p] - lo) / (hi - lo)
			if not grip_lo:
				t = 1.0 - t
			if t < 0.8:
				continue
			for k in range(1, 6):
				if 0.86 < t < 0.95 and k <= 3:
					continue
				q = (int(round(p[0] + nx * k)), int(round(p[1] + ny * k)))
				if q in occupied:
					continue
				occupied.add(q)
				added.append(q)
		for q in added:
			if 0 <= q[1] < 240 and 0 <= q[0] < 1600:
				# Çene: ışığa bakan uç açık, gövdeye yakın koyu; pas noktaları.
				px[q] = _wrench_px((150, 150, 150, 255) if (q[0] + q[1]) % 4 else (210, 210, 210, 255),
					True, rnd, edge=False)[:3] + (255,)
	return added


def _outline(px, pts, w, h, outline=OUTLINE):
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if q in s or not (0 <= q[0] < w and 0 <= q[1] < h):
				continue
			if px[q][3] < 40:
				px[q] = outline


def gen_sheet(name: str, weapon: str) -> None:
	im = Image.open(ANIM / f"bat_{name}.png").convert("RGBA")
	w, h = im.size
	px = im.load()
	rnd = random.Random(307 + SHEETS.index(name))
	line = GPT_OUTLINE
	for x0 in range(0, w, CELL_W):
		skin = [(x, y) for y in range(h) for x in range(x0, x0 + CELL_W) if _is_skin(px[x, y])]
		for comp in _components(px, w, h, x0):
			# Saç/kıyafet kenarındaki gürültü değil, yalnız silahın kendisi.
			if len(comp) < 40:
				continue
			added = _paint(px, comp, skin, weapon, rnd)
			_outline(px, [q for q in added if x0 <= q[0] < x0 + CELL_W and 0 <= q[1] < h], w, h, line)
	im.save(ANIM / f"{weapon}_{name}.png")


# --- Yerdeki ikonlar (24×24 → 48×48) -------------------------------------

def _icon_canvas():
	return Image.new("RGBA", (24, 24), (0, 0, 0, 0))


def _diag(im, a, b, width, color_at):
	## a→b köşegeni boyunca `width` kalınlıkta piksel; color_at(t, side) renk.
	px = im.load()
	n = max(abs(b[0] - a[0]), abs(b[1] - a[1]))
	for i in range(n + 1):
		t = i / n
		x = round(a[0] + (b[0] - a[0]) * t)
		y = round(a[1] + (b[1] - a[1]) * t)
		for k in range(width):
			# köşegene dik (+1,+1) yönünde kalınlık
			q = (x + (k + 1) // 2, y + k // 2)
			if 0 <= q[0] < 24 and 0 <= q[1] < 24:
				px[q] = color_at(t, k / max(1, width - 1)) + (255,)


def _icon_outline(im, outline=OUTLINE):
	px = im.load()
	pts = [(x, y) for y in range(24) for x in range(24) if px[x, y][3] > 0]
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if 0 <= q[0] < 24 and 0 <= q[1] < 24 and q not in s and px[q][3] == 0:
				px[q] = outline


def icon_anahtar() -> Image.Image:
	## ChatGPT tarzı: 8 tonluk kırmızı emaye sap (sol üst kenarı fener ışığında), dövme
	## çelik baş + pas, ayar vidası, koyu mor kontur, sağ kenarda ay ışığı.
	rnd = random.Random(311)
	im = _icon_canvas()
	_diag(im, (3, 19), (13, 9), 3, lambda t, s: _gpt.pick(W_RED, 0.92 - s * 0.5 - t * 0.08, rnd, 0.5))
	px = im.load()
	for _ in range(4):  # boya kalkması
		t = rnd.random()
		q = (round(3 + 10 * t) + 1, round(19 - 10 * t))
		if px[q][3]:
			px[q] = _gpt.pick(W_STEEL, 0.35, rnd, 0.2) + (255,)
	head = [
		"..####..",
		".######.",
		"###..###",
		"##....##",
		"##.....#",
		"###.....",
		".###....",
		"..##....",
	]
	for j, row in enumerate(head):
		for i, c in enumerate(row):
			if c == "#":
				v = 0.97 - (i + j) * 0.055
				col = _gpt.pick(W_STEEL, v, rnd, 0.4)
				if rnd.random() < 0.14 and i + j > 4:
					col = _gpt.pick(W_RUST, 0.5, rnd, 0.3)
				if i + j < 3:
					col = _gpt.mix(col, (240, 200, 140), 0.3)
				px[12 + i, 3 + j] = col + (255,)
	# Ayar vidası (tırtıllı halka).
	px[13, 11] = W_STEEL[1] + (255,)
	px[14, 11] = W_STEEL[6] + (255,)
	px[14, 12] = W_STEEL[3] + (255,)
	# Sağa bakan kenarlar soğuk ay ışığı alır.
	for y in range(24):
		for x in range(23, -1, -1):
			if px[x, y][3]:
				px[x, y] = _gpt.mix(px[x, y][:3], W_MOON, 0.35) + (255,)
				break
	_icon_outline(im, GPT_OUTLINE)
	return im


def icon_semsiye() -> Image.Image:
	## Kapalı şemsiye: ortada kalın, uçlara incelen katlı bordo kumaş, kıvrım olukları,
	## çelik uç, cilalı ahşap J sap, pirinç kayış düğmesi; koyu mor kontur, ay kenarı.
	rnd = random.Random(313)
	im = _icon_canvas()
	px = im.load()
	for i in range(15):
		t = i / 14
		x, y = 6 + i, 17 - i
		width = 1 + round(3 * (1 - abs(t - 0.38) * 1.6))
		for k in range(max(1, width)):
			q = (x + (k + 1) // 2, y + k // 2)
			lv = 0.82 - k / max(1, width) * 0.6
			if i % 4 == 2 and k > 0:
				lv = 0.05  # kıvrım oluğu
			px[q] = _gpt.pick(W_BORDO, lv, rnd, 0.4) + (255,)
	px[21, 2] = _gpt.mix(W_STEEL[8], (240, 200, 140), 0.2) + (255,)
	px[22, 1] = W_STEEL[5] + (255,)
	for q, v in [((5, 18), 0.6), ((4, 19), 0.7), ((3, 20), 0.5), ((3, 21), 0.35),
			((4, 22), 0.25), ((5, 22), 0.35), ((6, 21), 0.55)]:
		px[q] = _gpt.pick(W_WOOD, v, rnd, 0.2) + (255,)
	px[10, 14] = _gpt.BRASS[3] + (255,)
	for y in range(24):
		for x in range(23, -1, -1):
			if px[x, y][3]:
				px[x, y] = _gpt.mix(px[x, y][:3], W_MOON, 0.35) + (255,)
				break
	_icon_outline(im, GPT_OUTLINE)
	return im


# Tek taş: üst yüz açık, yan yüz koyu, sağ altta gölge; '#' gövde, '+' üst yüz,
# '*' parlak kenar, '-' koyu yan/çatlak.
STONE = [
	"..*++++*..",
	".*+++++++.",
	"#*++++++##",
	"##+++++###",
	"#######-##",
	"-###--###-",
	".--####--.",
]


STONE_LV = {"*": 0.9, "+": 0.62, "#": 0.32, "-": 0.1}


def _stone_col(c, i, j, w, rnd):
	## Şablon tonu + sol üst ışık eğimi + oyuk benekleri + sağ kenarda ay ışığı.
	lv = STONE_LV[c] - i / w * 0.12
	if c in "+#" and rnd.random() < 0.12:
		lv -= 0.22  # gözenek / oyuk
	col = _gpt.pick(W_BAZALT, lv, rnd, 0.5)
	if c == "*":
		col = _gpt.mix(col, (240, 200, 140), 0.2)
	if i >= w - 2 and c != "-":
		col = _gpt.mix(col, W_MOON, 0.3)
	return col


def _stone(px, x0, y0, flip=False, rnd=None):
	rnd = rnd or random.Random(317)
	w = len(STONE[0])
	for j, row in enumerate(STONE):
		for i, c in enumerate(row[::-1] if flip else row):
			if c == ".":
				continue
			px[x0 + i, y0 + j] = _stone_col(c, i, j, w, rnd) + (255,)


def icon_tas() -> Image.Image:
	im = _icon_canvas()
	px = im.load()
	# Üç taşlık yığın: altta iki, üstte bir (kaldırımdan sökülmüş).
	rnd = random.Random(331)
	_stone(px, 2, 14, rnd=rnd)
	_stone(px, 12, 15, True, rnd=rnd)
	_stone(px, 7, 8, rnd=rnd)
	# Yığının dibinde harç kırıntısı ve yosun.
	for x, c in ((4, _gpt.CREAM[2]), (11, _gpt.CREAM[1]), (12, (52, 66, 40)), (20, _gpt.CREAM[2])):
		px[x, 21] = c + (255,)
	_icon_outline(im, GPT_OUTLINE)
	return im


def tas_mermi() -> Image.Image:
	im = Image.new("RGBA", (12, 10), (0, 0, 0, 0))
	px = im.load()
	_stone(px, 1, 1, rnd=random.Random(337))
	pts = [(x, y) for y in range(10) for x in range(12) if px[x, y][3] > 0]
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if 0 <= q[0] < 12 and 0 <= q[1] < 10 and q not in s and px[q][3] == 0:
				px[q] = GPT_OUTLINE
	return im


# --- Elde taş: tas_{idle,walk} sayfaları ----------------------------------
#
# Gövde kareleri silahsız sayfalardan birebir kopyalanır (pantolon/saç işaretleri
# korunur, kostüm çapaları aynı kalır); öndeki yumruğun üstüne 2x bazalt taş çizilir.
# Taş pikselleri silah işaretiyle (alfa 252) yazılır: kostüm shader'ı gri taşı ceket
# rengine boyamaz. Fırlatmanın ayrı sayfası yok (combo_a kareleri, elde taş olmadan):
# mermi tuşa basıldığı anda doğar, geri çekiş karesinde elde taş kalsa ekranda iki taş olurdu.

WEAPON_MARK = 252
STONE_SCALE = 2


def _front_fist(px, x0, h):
	## Kalça hizasının altındaki en öndeki (en sağdaki) ten lekesinin merkezi.
	pts = [(x, y) for y in range(140, h) for x in range(x0, x0 + CELL_W) if _is_skin(px[x, y])]
	if not pts:
		return None
	right = max(x for x, _ in pts)
	blob = [(x, y) for x, y in pts if x >= right - 12]
	return (sum(x for x, _ in blob) // len(blob) - x0, sum(y for _, y in blob) // len(blob))


def _held_stone(px, cx, cy) -> None:
	## Yumruğun önüne 2x taş + kontur; yumruğun alt boğumu görünür kalsın diye
	## taş merkezi yumruğun biraz üstünde.
	s = STONE_SCALE
	w, h = len(STONE[0]) * s, len(STONE) * s
	ox, oy = cx - w // 2 + 2, cy - h + 4
	pts = set()
	rnd = random.Random(cx * 31 + cy)
	for j, row in enumerate(STONE):
		for i, c in enumerate(row):
			if c == ".":
				continue
			col = _stone_col(c, i, j, len(row), rnd)
			for dy in range(s):
				for dx in range(s):
					q = (ox + i * s + dx, oy + j * s + dy)
					px[q] = col + (WEAPON_MARK,)
					pts.add(q)
	for (x, y) in list(pts):
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if q not in pts:
				px[q] = GPT_OUTLINE[:3] + (WEAPON_MARK,)


def gen_tas_sheets() -> None:
	for base in ("idle", "walk"):
		im = Image.open(ANIM / f"{base}.png").convert("RGBA")
		w, h = im.size
		px = im.load()
		for x0 in range(0, w, CELL_W):
			fist = _front_fist(px, x0, h)
			if fist is not None:
				_held_stone(px, x0 + fist[0], fist[1])
		im.save(ANIM / f"tas_{base}.png")


def main_tas() -> None:
	icon_tas().resize((48, 48), Image.NEAREST).save(PICK / "placeholder_tas.png")
	fx = ROOT / "assets" / "fx"
	fx.mkdir(exist_ok=True)
	tas_mermi().save(fx / "tas_mermi.png")
	gen_tas_sheets()
	print("kaldırım taşı ikonu, mermisi ve elde taş sayfaları yazıldı")


def main_anahtar() -> None:
	## Yalnız boru anahtarı: sayfalar + ikon (ardından gen_weapon_mask.py).
	for name in SHEETS:
		gen_sheet(name, "anahtar")
	icon_anahtar().resize((48, 48), Image.NEAREST).save(PICK / "placeholder_anahtar.png")


def main_semsiye() -> None:
	## Yalnız şemsiye: sayfalar + ikon (ardından gen_weapon_mask.py).
	for name in SHEETS:
		gen_sheet(name, "semsiye")
	icon_semsiye().resize((48, 48), Image.NEAREST).save(PICK / "placeholder_semsiye.png")


def main() -> None:
	for weapon in ("anahtar", "semsiye"):
		for name in SHEETS:
			gen_sheet(name, weapon)
	for name, fn in (("anahtar", icon_anahtar), ("semsiye", icon_semsiye)):
		fn().resize((48, 48), Image.NEAREST).save(PICK / f"placeholder_{name}.png")
	print("silah sayfaları ve ikonları yazıldı")
	main_tas()


if __name__ == "__main__":
	main()
