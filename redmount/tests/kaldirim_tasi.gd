## Kaldırım taşı (OYNANIS-KALITE P1 yeni silahlar, ikinci dilim): tek atımlık
## fırlatılan silah — mevcut GunConfig/Projectile yeniden kullanılır, mermi yay
## çizer; 3 taş bitince silah düşer. Duraklat cephaneliği tek kaynaktan
## (PauseMenu.ARMORY) yeni silahları satar; Bölüm 2'de elle konmuş taş yığını.
##
##  godot --headless --path . res://tests/kaldirim_tasi.tscn
extends Node

const STONE := preload("res://resources/weapons/kaldirim_tasi.tres")
const PISTOL := preload("res://resources/weapons/pistol.tres")
const Survival = preload("res://scripts/systems/survival.gd")

var _fails := 0


func _ready() -> void:
	Save._path = "user://kaldirim_tasi_test.cfg"
	Save.wipe()
	_resources()
	await _in_level()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://kaldirim_tasi_test.cfg"))
	print("KALDIRIM TASI: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _resources() -> void:
	_check(STONE.mag_size + STONE.starting_reserve == 3, "üç taş")
	_check(STONE.projectile_gravity > 0.0 and STONE.throw_lift > 0.0, "taş yay çizer")
	_check(PISTOL.projectile_gravity == 0.0 and PISTOL.projectile_scene == "" and PISTOL.ammo_label == "MERMİ",
		"eski ateşli silahlar varsayılanla okunur")
	_check(STONE.damage > PISTOL.damage * 2, "taş tek atışta ağır")
	var p = (load("res://scenes/pickups/TasPickup.tscn") as PackedScene).instantiate()
	_check(p.kind == "tas" and p.gun == STONE, "taş pickup sahnesi")
	p.free()
	var icon: Texture2D = load("res://assets/pickups/placeholder_tas.png")
	_check(icon != null and icon.get_width() == 48, "48 px piksel ikon")
	# Cephanelik: tek kaynak, yeni silahlar, Survival fiyatı aynı.
	var ids: Array = PauseMenu.ARMORY.map(func(i): return i.id)
	for k in ["fists", "bat", "knife", "anahtar", "semsiye", "tas", "pistol", "rifle", "armor"]:
		_check(ids.has(k), "cephanelikte " + k)
		_check(PauseMenu.ICONS.has(k), "cephanelik ikonu " + k)
	_check(Survival.armory_cost("tas") == PauseMenu.armory_cost("tas") and PauseMenu.armory_cost("tas") == 15,
		"Survival fiyatı tek kaynaktan")
	_check(Survival.armory_cost("rifle") == 60 and PauseMenu.armory_cost("yok") == -1, "eski fiyatlar")


func _in_level() -> void:
	GameState.level_index = 1  # Bölüm 2: tüfekliden önce taş yığını
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	await get_tree().process_frame
	var found := false
	for node in main._level.get_children():
		if node is PickupBase and node.get("gun") == STONE:
			found = true
	_check(found, "Bölüm 2'de elle konmuş taş yığını")

	# Cephanelikten al: coin düşer, taş kuşanılır, HUD "TAŞ 3" / "Taş: 3".
	var player = main._player
	GameState.add_coins(100)
	var before := GameState.coins
	main._on_armory_requested("tas")
	_check(GameState.coins == before - 15, "taş 15 coin")
	_check(player.has_gun() and player._gun == STONE, "taş kuşanıldı")
	_check(main._hud._ammo.text.ends_with("3") and main._hud._ammo.text.to_upper().begins_with("TAŞ"),
		"HUD taş sayısı (%s)" % main._hud._ammo.text)

	# Hedef: oyuncunun önüne konmuş düşman; taş yay çizip vurmalı.
	var enemy: EnemyBase = null
	for node in main._level.get_children():
		if node is EnemyBase:
			enemy = node
			break
	_check(enemy != null, "bölümde düşman")
	if enemy == null:
		return
	player.global_position = enemy.global_position + Vector2(-260, 0)
	player._facing = 1
	enemy.set_physics_process(false)
	await get_tree().physics_frame
	var hp: int = enemy.get_health()
	player._fire_gun()
	var stone: Projectile = null
	for node in get_tree().current_scene.get_children():
		if node is Projectile:
			stone = node
	_check(stone != null and stone.arc_gravity == STONE.projectile_gravity, "atılan taş yerçekimli")
	if stone != null:
		var vy0: float = stone._velocity.y
		_check(vy0 < 0.0, "taş yukarı doğru çıkar")
		await get_tree().physics_frame
		await get_tree().physics_frame
		if is_instance_valid(stone):
			_check(stone._velocity.y > vy0, "yerçekimi hızı aşağı çeker")
	for i in 40:
		await get_tree().physics_frame
	_check(enemy.get_health() < hp, "260 px'teki düşmana taş isabet etti (%d → %d)" % [hp, enemy.get_health()])

	# Üç atıştan sonra silah düşer (otomatik "yerden yeni taş" dolumu dahil).
	for i in 2:
		await get_tree().create_timer(0.6).timeout
		player._fire_gun()
	_check(not player.has_gun(), "üçüncü taştan sonra elde taş kalmaz")
	_check(main._hud._ammo.text == "", "HUD taş satırı gizlenir")
