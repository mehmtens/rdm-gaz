extends Node

## Uzun mobil oturum: aynı Main içinde bölüm yeniden yükleme, bölüm geçişi ve kontrol noktası
## dönüşü nesne/düğüm biriktirmemeli. Bir sızıntı (ör. eski bölüme bağlı kalan sinyal, ağaçtan
## çıkarılıp silinmeyen düğüm) her yüklemede sayıyı büyütür; ölçüm ikinci turu ilkiyle karşılaştırır.
## (Tur 286 ölçümü: Bölüm 1 yeniden yüklemede obj 4328 sabit, 0–3 döngüsü iki turda aynı, orphan 0.)

const SETTLE := 20
## Bölüm başına kabul edilen nesne farkı (tween/zamanlayıcı gibi geçici nesneler için pay).
const OBJ_SLACK := 8

var _main: Node


func _ready() -> void:
	Save._path = "user://level_reload_memory.cfg"
	call_deferred(&"_run")


func _counts() -> Dictionary:
	for i in SETTLE:
		await get_tree().process_frame
	return {
		"obj": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"node": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"orphan": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
	}


func _load(idx: int) -> Dictionary:
	GameState.level_index = idx
	_main._load_current_level()
	return await _counts()


func _fail(msg: String) -> void:
	push_error(msg)
	print("LEVEL RELOAD MEMORY: FAIL — " + msg)
	get_tree().quit(1)


func _run() -> void:
	_main = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(_main)
	await _counts()
	## Isınma: ilk yükleme önbellekleri doldurur.
	var first: Dictionary = await _load(0)
	for k in 3:
		var c: Dictionary = await _load(0)
		if c.node != first.node or absi(c.obj - first.obj) > OBJ_SLACK or c.orphan != 0:
			_fail("Bölüm 1 yeniden yükleme %d: %s, ilk %s" % [k, c, first])
			return
	var pass1 := {}
	for idx in [1, 2, 0]:
		pass1[idx] = await _load(idx)
	for idx in [1, 2, 0]:
		var c: Dictionary = await _load(idx)
		var p: Dictionary = pass1[idx]
		if c.node != p.node or absi(c.obj - p.obj) > OBJ_SLACK or c.orphan != 0:
			_fail("Bölüm %d ikinci geçiş: %s, ilk %s" % [idx + 1, c, p])
			return
	var before: Dictionary = await _counts()
	for k in 3:
		_main._respawn_player()
	var after: Dictionary = await _counts()
	if after.node != before.node or absi(after.obj - before.obj) > OBJ_SLACK or after.orphan != 0:
		_fail("Kontrol noktası dönüşü: %s, önce %s" % [after, before])
		return
	print("LEVEL RELOAD MEMORY: PASS (obj %d, node %d)" % [after.obj, after.node])
	get_tree().quit(0)
