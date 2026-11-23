## Katı cisme gömülü düşman / ödül taraması (tur 367).
## Otomatik gizli han'ın sandık basamakları elle konmuş düşmanların üstüne kuruluyordu
## (Bölüm 17/24/33/34): düşman sandığın içinde donup kalıyordu. Bölüm 32'de bir coin
## kulenin gövdesinde, Bölüm 4'te açılış tepesi gizli mahzenin yarısını yutuyordu.
## 36 bölüm kurulur; 1 sn sonra hâlâ katı gövdeyle çakışan düşman ya da ödül hata sayılır.
## Hareketli gövdeler (pres, asansör) yok sayılır: çakışma anlıktır, tasarım gereği.
extends Node

const SETTLE_FRAMES := 60


func _ready() -> void:
	Save._path = "user://_embedded_objects.cfg"
	var bad := 0
	var total := 0
	for i in GameState.LEVELS.size():
		var level: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(level)
		for f in SETTLE_FRAMES:
			await get_tree().physics_frame
		var space := (level as Node2D).get_world_2d().direct_space_state
		for n in _all(level):
			var size := Vector2.ZERO
			var center := Vector2.ZERO
			if n is EnemyBase:
				size = Vector2(24, 50)
				center = (n as Node2D).global_position + Vector2(0, -27)
			elif n is PickupBase:
				size = Vector2(16, 16)
				center = (n as Node2D).global_position
			else:
				continue
			total += 1
			var shape := RectangleShape2D.new()
			shape.size = size
			var q := PhysicsShapeQueryParameters2D.new()
			q.shape = shape
			q.transform = Transform2D(0.0, center)
			q.collision_mask = 1
			q.collide_with_areas = false
			if n is CollisionObject2D:
				q.exclude = [(n as CollisionObject2D).get_rid()]
			for h in space.intersect_shape(q, 8):
				var col: Node = h.collider
				if col is CharacterBody2D or col is RigidBody2D or col is AnimatableBody2D:
					continue
				if _moving(col):
					continue
				bad += 1
				print("GOMULU bolum=%d %s %s p=%s -> %s" % [i + 1, n.get_class(),
						String(n.scene_file_path).get_file(), (n as Node2D).global_position, col.name])
				break
		level.queue_free()
		await get_tree().process_frame
	print("GOMULU NESNE: %d nesne, %d gomulu" % [total, bad])
	print("EMBEDDED OBJECTS: PASS" if bad == 0 else "EMBEDDED OBJECTS: FAIL")
	get_tree().quit(0 if bad == 0 else 1)


## Pres/ezici gibi kendi betiğiyle hareket eden gövde ya da onun çocuğu.
func _moving(col: Node) -> bool:
	var n := col
	while n != null:
		var s: Script = n.get_script()
		if s != null and (s.resource_path.contains("crusher") or s.resource_path.contains("moving")
				or s.resource_path.contains("collapse")):
			return true
		n = n.get_parent()
		if n is DtmLevel:
			break
	return false


func _all(n: Node) -> Array:
	var out := [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out
