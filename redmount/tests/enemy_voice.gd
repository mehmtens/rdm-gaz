## Düşman türüne göre ses perdesi (tur 269): iri düşman kalın, çevik ince; boss tabanda.
extends Node

var _fails := 0


func _ready() -> void:
	var p := {}
	for id in ["agile_assassin", "street_thug", "armored_bruiser", "mini_boss", "broadcast_director"]:
		var e := EnemyBase.new()
		e.config = load("res://resources/enemies/%s.tres" % id)
		p[id] = e.voice_pitch()
		e.free()
	print("perdeler: ", p)
	_check(p.agile_assassin > p.street_thug, "çevik eşkıyadan ince")
	_check(is_equal_approx(p.street_thug, 1.0), "eşkıya taban perde")
	_check(p.armored_bruiser < p.street_thug, "zırhlı eşkıyadan kalın")
	_check(p.agile_assassin / p.armored_bruiser > 1.25, "uçlar arası ≥ ~4 yarım ton (±%6 rastgeleden büyük)")
	_check(is_equal_approx(p.mini_boss, 0.72) and is_equal_approx(p.broadcast_director, 0.72), "boss tabanı")
	print("ENEMY VOICE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
