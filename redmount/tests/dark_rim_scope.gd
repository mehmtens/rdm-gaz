## Gece konturunun bölüm kapsamı (birikim: gece geçişinde düşman konturu). main.gd
## bölüm değiştirirken eski bölümü queue_free eder ve yenisini aynı karede ekler; düşman
## konturu ertelenmiş kurulduğu için o karede ağaçta iki bölüm vardır. Düşman ve
## platform kenarı kendi bölümüne bakmalı, grubun ilk düğümüne değil.
##
##  godot --headless --path . res://tests/dark_rim_scope.tscn
extends Node

const ENEMY := preload("res://scenes/enemies/EnemyBase.tscn")

var _fails := 0


func _ready() -> void:
	await _night_to_day()
	await _day_to_night()
	await _night_to_night()
	_outside_level()
	print("DARK RIM SCOPE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


## Bölüm + içinde bir düşman; `night` ise gece grubuna ve verilen kenar ışığına alınır.
func _level(night: bool, rim := Color.WHITE) -> Array:
	var lvl := Level.new()
	if night:
		lvl.add_to_group(&"dark_scene")
	add_child(lvl)
	if night:
		lvl.edge_light = rim
	var e := ENEMY.instantiate()
	lvl.add_child(e)
	return [lvl, e]


## main.gd'nin bölüm değişimi: eskiyi queue_free, yeniyi aynı karede ekle.
func _swap(old: Node, night: bool, rim := Color.WHITE) -> Array:
	old.queue_free()
	return _level(night, rim)


func _rim_of(e: Node) -> Variant:
	var m: Material = (e.sprite as CanvasItem).material
	return m.get_shader_parameter(&"rim_color") if m is ShaderMaterial else null


func _frames(n := 3) -> void:
	for i in n:
		await get_tree().process_frame


func _night_to_day() -> void:
	var a := _level(true, Color(1, 0.5, 0.2))
	await _frames()
	_check(_rim_of(a[1]) == Color(1, 0.5, 0.2), "gece bölümünde düşman konturlu")
	var b := _swap(a[0], false)
	await _frames()
	_check(_rim_of(b[1]) == null, "geceden sonra gelen gündüz bölümünde düşman kontursuz")
	b[0].queue_free()
	await _frames()


func _day_to_night() -> void:
	var a := _level(false)
	await _frames()
	_check(_rim_of(a[1]) == null, "gündüz bölümünde düşman kontursuz")
	var b := _swap(a[0], true, Color(0.2, 0.9, 0.4))
	await _frames()
	_check(_rim_of(b[1]) == Color(0.2, 0.9, 0.4), "gündüzden sonra gelen gece bölümünde düşman konturlu")
	b[0].queue_free()
	await _frames()


## İki gece bölümü arka arkaya: yeni bölümün düşmanı yeni bölümün kenar ışığını alır.
func _night_to_night() -> void:
	var a := _level(true, Color(1, 0, 0))
	await _frames()
	var b := _swap(a[0], true, Color(0, 0, 1))
	await _frames()
	_check(_rim_of(b[1]) == Color(0, 0, 1), "gece→gece: yeni bölümün kenar ışığı")
	b[0].queue_free()
	await _frames()


## Bölüm dışındaki düğüm: ağaçta tek gece bölümü varsa o, yoksa/çoksa null.
func _outside_level() -> void:
	var loose := Node2D.new()
	add_child(loose)
	_check(Level.dark_scene_of(loose) == null, "gece bölümü yokken null")
	var n1 := Node2D.new()
	n1.add_to_group(&"dark_scene")
	add_child(n1)
	_check(Level.dark_scene_of(loose) == n1, "tek gece bölümü kabul edilir")
	var n2 := Node2D.new()
	n2.add_to_group(&"dark_scene")
	add_child(n2)
	_check(Level.dark_scene_of(loose) == null, "iki gece bölümü varken belirsiz → null")
	var day := Level.new()
	add_child(day)
	var child := Node2D.new()
	day.add_child(child)
	_check(Level.dark_scene_of(child) == null, "gündüz bölümü içindeki düğüm, başka gece bölümü olsa da kontursuz")
	_check(Level.dark_scene_of(null) == null, "null güvenli")
