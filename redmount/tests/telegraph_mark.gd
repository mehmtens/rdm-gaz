## Saldırı uyarısı (birikim, 26 Ekim): piksel ünlem başın üstünde en az MIN_SHOW sn
## durur, hazırlıkta kontur beyaz kırpışır, bitince/düşman vurulunca eski kontur geri gelir.
##
##  godot --headless --path . res://tests/telegraph_mark.tscn
extends Node

const ENEMY := preload("res://scenes/enemies/EnemyBase.tscn")

var _fails := 0


func _ready() -> void:
	var lvl := Level.new()
	add_child(lvl)
	var e: EnemyBase = ENEMY.instantiate()
	lvl.add_child(e)
	await _frames(3)
	var mat := (e.sprite as CanvasItem).material as ShaderMaterial
	_check(mat != null, "düşmanın kontur malzemesi var")
	var base: Color = mat.get_shader_parameter(&"rim_color")
	e._telegraph(false, 0.3)
	var mark := e._warn_mark as Sprite2D
	_check(mark != null and mark.texture != null, "uyarı ünlemi eklendi")
	_check(mark.region_rect.position.x == 0.0, "normal uyarı kehribar hücre")
	await _frames(1)
	_check(mat.get_shader_parameter(&"rim_color") == Color(1, 1, 1, 0.95), "hazırlıkta kontur beyaz")
	await get_tree().create_timer(0.45).timeout
	await _frames(1)
	_check(not is_instance_valid(mark), "süre dolunca ünlem kalkar")
	_check(mat.get_shader_parameter(&"rim_color") == base, "kontur eski rengine döner")
	# Hızlı hazırlık (0,05 sn) bile en az MIN_SHOW görünür.
	e._telegraph(true, 0.05)
	mark = e._warn_mark as Sprite2D
	_check(mark.region_rect.position.x == 10.0, "ağır uyarı kızıl hücre")
	await get_tree().create_timer(0.15).timeout
	_check(is_instance_valid(mark), "kısa hazırlıkta ünlem hâlâ görünür")
	_check(mat.get_shader_parameter(&"rim_color") == base, "kırpışma yalnız gerçek hazırlıkta")
	# Üst üste uyarı: ilk temizlenir, taban renk bozulmaz.
	e._telegraph(false, 0.3)
	await _frames(1)
	e._telegraph(false, 0.3)
	await _frames(1)
	# Vurulan düşmanda uyarı hemen kalkar.
	e._state = EnemyBase.State.HURT
	await _frames(2)
	_check(not is_instance_valid(e._warn_mark), "vurulunca ünlem kalkar")
	_check(mat.get_shader_parameter(&"rim_color") == base, "üst üste uyarı + vuruştan sonra taban kontur")
	print("TELEGRAPH MARK: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
