"""REDMOUNT piksel art arayüz kiti: 9 parçalı panel, düğme, konuşma balonu, çubuk.

    python tools/gen_pixel_ui.py  -> assets/ui/pixel/*.png

Dil: koyu mürdüm/ahşap zemin, koyu kontur, içte ince altın çizgi, köşelerde
Osmanlı tarzı küçük altın süs. Godot'da StyleBoxTexture olarak 3x ölçekle.
"""
from pathlib import Path

from PIL import Image

from pixelart import Canvas, P

SCALE = 3


def save(c, name):
    """Godot StyleBoxTexture dokuyu ölçeklemez: 3x (NEAREST) kaydet."""
    c.im.resize((c.w * SCALE, c.h * SCALE), Image.NEAREST).save(OUT / name)

OUT = Path(__file__).resolve().parent.parent / "assets" / "ui" / "pixel"


def _frame(c, w, h, fill, edge_hi, edge_lo, gold=True):
    c.rect(1, 1, w - 2, h - 2, fill)
    c.rect(0, 1, 0, h - 2, "ink")
    c.rect(w - 1, 1, w - 1, h - 2, "ink")
    c.rect(1, 0, w - 2, 0, "ink")
    c.rect(1, h - 1, w - 2, h - 1, "ink")
    c.hline(1, w - 2, 1, edge_hi)
    c.vline(1, 1, h - 2, edge_hi)
    c.hline(1, w - 2, h - 2, edge_lo)
    c.vline(w - 2, 1, h - 2, edge_lo)
    if gold:
        c.hline(3, w - 4, 3, "gold1")
        c.hline(3, w - 4, h - 4, "gold0")
        c.vline(3, 3, h - 4, "gold1")
        c.vline(w - 4, 3, h - 4, "gold0")
        for (x, y) in [(3, 3), (w - 4, 3), (3, h - 4), (w - 4, h - 4)]:
            c.put(x, y, "gold3")
        # köşe süsü: küçük altın baklava
        for (x, y) in [(5, 5), (w - 6, 5), (5, h - 6), (w - 6, h - 6)]:
            c.put(x, y, "gold2")
            c.put(x - 1, y, "gold0")
            c.put(x + 1, y, "gold0")
            c.put(x, y - 1, "gold0")
            c.put(x, y + 1, "gold0")


def panel():
    c = Canvas(24, 24)
    _frame(c, 24, 24, (34, 24, 36, 240), (70, 52, 70, 255), (18, 12, 20, 255))
    save(c, "panel.png")
    h = Canvas(24, 24)
    _frame(h, 24, 24, (24, 18, 28, 200), (64, 48, 64, 230), (14, 10, 16, 230))
    save(h, "panel_hud.png")


def buttons():
    states = {
        "button_normal": ((92, 56, 32, 255), "wood2", "wood0"),
        "button_hover": ((150, 52, 34, 255), "red3", "red0"),
        "button_pressed": ((96, 30, 22, 255), "red0", "red2"),
        "button_disabled": ((50, 44, 52, 255), "grey1", "grey0"),
    }
    for name, (fill, hi, lo) in states.items():
        c = Canvas(18, 14)
        _frame(c, 18, 14, fill, hi, lo, gold=False)
        if name != "button_disabled":
            c.hline(3, 14, 3, "gold1" if name != "button_pressed" else "gold0")
        save(c, (name + ".png"))


def bubble():
    c = Canvas(18, 18)
    _frame(c, 18, 18, "white", "white", "cream", gold=False)
    c.hline(2, 15, 2, (255, 250, 236, 255))
    save(c, "balon.png")
    t = Canvas(9, 7)
    for y in range(6):
        for x in range(y, 9 - y):
            t.put(x, y, "white")
    for y in range(6):
        t.put(y - 1 if y > 0 else 0, y, "ink")
        t.put(9 - y, y, "ink")
    t.put(4, 6, "ink")
    save(t, "balon_kuyruk.png")
    # konuşan adı şeridi (renk Godot'da boyanır: gri tonlu)
    n = Canvas(12, 8)
    n.rect(0, 0, 11, 7, (200, 200, 200, 255))
    n.hline(0, 11, 0, (255, 255, 255, 255))
    n.hline(0, 11, 7, (130, 130, 130, 255))
    save(n, "balon_ad.png")


def bars():
    bg = Canvas(12, 8)
    _frame(bg, 12, 8, (20, 14, 22, 255), (40, 30, 42, 255), (10, 8, 12, 255), gold=False)
    save(bg, "cubuk_zemin.png")
    fill = Canvas(6, 4)
    fill.rect(0, 0, 5, 3, "red2")
    fill.hline(0, 5, 0, "red3")
    fill.hline(0, 5, 3, "red0")
    save(fill, "cubuk_dolgu.png")


def knob():
    c = Canvas(8, 10)
    c.rect(1, 1, 6, 8, "gold1")
    c.hline(1, 6, 1, "gold3")
    c.vline(1, 1, 8, "gold2")
    c.hline(1, 6, 8, "gold0")
    c.vline(6, 1, 8, "gold0")
    c.vline(3, 3, 6, "gold0")
    c.vline(4, 3, 6, "gold2")
    c.outline()
    save(c, "tutamac.png")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    # panel / panel_hud / balon* artık tools/gen_gpt_style_ui.py'de (ChatGPT tarzı).
    buttons()
    bars()
    knob()
    print("ok")
