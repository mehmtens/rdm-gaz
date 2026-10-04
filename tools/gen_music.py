#!/usr/bin/env python3
# REDMOUNT procedural chiptune muzik uretici (Gorev 26).
import wave, struct, math, os, random

SR = 22050
OUT = "C:/rdm-gaz/redmount/assets/music"
os.makedirs(OUT, exist_ok=True)


def midi_hz(n):
    return 440.0 * (2.0 ** ((n - 69) / 12.0))


def square(ph, duty=0.5):
    return 1.0 if (ph % 1.0) < duty else -1.0


def tri(ph):
    p = ph % 1.0
    return 4.0 * abs(p - 0.5) - 1.0


def saw(ph):
    return 2.0 * (ph % 1.0) - 1.0


def adsr(i, n, a, d, s, r):
    at = int(a * SR); dt = int(d * SR); rt = int(r * SR)
    if i < at:
        return i / max(1, at)
    if i < at + dt:
        return 1.0 - (1.0 - s) * (i - at) / max(1, dt)
    if i < n - rt:
        return s
    return s * max(0.0, (n - i) / max(1, rt))


class Buf:
    def __init__(self, seconds):
        self.n = int(seconds * SR)
        self.d = [0.0] * self.n

    def add(self, start, samples, gain=1.0):
        s = int(start * SR)
        for i, v in enumerate(samples):
            j = s + i
            if 0 <= j < self.n:
                self.d[j] += v * gain

    def add_wrap(self, start, samples, gain=1.0):
        s = int(start * SR)
        for i, v in enumerate(samples):
            j = (s + i) % self.n
            self.d[j] += v * gain


def tone(freq, dur, wave_fn, a=0.005, d=0.04, s=0.7, r=0.08, detune=0.0):
    n = int(dur * SR)
    out = [0.0] * n
    ph = 0.0
    ph2 = 0.0
    for i in range(n):
        ph += freq / SR
        env = adsr(i, n, a, d, s, r)
        v = wave_fn(ph)
        if detune:
            ph2 += (freq * (1.0 + detune)) / SR
            v = 0.5 * (v + wave_fn(ph2))
        out[i] = v * env
    return out


def kick(dur=0.18, f0=140.0, f1=45.0):
    n = int(dur * SR)
    out = [0.0] * n
    ph = 0.0
    for i in range(n):
        t = i / n
        ph += (f0 * (1.0 - t) + f1 * t) / SR
        out[i] = math.sin(2 * math.pi * ph) * math.exp(-6.0 * t)
    return out


def hat(dur=0.05, bright=1.0):
    n = int(dur * SR)
    return [(random.random() * 2 - 1) * math.exp(-35.0 * (i / n) / bright) for i in range(n)]


def snare(dur=0.14):
    n = int(dur * SR)
    out = [0.0] * n
    ph = 0.0
    for i in range(n):
        t = i / n
        ph += 190.0 / SR
        out[i] = (math.sin(2 * math.pi * ph) * 0.4 + (random.random() * 2 - 1) * 0.9) * math.exp(-16.0 * t)
    return out


MIN_TRIAD = [0, 3, 7]


def lead_of(wave_fn, duty):
    if wave_fn is square:
        return lambda p: square(p, duty)
    return wave_fn


