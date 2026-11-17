"""REDMOUNT menü sesleri — gezinme tıkı, seçim, reddetme.

Oyunun chiptune/saz paletine uyan kısa sesler (gen_music.py ile aynı aile):
  ui_move   — odak değişince: kısa, yumuşak kare dalga tıkı (saz telinin mızrap ucu gibi)
  ui_select — düğmeye basınca: hicaz'ın 1→4 aralığında iki notalı parlak çıkış
  ui_deny   — coin yetmeyince: alçak, kısık iki "bıt" (kulağa "yok" gibi gelir)

    python tools/gen_ui_sfx.py

Çıktı: assets/audio/ui_*.wav, 22050 Hz mono 16-bit (mevcut efektlerle aynı biçim).
"""
import wave
from pathlib import Path

import numpy as np

SR = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "audio"


def midi_hz(m):
	return 440.0 * 2.0 ** ((m - 69) / 12.0)


def square(freq, dur, duty=0.5):
	t = np.arange(int(SR * dur)) / SR
	phase = (t * freq) % 1.0
	return np.where(phase < duty, 1.0, -1.0)


def env(n, attack=0.002, decay=0.06):
	t = np.arange(n) / SR
	a = np.clip(t / attack, 0.0, 1.0)
	return a * np.exp(-t / decay)


def lowpass(x, k=0.35):
	## Tek kutuplu yumuşatma — kare dalganın cızırtısını alır, "chip" karakteri kalır.
	y = np.empty_like(x)
	acc = 0.0
	for i, v in enumerate(x):
		acc += k * (v - acc)
		y[i] = acc
	return y


def note(m, dur, duty=0.5, decay=0.06, k=0.35):
	x = square(midi_hz(m), dur, duty)
	return lowpass(x * env(len(x), decay=decay), k)


def write(name, x, peak=0.6):
	x = x / max(1e-6, np.max(np.abs(x))) * peak
	# Sonda tık olmasın: son 4 ms'yi sıfıra indir.
	fade = min(len(x), int(SR * 0.004))
	x[-fade:] *= np.linspace(1.0, 0.0, fade)
	data = (x * 32767).astype("<i2").tobytes()
	with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
		w.setnchannels(1)
		w.setsampwidth(2)
		w.setframerate(SR)
		w.writeframes(data)
	print(f"{name}.wav  {len(x) / SR * 1000:.0f} ms")


def main():
	# Gezinme: A5 üzerinde %25 görev oranlı çok kısa tık + bir oktav üstte hayalet.
	mv = note(81, 0.045, duty=0.25, decay=0.012, k=0.45)
	mv[: len(mv)] += 0.25 * note(93, 0.045, duty=0.5, decay=0.006, k=0.5)
	write("ui_move", mv, peak=0.45)

	# Seçim: hicaz D(74) → G(79) (1→4), ikinci nota uzun ve parlak.
	a = note(74, 0.05, duty=0.5, decay=0.03)
	b = note(79, 0.13, duty=0.25, decay=0.06)
	sel = np.concatenate([a, b])
	sel[len(a):] += 0.3 * note(86, 0.13, duty=0.5, decay=0.03, k=0.5)
	write("ui_select", sel, peak=0.55)

	# Reddetme: iki alçak, kısık "bıt" (E3 → Eb3, küçük ikili iniş — hicaz renginde).
	gap = np.zeros(int(SR * 0.03))
	d1 = note(52, 0.07, duty=0.125, decay=0.05, k=0.25)
	d2 = note(51, 0.11, duty=0.125, decay=0.07, k=0.25)
	write("ui_deny", np.concatenate([d1, gap, d2]), peak=0.6)


if __name__ == "__main__":
	main()
