## Su okunurluğu (tur 293): oyuncu kanal suyunun altındayken su gövdesi oyuncu
## sütununda saydamlaşır (`_diver_x` sayı döner); kıyıda/köprüde pencere açılmaz.
##
##  godot --headless --path . res://tests/water_diver.tscn
extends Node

var _fails := 0


func _ready() -> void:
	Save._path = "user://water_diver_test.cfg"
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	GameState.level_index = 11  ## Bölüm 12: sarnıç kanalı 3300–4300, derinlik 120
	main._load_current_level()
	await get_tree().process_frame
	await get_tree().process_frame
	var water: Node2D = null
	for n in get_tree().root.find_children("*", "Node2D", true, false):
		if n.has_method(&"_diver_x") and n.get(&"kind") == DtmLevel._Art.A_WATER:
			water = n
			break
	_check(water != null, "Bölüm 12'de su sanatı bulundu")
	if water != null:
		var p := get_tree().get_first_node_in_group(&"player") as Node2D
		var surf: float = -water.size.y * 0.5 + 26.0
		p.global_position = Vector2(3620.0, 110.0)
		_check(not is_nan(water._diver_x(surf)), "kanal içinde pencere açık")
		p.global_position = Vector2(3620.0, -10.0)
		_check(is_nan(water._diver_x(surf)), "tahta üstünde pencere kapalı")
		p.global_position = Vector2(2900.0, 110.0)
		_check(is_nan(water._diver_x(surf)), "kanal dışında pencere kapalı")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Save._path))
	print("WATER DIVER: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("FAIL: " + what)
