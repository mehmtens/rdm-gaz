## Bölüm sonu yıldızları (Yol haritası 9): kayıt birleştirme, eski kayıt uyumu,
## sonuç kartında yalnız kazanılan yıldızların dolması.
##
##  godot --headless --path . res://tests/level_stars.tscn
extends Node

const PATH := "user://level_stars_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_save_merge()
	_legacy_save()
	await _results_card()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("LEVEL STARS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _save_merge() -> void:
	Save.record_stars(0, Save.STAR_SPEED)
	Save.record_stars(0, Save.STAR_SECRETS)
	Save.record_stars(0, 0)
	_check(Save.stars_of(0) == Save.STAR_SPEED | Save.STAR_SECRETS, "yıldızlar birleşmeli, kaybolmamalı")
	Save.record_stars(5, 0xFF)
	_check(Save.star_count(5) == 3, "geçersiz bitler atılmalı")
	_check(Save.total_stars() == 5, "toplam yıldız: %d" % Save.total_stars())
	_check(not Save.is_complete(0) and Save.is_complete(5), "%100 yalnız 3 yıldızda")
	Save.load_game()
	_check(Save.total_stars() == 5, "yıldızlar kayıttan okunmalı")


## Yıldız alanı olmayan eski kayıt: hata vermeden 0 yıldızla açılmalı.
func _legacy_save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_level", 4)
	cfg.set_value("progress", "ranks", {2: "S"})
	cfg.save(PATH)
	Save.load_game()
	_check(Save.unlocked_level == 4, "eski kayıt ilerlemesi okunmalı")
	_check(Save.total_stars() == 0 and Save.stars_of(2) == 0, "eski kayıtta yıldız 0")
	_check(not Save.is_complete(2), "eski S rütbesi tek başına %100 değil")


func _results_card() -> void:
	var hud: Control = (load("res://scenes/ui/HUD.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.show_stage_clear(2, Save.STAR_SPEED | Save.STAR_SECRETS, 60.0, 3, 4, 1, 900)
	_check(hud._star_row.visible, "yıldız sırası görünmeli")
	_check(not hud._results_rank.visible, "harf rütbesi gösterilmemeli")
	await get_tree().create_timer(1.6).timeout
	_check(hud._star_icons[0].texture == hud.STAR_FULL, "HIZ yıldızı dolu")
	_check(hud._star_icons[1].texture == hud.STAR_EMPTY, "HASARSIZ yıldızı boş")
	_check(hud._star_icons[2].texture == hud.STAR_FULL, "GİZLİ ALAN yıldızı dolu")
	hud.show_results(0, 0, 0, 10.0, 0, "SURVIVAL", -1)
	_check(not hud._star_row.visible, "yıldızsız sonuçta sıra gizli")
	hud.queue_free()
