"""REDMOUNT müzik üreticisi — Türk makamı tadında chiptune + saz döngüleri.

Her parça çok bölümlü (giriş / A / B / A' / ara) ~50-80 sn'lik kesintisiz döngüdür.
Çalgılar: bağlama benzeri telli (Karplus-Strong), kare dalga lead, ney benzeri
nefesli, üçgen bas, darbuka (düm / tek / ka). Döngü sonu kuyruğu başa karıştırılır.

    python tools/gen_music.py            # hepsini yaz (assets/music/mus_*.wav)
    python tools/gen_music.py street     # tek parça

Çıktı: 32 kHz mono 16-bit WAV. Godot içe aktarımında loop_mode=1 (music.gd de zorlar).
"""
import sys
import wave
from pathlib import Path

import numpy as np
from scipy.signal import lfilter

SR = 32000
OUT = Path(__file__).resolve().parent.parent / "assets" / "music"

SCALES = {
    "hicaz": [0, 1, 4, 5, 7, 8, 10],
    "ussak": [0, 1, 3, 5, 7, 8, 10],
    "nihavent": [0, 2, 3, 5, 7, 8, 11],
    "rast": [0, 2, 4, 5, 7, 9, 10],
}


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12.0)


# --- Çalgılar ---------------------------------------------------------------

def env(n, a=0.005, d=0.1, s=0.6, r=0.05):
    t = np.arange(n) / SR
    e = np.ones(n) * s
    ai = int(a * SR)
    di = int(d * SR)
    ri = int(r * SR)
    if ai > 0:
        e[:ai] = np.linspace(0, 1, ai)
    if di > 0:
        e[ai:ai + di] = np.linspace(1, s, len(e[ai:ai + di]))
    if ri > 0 and ri < n:
        e[-ri:] *= np.linspace(1, 0, ri)
    return e


def saz(freq, dur, rng, bright=0.5):
    """Bağlama: Karplus-Strong telli + hafif ikinci tel (oktav) + metalik parlaklık."""
    n = int(dur * SR)
    out = np.zeros(n)
    for mul, amp in ((1.0, 1.0), (2.0, 0.35)):
        p = max(2, int(SR / (freq * mul)))
        decay = 0.996 - (1 - bright) * 0.004
        # Karplus-Strong özyinelemesi: y[n] = x[n] + d/2 (y[n-p] + y[n-p-1])
        x = np.zeros(n)
        x[:p] = rng.uniform(-1, 1, min(p, n))
        a_coef = np.zeros(p + 2)
        a_coef[0] = 1.0
        a_coef[p] = -0.5 * decay
        a_coef[p + 1] = -0.5 * decay
        out += lfilter([1.0], a_coef, x) * amp
    return out * env(n, 0.001, 0.0, 1.0, 0.03)


