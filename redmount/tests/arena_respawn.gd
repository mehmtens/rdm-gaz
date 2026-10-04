extends "res://_autoplay.gd"


func _physics_process(delta: float) -> void:
	if _main != null and _player != null:
		for arena in get_tree().get_nodes_in_group(&"battle_arena"):
			if arena._active and not arena._done and arena.use_gates:
				_main._respawn_player()
				assert(_player.global_position.x > arena.gate_left_x)
				assert(_player.global_position.x < arena.gate_right_x)
				print("ARENA RESPAWN: PASS")
				get_tree().quit()
				return
	super._physics_process(delta)
