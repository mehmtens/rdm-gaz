## Kitap geçiş sinematikleri (Yol haritası 10): yalnız kitap sonlarında açılır, kareler
## sırayla çakılır, girdi kareyi öne alır, erken basış şeridi kapatmaz, duraklat atlar.
##
##  godot --headless --path . res://tests/book_comic.tscn
extends Node

var _fails := 0
var _done := 0


func _ready() -> void:
	for i in 36:
		_check(BookComic.has_page(i) == (i in [11, 23, 35]), "kitap sonu bölüm %d" % (i + 1))
	for k in [1, 2, 3]:
		for p in 4:
			var tex := load("res://assets/ui/comic/k%d_%d.png" % [k, p]) as Texture2D
			_check(tex != null and tex.get_size() == Vector2(100, 60), "kare k%d_%d" % [k, p])
	var comic := BookComic.new()
	add_child(comic)
	comic.finished.connect(func() -> void: _done += 1)

	comic.present(4)
	_check(_done == 1 and not comic.is_active(), "kitap sonu olmayan bölüm hemen bitmeli")

	comic.present(11)
	_check(comic.is_active() and comic.shown_count() == 1, "ilk kare hemen çakılmalı")
	await get_tree().create_timer(BookComic.STEP + 0.15).timeout
	_check(comic.shown_count() == 2, "kareler kendiliğinden akmalı: %d" % comic.shown_count())
	comic.advance()
	comic.advance()
	_check(comic.shown_count() == 4, "girdi kareyi öne almalı")
	comic.advance()
	_check(comic.is_active() and _done == 1, "son kareden hemen sonra basış kapatmamalı")
	await get_tree().create_timer(BookComic.MIN_CLOSE + 0.1).timeout
	comic.advance()
	_check(not comic.is_active() and _done == 2, "hepsi açıkken basış kapatmalı")

	comic.present(35)
	var esc := InputEventAction.new()
	esc.action = &"pause"
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(not comic.is_active() and _done == 3, "duraklat şeridi atlamalı")

	print("BOOK COMIC: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
