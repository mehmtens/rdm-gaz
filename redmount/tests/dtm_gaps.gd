## Dan the Man boşlukları (23 Ekim): arena dalga göstergesi, düşmandan silah düşmesi,
## kırılabilir nesne ganimet tablosu, bölüm en iyi süresi ve %100 ustalık ödülü.
##
##  godot --headless --path . res://tests/dtm_gaps.tscn
extends Node

var _fails := 0
var _waves: Array = []


func _ready() -> void:
	Save._path = "user://dtm_gaps_test.cfg"
	Save.wipe()
	_loot_table()
	_mastery()
	await _hud_counter()
	await _arena_signal()
	await _enemy_drop()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://dtm_gaps_test.cfg"))
	print("DTM GAPS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _loot_table() -> void:
	var health := BreakableProp.roll_loot("kasa", 0.1, 0)
	_check(health != null and health.resource_path.ends_with("HealthPickup.tscn"), "kasa yiyecek düşürmeli")
	_check(BreakableProp.roll_loot("kasa", 0.9, 0) == null, "kasa zar tutmazsa boş")
	_check(BreakableProp.roll_loot("vazo", 0.0, 0) == null, "vazo yalnız coin")
	var knife := BreakableProp.roll_loot("sandik", 0.0, 1)
	_check(knife != null and knife.resource_path.ends_with("KnifePickup.tscn"), "sandık silah düşürmeli")


func _mastery() -> void:
	Save.record_stars(3, Save.STAR_SPEED | Save.STAR_FLAWLESS)
	_check(not Save.is_complete(3), "eksik yıldızla %100 sayılmamalı")
	_check(Save.claim_mastery(3) == 0, "eksik bölüm ödül vermemeli")
	Save.record_stars(3, Save.STAR_SECRETS)
	_check(Save.stars_of(3) == 7 and Save.star_count(3) == 3, "yıldızlar koşular arası birleşmeli")
	_check(Save.is_complete(3), "3 yıldız = %100")
	_check(Save.claim_mastery(3) == Save.MASTERY_REWARD, "ilk %100 ödülü")
	_check(Save.total_coins == Save.MASTERY_REWARD, "ödül cüzdana eklenmeli")
	_check(Save.claim_mastery(3) == 0, "ödül ikinci kez verilmemeli")
	Save.record_time(3, 200.0)
	Save.record_time(3, 150.0)
	Save.record_time(3, 300.0)
	_check(is_equal_approx(Save.best_time(3), 150.0), "en iyi süre en kısası olmalı")
	Save.load_game()
	_check(Save.mastered.has(3) and is_equal_approx(Save.best_time(3), 150.0), "ustalık ve süre kayda yazılmalı")
	_check(Save.star_count(3) == 3 and Save.total_stars() == 3, "yıldızlar kayda yazılmalı")


func _hud_counter() -> void:
	var hud: Control = (load("res://scenes/ui/HUD.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.set_arena_wave(2, 3, 4)
	_check(hud._arena_panel.visible, "arena göstergesi görünmeli")
	_check(hud._arena_label.text == "DALGA 2/3  ·  4 DÜŞMAN", "gösterge metni: " + hud._arena_label.text)
	hud.set_arena_wave(0, 0, 0)
	_check(not hud._arena_panel.visible, "arena bitince gösterge gizlenmeli")
	hud.queue_free()


func _arena_signal() -> void:
	var thug := load("res://scenes/enemies/StreetThug.tscn") as PackedScene
	var holder := Node2D.new()
	add_child(holder)
	var arena := BattleArena.new()
	arena.lock_camera = false
	arena.use_gates = false
	arena.wave_delay = 0.1
	arena.wave1 = [thug]
	arena.wave2 = [thug, thug]
	holder.add_child(arena)
	arena.wave_changed.connect(func(w: int, t: int, r: int) -> void: _waves.append([w, t, r]))
	arena._spawn_wave()
	_check(_waves.back() == [1, 2, 1], "dalga 1 başlangıcı: %s" % [_waves])
	arena._on_enemy_down(arena._alive[0])
	await get_tree().create_timer(0.4).timeout
	_check(_waves.has([1, 2, 0]), "dalga 1 temizlendi sinyali: %s" % [_waves])
	_check(_waves.back() == [2, 2, 2], "dalga 2 başlangıcı: %s" % [_waves])
	holder.queue_free()
	await get_tree().process_frame


func _enemy_drop() -> void:
	var holder := Node2D.new()
	add_child(holder)
	var agent: Node2D = (load("res://scenes/enemies/KnifeAgent.tscn") as PackedScene).instantiate()
	agent.config = agent.config.duplicate()
	agent.config.drop_chance = 1.0
	holder.add_child(agent)
	await get_tree().process_frame
	agent.apply_hit(999, Vector2.RIGHT, 0.0)
	await get_tree().process_frame
	var dropped := false
	for n in holder.get_children():
		if n is PickupBase and n.get(&"weapon") != null:
			dropped = n.weapon.resource_path.ends_with("knife.tres")
	_check(dropped, "Bıçaklı Ajan bıçağını bırakmalı")
	holder.queue_free()
	await get_tree().process_frame
