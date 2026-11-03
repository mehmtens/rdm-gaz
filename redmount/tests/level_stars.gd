## Bölüm sonu yıldızları (Yol haritası 9): kayıt birleştirme, eski kayıt uyumu,
## sonuç kartında yalnız kazanılan yıldızların dolması, önceden kazanılanların soluk kalması.
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
	await _menu_cards()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("LEVEL STARS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


## Bölüm/mağaza kartı: yazı kartın kırmızı başlık şeridinin (üst 18 px) altında başlamalı,
## iki satıra kırılan uzun ad süre satırını alt çerçeveye itmemeli.
func _menu_cards() -> void:
	_check(PixelUI.box("kart", 14).content_margin_top >= 20, "kart içeriği şeridin altında")
	Save.unlocked_level = 11
	var menu: Node = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu._show(menu._levels)
	for i in 4:
		await get_tree().process_frame
	## Bölüm 4 "Silahlı Kontrol Bölgesi" 1280 genişlikte iki satıra kırılıyor.
	var card: Button = menu._grid.get_child(3)
	var labels := card.find_children("*", "Label", true, false)
	_check(labels.size() >= 3, "kartta numara, ad, süre satırı")
	for l: Label in labels:
		var top := l.global_position.y - card.global_position.y
		var bottom := top + l.size.y
		_check(top >= 18.0, "'%s' şeridin üstüne biniyor (y=%d)" % [l.text, top])
		_check(bottom <= card.size.y - 8.0, "'%s' alt çerçeveye taşıyor (%d/%d)" % [l.text, bottom, card.size.y])
	menu.queue_free()
	await get_tree().process_frame


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
	## Önceden kazanılmış ama bu koşuda alınmamış yıldız soluk; bu koşununki yine dolu.
	hud.earned_stars = Save.STAR_FLAWLESS | Save.STAR_SECRETS
	hud.show_stage_clear(2, Save.STAR_SECRETS, 60.0, 3, 4, 1, 900)
	_check(hud._star_icons[1].texture == hud.STAR_FAINT, "önceki HASARSIZ soluk")
	_check(hud._star_icons[0].texture == hud.STAR_EMPTY, "hiç alınmamış HIZ boş")
	_check(hud.earned_stars == 0, "önceki maske kartta tüketilmeli")
	await get_tree().create_timer(1.6).timeout
	_check(hud._star_icons[2].texture == hud.STAR_FULL, "bu koşunun GİZLİ ALAN'ı dolu")
	_check(hud._star_icons[1].texture == hud.STAR_FAINT, "soluk yıldız açılışta kalmalı")
	hud.show_stage_clear(2, 0, 60.0, 3, 4, 1, 900)
	_check(hud._star_icons[1].texture == hud.STAR_EMPTY, "sonraki kartta eski maske sızmamalı")
	## Hız yıldızı okunur: hedef süre kartta yazılı; hedefsiz kartta (Survival) yazılmaz.
	_check(not hud._results_stats.text.contains("hedef"), "hedefsiz kartta 'hedef' yok")
	hud.par_seconds = 160.0
	hud.show_stage_clear(2, 0, 83.0, 3, 4, 1, 900)
	_check(hud._results_stats.text.contains("Süre: 1:23 / hedef 2:40"), "kartta hedef süre: " + hud._results_stats.text)
	hud.par_seconds = 0.0
	hud.show_results(0, 0, 0, 10.0, 0, "SURVIVAL", -1)
	_check(not hud._star_row.visible, "yıldızsız sonuçta sıra gizli")
	_check(not hud._results_stats.text.contains("hedef"), "Survival kartında hedef yok")
	hud.queue_free()
	_level_pars()


## Her kampanya bölümünün kendi hız hedefi var (düz 240 sn kalktı); makul aralıkta.
func _level_pars() -> void:
	var seen := {}
	for path in GameState.LEVELS:
		var lv := (load(path) as PackedScene).instantiate()
		var par: float = lv.par_time
		lv.free()
		_check(par >= 90.0 and par <= 420.0, "%s par aralık dışı: %.0f" % [path, par])
		seen[par] = true
	_check(seen.size() >= 10, "par süreleri bölüme özgü olmalı (%d farklı)" % seen.size())
