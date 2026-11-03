## Bölüm sonu ipucu ekranı sade (denetim, 3 Kasım): tebeşir bulununca duyuru yalnız üst
## kartta (başlık "İPUCU BULUNDU", ikinci satır tebeşirin tekrarı değil); sahne sırasında
## sol üst durum sütunu bütün olarak söner, sahne bitince geri gelir.
##
##  godot --headless --path . res://tests/clue_card.tscn
extends Node

var _fails := 0


func _ready() -> void:
	Save._path = "user://clue_card_test.cfg"
	Save.wipe()
	GameState.level_index = 1
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	var cutscene: Cutscene = null
	var chalk: Node2D = null
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
			if cutscene == null:
				cutscene = node
		elif node.has_method(&"_reveal") and node.get("text") is String:
			chalk = node
	await get_tree().process_frame
	var hud = main.get_node(^"UI/HUD")
	_check(chalk != null, "Bölüm 2'de tebeşir ipucu olmalı")
	if chalk != null:
		main._player.global_position = chalk.global_position + Vector2(0, 120)
		for i in 6:
			await get_tree().process_frame
		var place = hud._place
		_check(place != null and place.visible, "tebeşir bulununca üst kart açılmalı")
		if place != null:
			_check(place._title == "İPUCU BULUNDU", "kart başlığı duyuru olmalı (%s)" % place._title)
			_check(place._story.text != chalk.text, "kartın ikinci satırı tebeşirin tekrarı olmamalı")

	# Sahne: durum sütunu bütün olarak söner (yarım HUD yok), sahne bitince döner.
	var column: Array = [hud.get_node(^"HealthBg"), hud._coins, hud._weapon, hud._ammo]
	Cutscene.active = cutscene
	for i in 40:
		await get_tree().process_frame
	for c: CanvasItem in column:
		_check(c.modulate.a < 0.05, "%s sahnede sönmeli (%.2f)" % [c.name, c.modulate.a])
	Cutscene.active = null
	for i in 40:
		await get_tree().process_frame
	for c: CanvasItem in column:
		_check(c.modulate.a > 0.95, "%s sahne bitince geri gelmeli (%.2f)" % [c.name, c.modulate.a])

	main.queue_free()
	await get_tree().process_frame
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://clue_card_test.cfg"))
	print("CLUE CARD: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
