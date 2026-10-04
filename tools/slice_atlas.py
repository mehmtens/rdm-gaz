"""
slice_atlas.py — otomatik sprite atlas dilimleyici (REDMOUNT).

AI ile üretilmiş el-çizimi görünümlü sprite sayfaları düzenli bir ızgara DEĞİL:
satırlar değişken sayıda kare içeriyor, kareler hizalı değil, arka plan bazen
beyaz bazen koyu. Bu araç:

  1) Kenarlardan flood-fill ile arka planı saydamlaştırır (beyaz VEYA koyu).
  2) Boş yatay bantlara göre SATIRLARI bulur.
  3) Her satır içinde boş dikey bantlara göre KARELERİ bulur.
  4) Her kareyi ayak-hizası (alt-orta) sabitlemesiyle tek boy hücreye yerleştirir.
  5) İsteğe bağlı: segmentasyon debug PNG'si üretir.

Kullanım:
  python tools/slice_atlas.py analyze  <atlas.png> [--bg auto|light|dark] [--debug out.png]
  python tools/slice_atlas.py sheet    <atlas.png> <out_dir> --map "row0=idle:4,row1=walk:8,..." \
        [--cell 128x256] [--bg auto|light|dark] [--pad 6]
"""
import sys, os, argparse
import numpy as np
from PIL import Image
from collections import deque
from scipy import ndimage


def load_rgba(path):
    return np.array(Image.open(path).convert("RGBA"))


def bg_mask(rgba, mode="auto"):
    """True = arka plan (silinecek)."""
    h, w, _ = rgba.shape
    r = rgba[:, :, 0].astype(int)
    g = rgba[:, :, 1].astype(int)
    b = rgba[:, :, 2].astype(int)
    a = rgba[:, :, 3].astype(int)
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    sat = mx - mn

    if mode == "auto":
        # kenar şeridinin ortalama parlaklığına bak
        border = np.concatenate([
            mx[0:4, :].ravel(), mx[-4:, :].ravel(),
            mx[:, 0:4].ravel(), mx[:, -4:].ravel()])
        mode = "light" if border.mean() > 128 else "dark"

    if mode == "light":
        bgcol = (mn >= 218) & (sat <= 22)
    else:  # dark — koyu, düşük doygunluk (siyah/koyu-kahve degrade)
        bgcol = (mx <= 70)
    bgcol |= (a <= 8)

    # flood fill kenardan + (light modda) iç beyaz cepler
    visited = np.zeros((h, w), dtype=bool)
    dq = deque()
    for x in range(w):
        for y in (0, h - 1):
            if bgcol[y, x] and not visited[y, x]:
                visited[y, x] = True
                dq.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if bgcol[y, x] and not visited[y, x]:
                visited[y, x] = True
                dq.append((y, x))
    if mode == "light":
        # bacak arası / koltuk altı gibi kapalı saf-beyaz blokları da tohumla
        strict = (mn >= 236) & (sat <= 10)
        er = ndimage.binary_erosion(strict, iterations=3)
        sy, sx = np.where(er & ~visited)
        for y, x in zip(sy.tolist(), sx.tolist()):
            if not visited[y, x]:
                visited[y, x] = True
                dq.append((y, x))
    while dq:
        y, x = dq.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx] and bgcol[ny, nx]:
                visited[ny, nx] = True
                dq.append((ny, nx))
    return visited


