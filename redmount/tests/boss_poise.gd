## Patron duruşu (tur 324): zırhlı patron kesintisiz komboyla kilitlenmemeli. Ağır Zırhlı'ya
## 0,2 sn arayla 4 sn boyunca hafif darbe atılır; duruşla en az bir saldırı hazırlığına
## geçebilmeli; eski davranışta (poise_time = 0) yalnız zırh kırılmasından çıkışta tek hamle
## kaçabiliyordu. Yeni sürüm en az iki kat saldırı yapmalı ve zırh kırılması sürmeli.
##
##  godot --headless --path . res://tests/boss_poise.tscn  -> "BOSS POISE: PASS"
extends Node


func _run(main: Node, poise: float) -> Dictionary:
	var lv: Node = main.get_node(^"LevelHolder").get_child(0)
	var b: Node2D = load("res://scenes/enemies/MiniBoss.tscn").instantiate()
	b.config = b.config.duplicate()
	b.config.poise_time = poise
	b.config.max_health = 5000
	b.position = Vector2(5800, 0)
	lv.add_child(b)
	var hero: Node2D = main.get_node(^"Redmount")
	var attacks := 0
	var breaks := 0
	var last := ""
	var attack_frames := 0
	for i in 240:
		get_tree().paused = false
		if Cutscene.active != null:
			Cutscene.active._skip = true
		hero.global_position = Vector2(b.global_position.x - 60, -20)
		hero.set(&"health", 100)
		if i % 12 == 0:
			b.apply_hit(6, Vector2(1, 0), 100.0)
		await get_tree().physics_frame
		var st: String = b.get_state_name()
		if st == "ATTACK" or st == "DASH":
			attack_frames += 1
		if st != last:
			if st == "ATTACK" or st == "DASH":
				attacks += 1
			if st == "ARMOR_BREAK":
				breaks += 1
			last = st
	b.queue_free()
	return {"attacks": attacks, "frames": attack_frames, "breaks": breaks}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.level_index = 0
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main._load_current_level()
	for i in 60:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	var old := await _run(main, 0.0)
	await get_tree().physics_frame
	var new := await _run(main, 0.6)
	print("BOSS POISE eski=%s yeni=%s" % [old, new])
	var ok: bool = new["attacks"] >= 2 and new["attacks"] >= 2 * old["attacks"] 		and new["frames"] > old["frames"] and new["breaks"] >= 1
	print("BOSS POISE: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
