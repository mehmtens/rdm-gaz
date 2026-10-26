## Adlı rakip (tasarım denetimi Bölüm 4, 26 Ekim): ara sahnede tanıtılan Yüzbaşı Demir
## dövüşte sıradan bir Seçkin Muhafızdı. Arenanın `named_wave` dalgasının ilk düşmanı
## adıyla boss olur (HUD can çubuğu), canı katlanır; ortak ayar dosyası bozulmaz.
##
##  godot --headless --path . --fixed-fps 60 res://tests/named_foe.tscn
extends Node

const ARENA := preload("res://scenes/systems/BattleArena.tscn")
const ELITE := preload("res://scenes/enemies/EliteGuard.tscn")

var _fails := 0


func _ready() -> void:
	var arena: BattleArena = ARENA.instantiate()
	arena.gate_left_x = 0
	arena.gate_right_x = 600
	arena.wave1 = [ELITE, ELITE]
	arena.named_title = "YÜZBAŞI DEMİR"
	arena.named_wave = 1
	var spawned: Array = []
	arena.enemy_spawned.connect(func(e: Node) -> void: spawned.append(e))
	add_child(arena)
	arena._active = true
	arena._activate()
	await get_tree().physics_frame
	_check(spawned.size() == 2, "iki düşman doğdu (%d)" % spawned.size())
	if spawned.size() == 2:
		var boss: EnemyBase = spawned[0]
		var guard: EnemyBase = spawned[1]
		_check(boss.config.is_boss and boss.config.display_name == "YÜZBAŞI DEMİR", "ilk düşman adlı boss")
		_check(boss.get_health() == 100, "can 40 × 2,5 = 100 (%d)" % boss.get_health())
		_check(not guard.config.is_boss and guard.get_health() == 40, "ikinci düşman sıradan")
	var fresh: EnemyBase = ELITE.instantiate()
	_check(not fresh.config.is_boss and fresh.config.max_health == 40, "ortak ayar dosyası değişmedi")
	fresh.free()
	print("NAMED FOE: %s" % ["PASS" if _fails == 0 else "FAIL (%d)" % _fails])
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("NAMED FOE FAIL: " + what)