def smoothness_fg(rgba, gthr=42, dilate=2):
    """Koyu karakter / koyu-dumanlı degrade zemin: renkle ayrılamaz.
    Zemin düzgün (düşük gradyan) ve KENARDAN bağlı; karakterin siyah çini
    dış hattı yüksek gradyan → seli durdurur. Düzgün pikselleri kenardan
    'flood' et → geri kalan = karakter (iç düz bölgeler dolu kalır)."""
    r = rgba[:, :, 0].astype(float)
    g = rgba[:, :, 1].astype(float)
    b = rgba[:, :, 2].astype(float)
    gray = 0.299 * r + 0.587 * g + 0.114 * b
    grad = ndimage.gaussian_filter(
        np.hypot(ndimage.sobel(gray, axis=0), ndimage.sobel(gray, axis=1)), 0.6)
    smooth = grad < gthr
    lbl, n = ndimage.label(smooth)
    border = set(np.unique(np.r_[lbl[0], lbl[-1], lbl[:, 0], lbl[:, -1]]).tolist())
    border.discard(0)
    bg = np.isin(lbl, list(border))
    fg = ~bg
    fg = ndimage.binary_opening(fg, np.ones((3, 3)))
    fg = ndimage.binary_closing(fg, np.ones((3, 3)))
    # delikleri BİLEŞEN BAZINDA doldur (satırlar arası köprü kurmadan)
    l2, m = ndimage.label(fg)
    if m:
        sz = ndimage.sum(np.ones_like(l2), l2, range(1, m + 1))
        big = np.zeros(m + 1, dtype=bool)
        big[1:] = sz >= 1200
        fg = big[l2]
        fg = ndimage.binary_fill_holes(fg)
    if dilate:
        fg = ndimage.binary_dilation(fg, iterations=dilate)
    return fg


