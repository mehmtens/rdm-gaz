## Gizli oda iç mekânda depo dolabı (tur 132): boyalı salonun içinde (Bölüm 17 telgraf
## odası) kiremit damlı ev değil raf cephesi; açık hava avluda (Bölüm 25) ev kalır.
##
##  godot --headless --path . res://tests/secret_cabinet.tscn
extends Node

var _fails := 0


func _ready() -> void:
	_check(await _cabinets(17) >= 1, "Bölüm 17 gizli odası depo dolabı olmalı")
	_check(await _cabinets(16) >= 1, "Bölüm 16 arşiv gizli odası depo dolabı olmalı")
	_check(await _cabinets(25) == 0, "Bölüm 25 avlusunda gizli oda kiremitli ev kalmalı")
	_check(await _cabinets(1) == 0, "Bölüm 1 sokak gizli odası kiremitli ev kalmalı")
	print("SECRET CABINET: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


## Bölümdeki raf cepheli (stil 3) gizli oda sayısı.
func _cabinets(n: int) -> int:
	var lv: Node = load("res://scenes/levels/Bolum%02d.tscn" % n).instantiate()
	add_child(lv)
	await get_tree().process_frame
	var k := 0
	for ch in lv.get_children():
		if ch.get(&"rect") is Rect2 and ch.get(&"style") == 3:
			k += 1
	lv.queue_free()
	await get_tree().process_frame
	return k
