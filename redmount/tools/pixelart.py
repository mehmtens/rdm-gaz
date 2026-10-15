"""REDMOUNT piksel art yardımcıları — düşük çözünürlükte elle "boyanan" sprite'lar.

Oyunun sanatı koyu konturlu, sıcak ışıklı, 3 ton gölgeli piksel art. Burada her
sprite gerçek piksel ızgarasında çizilir (1 sanat pikseli = oyunda 3 ekran pikseli,
NEAREST filtre). Geometrik çizim yerine: palet + kontur + gölge + dither.
"""
from PIL import Image

# Ortak palet (assets/ içindeki mahalle/kale çizimlerinden örneklenmiş tonlar).
P = {
    "ink": (26, 18, 24, 255),
    "wood0": (58, 34, 22, 255), "wood1": (92, 56, 32, 255), "wood2": (130, 84, 46, 255), "wood3": (168, 116, 66, 255),
    "gold0": (122, 78, 18, 255), "gold1": (190, 138, 40, 255), "gold2": (236, 190, 80, 255), "gold3": (255, 232, 150, 255),
    "red0": (86, 18, 20, 255), "red1": (150, 34, 30, 255), "red2": (198, 56, 42, 255), "red3": (236, 104, 72, 255),
    "grey0": (34, 38, 48, 255), "grey1": (58, 66, 82, 255), "grey2": (88, 98, 118, 255), "grey3": (126, 138, 158, 255),
    "stone0": (52, 46, 50, 255), "stone1": (84, 76, 78, 255), "stone2": (118, 108, 104, 255), "stone3": (156, 144, 134, 255),
    "iron0": (30, 32, 38, 255), "iron1": (52, 56, 64, 255), "iron2": (84, 90, 102, 255), "iron3": (128, 136, 150, 255),
    "white": (242, 234, 216, 255), "cream": (214, 198, 166, 255),
    "sand0": (92, 74, 48, 255), "sand1": (136, 112, 74, 255), "sand2": (172, 146, 100, 255), "sand3": (204, 182, 136, 255),
    "brick0": (70, 30, 24, 255), "brick1": (112, 50, 36, 255), "brick2": (150, 74, 50, 255), "brick3": (186, 108, 72, 255),
    "glow0": (140, 70, 20, 255), "glow1": (220, 130, 40, 255), "glow2": (255, 196, 90, 255), "glow3": (255, 238, 180, 255),
    "water0": (16, 40, 56, 255), "water1": (28, 66, 84, 255), "water2": (48, 104, 124, 255), "water3": (120, 186, 200, 255),
    "fire0": (150, 30, 10, 255), "fire1": (230, 90, 20, 255), "fire2": (255, 170, 40, 255), "fire3": (255, 240, 160, 255),
    "clear": (0, 0, 0, 0),
}


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.px = self.im.load()

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[x, y] = P[c] if isinstance(c, str) else c

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.px[x, y]
        return (0, 0, 0, 0)

    def rect(self, x0, y0, x1, y1, c):
        """Kapalı aralık [x0..x1] x [y0..y1]."""
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, c)

    def hline(self, x0, x1, y, c):
        self.rect(x0, y, x1, y, c)

    def vline(self, x, y0, y1, c):
        self.rect(x, y0, x, y1, c)

    def dither(self, x0, y0, x1, y1, a, b):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, a if (x + y) % 2 == 0 else b)

    def disc(self, cx, cy, r, c):
        for y in range(int(cy - r) - 1, int(cy + r) + 2):
            for x in range(int(cx - r) - 1, int(cx + r) + 2):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                    self.put(x, y, c)

    def outline(self, color="ink"):
        """Opak piksellerin çevresine 1 px koyu kontur (oyunun çizim dili)."""
        src = [[self.get(x, y)[3] > 0 for x in range(self.w)] for y in range(self.h)]
        for y in range(self.h):
            for x in range(self.w):
                if src[y][x]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < self.w and 0 <= yy < self.h and src[yy][xx]:
                        self.put(x, y, color)
                        break

    def paste(self, other, ox, oy):
        for y in range(other.h):
            for x in range(other.w):
                c = other.get(x, y)
                if c[3] > 0:
                    self.put(ox + x, oy + y, c)


def strip(frames):
    w = sum(f.w for f in frames)
    h = max(f.h for f in frames)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x = 0
    for f in frames:
        out.alpha_composite(f.im, (x, 0))
        x += f.w
    return out
