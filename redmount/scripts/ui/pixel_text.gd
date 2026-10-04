## PixelText — 5×7 bitmap yazı tipi ve piksel-art tabela çizimi.
##
## Dünyadaki tabelalar vektör yazı tipi yerine bununla çizilir; böylece yazı,
## zemin ve cephelerle aynı piksel ızgarasına oturur. Yalnız BÜYÜK harf, rakam
## ve birkaç işaret içerir (Türkçe: Ç Ğ İ Ö Ş Ü). Hücre 5×10'dur: üstte iki
## satır şapka/nokta, 7 satır gövde, altta bir satır çengel.
class_name PixelText
extends RefCounted

const CELL_W := 5
const CELL_H := 10
## Harfler arası boşluk dâhil adım (piksel).
const ADVANCE := 6

const _BODY := {
	"A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
	"C": [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."],
	"D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
	"E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
	"F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
	"G": [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."],
	"H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"I": [".###.", "..#..", "..#..", "..#..", "..#..", "..#..", ".###."],
	"J": ["..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."],
	"K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
	"L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
	"M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
	"N": ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
	"O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
	"Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
	"R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
	"S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
	"T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
	"U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"V": ["#...#", "#...#", "#...#", "#...#", "#...#", ".#.#.", "..#.."],
	"W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"],
	"X": ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"],
	"Y": ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."],
	"Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
	"0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
	"1": ["..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."],
	"2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
	"3": ["####.", "....#", "....#", ".###.", "....#", "....#", "####."],
	"4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
	"5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
	"6": [".###.", "#....", "#....", "####.", "#...#", "#...#", ".###."],
	"7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
	"8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
	"9": [".###.", "#...#", "#...#", ".####", "....#", "....#", ".###."],
	".": [".....", ".....", ".....", ".....", ".....", ".##..", ".##.."],
	",": [".....", ".....", ".....", ".....", ".##..", ".##..", ".#..."],
	":": [".....", ".##..", ".##..", ".....", ".##..", ".##..", "....."],
	"·": [".....", ".....", ".....", ".##..", ".##..", ".....", "....."],
	"-": [".....", ".....", ".....", ".###.", ".....", ".....", "....."],
	"'": ["..#..", "..#..", ".#...", ".....", ".....", ".....", "....."],
	"!": ["..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."],
	"?": [".###.", "#...#", "....#", "...#.", "..#..", ".....", "..#.."],
	"/": ["....#", "....#", "...#.", "..#..", ".#...", "#....", "#...."],
	"+": [".....", "..#..", "..#..", "#####", "..#..", "..#..", "....."],
}

## Türkçe harf → [gövde harfi, üst iki satır, alt satır].
const _MARKED := {
	"Ç": ["C", [".....", "....."], "..##."],
	"Ş": ["S", [".....", "....."], "..##."],
	"Ğ": ["G", ["#...#", ".###."], "....."],
	"İ": ["I", ["..#..", "....."], "....."],
	"Ö": ["O", [".#.#.", "....."], "....."],
	"Ü": ["U", [".#.#.", "....."], "....."],
	"Â": ["A", ["..#..", ".#.#."], "....."],
}

static var _runs: Dictionary = {}


## Türkçe kurallarıyla büyük harfe çevirir (i → İ, ı → I).
static func upper(text: String) -> String:
	return text.replace("i", "İ").replace("ı", "I").to_upper()


static func width(text: String, px: float) -> float:
	return maxf(float(upper(text).length() * ADVANCE - 1), 0.0) * px


static func height(px: float) -> float:
	return float(CELL_H) * px


## `pos` hücrenin sol üst köşesidir (şapka satırı dâhil).
static func draw(ci: CanvasItem, pos: Vector2, text: String, px: float, color: Color,
		shadow: Color = Color(0, 0, 0, 0)) -> void:
	var caps := upper(text)
	for pass_index in 2:
		var tint := shadow if pass_index == 0 else color
		if tint.a <= 0.0:
			continue
		var origin := pos + (Vector2(px, px) if pass_index == 0 else Vector2.ZERO)
		for i in caps.length():
			for run in _glyph_runs(caps[i]):
				ci.draw_rect(Rect2(origin + Vector2(float(i * ADVANCE + run.x), float(run.y)) * px,
					Vector2(float(run.z) * px, px)), tint)


static func draw_centered(ci: CanvasItem, center_x: float, top: float, text: String, px: float,
		color: Color, shadow: Color = Color(0, 0, 0, 0)) -> void:
	draw(ci, Vector2(roundf(center_x - width(text, px) * 0.5), top), text, px, color, shadow)


## Asma ahşap tabela: `center` tahtanın ortasıdır. Dönen değer tahtanın kapladığı alan.
static func sign_board(ci: CanvasItem, center: Vector2, text: String, accent: Color,
		px: float = 3.0, hanging: bool = true) -> Rect2:
	var text_w := width(text, px)
	var w := text_w + 14.0 * px
	var h := 16.0 * px
	var board := Rect2(roundf(center.x - w * 0.5), roundf(center.y - h * 0.5), w, h)
	var ink := Color("17131f")
	var wood := Color("5a3a2a")
	var wood_light := Color("8a5c3c")
	var wood_dark := Color("3a2419")
	var plate := Color("241d2e")
	if hanging:
		for side in [board.position.x + 4.0 * px, board.end.x - 5.0 * px]:
			for k in 5:
				ci.draw_rect(Rect2(side, board.position.y - float(k * 2 + 2) * px, px, px), ink)
				ci.draw_rect(Rect2(side, board.position.y - float(k * 2 + 1) * px, px, px), Color("8d8a96"))
	# Dış kontur + ahşap çerçeve + iç levha, hepsi piksel ızgarasında.
	ci.draw_rect(board.grow(px), ink)
	ci.draw_rect(board, wood)
	ci.draw_rect(Rect2(board.position, Vector2(w, px)), wood_light)
	ci.draw_rect(Rect2(board.position, Vector2(px, h)), wood_light)
	ci.draw_rect(Rect2(board.position.x, board.end.y - px, w, px), wood_dark)
	ci.draw_rect(Rect2(board.end.x - px, board.position.y, px, h), wood_dark)
	var inner := board.grow(-2.0 * px)
	ci.draw_rect(inner, ink)
	ci.draw_rect(inner.grow(-px), plate)
	ci.draw_rect(Rect2(inner.position.x + px, inner.end.y - 3.0 * px, inner.size.x - 2.0 * px, px),
		Color(accent, 0.85))
	for corner in [board.position + Vector2(px, px), Vector2(board.end.x - 2.0 * px, board.position.y + px),
			Vector2(board.position.x + px, board.end.y - 2.0 * px), board.end - Vector2(2.0 * px, 2.0 * px)]:
		ci.draw_rect(Rect2(corner, Vector2(px, px)), Color("d9b36a"))
	draw_centered(ci, center.x, board.position.y + 2.5 * px, text, px, Color("f4e6c8"), ink)
	return board.grow(px)


## Glif satırlarını yatay dizilere indirger: Vector3i(x, y, uzunluk).
static func _glyph_runs(ch: String) -> Array:
	if _runs.has(ch):
		return _runs[ch]
	var rows: Array = []
	if _MARKED.has(ch):
		var marked: Array = _MARKED[ch]
		rows.append_array(marked[1])
		rows.append_array(_BODY[marked[0]])
		rows.append(marked[2])
	elif _BODY.has(ch):
		rows = [".....", "....."]
		rows.append_array(_BODY[ch])
		rows.append(".....")
	var out: Array = []
	for y in rows.size():
		var row: String = rows[y]
		var x := 0
		while x < row.length():
			if row[x] != "#":
				x += 1
				continue
			var start := x
			while x < row.length() and row[x] == "#":
				x += 1
			out.append(Vector3i(start, y, x - start))
	_runs[ch] = out
	return out
