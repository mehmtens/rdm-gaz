## Boss öfke evresi denetimi: canı yarıya indir, evre + yardımcı + şok dalgası.
extends Node


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
	var lv: Node = main.get_node(^"LevelHolder").get_child(0)
	var b: Node2D = load("res://scenes/enemies/Karahanli.tscn").instantiate()
	b.position = Vector2(6000, 0)
	lv.add_child(b)
	main.get_node(^"Redmount").global_position = Vector2(5700, -20)
	for i in 20:
		get_tree().paused = false
		await get_tree().physics_frame
	var before := get_tree().get_nodes_in_group(&"enemy_ai").size()
	b.apply_hit(130, Vector2(1, 0), 100.0)
	var waves := 0
	for i in 600:
		get_tree().paused = false
		if Cutscene.active != null:
			Cutscene.active._skip = true
		await get_tree().physics_frame
		waves = maxi(waves, get_tree().get_nodes_in_group(&"shockwave").size())
	print("BOSS raged=%s enemies %d->%d hp=%d shockwaves_seen=%d" % [b.get("_raged"), before,
		get_tree().get_nodes_in_group(&"enemy_ai").size(), b.get_health(), waves])
	get_tree().quit()
