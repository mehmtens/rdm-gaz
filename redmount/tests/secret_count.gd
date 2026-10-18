## Her bölümdeki gizli alan sayısını yazar (yerleşim denetimi).
##  godot --headless --path . res://tests/secret_count.tscn
extends Node


func _ready() -> void:
	for i in GameState.level_count():
		var lv: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(lv)
		await get_tree().process_frame
		var xs: Array = []
		for z in get_tree().get_nodes_in_group(&"secret_zone"):
			if lv.is_ancestor_of(z):
				xs.append(int(z.global_position.x))
		print("B%d secrets=%d %s" % [i + 1, xs.size(), str(xs)])
		lv.queue_free()
		await get_tree().process_frame
	get_tree().quit()
