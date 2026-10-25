## Düşük can uyarısı (tasarım denetimi 26 Ekim): can %30'un altında ekran kenarı atar,
## kritikte hızlanır, iyileşince ve ölümde söner; kenar dokunuşu engellemez.
##
##  godot --headless --path . res://tests/low_health.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	var edge := hud.get_node_or_null(^"DangerEdge") as TextureRect
	_check(edge != null, "DangerEdge düğümü")
	if edge == null:
		_finish()
		return
	_check(edge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "kenar dokunuşu engellememeli")
	_check(edge.get_index() == 0, "kenar HUD öğelerinin arkasında")
	hud.set_health(100, 115)
	await _frames(20)
	_check(edge.modulate.a < 0.01, "sağlıklıyken görünmez")
	hud.set_health(30, 115)
	var peak := 0.0
	var low := 1.0
	for i in 70:
		await get_tree().process_frame
		peak = maxf(peak, edge.modulate.a)
		low = minf(low, edge.modulate.a)
	_check(peak > 0.8, "tehlikede atış zirvesi görünür (%.2f)" % peak)
	_check(low >= 0.29, "atışlar arası taban görünür kalır (%.2f)" % low)
	_check(hud.get("_hp_ratio") <= hud.DANGER_RATIO, "oran tehlike bölgesinde")
	hud.set_health(10, 115)
	await _frames(5)
	_check(hud._hp_ratio <= hud.DANGER_CRITICAL, "kritik bölge")
	hud.set_health(0, 115)
	await _frames(40)
	_check(edge.modulate.a < 0.05, "ölümde söner")
	hud.set_health(115, 115)
	await _frames(40)
	_check(edge.modulate.a < 0.01, "iyileşince söner")
	_finish()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _finish() -> void:
	print("LOW HEALTH: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)