def segment_by_energy(rgba, row_gap=14, col_gap=12, gthr=42, min_area=1400):
    """Döndürür: (rows_of_boxes, cleaned_rgba). Koyu zeminli düşman sayfaları.
    Temiz fg maskesinde bağlı-bileşen → y-örtüşmesine göre satır grupları."""
    fg = smoothness_fg(rgba, gthr=gthr)
    out = rgba.copy()
    out[:, :, 3] = np.where(fg, 255, 0).astype(np.uint8)

    lbl, n = ndimage.label(fg)
    comps = []
    for i in range(1, n + 1):
        ys, xs = np.where(lbl == i)
        if len(xs) < min_area:
            continue
        comps.append([int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1])
    if not comps:
        return [], out

    # Satır = ortak TABAN çizgisi (bottom-y). Aynı satırdaki karakterler aynı
    # zemine basar; poz yüzünden tepe-y değişir ama taban ~sabittir.
    heights = sorted(c[3] - c[1] for c in comps)
    med_h = heights[len(heights) // 2]
    tol = max(24.0, med_h * 0.28)
    comps.sort(key=lambda c: (c[3], c[0]))
    rows = []
    for c in comps:
        base = c[3]
        placed = False
        for row in rows:
            if abs(row["base"] - base) <= tol:
                row["items"].append(c)
                row["base"] = (row["base"] * (len(row["items"]) - 1) + base) / len(row["items"])
                placed = True
                break
        if not placed:
            rows.append({"base": float(base), "items": [c]})
    rows = [r["items"] for r in rows]

    all_boxes = []
    for row in rows:
        row.sort(key=lambda c: c[0])
        widths = sorted(c[2] - c[0] for c in row)
        med_w = widths[len(widths) // 2]
        boxes = []
        for c in row:
            if (c[2] - c[0]) > med_w * 1.65 and med_w > 0:
                cm = (lbl[c[1]:c[3], c[0]:c[2]] > 0)
                for (s0, s1) in _split_wide(cm, c[0], med_w):
                    seg = fg[c[1]:c[3], s0:s1]
                    ys = np.where(seg.any(axis=1))[0]
                    xs = np.where(seg.any(axis=0))[0]
                    if len(xs) and len(ys):
                        boxes.append((s0 + xs[0], c[1] + ys[0], s0 + xs[-1] + 1, c[1] + ys[-1] + 1))
            else:
                boxes.append(tuple(c))
        boxes = [b for b in boxes if (b[2] - b[0]) >= 24 and (b[3] - b[1]) >= 40]
        if boxes:
            all_boxes.append(boxes)
    return all_boxes, out


def clean_rgba(rgba, mode="auto"):
    out = rgba.copy()
    bg = bg_mask(rgba, mode)
    out[bg, 3] = 0
    # küçük gürültü temizliği: alfa<24 -> 0
    faint = out[:, :, 3] < 24
    out[faint, 3] = 0
    return out


def bands(mask_1d, min_gap, min_size):
    """1B boolean dizide True bloklarını (start,end) döndür; küçük boşlukları birleştir."""
    idx = np.where(mask_1d)[0]
    if len(idx) == 0:
        return []
    groups = []
    s = idx[0]
    prev = idx[0]
    for i in idx[1:]:
        if i - prev > min_gap:
            groups.append((s, prev + 1))
            s = i
        prev = i
    groups.append((s, prev + 1))
    return [(a, b) for a, b in groups if b - a >= min_size]


def find_rows(alpha, row_gap=10, row_min=24):
    rowfill = alpha.any(axis=1)
    return bands(rowfill, row_gap, row_min)


def _split_wide(comp_mask, x0, med_w):
    """Geniş bir bileşeni (2 karakter yapışmış) dikey yoğunluk vadisinden böl."""
    w = comp_mask.shape[1]
    if med_w <= 0 or w < med_w * 1.55:
        return [(x0, x0 + w)]
    n = max(2, int(round(w / med_w)))
    colsum = comp_mask.sum(axis=0).astype(float)
    cuts = [0]
    for k in range(1, n):
        target = int(w * k / n)
        lo, hi = max(1, target - int(med_w * 0.35)), min(w - 1, target + int(med_w * 0.35))
        if hi <= lo:
            cuts.append(target)
            continue
        cut = lo + int(np.argmin(colsum[lo:hi]))
        cuts.append(cut)
    cuts.append(w)
    return [(x0 + cuts[i], x0 + cuts[i + 1]) for i in range(len(cuts) - 1)]


def find_frames_in_row(alpha, y0, y1, col_gap=8, col_min=12):
    """Satır bandında bağlı-bileşen analizi ile kare kutuları döndür."""
    sub = alpha[y0:y1]
    rowh = y1 - y0
    lbl, n = ndimage.label(sub)
    if n == 0:
        return []
    comps = []
    for i in range(1, n + 1):
        ys, xs = np.where(lbl == i)
        area = len(xs)
        comps.append({
            "x0": xs.min(), "x1": xs.max() + 1,
            "y0": ys.min(), "y1": ys.max() + 1, "area": area,
        })
    areas = sorted(c["area"] for c in comps)
    med_area = areas[len(areas) // 2]
    big = [c for c in comps if c["area"] >= max(200, med_area * 0.35)
           and (c["y1"] - c["y0"]) >= rowh * 0.30]
    small = [c for c in comps if c not in big]
    big.sort(key=lambda c: c["x0"])
    # küçük parçaları (kopuk yumruk/ayak) yatayda örtüşen/yakın büyük parçaya kat
    for s in small:
        if s["area"] < 40:
            continue
        best, bestd = None, 1e9
        for b in big:
            gap = max(b["x0"] - s["x1"], s["x0"] - b["x1"], 0)
            if gap < bestd:
                bestd, best = gap, b
        if best is not None and bestd < 26:
            best["x0"] = min(best["x0"], s["x0"])
            best["x1"] = max(best["x1"], s["x1"])
            best["y0"] = min(best["y0"], s["y0"])
            best["y1"] = max(best["y1"], s["y1"])
    if not big:
        return []
    widths = sorted(b["x1"] - b["x0"] for b in big)
    med_w = widths[len(widths) // 2]
    boxes = []
    for b in big:
        cw = b["x1"] - b["x0"]
        if cw > med_w * 1.55:
            cm = (lbl[:, b["x0"]:b["x1"]] > 0)
            for (sx0, sx1) in _split_wide(cm, b["x0"], med_w):
                seg = sub[:, sx0:sx1]
                ys = np.where(seg.any(axis=1))[0]
                xs = np.where(seg.any(axis=0))[0]
                if len(xs) == 0:
                    continue
                boxes.append((sx0 + xs[0], y0 + ys[0], sx0 + xs[-1] + 1, y0 + ys[-1] + 1))
        else:
            boxes.append((b["x0"], y0 + b["y0"], b["x1"], y0 + b["y1"]))
    boxes.sort(key=lambda t: t[0])
    return boxes


def frame_bbox(alpha, y0, y1, x0, x1):
    return (x0, y0, x1, y1)


def analyze(path, bg="auto", debug=None, row_gap=10, col_gap=8):
    raw = load_rgba(path)
    if bg in ("detail", "energy", "dark2"):
        all_boxes, rgba = segment_by_energy(raw, row_gap=max(row_gap, 12),
                                            col_gap=max(col_gap, 10))
        print(f"{os.path.basename(path)}  {rgba.shape[1]}x{rgba.shape[0]}  bg={bg}")
        print(f"  {len(all_boxes)} satır:")
        for ri, boxes in enumerate(all_boxes):
            ws = [b[2] - b[0] for b in boxes]
            hs = [b[3] - b[1] for b in boxes]
            print(f"  row{ri}: {len(boxes)} kare  "
                  f"w~{min(ws) if ws else 0}-{max(ws) if ws else 0}  "
                  f"h~{min(hs) if hs else 0}-{max(hs) if hs else 0}")
        if debug:
            _dump_debug(rgba, all_boxes, debug)
        return all_boxes, rgba

    rgba = clean_rgba(raw, bg)
    alpha = rgba[:, :, 3] > 16
    rows = find_rows(alpha, row_gap=row_gap)
    print(f"{os.path.basename(path)}  {rgba.shape[1]}x{rgba.shape[0]}  bg={bg}")
    print(f"  {len(rows)} satır:")
    all_boxes = []
    for ri, (y0, y1) in enumerate(rows):
        boxes = find_frames_in_row(alpha, y0, y1, col_gap=col_gap)
        all_boxes.append(boxes)
        widths = [b[2] - b[0] for b in boxes]
        heights = [b[3] - b[1] for b in boxes]
        print(f"  row{ri}: y={y0}-{y1} ({y1-y0}px)  {len(boxes)} kare  "
              f"w~{min(widths) if widths else 0}-{max(widths) if widths else 0}  "
              f"h~{min(heights) if heights else 0}-{max(heights) if heights else 0}")
    if debug:
        _dump_debug(rgba, all_boxes, debug)
    return all_boxes, rgba


def _dump_debug(rgba, all_boxes, debug):
    dbg = Image.fromarray(rgba).convert("RGBA")
    px = dbg.load()
    W, H = dbg.size
    for boxes in all_boxes:
        for (x0, y0, x1, y1) in boxes:
            for x in range(max(0, x0), min(W, x1)):
                for y in (y0, y1 - 1):
                    if 0 <= y < H:
                        px[x, y] = (255, 0, 128, 255)
            for y in range(max(0, y0), min(H, y1)):
                for x in (x0, x1 - 1):
                    if 0 <= x < W:
                        px[x, y] = (255, 0, 128, 255)
    bgimg = Image.new("RGBA", dbg.size, (40, 44, 52, 255))
    bgimg.alpha_composite(dbg)
    bgimg.save(debug)
    print(f"  debug -> {debug}")


def build_sheet(path, out_dir, mapping, cell=(128, 256), bg="auto", pad=6,
                row_gap=10, col_gap=8, stand_row=0, stand_h=196):
    """mapping: list of (row_index, anim_name, expected_count_or_None).
    Tüm karelere ATLAS-GENELİ tek ölçek uygulanır (stand_row'un medyan yüksekliği
    stand_h'ye oturur) → vücut oranı sabit kalır."""
    all_boxes, rgba = analyze(path, bg=bg, row_gap=row_gap, col_gap=col_gap)
    alpha_img = Image.fromarray(rgba)
    os.makedirs(out_dir, exist_ok=True)
    cw, ch = cell

    sr = stand_row if stand_row < len(all_boxes) else 0
    sh = sorted((b[3] - b[1]) for b in all_boxes[sr]) if all_boxes[sr] else [stand_h]
    ref_h = sh[len(sh) // 2]
    gscale = stand_h / ref_h
    maxw, maxh = cw - pad * 2, ch - pad * 2

    manifest = []
    for (ri, name, cnt) in mapping:
        if ri >= len(all_boxes):
            print(f"  !! row{ri} yok ({name})")
            continue
        boxes = all_boxes[ri]
        if cnt and len(boxes) != cnt:
            print(f"  ~ row{ri} {name}: {len(boxes)} kare bulundu, {cnt} beklendi")
        frames = []
        for (x0, y0, x1, y1) in boxes:
            crop = alpha_img.crop((x0, y0, x1, y1))
            fw, fh = crop.size
            # Ölçek yalnızca YÜKSEKLİĞE göre (atlas-geneli) → vücut oranı sabit.
            # Aşırı geniş aksiyon pozları (uzanan yumruk) yatayda taşabilir/kırpılır.
            scale = gscale
            if fh * scale > maxh:
                scale = maxh / fh
            nw, nh = max(1, round(fw * scale)), max(1, round(fh * scale))
            if (nw, nh) != (fw, fh):
                crop = crop.resize((nw, nh), Image.NEAREST)
            canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
            ox = (cw - nw) // 2
            oy = ch - pad - nh   # ayak hizası alta sabit
            if ox < 0 or oy < 0 or ox + nw > cw or oy + nh > ch:
                # taşan kısmı kırp
                cx0 = max(0, -ox); cy0 = max(0, -oy)
                cx1 = min(nw, cw - ox); cy1 = min(nh, ch - oy)
                crop = crop.crop((cx0, cy0, cx1, cy1))
                ox += cx0; oy += cy0
            canvas.alpha_composite(crop, (ox, oy))
            frames.append(canvas)
        if not frames:
            continue
        strip = Image.new("RGBA", (cw * len(frames), ch), (0, 0, 0, 0))
        for i, fr in enumerate(frames):
            strip.alpha_composite(fr, (i * cw, 0))
        outp = os.path.join(out_dir, f"{name}.png")
        strip.save(outp)
        manifest.append((name, len(frames)))
        print(f"  -> {name}.png  ({len(frames)} kare @ {cw}x{ch})")
    print("\nMANIFEST:")
    for name, n in manifest:
        print(f"  {name}: {n}")
    return manifest


def parse_map(s):
    out = []
    for part in s.split(","):
        part = part.strip()
        if not part:
            continue
        key, val = part.split("=")
        ri = int(key.replace("row", ""))
        if ":" in val:
            name, cnt = val.split(":")
            out.append((ri, name.strip(), int(cnt)))
        else:
            out.append((ri, val.strip(), None))
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("analyze")
    a.add_argument("atlas")
    a.add_argument("--bg", default="auto")
    a.add_argument("--debug", default=None)
    a.add_argument("--row-gap", type=int, default=10)
    a.add_argument("--col-gap", type=int, default=8)
    s = sub.add_parser("sheet")
    s.add_argument("atlas")
    s.add_argument("out_dir")
    s.add_argument("--map", required=True)
    s.add_argument("--cell", default="128x256")
    s.add_argument("--bg", default="auto")
    s.add_argument("--pad", type=int, default=6)
    s.add_argument("--row-gap", type=int, default=10)
    s.add_argument("--col-gap", type=int, default=8)
    s.add_argument("--stand-row", type=int, default=0)
    s.add_argument("--stand-h", type=int, default=196)
    args = ap.parse_args()

    if args.cmd == "analyze":
        analyze(args.atlas, bg=args.bg, debug=args.debug,
                row_gap=args.row_gap, col_gap=args.col_gap)
    else:
        cw, ch = (int(v) for v in args.cell.lower().split("x"))
        build_sheet(args.atlas, args.out_dir, parse_map(args.map),
                    cell=(cw, ch), bg=args.bg, pad=args.pad,
                    row_gap=args.row_gap, col_gap=args.col_gap,
                    stand_row=args.stand_row, stand_h=args.stand_h)
