## Sinematik üstünde oyun katmanı kalmasın (tur 146, Bölüm 1 denetimi): öğretici ipucu
## balonu sahne boyunca gizlenir ve sonra geri gelir; yer/film rulosu duyurusu sahne
## sırasında süresini harcamaz, sahne bitince okunur.
##
##  godot --headless --path . res://tests/cutscene_overlays.tscn
extends Node

const HINT := preload("res://scenes/systems/HintTrigger.tscn")
const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")

var _fails := 0
var _hint: HintTrigger
var _banner: Control
var _seen_in_scene := {}


func _ready() -> void:
	var who := Node2D.new()
	who.add_to_group(&"player")
	add_child(who)
	_hint = HINT.instantiate()
	_hint.text = "Tenteye zıplayıp çatılara çık."
	add_child(_hint)
	_banner = HUD_SCRIPT._PlaceBanner.new()
	_banner.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_banner)
	await _frames(2)
	_hint._on_enter(who)
	_banner.present("FİLM RULOSU 1 / 3", "Gazelle'in kanıt fotoğrafı bulundu", Color("ffd34e"))
	await _frames(10)
	var t_before: float = _banner._t

	var cs := Cutscene.new()
	cs.force_start = true
	cs.script_fn = _scene
	add_child(cs)
	await cs.done
	_check(not _seen_in_scene.get("hint", true), "sahne sırasında ipucu gizli")
	_check(_seen_in_scene.get("banner_a", 1.0) == 0.0, "sahne sırasında duyuru görünmez")
	_check(absf(_seen_in_scene.get("banner_t", -1.0) - t_before) < 0.05,
		"duyurunun süresi sahnede işlemez (%.2f → %.2f)" % [t_before, _seen_in_scene.get("banner_t", -1.0)])
	_check(_hint.visible, "sahne bitince ipucu geri gelir")
	await get_tree().create_timer(0.4).timeout
	_check(_banner.visible and _banner.modulate.a > 0.5, "sahne bitince duyuru okunur (%.2f)" % _banner.modulate.a)
	print("CUTSCENE OVERLAYS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _scene(_cs: Cutscene) -> void:
	await get_tree().create_timer(1.5, true, false, true).timeout
	_seen_in_scene["hint"] = _hint.visible
	_seen_in_scene["banner_a"] = _banner.modulate.a
	_seen_in_scene["banner_t"] = _banner._t


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
