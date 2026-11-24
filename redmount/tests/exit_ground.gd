## Bölüm sonu zemini kamera sınırına kadar uzanmalı: Bölüm 14–17'de zemin sınırdan
## önce bitiyor, çıkış kapısının altı ve sağı zeminsiz boşluk gösteriyordu (tur 419).
##
##  godot --headless --path . res://tests/exit_ground.tscn
extends Node

const GAME_STATE_SCRIPT := preload("res://scripts/systems/game_state.gd")


func _ready() -> void:
	var fails := 0
	var checked := 0
	for path in GAME_STATE_SCRIPT.LEVELS:
		var level: Node = (load(path) as PackedScene).instantiate()
		add_child(level)
		await get_tree().process_frame
		if level is DtmLevel:
			checked += 1
			var right := -INF
			for g in level._ground_parts:
				right = maxf(right, float(g[1]))
			if right < float(level.camera_limit_right):
				fails += 1
				push_error("BASARISIZ: %s zemin %d'de bitiyor, kamera sınırı %d" % [
					path, int(right), level.camera_limit_right])
		level.queue_free()
		await get_tree().process_frame
	print("EXIT GROUND: %s (%d bölüm)" % ["PASS" if fails == 0 and checked > 0 else "FAIL (%d)" % fails, checked])
	get_tree().quit(0 if fails == 0 and checked > 0 else 1)
