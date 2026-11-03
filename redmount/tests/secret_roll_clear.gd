## Gizli alan film rulosu ödülü örtmemeli (3 Kasım oyun testi: ödül görünür olmalı).
## 36 bölümde her rulonun dikdörtgeni, aynı bölümdeki kırılır kap ve coin dışı pikaplarla
## kesişmez.
##
##  godot --headless --path . res://tests/secret_roll_clear.tscn
extends Node

var _fails := 0


func _ready() -> void:
	var total := 0
	for i in GameState.LEVELS.size():
		var lvl: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		await get_tree().process_frame
		for z in get_tree().get_nodes_in_group(&"secret_zone"):
			if not z.has_method("roll_rect"):
				continue
			total += 1
			var rr: Rect2 = z.roll_rect()
			for n in lvl.get_children():
				var r: Rect2 = z.reward_rect(n)
				if r.size != Vector2.ZERO and rr.intersects(r):
					_fails += 1
					print("  Bölüm %d: rulo %s, ödül %s %s" % [i + 1, rr.get_center().round(), n.name, r.get_center().round()])
		lvl.queue_free()
		await get_tree().process_frame
	print("SECRET ROLL CLEAR: %s (%d rulo)" % ["PASS" if _fails == 0 else "FAIL (%d)" % _fails, total])
	get_tree().quit(0 if _fails == 0 else 1)
