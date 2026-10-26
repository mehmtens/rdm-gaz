"""Mahalle evlerine sıva rengi çeşitleri (ChatGPT evlerinin aynı çizimi, yeni boya).

36 bölümün ön ve arka sırasında yalnız üç ev (`assets/environment/mahalle/house_{a,b,c}.png`)
aynı bej sıvayla tekrarlanıyordu (tasarım denetimi, 26 Ekim). İstanbul'un eski mahalle
evlerinde sıva gül kurusu, gri-mavi, okra boyalıdır. Bu araç yalnız SIVA piksellerini
yeniden boyar; pencere ışığı, kiremit, açıkta kalan tuğla, ahşap kapı/hatıl, taş söve,
bitki ve demir dokunulmadan kalır. Parlaklık (fener ışığı, gölge, doku) piksel piksel
korunur: yalnız ton ve doygunluk değişir, koyu tonlar mora kayar (tarz kuralı).

Sıva: sıcak ton (0,02–0,16), doygunluk < 0,7, orta parlaklık; doygun ve koyu pikseller
(tuğla, ahşap) dışarıda; en az 1500 piksellik bağlı bölgeler, kapanışla içindeki benekler.

  python tools/gen_house_variants.py   # house_{a,b,c}_{gul,mavi,okra}.png yazar
"""
import colorsys
import os

import numpy as np
from PIL import Image
from scipy import ndimage

DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "environment", "mahalle")
## ad -> (ton, doygunluk çarpanı, parlaklık çarpanı)
PAINTS = {
	"gul": (0.985, 1.05, 0.98),   # gül kurusu
	"mavi": (0.58, 0.55, 0.96),   # gri-mavi
	"okra": (0.115, 1.15, 0.97),  # soluk okra
}
SHADOW_HUE = 0.8   # koyu tonlar bu (mor) tona doğru kayar
SHADOW_V = 0.42    # bu parlaklığın altı gölge sayılır


def _hsv(a: np.ndarray):
	rgb = a[..., :3] / 255.0
	mx = rgb.max(axis=2)
	mn = rgb.min(axis=2)
	d = mx - mn + 1e-6
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) / 6.0
	s = np.where(mx > 0, d / np.maximum(mx, 1e-6), 0)
	return h, s, mx


def plaster_mask(a: np.ndarray) -> np.ndarray:
	h, s, v = _hsv(a)
	warm = (h >= 0.02) & (h <= 0.16) & (s > 0.1) & (s < 0.7) & (v > 0.2) & (v < 0.88) & (a[..., 3] > 200)
	# Tuğla ve ahşap: doygun ve koyu (fener ışığındaki sıva doygun ama açık kalır).
	warm &= ~((s > 0.46) & (v < 0.52))
	lab, cnt = ndimage.label(warm)
	sizes = ndimage.sum(np.ones_like(lab), lab, range(cnt + 1))
	big = (sizes >= 1500)[lab] & (lab > 0)
	return big | (ndimage.binary_closing(big, np.ones((3, 3)), iterations=2) & warm)


def repaint(a: np.ndarray, mask: np.ndarray, paint) -> np.ndarray:
	th, ts, tv = paint
	h, s, v = _hsv(a)
	out = a.copy()
	for y, x in zip(*np.nonzero(mask)):
		vv = min(1.0, v[y, x] * tv)
		hh = th
		if vv < SHADOW_V:
			# Gölge: hedef tondan mora doğru (karanlıkta daha çok).
			k = (SHADOW_V - vv) / SHADOW_V * 0.6
			dh = ((SHADOW_HUE - hh + 0.5) % 1.0) - 0.5
			hh = (hh + dh * k) % 1.0
		ss = min(1.0, s[y, x] * ts)
		r, g, b = colorsys.hsv_to_rgb(hh, ss, vv)
		rgb = np.array((r * 255.0, g * 255.0, b * 255.0))
		# Fenerin vurduğu sıva (doygun, açık) sıcaklığını kısmen korur: ışık boyadan baskın.
		glow = min(1.0, max(0.0, (s[y, x] - 0.42) / 0.25)) * min(1.0, max(0.0, (v[y, x] - 0.5) / 0.3))
		out[y, x, :3] = rgb * (1.0 - 0.65 * glow) + a[y, x, :3] * (0.65 * glow)
	return out


def main() -> None:
	for n in "abc":
		src = os.path.join(DIR, "house_%s.png" % n)
		a = np.array(Image.open(src).convert("RGBA")).astype(np.float32)
		m = plaster_mask(a)
		for name, paint in PAINTS.items():
			img = Image.fromarray(np.clip(repaint(a, m, paint), 0, 255).astype(np.uint8))
			img.save(os.path.join(DIR, "house_%s_%s.png" % (n, name)))


if __name__ == "__main__":
	main()
