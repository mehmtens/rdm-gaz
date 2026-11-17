"""REDMOUNT dövüş uyarı sesi — düşman saldırı hazırlığı (tur 267, ses denetimi).

  warn — düşmanın başında ünlem belirdiği an: kısa, keskin "çın" (bıçak ağzında ışık
         parlaması gibi) + altında hızlı yükselen hışırtı (nefes çekme). Ağır saldırıda
         oyun bunu daha kalın perdede ve daha yüksek çalar (`enemy_base._telegraph`).

Ekran dışından ya da arkadan gelen saldırıyı mobil oyuncu yalnız görselden okuyordu;
uyarı sesi saldırıdan ~0,3 sn önce kulağa haber verir. Paleti gen_ui_sfx.py ile aynı
(lowpass'li kare dalga), dövüş seslerinin üstünde ayrışsın diye daha tiz.

    python tools/gen_combat_cue_sfx.py

Çıktı: assets/audio/warn.wav, 22050 Hz mono 16-bit.
"""
import numpy as np

from gen_ui_sfx import SR, note, write


def noise_swell(dur, k0=0.05, k1=0.6, seed=7):
	## Yükselen hışırtı: beyaz gürültü, kesim frekansı zamanla açılır, sonda kesilir.
	rng = np.random.default_rng(seed)
	n = int(SR * dur)
	x = rng.uniform(-1.0, 1.0, n)
	y = np.empty(n)
	acc = 0.0
	for i in range(n):
		k = k0 + (k1 - k0) * (i / n)
		acc += k * (x[i] - acc)
		y[i] = acc
	amp = np.linspace(0.0, 1.0, n) ** 2
	return y * amp


def main():
	swell = noise_swell(0.06)
	# Çın: E6 (88) %12,5 görev oranı, bir oktav + beşli üstte hayalet (metal tını).
	ping = note(88, 0.11, duty=0.125, decay=0.035, k=0.6)
	ping += 0.35 * note(107, 0.11, duty=0.5, decay=0.015, k=0.7)
	out = np.concatenate([0.5 * swell, ping])
	write("warn", out, peak=0.55)


if __name__ == "__main__":
	main()
