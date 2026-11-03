## Kahraman okunurluk konturu: gündüz bölümünde sıcak-soluk gündüz rim'i, gece bölümünde
## soğuk gece rim'i; gündüz→gece→gündüz geçişinde doğru kontur kalır (paylaşılan rig
## malzemesi eski bölümün _exit_tree'sinde bozulmaz). Varsayılan kostüm (sokak, malzemesiz).
##
##  godot --headless --path . res://tests/hero_rim.tscn
extends Node

const PATH := "user://hero_rim_test.cfg"

var _fails := 0
var _main: Node


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	Save.costume = Shop.DEFAULT_COSTUME
	_main = load("res://scenes/Main.tscn").instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame

	## Bölüm 1 gündüz: gündüz konturu uygulanmalı.
	await _load(0)
	_check_meta(&"day_rim", "Bölüm 1 (gündüz) → gündüz konturu")

	## Bölüm 3 gece: gece konturu, gündüz konturunu değiştirmeli.
	await _load(2)
	_check_meta(&"night_rim", "Bölüm 3 (gece) → gece konturu")

	## Gece→gündüz: eski gece bölümünün _exit_tree'si yeni gündüz konturunu silmemeli.
	await _load(0)
	_check_meta(&"day_rim", "Bölüm 3→1 geçişi → gündüz konturu geri")

	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("HERO RIM: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _load(idx: int) -> void:
	GameState.level_index = idx
	_main._load_current_level()
	## deferred _rim_player(_day) + eski bölümün queue_free'si (bir kare sonra) otursun.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame


func _rig_material() -> Material:
	var p := get_tree().get_first_node_in_group(&"player")
	var rig: CanvasItem = p.get_node_or_null(^"Rig") if p != null else null
	return rig.material if rig != null else null


func _check_meta(meta: StringName, what: String) -> void:
	var mat := _rig_material()
	var ok := mat != null and mat.has_meta(meta)
	if not ok:
		_fails += 1
		var got := "yok" if mat == null else "başka malzeme"
		push_error("BASARISIZ: %s (beklenen meta=%s, bulunan=%s)" % [what, meta, got])
