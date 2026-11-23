## Her kontrol noktasının doğma alanı boş mu? (tur 366)
## Bölüm 7'de otomatik gizli han'ın sandık basamakları x=8000 kontrol noktasının üstüne
## kuruluyordu: oyuncu ölünce bloğun içinde doğup sıkışıyordu (bot 800 sn takıldı).
## Bütün bölümler kurulur; her kontrol noktasında oyuncu gövdesi kadar alan katı
## cisimle çakışmamalı.
extends Node


func _ready() -> void:
	Save._path = "user://_checkpoint_clear.cfg"
	var bad := 0
	var total := 0
	for i in GameState.LEVELS.size():
		var level: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(level)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var space := (level as Node2D).get_world_2d().direct_space_state
		for cp in _all(level):
			if not cp.is_in_group(&"checkpoint") or not (cp is Node2D):
				continue
			total += 1
			var p: Vector2 = (cp as Node2D).global_position
			var shape := RectangleShape2D.new()
			shape.size = Vector2(28, 56)
			var q := PhysicsShapeQueryParameters2D.new()
			q.shape = shape
			q.transform = Transform2D(0.0, p + Vector2(0, -30))
			q.collision_mask = 1
			q.collide_with_areas = false
			var hits := space.intersect_shape(q, 4)
			if not hits.is_empty():
				bad += 1
				var col: Node = hits[0].collider
				var info := ""
				for sh in col.get_children():
					if sh is CollisionShape2D and sh.shape is RectangleShape2D:
						info = str(Rect2((sh as Node2D).global_position - sh.shape.size * 0.5, sh.shape.size))
				for ch in col.get_children():
					info += " " + ch.get_class() + (":" + str(ch.get("kind")) if ch.get("kind") != null else "")
				print("CAKISMA bolum=%d %s cp=%s -> %s %s" % [i + 1, GameState.LEVELS[i].get_file(), p, col.name, info])
		level.queue_free()
		await get_tree().process_frame
	print("KONTROL NOKTASI: %d nokta, %d cakisma" % [total, bad])
	print("CHECKPOINT CLEAR: PASS" if bad == 0 else "CHECKPOINT CLEAR: FAIL")
	get_tree().quit(0 if bad == 0 else 1)


func _all(n: Node) -> Array:
	var out := [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out
