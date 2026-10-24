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
	# Elde taş sayfaları: her bekleme/yürüme karesinde silah işaretli (alfa 252) taş.
	for sheet in ["tas_idle", "tas_walk"]:
		var img := Image.load_from_file(ProjectSettings.globalize_path("res://assets/anim/redmount/%s.png" % sheet))
		_check(img != null and img.get_height() == 240, "%s sayfası" % sheet)
		if img == null:
			continue
		for c in img.get_width() / 200:
			var marked := 0
			for y in range(120, 200):
				for x in range(c * 200 + 40, c * 200 + 180):
					if img.get_pixel(x, y).a8 == 252:
						marked += 1
			_check(marked > 100, "%s %d. kare taş işareti (%d px)" % [sheet, c, marked])
	_check(CostumeAccessory.anchor("tas_idle", 2) == CostumeAccessory.anchor("idle", 2)
		and not CostumeAccessory.anchor("tas_walk", 7).is_empty(), "taş sayfaları başlık çapasını paylaşır")


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
	var rig: AnimatedSprite2D = player.rig
	# Işınlanınca iniş/çömelme karesi oynar; yere oturup durunca bekleme.
	for i in 60:
		await get_tree().physics_frame
		if rig.animation == &"tas_idle":
			break
	_check(rig.animation == &"tas_idle", "beklerken elde taş görünür (%s)" % rig.animation)
	_check(rig.sprite_frames.get_frame_count(&"tas_walk") == 8
		and rig.sprite_frames.get_frame_count(&"tas_shoot") == 4, "taş animasyon kare sayıları")
	var hp: int = enemy.get_health()
	player._fire_gun()
	await get_tree().physics_frame
	_check(rig.animation == &"tas_shoot", "atışta fırlatma sayfası oynar (%s)" % rig.animation)
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

	# Dördüncü dilim: varil ganimeti oyuncunun eline göre, büfede taş, kutu sınırı.
	var ammo := load(BreakableProp.AMMO_PATH) as PackedScene
	_check(BreakableProp.adapt_loot(ammo, player).resource_path == BreakableProp.STONES_PATH,
		"silahsızken varilden cephane yerine taş")
	_check(BreakableProp.adapt_loot(null, player) == null, "boş zar boş kalır")
	var crate := load("res://scenes/pickups/HealthPickup.tscn") as PackedScene
	_check(BreakableProp.adapt_loot(crate, player) == crate, "yiyecek değişmez")
	player.equip_gun(PISTOL)
	_check(BreakableProp.adapt_loot(ammo, player) == ammo, "tabancalıyken cephane kalır")
	player.equip_gun(STONE)
	var reserve: int = player._reserve
	player.add_ammo(16)
	_check(player._reserve == reserve + 3, "cephane kutusu taşa bir yığın ekler (%d)" % (player._reserve - reserve))
	_check(LevelShop.CATALOG.has("tas") and LevelShop.CATALOG["tas"]["scene"].resource_path == BreakableProp.STONES_PATH,
		"büfe kataloğunda taş")
	var shop_has := false
	for node in main._level.get_children():
		if node is LevelShop and node.items.has("tas"):
			shop_has = true
	_check(shop_has, "Bölüm 2 bakkalında taş satılıyor")
