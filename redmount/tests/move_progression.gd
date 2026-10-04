extends Node

func _ready() -> void:
	call_deferred(&"_run")

func _run() -> void:
	var old_purchased := Save.purchased.duplicate()
	var old_upgrades := Save.upgrade_levels.duplicate(true)
	Save.purchased = []
	Save.upgrade_levels = {}
	var player: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	player.add_to_group(&"player")
	add_child(player)
	assert(player._combo_limit() == 2, "Başlangıç kombosu iki vuruş olmalı")
	assert(player.get_max_health() == player.combat.max_health, "Başlangıç canı değişmemeli")

	Save.purchased = ["combo_finish", "ground_slam"]
	Save.upgrade_levels = {
		"fist_power": 3,
		"combo_speed": 3,
		"finisher_power": 3,
		"weapon_capacity": 3,
		"weapon_power": 3,
		"firearm_power": 3,
		"max_health": 3,
	}
	var upgraded: CharacterBody2D = load("res://scenes/characters/Redmount.tscn").instantiate()
	add_child(upgraded)
	assert(player._combo_limit() == 3, "Yükseltme üçüncü vuruşu açmalı")
	assert(upgraded.get_max_health() == upgraded.combat.max_health + 45,
		"Üç can kademesi toplam +45 can vermeli")
	assert(is_equal_approx(upgraded._combo_time_multiplier(), 0.82),
		"Üç kombo hızı kademesi süreyi %18 azaltmalı")
	upgraded._attack = upgraded.Attack.COMBO
	upgraded._combo_index = 0
	assert(upgraded._current_damage() == 8, "Yumruk gücü ilk vuruşu 6'dan 8'e çıkarmalı")
	upgraded._combo_index = 2
	assert(upgraded._current_damage() == 28, "Bitirici gücü üçüncü vuruşa ayrıca uygulanmalı")
	var thug: EnemyBase = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	add_child(thug)
	upgraded._hit_this_swing.clear()
	upgraded._deal_attack_hit(thug)
	assert(thug._state == EnemyBase.State.KNOCKDOWN and thug.velocity.y < -250.0,
		"Üçüncü kombo vuruşu düşmanı havaya savurup yere düşürmeli")
	thug.global_position = upgraded.global_position + Vector2(40, 0)
	var throw_health := thug._health
	assert(upgraded._try_throw(), "Yakındaki sersemlemiş düşman ağır saldırıyla fırlatılabilmeli")
	assert(thug._health < throw_health and thug.velocity.x > 500.0 and thug.velocity.y < -300.0,
		"Fırlatma hasar ve belirgin yatay/dikey hız vermeli")
	var collision_target: EnemyBase = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	add_child(collision_target)
	collision_target.global_position = thug.global_position + Vector2(40, 0)
	var collision_health := collision_target._health
	thug._tick_thrown_collision(0.016)
	assert(collision_target._health < collision_health,
		"Fırlatılan düşman çarptığı başka düşmana hasar vermeli")
	var waiting_thug: EnemyBase = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	add_child(waiting_thug)
	collision_target.global_position = player.global_position + Vector2(50, 0)
	collision_target._state = EnemyBase.State.ATTACK
	assert(not waiting_thug._has_melee_turn(),
		"İki normal düşman aynı anda yakın saldırıya başlamamalı")
	collision_target.global_position = player.global_position + Vector2(500, 0)
	assert(waiting_thug._has_melee_turn(),
		"Uzak bir çatışmadaki düşman yakın saldırı sırasını kilitlememeli")
	collision_target._state = EnemyBase.State.CHASE
	assert(waiting_thug._has_melee_turn(), "Saldırı bitince sıradaki düşman ilerleyebilmeli")
	upgraded.equip_weapon(load("res://resources/weapons/bat.tres"))
	assert(upgraded._weapon_uses == 19, "Silah kapasitesi sopa dayanıklılığını artırmalı")
	upgraded._attack = upgraded.Attack.WEAPON
	assert(upgraded._current_damage() == int(roundf(upgraded._weapon.damage * 1.45)),
		"Yakın silah ustalığı üçüncü kademede hasarı %45 artırmalı")
	upgraded.equip_gun(load("res://resources/weapons/pistol.tres"))
	assert(upgraded._reserve == 38, "Silah kapasitesi yedek cephaneyi artırmalı")
	assert(upgraded._gun_damage() == int(roundf(upgraded._gun.damage * 1.45)),
		"Atış eğitimi üçüncü kademede mermi hasarını %45 artırmalı")
	var air_target: EnemyBase = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	add_child(air_target)
	air_target.launch(300.0)
	upgraded._attack = upgraded.Attack.AIR_KNEE
	upgraded._hit_this_swing.clear()
	upgraded.velocity.y = 0.0
	upgraded._deal_attack_hit(air_target)
	assert(air_target.velocity.y < -300.0 and upgraded.velocity.y < -200.0,
		"Hava dizi havadaki düşmanı yeniden yükseltip oyuncuyu sektirmeli")

	var enemy: EnemyBase = load("res://scenes/enemies/ArmoredBruiser.tscn").instantiate()
	add_child(enemy)
	enemy.global_position = player.global_position + Vector2(50, 0)
	var health_before: int = enemy._health
	player._slam_impact()
	assert(enemy._health < health_before, "Yere çakma hasar vermeli")
	assert(enemy._state == EnemyBase.State.ARMOR_BREAK, "Yere çakma zırhı sarsmalı")

	var unupgraded: EnemyBase = load("res://scenes/enemies/ArmoredBruiser.tscn").instantiate()
	add_child(unupgraded)
	for i in 4:
		unupgraded.apply_hit(8, Vector2.RIGHT, 0)
	assert(unupgraded._state == EnemyBase.State.ARMOR_BREAK,
		"Yükseltme olmadan tekrar vurarak zırh kırılabilmeli")
	Save.purchased = old_purchased
	Save.upgrade_levels = old_upgrades
	print("MOVE PROGRESSION OK")
	get_tree().quit(0)