def pulse(freq, dur, duty=0.25, vib=0.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    f = freq * (1 + vib * np.sin(2 * np.pi * 5.5 * t) * np.clip(t * 4 - 0.4, 0, 1))
    ph = np.cumsum(f) / SR
    return np.where((ph % 1.0) < duty, 1.0, -1.0) * env(n, 0.004, 0.08, 0.55, 0.04)


def ney(freq, dur, rng):
    n = int(dur * SR)
    t = np.arange(n) / SR
    f = freq * (1 + 0.006 * np.sin(2 * np.pi * 5.0 * t))
    ph = np.cumsum(f) / SR
    tone = np.sin(2 * np.pi * ph) + 0.25 * np.sin(4 * np.pi * ph) + 0.08 * np.sin(6 * np.pi * ph)
    breath = rng.normal(0, 1, n)
    breath = np.convolve(breath, np.ones(18) / 18, mode="same") * 0.35
    return (tone + breath) * env(n, 0.09, 0.15, 0.8, 0.12)


def tri_bass(freq, dur):
    n = int(dur * SR)
    t = np.arange(n) / SR
    ph = (freq * t) % 1.0
    tri = 4 * np.abs(ph - 0.5) - 1
    sq = np.where(ph < 0.5, 1.0, -1.0) * 0.25
    return (tri + sq) * env(n, 0.003, 0.12, 0.7, 0.03)


def dum(rng):
    n = int(0.32 * SR)
    t = np.arange(n) / SR
    f = 95 * np.exp(-t * 9) + 52
    ph = np.cumsum(f) / SR
    body = np.sin(2 * np.pi * ph) * np.exp(-t * 11)
    click = rng.normal(0, 1, n) * np.exp(-t * 160) * 0.3
    return (body + click) * 1.1


def tek(rng):
    n = int(0.12 * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    # Yüksek geçiren: gövdeyi at, parlak "tek" kalsın.
    hp = noise - np.convolve(noise, np.ones(6) / 6, mode="same")
    ring = np.sin(2 * np.pi * 1850 * t) * 0.35
    return (hp * 0.9 + ring) * np.exp(-t * 48) * 0.75


def ka(rng):
    n = int(0.07 * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    hp = noise - np.convolve(noise, np.ones(4) / 4, mode="same")
    return hp * np.exp(-t * 70) * 0.4


def hat(rng):
    n = int(0.05 * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    hp = noise - np.convolve(noise, np.ones(3) / 3, mode="same")
    return hp * np.exp(-t * 110) * 0.22


# --- Besteci ----------------------------------------------------------------

class Track:
    def __init__(self, bpm, bars, seed):
        self.bpm = bpm
        self.beat = 60.0 / bpm
        self.bar = self.beat * 4
        self.n = int(self.bar * bars * SR)
        self.tail = int(2.0 * SR)
        self.buf = np.zeros(self.n + self.tail)
        self.rng = np.random.default_rng(seed)

    def add(self, t, sig, gain):
        i = int(t * SR)
        end = min(i + len(sig), len(self.buf))
        if i < len(self.buf):
            self.buf[i:end] += sig[: end - i] * gain

    def render(self):
        out = self.buf[: self.n].copy()
        out[: self.tail] += self.buf[self.n:]          # kuyruk başa: kusursuz döngü
        out -= np.mean(out)
        peak = np.max(np.abs(out)) + 1e-9
        return out / peak * 0.89


def drum_pattern(tr, bar0, bars, style, rng, fill_every=4):
    """style: maksum (düm tek . tek düm . tek .) / ayyub / battle."""
    patterns = {
        "maksum": ["D", "T", "", "T", "D", "", "T", ""],
        "ayyub": ["D", "", "T", "", "D", "", "T", ""],
        "battle": ["D", "k", "T", "k", "D", "D", "T", "k"],
        "sparse": ["D", "", "", "", "", "", "T", ""],
    }
    pat = patterns[style]
    e8 = tr.beat / 2
    for b in range(bars):
        for i, hit in enumerate(pat):
            t = (bar0 + b) * tr.bar + i * e8
            fill = (b % fill_every == fill_every - 1) and i >= 6
            if hit == "D":
                tr.add(t, dum(rng), 0.85)
            elif hit == "T":
                tr.add(t, tek(rng), 0.55)
            elif hit == "k":
                tr.add(t, ka(rng), 0.5)
            if fill:
                tr.add(t + e8 / 2, tek(rng), 0.42)
                tr.add(t + e8 * 0.75, ka(rng), 0.35)
            if style == "battle":
                tr.add(t, hat(rng), 0.6)
                tr.add(t + e8 / 2, hat(rng), 0.35)
            else:
                tr.add(t + e8 / 2, ka(rng), 0.18)


def phrase(rng, scale, length, start_deg=0, span=6, rest_p=0.12, leap_p=0.2):
    """Bir motif: (derece, süre-sekizlik) listesi; kademeli hareket, ara sıra sıçrama."""
    notes = []
    deg = start_deg
    left = length
    durs = [1, 1, 1, 2, 2, 3, 4]
    while left > 0:
        d = int(rng.choice(durs))
        d = min(d, left)
        if rng.random() < rest_p and notes:
            notes.append((None, d))
        else:
            step = int(rng.choice([-1, 1, 1, -2, 2])) if rng.random() > leap_p else int(rng.choice([-4, 3, 4]))
            deg = int(np.clip(deg + step, -2, span))
            notes.append((deg, d))
        left -= d
    # Cümle sonu: tonik ya da beşliye otur.
    if notes and notes[-1][0] is not None:
        notes[-1] = (int(rng.choice([0, 4])), notes[-1][1])
    return notes


def deg_to_midi(root, scale, deg):
    octv, idx = divmod(deg, len(scale))
    return root + scale[idx] + 12 * octv


def play_phrase(tr, bar0, notes, root, scale, inst, gain, rng, octave=0):
    e8 = tr.beat / 2
    t = bar0 * tr.bar
    for deg, d in notes:
        dur = d * e8
        if deg is not None:
            f = midi_hz(deg_to_midi(root + 12 * octave, scale, deg))
            if inst == "saz":
                sig = saz(f, dur + 0.25, rng)
            elif inst == "pulse":
                sig = pulse(f, dur * 0.95, duty=0.25, vib=0.008)
            elif inst == "pulse12":
                sig = pulse(f, dur * 0.9, duty=0.125, vib=0.01)
            else:
                sig = ney(f, dur * 1.02, rng)
            tr.add(t, sig, gain)
            # Türk süslemesi: uzun notada üst komşudan çarpma (çeşni).
            if d >= 3 and inst in ("pulse", "pulse12") and rng.random() < 0.5:
                g = midi_hz(deg_to_midi(root + 12 * octave, scale, deg + 1))
                tr.add(t, pulse(g, e8 * 0.25, 0.25), gain * 0.6)
        t += dur


def bass_line(tr, bar0, bars, root, scale, prog, rng, busy=False):
    e8 = tr.beat / 2
    for b in range(bars):
        chord = prog[b % len(prog)]
        r = deg_to_midi(root - 24, scale, chord)
        f = midi_hz(r)
        t = (bar0 + b) * tr.bar
        if busy:
            for i in range(8):
                ff = f * (2 if i in (3, 7) else 1)
                tr.add(t + i * e8, tri_bass(ff, e8 * 0.9), 0.5)
        else:
            for i, (o, d) in enumerate(((0, 3), (3, 1), (4, 2), (6, 2))):
                ff = f * (1.5 if i == 2 else 1)
                tr.add(t + o * e8, tri_bass(ff, d * e8 * 0.95), 0.55)


def drone(tr, bar0, bars, root, rng, gain=0.12):
    """Uzun ney/akort dronu: tonik + beşli."""
    dur = bars * tr.bar
    t = bar0 * tr.bar
    for semi in (0, 7):
        tr.add(t, ney(midi_hz(root - 12 + semi), dur, rng), gain)


# --- Parçalar ---------------------------------------------------------------

def compose(name):
    if name == "street":
        # Balat sokakları: Uşşak, orta tempo, saz + kare lead, maksum ritim.
        tr = Track(bpm=104, bars=36, seed=11)
        root, sc = 62, SCALES["ussak"]
        prog = [0, 0, 3, 4, 0, 5, 3, 0]
        r = tr.rng
        A = phrase(r, sc, 16, 0)
        A2 = A[:-2] + phrase(r, sc, sum(d for _, d in A[-2:]), 2)
        B = phrase(r, sc, 16, 4, span=8)
        drum_pattern(tr, 0, 4, "sparse", r)
        bass_line(tr, 0, 4, root, sc, [0], r)
        for k in range(2):
            play_phrase(tr, k * 2, phrase(r, sc, 16, 0, span=4, rest_p=0.3), root, sc, "saz", 0.45, r)
        drum_pattern(tr, 4, 32, "maksum", r)
        bass_line(tr, 4, 32, root, sc, prog, r)
        for k, ph in enumerate([A, A2, A, A2]):
            play_phrase(tr, 4 + k * 2, ph, root, sc, "pulse", 0.32, r, octave=1)
            play_phrase(tr, 4 + k * 2, ph, root, sc, "saz", 0.30, r)
        for k, ph in enumerate([B, B, A, A2]):
            play_phrase(tr, 12 + k * 2, ph, root, sc, "saz", 0.5, r)
            if k >= 2:
                play_phrase(tr, 12 + k * 2, ph, root, sc, "pulse12", 0.22, r, octave=1)
        drone(tr, 20, 8, root, r, 0.10)
        for k in range(4):
            play_phrase(tr, 20 + k * 2, phrase(r, sc, 16, 2, span=7, rest_p=0.25), root, sc, "ney", 0.38, r, octave=1)
        for k, ph in enumerate([A, A2]):
            play_phrase(tr, 28 + k * 2, ph, root, sc, "pulse", 0.34, r, octave=1)
            play_phrase(tr, 28 + k * 2, ph, root, sc, "saz", 0.36, r)
        play_phrase(tr, 32, B, root, sc, "saz", 0.45, r)
        play_phrase(tr, 34, A, root, sc, "pulse", 0.3, r, octave=1)
        return tr
    if name == "battle":
        # Kilitli arena: Hicaz, hızlı, sürekli bas + gergin kare lead, savaş ritmi.
        tr = Track(bpm=152, bars=40, seed=23)
        root, sc = 64, SCALES["hicaz"]
        prog = [0, 0, 1, 0, 3, 3, 1, 4]
        r = tr.rng
        drum_pattern(tr, 0, 40, "battle", r)
        bass_line(tr, 0, 40, root, sc, prog, r, busy=True)
        riff = phrase(r, sc, 8, 0, span=4, rest_p=0.05, leap_p=0.1)
        for b in range(0, 8):
            play_phrase(tr, b, riff, root, sc, "saz", 0.42, r)
        A = phrase(r, sc, 16, 2, span=7, rest_p=0.05)
        B = phrase(r, sc, 16, 4, span=9, rest_p=0.05, leap_p=0.3)
        for k, ph in enumerate([A, A, B, A]):
            play_phrase(tr, 8 + k * 2, ph, root, sc, "pulse", 0.34, r, octave=1)
            play_phrase(tr, 8 + k * 2, riff + riff, root, sc, "saz", 0.28, r)
        for k, ph in enumerate([B, B, A, B]):
            play_phrase(tr, 16 + k * 2, ph, root, sc, "pulse12", 0.3, r, octave=1)
            play_phrase(tr, 16 + k * 2, ph, root, sc, "saz", 0.34, r)
        for b in range(24, 32):
            play_phrase(tr, b, riff, root, sc, "saz", 0.45, r)
            play_phrase(tr, b, riff, root, sc, "pulse", 0.18, r, octave=1)
        for k, ph in enumerate([A, B, A, A]):
            play_phrase(tr, 32 + k * 2, ph, root, sc, "pulse", 0.36, r, octave=1)
        return tr
    if name == "boss":
        tr = Track(bpm=132, bars=32, seed=37)
        root, sc = 57, SCALES["hicaz"]
        prog = [0, 1, 0, 1, 3, 4, 1, 0]
        r = tr.rng
        drum_pattern(tr, 0, 32, "battle", r, fill_every=2)
        bass_line(tr, 0, 32, root, sc, prog, r, busy=True)
        drone(tr, 0, 32, root, r, 0.08)
        A = phrase(r, sc, 16, 0, span=6, rest_p=0.05)
        B = phrase(r, sc, 16, 3, span=9, rest_p=0.05, leap_p=0.35)
        for k, ph in enumerate([A, A, B, B, A, B, A, A, B, B, A, A, B, A, A, A]):
            inst = "pulse" if k % 2 == 0 else "pulse12"
            play_phrase(tr, k * 2, ph, root, sc, inst, 0.32, r, octave=1)
            play_phrase(tr, k * 2, ph, root, sc, "saz", 0.3, r)
        return tr
    if name in AMBIENT:
        return ambient(*AMBIENT[name])
    raise SystemExit("bilinmeyen parça: " + name)


## Bölge parçaları: (bpm, kök, makam, ritim, seed, lead çalgısı, ney ara bölümü)
AMBIENT = {
    "industrial": (96, 59, "nihavent", "ayyub", 41, "pulse12", True),
    "fortress": (112, 60, "rast", "maksum", 53, "pulse", False),
    "keep": (88, 57, "hicaz", "ayyub", 67, "ney", True),
    "menu": (84, 62, "ussak", "sparse", 79, "saz", True),
}


def ambient(bpm, root, scale_name, rhythm, seed, lead, ney_break):
    tr = Track(bpm=bpm, bars=32, seed=seed)
    sc = SCALES[scale_name]
    r = tr.rng
    prog = [0, 0, 3, 4, 0, 5, 3, 0] if scale_name != "hicaz" else [0, 1, 0, 3, 4, 1, 0, 0]
    A = phrase(r, sc, 16, 0)
    B = phrase(r, sc, 16, 4, span=8)
    drum_pattern(tr, 0, 4, "sparse", r)
    bass_line(tr, 0, 32, root, sc, prog, r)
    drum_pattern(tr, 4, 28, rhythm, r)
    for k in range(2):
        play_phrase(tr, k * 2, phrase(r, sc, 16, 0, span=4, rest_p=0.3), root, sc, "saz", 0.42, r)
    order = [A, A, B, A, B, B, A, A] if not ney_break else [A, A, B, A, None, None, B, A]
    for k, ph in enumerate(order):
        bar = 4 + k * 2
        if bar >= 32:
            break
        if ph is None:
            drone(tr, bar, 2, root, r, 0.1)
            play_phrase(tr, bar, phrase(r, sc, 16, 2, span=7, rest_p=0.25), root, sc, "ney", 0.38, r, octave=1)
            continue
        play_phrase(tr, bar, ph, root, sc, lead, 0.32 if lead != "ney" else 0.4, r, octave=1)
        play_phrase(tr, bar, ph, root, sc, "saz", 0.3, r)
    for k, ph in enumerate([B, A, A, B, A, A, A, A]):
        bar = 20 + k * 2
        if bar >= 32:
            break
        play_phrase(tr, bar, ph, root, sc, "saz", 0.42, r)
        play_phrase(tr, bar, ph, root, sc, lead, 0.24, r, octave=1)
    return tr


def write(name):
    tr = compose(name)
    data = tr.render()
    pcm = (data * 32767).astype(np.int16)
    path = OUT / ("mus_%s.wav" % name)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print("%s  %.1f sn" % (path.name, len(pcm) / SR))


if __name__ == "__main__":
    names = sys.argv[1:] or ["street", "battle", "boss", "industrial", "fortress", "keep", "menu"]
    for n in names:
        write(n)
