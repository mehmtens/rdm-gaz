## Kilitli arenada ve bölüm sonu kamera sınırında kamera neredeyse sabit durur. Gökyüzü
## geçişi konuma bağlıyken bant içindeki duran kamera iki resmi kalıcı olarak üst üste
## gösteriyordu (tur 91: 19 arena, Bölüm 21 finali tüm dövüş boyunca). Geçiş artık zamana
## bağlı: her arenanın ortasında duran kamera geçiş süresi içinde tek resme oturmalı, ±150 px
## gezinen kamerada resim en fazla bir kez değişmeli (geri dönüş payı); tek
## geçişin ortasında iki resim de görünmeli (geçiş gerçekten oluyor).
##
##  godot --headless --path . res://tests/sky_blend_arenas.tscn
extends Node

const SKY_BLEND := 240.0


func _ready() -> void:
	var bad := 0
	var checked := 0
	var cam := Camera2D.new()
	add_child(cam)
	cam.make_current()
	for i in GameState.LEVELS.size():
		var path: String = GameState.LEVELS[i]
		var lvl: Node = (load(path) as PackedScene).instantiate()
		add_child(lvl)
		await get_tree().process_frame
		cam.make_current()
		var sky: Node = _find_sky(lvl)
		if sky == null:
			lvl.queue_free()
			continue
		var cells: Array = lvl.sky_cells
		var xs: Array[float] = []
		for a in get_tree().get_nodes_in_group(&"battle_arena"):
			if lvl.is_ancestor_of(a):
				xs.append((a.gate_left_x + a.gate_right_x) * 0.5)
		for x in xs:
			cam.global_position = Vector2(x, -200)
			# Geçiş süresi (perde süpürmesi, 3 Kasım'da 0,6 → 1,5 sn) + pay.
			var wait: float = sky.SKY_FADE + 0.3
			await get_tree().create_timer(wait).timeout
			checked += 1
			if not sky.settled():
				bad += 1
				print("YARIM %s: kamera %.0f'da %.1f sn'de geçiş bitmedi" % [path.get_file(), x, wait])
			# Dövüşte kamera arena içinde ±150 px gezinir: sınır aradaysa resim bir kez
			# değişebilir, ama ileri geri değişmemeli.
			var shown: int = sky._to
			var changes := 0
			for dx in [150.0, -150.0, 150.0, -150.0, 150.0]:
				cam.global_position = Vector2(x + dx, -200)
				await get_tree().create_timer(0.1).timeout
				if sky._to != shown:
					changes += 1
					shown = sky._to
			if changes > 1:
				bad += 1
				print("SALINIM %s: kamera %.0f±150'de resim %d kez değişti" % [path.get_file(), x, changes])
			cam.global_position = Vector2(x, -200)
			await get_tree().create_timer(0.7).timeout
		# Geçiş gerçekten oluyor mu: bir sınırı aşıp hemen bak (iki resim de görünmeli).
		if cells.size() > 1:
			var b := float(cells[1][1])
			# Geri dönüş payını sıfırla: önce ilk hücrenin derinine, sonra sınırın önüne.
			cam.global_position = Vector2(b - 2000.0, -200)
			await get_tree().create_timer(1.0).timeout
			cam.global_position = Vector2(b - SKY_BLEND, -200)
			await get_tree().create_timer(0.2).timeout
			cam.global_position = Vector2(b, -200)
			await get_tree().create_timer(0.15).timeout
			if sky.settled():
				bad += 1
				print("ANI %s: sınır %.0f aşılınca geçiş görünmedi" % [path.get_file(), b])
		lvl.queue_free()
		await get_tree().process_frame
	print("SKY BLEND ARENAS: %s (%d arena, %d hata)" % ["PASS" if bad == 0 and checked > 0 else "FAIL", checked, bad])
	get_tree().quit(0 if bad == 0 and checked > 0 else 1)


func _find_sky(lvl: Node) -> Node:
	for c in lvl.get_children():
		if c.has_method(&"settled") and c.has_method(&"target_cell"):
			return c
	return null