def build_track(bpm, root_prog, bars=8, lead_wave=square, lead_duty=0.5, lead_oct=1,
                bass_wave=square, drums="full", arp_div=4, detune=0.0, master=0.5, seed=1):
    random.seed(seed)
    beat = 60.0 / bpm
    bpb = 4
    length = bars * bpb * beat
    b = Buf(length)
    lw = lead_of(lead_wave, lead_duty)
    for bar in range(bars):
        root = root_prog[bar % len(root_prog)]
        bar_t = bar * bpb * beat
        chord = [root + iv for iv in MIN_TRIAD]
        for bt in range(bpb):
            gain = 0.9 if bt % 2 == 0 else 0.6
            b.add_wrap(bar_t + bt * beat,
                       tone(midi_hz(root - 12), beat * 0.92, bass_wave,
                            a=0.004, d=0.05, s=0.55, r=0.06, detune=detune * 0.5),
                       gain * 0.55 * master)
        step = beat / arp_div
        seqn = bpb * arp_div
        pat = chord + [chord[2] + 12, chord[1], chord[0]]
        for k in range(seqn):
            note = pat[k % len(pat)] + 12 * lead_oct
            dur = step * (1.6 if arp_div <= 2 else 0.95)
            b.add_wrap(bar_t + k * step,
                       tone(midi_hz(note), dur, lw, a=0.003, d=0.03, s=0.5, r=0.05, detune=detune),
                       0.26 * master)
        for note in chord:
            b.add_wrap(bar_t, tone(midi_hz(note), bpb * beat * 0.98, tri,
                                   a=0.08, d=0.2, s=0.4, r=0.3), 0.10 * master)
        if drums != "none":
            for bt in range(bpb):
                if bt % 2 == 0:
                    b.add_wrap(bar_t + bt * beat, kick(), 0.85 * master)
                if drums == "full" and bt % 2 == 1:
                    b.add_wrap(bar_t + bt * beat, snare(), 0.5 * master)
                for h in range(2):
                    b.add_wrap(bar_t + bt * beat + h * (beat / 2),
                               hat(bright=1.0 if h == 0 else 0.6),
                               (0.22 if h == 0 else 0.14) * master)
        if bar == bars - 1 and drums == "full":
            for j in range(4):
                b.add_wrap(bar_t + 3 * beat + j * (beat / 4), snare(0.09), 0.4 * master)
    return b


def normalize(buf, peak=0.86):
    m = max(1e-6, max(abs(v) for v in buf.d))
    g = peak / m
    for i in range(buf.n):
        buf.d[i] = math.tanh(buf.d[i] * g * 1.2) * 0.9


def write_wav(name, buf):
    normalize(buf)
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32000)) for v in buf.d))
    print("  %-20s %6.1fs  %d KB" % (name, buf.n / SR, os.path.getsize(path) // 1024))


def victory_sting():
    b = Buf(3.4)
    for i, nn in enumerate([60, 64, 67, 72, 76, 79]):
        b.add(0.09 * i, tone(midi_hz(nn), 0.9, lambda p: square(p, 0.5), a=0.004, d=0.05, s=0.6, r=0.4), 0.3)
    for nn in [60, 64, 67, 72]:
        b.add(0.62, tone(midi_hz(nn), 2.4, tri, a=0.02, d=0.3, s=0.5, r=1.2), 0.22)
    b.add(0.62, kick(0.25), 0.7)
    b.add(0.62, snare(0.3), 0.4)
    return b


print("REDMOUNT muzik uretimi -> %s" % OUT)

TRACKS = {
    "menu":       (92,  [57, 53, 60, 55], dict(lead_wave=tri, drums="none", bass_wave=tri, arp_div=2, master=0.42, seed=3)),
    "street":     (134, [52, 48, 55, 50], dict(lead_wave=square, lead_duty=0.5, arp_div=4, master=0.5, seed=7)),
    "industrial": (146, [50, 50, 46, 45], dict(lead_wave=saw, arp_div=4, detune=0.012, master=0.47, seed=11)),
    "fortress":   (124, [48, 44, 51, 43], dict(lead_wave=square, lead_duty=0.35, arp_div=4, master=0.52, seed=13)),
    "keep":       (116, [45, 45, 50, 52], dict(lead_wave=tri, lead_oct=2, arp_div=2, master=0.48, seed=17)),
    "boss":       (152, [50, 50, 48, 45], dict(lead_wave=saw, arp_div=4, detune=0.015, master=0.55, seed=19)),
}

for name, (bpm, prog, opts) in TRACKS.items():
    write_wav("mus_%s.wav" % name, build_track(bpm, prog, **opts))
write_wav("mus_victory.wav", victory_sting())
print("bitti.")
