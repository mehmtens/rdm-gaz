## Hikâye sahnesinde dövüş HUD'u susar (tur 227, Bölüm 12 denetimi): kombo flaşı sinema
## şeridinde ATLA düğmesinin dibinde parlak kalıyordu. Düşük candaki kalp atışı kenarı
## sahne ağacı duraklattığı için zaten söner; ikisi de sahne bitince normale döner.
##
##  godot --headless --path . res://tests/hud_cutscene_quiet.tscn
extends Node

var _fails := 0
var _hud: Control
var _seen := {}


func _ready() -> void:
	var who := Node2D.new()
	who.add_to_group(&"player")
	add_child(who)
	_hud = load("res://scenes/ui/HUD.tscn").instantiate()
	_hud.process_mode = Node.PROCESS_MODE_ALWAYS  ## main.gd ile aynı
	add_child(_hud)
	await get_tree().process_frame
	_hud.set_health(3, 115)
	_hud._on_combo_finished(5, 135)
	await get_tree().create_timer(0.5).timeout
	_check(_hud._combo.visible, "sahne öncesi kombo flaşı görünür")
	_check(_hud._danger.modulate.a > 0.2, "sahne öncesi tehlike kenarı atıyor (%.2f)" % _hud._danger.modulate.a)

	var cs := Cutscene.new()
	cs.force_start = true
	cs.script_fn = _scene
	add_child(cs)
	await cs.done
	_check(not _seen.get("combo", true), "sahnede kombo flaşı kapalı")
	_check(_seen.get("danger", 1.0) < 0.05, "sahnede tehlike kenarı sönük (%.2f)" % _seen.get("danger", 1.0))
	await get_tree().create_timer(0.6).timeout
	_check(_hud._danger.modulate.a > 0.2, "sahne bitince tehlike kenarı döner (%.2f)" % _hud._danger.modulate.a)
	_hud._on_combo_changed(3)
	_check(_hud._combo.visible, "sahne bitince yeni kombo görünür")
	print("HUD CUTSCENE QUIET: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _scene(_cs: Cutscene) -> void:
	await get_tree().create_timer(1.2, true, false, true).timeout
	_seen["combo"] = _hud._combo.visible
	_seen["danger"] = _hud._danger.modulate.a


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
