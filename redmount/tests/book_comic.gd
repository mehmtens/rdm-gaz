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
			# Katmanlar birleşince eski tek parça kareyle piksel piksel aynı olmalı.
			var bg := load("res://assets/ui/comic/k%d_%d_bg.png" % [k, p]) as Texture2D
			var on := load("res://assets/ui/comic/k%d_%d_on.png" % [k, p]) as Texture2D
			_check(bg != null and bg.get_size() == Vector2(100, 60), "sahne k%d_%d" % [k, p])
			_check(on != null and on.get_size() == Vector2(96, 56), "ön katman k%d_%d" % [k, p])
			if tex and bg and on:
				var img := bg.get_image()
				img.convert(Image.FORMAT_RGBA8)
				var top := on.get_image()
				top.convert(Image.FORMAT_RGBA8)
				img.blend_rect(top, Rect2i(0, 0, 96, 56), Vector2i(2, 2))
				var ref := tex.get_image()
				ref.convert(Image.FORMAT_RGBA8)
				_check(img.get_data() == ref.get_data(), "katmanlar birleşik kareyi vermeli k%d_%d" % [k, p])
	var comic := BookComic.new()
	add_child(comic)
	comic.finished.connect(func() -> void: _done += 1)

	comic.present(4)
	_check(_done == 1 and not comic.is_active(), "kitap sonu olmayan bölüm hemen bitmeli")

	comic.present(11)
	_check(comic.is_active() and comic.shown_count() == 1, "ilk kare hemen çakılmalı")
	# Ön katman: açılmamış kare aşağıda bekler, açılınca piksel piksel oturur, sonra nefes.
	_check(comic.layer_offset(3) == BookComic.SETTLE_PX, "açılmamış karenin katmanı aşağıda")
	var ages: Array[float] = comic._ages
	var keep := ages[0]
	ages[0] = 0.0
	_check(comic.layer_offset(0) == 3, "açılış anı 3 piksel aşağıda")
	ages[0] = BookComic.SETTLE_STEP * 1.5
	_check(comic.layer_offset(0) == 2, "bir adım sonra 2 piksel")
	var settled := BookComic.SETTLE_PX * BookComic.SETTLE_STEP
	ages[0] = settled + 0.05
	_check(comic.layer_offset(0) == 0, "oturunca yerinde")
	ages[0] = settled + BookComic.BREATH - 0.1
	_check(comic.layer_offset(0) == 1, "nefeste 1 piksel iner")
	ages[0] = settled + BookComic.BREATH + 0.1
	_check(comic.layer_offset(0) == 0, "nefesten sonra geri döner")
	ages[0] = keep
	# Konuşma balonu: yazılı karede katman oturduktan sonra belirir; balonsuz karede hiç.
	_check(comic.bubble_text(0) == "Bitti, Karahanlı." and comic.bubble_text(2).is_empty(), "balon yazıları")
	ages[0] = settled + BookComic.BUBBLE_DELAY * 0.5
	_check(not comic.bubble_visible(0), "balon katman oturmadan görünmez")
	ages[0] = settled + BookComic.BUBBLE_DELAY + 0.01
	_check(comic.bubble_visible(0), "balon oturduktan sonra görünür")
	ages[2] = 5.0
	_check(not comic.bubble_visible(2), "balonsuz karede balon yok")
	ages[2] = -1.0
	ages[0] = keep
	for i in 4:
		var bub: Control = comic._bubbles[i]
		var box := bub.get_child(0) as Control
		_check(bub.position.x >= 0.0 and bub.position.x + box.size.x <= BookComic.PANEL_SIZE.x, "balon kare içinde %d" % i)
		_check(int(bub.position.x) % BookComic.SCALE == 0, "balon sanat pikseline oturur %d" % i)
	await get_tree().process_frame
	_check(int(comic._layers[0].position.y) % BookComic.SCALE == 0, "katman tam sanat pikseline oturmalı")
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
