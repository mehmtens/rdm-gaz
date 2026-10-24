## Duraklat menüsündeki "giyili" kostüm rozeti: bonuslu kostümde ikon + ad + bonus,
## bonussuz sokak ceketinde gizli; kısa bonus metinleri `Shop.COSTUMES`'tan gelir.
##
##  godot --headless --path . res://tests/costume_badge.tscn
extends Node

var _fails := 0


func _ready() -> void:
	Save._path = "user://costume_badge_test.cfg"
	Save.wipe()
	_check(Shop.costume_bonus_text("sokak") == "", "sokak ceketi bonussuz")
	_check(Shop.costume_bonus_text("vapurcu") == "CAN +10", "vapurcu: " + Shop.costume_bonus_text("vapurcu"))
	_check(Shop.costume_bonus_text("hamal") == "SİLAH ÖMRÜ +%15", "hamal: " + Shop.costume_bonus_text("hamal"))
	_check(Shop.costume_bonus_text("kahveci") == "YİYECEK +%25", "kahveci: " + Shop.costume_bonus_text("kahveci"))
	_check(Shop.costume_bonus_text("kizil") == "YUMRUK +%8", "kizil: " + Shop.costume_bonus_text("kizil"))

	var pause := PauseMenu.new()
	add_child(pause)
	await get_tree().process_frame
	var badge := pause._root.get_node_or_null(^"Costume") as Control
	_check(badge != null, "rozet menüde olmalı")
	if badge:
		_check(not badge.visible, "varsayılan kostümde rozet gizli")
		Save.costume = "kizil"
		pause.open()
		await get_tree().process_frame
		_check(badge.visible, "kızıl dağ giyiliyken rozet görünür")
		_check(pause._costume_name.text == "GİYİLİ: KIZIL DAĞ", pause._costume_name.text)
		_check(pause._costume_bonus.text == "YUMRUK +%8", pause._costume_bonus.text)
		_check(pause._costume_icon.texture != null, "başlık ikonu yüklenmeli")
		pause.close()
	Save.costume = Shop.DEFAULT_COSTUME
	pause.queue_free()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://costume_badge_test.cfg"))
	print("COSTUME BADGE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
