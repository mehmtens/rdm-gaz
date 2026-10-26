## HUD sadeleştirme (tasarım denetimi 26 Ekim): cephanelik ipucu yalnız duraklatma bir kez
## açılana kadar görünür; silahsızken silah satırı boş; bayrak kayıtta, eski kayıtta false.
##
##  godot --headless --path . res://tests/hud_hints.tscn
extends Node

const PATH := "user://hud_hints_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_check(not Save.armory_seen, "silinen kayıtta ipucu görülmemiş")
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	var coins := hud.get_node(^"CoinLabel") as Label
	var weapon := hud.get_node(^"WeaponLabel") as Label
	GameState.level_index = 3
	hud._on_coins_changed(12)
	_check(coins.text.contains("CEPHANELİK"), "ilk kez: ipucu görünür (%s)" % coins.text)
	GameState.level_index = 0
	hud._on_coins_changed(12)
	_check(not coins.text.contains("CEPHANELİK"), "Bölüm 1'de ipucu yok")
	GameState.level_index = 3
	Save.set_armory_seen()
	hud._on_coins_changed(13)
	_check(not coins.text.contains("CEPHANELİK"), "cephanelik görüldükten sonra ipucu yok")
	# Kayıtta kalıcı.
	Save.armory_seen = false
	Save.load_game()
	_check(Save.armory_seen, "bayrak kayıttan okunur")
	# Eski kayıt: [hints] bölümü yok.
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.erase_section("hints")
	cfg.save(PATH)
	Save.load_game()
	_check(not Save.armory_seen, "eski kayıtta varsayılan false")
	hud.set_weapon("", 0, 0)
	_check(weapon.text.is_empty(), "silahsızken silah satırı boş")
	hud.set_weapon("Sopa", 3, 10)
	_check(weapon.text == "Sopa  3/10", "silah kısa biçim (%s)" % weapon.text)
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("HUD HINTS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
