extends Node

const Survival = preload("res://scripts/systems/survival.gd")


func _ready() -> void:
	assert(Survival.enemy_count_for_wave(1) == 3)
	assert(Survival.enemy_count_for_wave(9) == 8)
	assert(Survival.enemy_count_for_wave(10) == 1)
	assert(Survival.reward_for_wave(1) == 5)
	assert(Survival.reward_for_wave(5) == 13)
	assert(Survival.armory_cost("rifle") == 60)
	assert(Survival.armory_cost("unknown") == -1)
	assert(ResourceLoader.exists("res://scenes/Survival.tscn"))
	print("SURVIVAL MODE OK")
	get_tree().quit(0)
