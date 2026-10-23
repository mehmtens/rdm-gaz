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
"""
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


def _paint(px, comp, skin_px, weapon):
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
			px[p] = _ramp(STEEL if t > 0.7 else RED, src)
		else:
			if t < 0.13:
				col = _ramp(GRIP, src)
			elif t > 0.95:
				col = _ramp(STEEL, src)
			else:
				col = _ramp(BORDO, src)
				# Katlanmış kumaş: eksene dik koyu kıvrım çizgileri.
				if int(proj[p]) % 9 == 0:
					col = BORDO[0] + (src[3],)
			px[p] = col
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
			if 0 <= q[1] < 240:
				px[q] = STEEL[2] + (255,) if (q[0] + q[1]) % 5 else STEEL[3] + (255,)
	return added


def _outline(px, pts, w, h):
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if q in s or not (0 <= q[0] < w and 0 <= q[1] < h):
				continue
			if px[q][3] < 40:
				px[q] = OUTLINE


def gen_sheet(name: str, weapon: str) -> None:
	im = Image.open(ANIM / f"bat_{name}.png").convert("RGBA")
	w, h = im.size
	px = im.load()
	for x0 in range(0, w, CELL_W):
		skin = [(x, y) for y in range(h) for x in range(x0, x0 + CELL_W) if _is_skin(px[x, y])]
		for comp in _components(px, w, h, x0):
			# Saç/kıyafet kenarındaki gürültü değil, yalnız silahın kendisi.
			if len(comp) < 40:
				continue
			added = _paint(px, comp, skin, weapon)
			_outline(px, [q for q in added if x0 <= q[0] < x0 + CELL_W and 0 <= q[1] < h], w, h)
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


def _icon_outline(im):
	px = im.load()
	pts = [(x, y) for y in range(24) for x in range(24) if px[x, y][3] > 0]
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if 0 <= q[0] < 24 and 0 <= q[1] < 24 and q not in s and px[q][3] == 0:
				px[q] = OUTLINE


def icon_anahtar() -> Image.Image:
	im = _icon_canvas()
	# Kırmızı sap sol alttan sağ üste.
	_diag(im, (3, 19), (13, 9), 3, lambda t, s: RED[3] if s < 0.3 else RED[2] if s < 0.8 else RED[1])
	px = im.load()
	# Çelik baş: sapın ucunda çapraz blok + üstte açık çene.
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
				x, y = 12 + i, 3 + j
				shade = STEEL[3] if (i + j) < 5 else STEEL[2] if (i + j) < 9 else STEEL[1]
				px[x, y] = shade + (255,)
	# Ayar vidası.
	px[13, 11] = STEEL[0] + (255,)
	px[14, 11] = STEEL[1] + (255,)
	_icon_outline(im)
	return im


def icon_semsiye() -> Image.Image:
	im = _icon_canvas()
	px = im.load()
	# Kumaş: ortada kalın, iki uca incelen kapalı şemsiye.
	for i in range(15):
		t = i / 14
		x, y = 6 + i, 17 - i
		width = 1 + round(3 * (1 - abs(t - 0.38) * 1.6))
		for k in range(max(1, width)):
			q = (x + (k + 1) // 2, y + k // 2)
			col = BORDO[3] if k == 0 else BORDO[2] if k < width - 1 else BORDO[1]
			if i % 4 == 2 and k > 0:
				col = BORDO[0]
			px[q] = col + (255,)
	# Gümüş uç.
	px[21, 2] = STEEL[3] + (255,)
	px[22, 1] = STEEL[2] + (255,)
	# Sap ve J kanca (sol alt).
	for q, c in [((5, 18), GRIP[2]), ((4, 19), GRIP[2]), ((3, 20), GRIP[1]), ((3, 21), GRIP[1]),
			((4, 22), GRIP[1]), ((5, 22), GRIP[2]), ((6, 21), GRIP[3])]:
		px[q] = c + (255,)
	# Kayış düğmesi.
	px[10, 14] = (230, 200, 120, 255)
	_icon_outline(im)
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


def _stone(px, x0, y0, flip=False):
	for j, row in enumerate(STONE):
		for i, c in enumerate(row[::-1] if flip else row):
			if c == ".":
				continue
			col = {"*": BAZALT[3], "+": BAZALT[2], "#": BAZALT[1], "-": BAZALT[0]}[c]
			px[x0 + i, y0 + j] = col + (255,)


def icon_tas() -> Image.Image:
	im = _icon_canvas()
	px = im.load()
	# Üç taşlık yığın: altta iki, üstte bir (kaldırımdan sökülmüş).
	_stone(px, 2, 14)
	_stone(px, 12, 15, True)
	_stone(px, 7, 8)
	# Yığının dibinde toprak/harç kırıntısı.
	for x, c in ((4, (92, 74, 56)), (11, (120, 98, 72)), (12, (92, 74, 56)), (20, (120, 98, 72))):
		px[x, 21] = c + (255,)
	_icon_outline(im)
	return im


def tas_mermi() -> Image.Image:
	im = Image.new("RGBA", (12, 10), (0, 0, 0, 0))
	px = im.load()
	_stone(px, 1, 1)
	pts = [(x, y) for y in range(10) for x in range(12) if px[x, y][3] > 0]
	s = set(pts)
	for (x, y) in pts:
		for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
			q = (x + dx, y + dy)
			if 0 <= q[0] < 12 and 0 <= q[1] < 10 and q not in s and px[q][3] == 0:
				px[q] = OUTLINE
	return im


def main_tas() -> None:
	icon_tas().resize((48, 48), Image.NEAREST).save(PICK / "placeholder_tas.png")
	fx = ROOT / "assets" / "fx"
	fx.mkdir(exist_ok=True)
	tas_mermi().save(fx / "tas_mermi.png")
	print("kaldırım taşı ikonu ve mermisi yazıldı")


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
