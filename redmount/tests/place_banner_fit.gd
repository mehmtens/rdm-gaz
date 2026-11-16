## Yer / film rulosu duyurusunun alt satırı piksel plakada: kısa metinde plaka metne
## oturur (boydan boya şerit değil), uzun metin 580 px'te sarar, satır arası boş satır
## yok (tur 206: kaynakta CRLF'li çok satırlı dizgi duyuruya boş satır sokuyordu).
##
##  godot --headless --path . res://tests/place_banner_fit.tscn
extends Node

const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")

var _fails := 0


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_fails += 1
		print("FAIL: ", msg)


func _story_box(b: Control) -> Rect2:
	var l: Label = b._story
	return Rect2(l.position, l.size)


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var b: Control = HUD_SCRIPT._PlaceBanner.new()
	layer.add_child(b)
	await get_tree().process_frame
	b.present("FİLM RULOSU 1 / 3", "Gazelle'in kanıt fotoğrafı bulundu  ·  +10 coin\nKanıt Arşivi'ne eklendi", Color.GOLD)
	await get_tree().process_frame
	await get_tree().process_frame
	var r := _story_box(b)
	var l: Label = b._story
	_check(r.size.x < 580.0, "kısa duyuru plakası banner genişliğinde (%.0f)" % r.size.x)
	_check(l.get_line_count() == 2, "iki satırlık duyuru %d satır" % l.get_line_count())
	_check(l.get_theme_stylebox(&"normal") is StyleBoxTexture, "alt satırda piksel plaka yok")
	var two_h := r.size.y
	b.present("ÇİFT TEHLİKE", "Günün dalgası · " + "her düşman iki kat hızlı ve vuruşları daha sert, ".repeat(3), Color.GOLD)
	await get_tree().process_frame
	await get_tree().process_frame
	r = _story_box(b)
	_check(r.size.x <= 580.0, "uzun metin banner'ı taştı (%.0f)" % r.size.x)
	_check(l.get_line_count() >= 2, "uzun metin sarmadı")
	_check(r.size.y >= two_h - 1.0, "uzun metin plakası kısa kaldı")
	# Kaynak dizgide satır sonu kaçışı: çok satırlı literal CRLF ile boş satır üretiyordu.
	var src := FileAccess.get_file_as_string("res://scripts/systems/main.gd")
	var at := src.find("+10 coin")
	_check(at > 0 and src.substr(at, 12).find("\r") < 0, "film rulosu dizgisinde CR var")
	print("PLACE BANNER FIT: ", "PASS" if _fails == 0 else "FAIL")
	get_tree().quit(0 if _fails == 0 else 1)
