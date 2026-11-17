## Açılış mahzeni (x < -230) her bölümde zırh ödüllü tek zula taşır ve dizilim
## bölümler arasında değişir (tur 259: 36 bölümün hepsi aynı sandıktı).
##  godot --headless --path . res://tests/cellar_variety.tscn
extends Node

const ARMOR_PATH := "res://scenes/pickups/ArmorPickup.tscn"


func _ready() -> void:
	var fail := false
	var styles := {}
	for i in GameState.level_count():
		var lv: Node = load(GameState.LEVELS[i]).instantiate()
		add_child(lv)
		await get_tree().process_frame
		var kinds: Array = []
		var armor := 0
		for n in lv.get_children():
			if n is BreakableProp and n.position.x < -230.0 and n.position.x > -600.0:
				kinds.append(n.kind)
				if n.reward != null and n.reward.resource_path == ARMOR_PATH:
					armor += 1
		kinds.sort()
		var key := ",".join(kinds)
		styles[key] = int(styles.get(key, 0)) + 1
		if armor != 1:
			print("FAIL B%d mahzen zırh=%d %s" % [i + 1, armor, key])
			fail = true
		lv.queue_free()
		await get_tree().process_frame
	print("dizilimler: ", styles)
	if styles.size() < 2:
		print("FAIL tek dizilim")
		fail = true
	print("CELLAR VARIETY: ", "FAIL" if fail else "PASS")
	get_tree().quit(1 if fail else 0)
