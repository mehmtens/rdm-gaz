## Öğretici ipucu sırası (tasarım denetimi 26 Ekim): bölüm başlık kartı ekrandayken ipucu
## görünmez; kart sönünce açılır, aynı anda iki ipucu varsa yalnız yenisi kalır.
##
##  godot --headless --path . res://tests/hint_order.tscn
extends Node

const HINT := preload("res://scenes/systems/HintTrigger.tscn")

var _fails := 0


func _ready() -> void:
	var card := Node.new()
	card.add_to_group(&"title_card")
	add_child(card)
	var who := Node2D.new()
	who.add_to_group(&"player")
	add_child(who)
	var a: HintTrigger = HINT.instantiate()
	a.text = "eski"
	add_child(a)
	var b: HintTrigger = HINT.instantiate()
	b.text = "yeni"
	b.position.x = 400.0
	add_child(b)
	await _frames(2)
	a._on_enter(who)
	a._on_exit(who)
	b._on_enter(who)
	await _frames(20)
	_check(a._fade == 0.0 and b._fade == 0.0, "başlık kartı varken ipucu görünmez")
	card.queue_free()
	await get_tree().create_timer(0.7).timeout
	_check(b._fade > 0.9, "kart sönünce yeni ipucu açılır (%.2f)" % b._fade)
	_check(a._fade < 0.05, "eski ipucu yeniye yol verir (%.2f)" % a._fade)
	print("HINT ORDER: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
