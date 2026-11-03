## GÖREVLER (Achievements, OYNANIS-KALITE P2 başarımlar): kayıttan türeyen ilerleme, eski kayıt
## uyumu (tabela yağmuru yok, ödül alınabilir), tek seferlik ödül, olay sayaçları, HUD tabelası,
## arşivdeki GÖREVLER sekmesi ve ana menü "· n ÖDÜL" düğmesi.
##
##  godot --headless --path . res://tests/achievements.tscn
extends Node

const PATH := "user://achievements_test.cfg"

var _fails := 0
var _heard: Array = []


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	Save.achievement_reached.connect(func(id: String) -> void: _heard.append(id))
	_definitions()
	_progress_and_claim()
	_legacy_save()
	await _hud_toast()
	await _menu()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("ACHIEVEMENTS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _definitions() -> void:
	var ids := {}
	for a in Achievements.LIST:
		_check(not ids.has(a.id), "tekrar eden id " + String(a.id))
		ids[a.id] = true
		_check(int(a.goal) > 0 and int(a.reward) > 0, "%s hedef/ödül" % a.id)
		_check(String(a.name) == String(a.name).strip_edges() and String(a.name).length() <= 18,
			"%s adı tabelaya sığmalı" % a.id)
		_check(Achievements.value(a) == 0, "%s boş kayıtta 0" % a.id)
	_check(Achievements.LIST.size() >= 15, "en az 15 görev")
	_check(Achievements.reached().is_empty() and Achievements.unclaimed() == 0, "boş kayıtta görev yok")


func _progress_and_claim() -> void:
	_heard.clear()
	Save.record_level_clear(0, 0, 500)
	_check(Achievements.is_done(Achievements.find("ilk_adim")), "Bölüm 1 bitince İLK ADIM")
	_check(_heard == ["ilk_adim"], "tabela bir kez duyurulmalı: %s" % [_heard])
	Save.record_level_clear(0, 0, 600)
	_check(_heard.size() == 1, "aynı görev ikinci kez duyurulmaz")
	_check(Save.total_coins == 0, "ödül kendiliğinden eklenmez")
	_check(Achievements.unclaimed() == 1, "bir alınmamış ödül")
	_check(Save.claim_achievement("ilk_adim") == 30 and Save.total_coins == 30, "ödül 30 coin")
	_check(Save.claim_achievement("ilk_adim") == 0 and Save.total_coins == 30, "ödül bir kez")
	_check(Save.claim_achievement("kitap3") == 0, "bitmemiş görev ödülü alınamaz")
	_check(Save.claim_achievement("yok_boyle") == 0, "bilinmeyen id")
	## Olay sayaçları: düşman ve kombo (Combat sinyali üzerinden).
	for i in 100:
		Save.count_defeat()
	_check("yuz_kavga" in _heard, "100. düşmanda MAHALLE KAVGASI")
	Combat.combo_finished.emit(12, 0)
	Combat.combo_finished.emit(8, 0)
	_check(Save.stat_best_combo == 12, "en uzun kombo tutulur")
	Combat.combo_finished.emit(25, 0)
	_check("kombo_25" in _heard, "25 kombo görevi")
	## Kayıttan türeyenler: gizli alan, yıldız, kostüm, geliştirme, survival, seri.
	for i in 4:
		Save.record_secrets(i, 3, 3)
	_check(Achievements.value(Achievements.find("iz_suren")) == 12, "gizli alanlar toplanır")
	Save.purchased.append_array(["costume_vapurcu", "costume_hamal", "combo_finish"])
	_check(Achievements.value(Achievements.find("gardirop")) == 2, "yalnız kostümler sayılır")
	Save.upgrade_levels = {"fist_power": 3, "max_health": 2}
	_check(Achievements.value(Achievements.find("talim")) == 5, "geliştirme kademeleri toplanır")
	Save.record_survival(10, 0)
	_check("dalga_10" in _heard and not ("dalga_20" in _heard), "survival 10. dalga")
	## Kalıcılık: sayaçlar ve alınan ödül yeniden yüklemede korunur.
	Save.save_game()
	Save.load_game()
	_check(Save.stat_defeats == 100 and Save.stat_best_combo == 25, "sayaçlar kayıtta")
	_check("ilk_adim" in Save.achievements_claimed, "alınan ödül kayıtta")
	_check(Save.can_claim_achievement("yuz_kavga") and not Save.can_claim_achievement("ilk_adim"),
		"alınabilirlik yüklemeden sonra doğru")


## Görev alanları olmayan eski kayıt: tamamlanmışlar görülmüş sayılır (tabela yağmuru yok),
## ödülleri yine alınabilir; eski alanlar bozulmaz.
func _legacy_save() -> void:
	Save.wipe()
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_level", 12)
	cfg.set_value("progress", "total_coins", 40)
	cfg.set_value("progress", "best_scores", {0: 100, 11: 900})
	cfg.save(PATH)
	_heard.clear()
	Save.load_game()
	_check(Save.total_coins == 40 and Save.unlocked_level == 12, "eski alanlar okunur")
	_check("kitap1" in Save.achievements_seen and "ilk_adim" in Save.achievements_seen, "eski ilerleme görülmüş")
	Save.save_game()
	_check(_heard.is_empty(), "eski kayıtta tabela çıkmaz: %s" % [_heard])
	_check(Achievements.unclaimed() == 2, "eski ilerlemenin ödülü alınabilir")
	_check(Save.stat_defeats == 0 and Save.stat_best_combo == 0, "eski kayıtta sayaçlar 0")


func _hud_toast() -> void:
	Save.wipe()
	var hud: Control = (load("res://scenes/ui/HUD.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	Save.record_level_clear(0, 0, 100)
	await get_tree().process_frame
	_check(hud._ach != null and hud._ach.showing() == "İLK ADIM", "HUD tabelası açıldı")
	## Sıradaki görev kuyruğa girer, ilki bitince gösterilir.
	for i in 100:
		Save.count_defeat()
	_check(hud._ach.showing() == "İLK ADIM", "ikinci görev sırada bekler")
	await get_tree().create_timer(3.4).timeout
	_check(hud._ach.showing() == "MAHALLE KAVGASI", "sıradaki görev gösterildi")
	await get_tree().create_timer(3.4).timeout
	_check(hud._ach.showing() == "", "kuyruk bitince kapanır")
	hud.queue_free()
	await get_tree().process_frame


func _menu() -> void:
	## Önceki adımda iki görev tamamlandı, ödülleri alınmadı.
	var menu: Node = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	var btn: Button = menu.find_child("ArchiveButton", true, false)
	_check(btn != null and btn.text == "KANIT ARŞİVİ · 2 ÖDÜL", "ana menüde ödül sayısı: %s" % (btn.text if btn else "yok"))
	btn.pressed.emit()
	for i in 3:
		await get_tree().process_frame
	_check(menu._archive.visible and menu._arch_book == menu.ACH_TAB, "arşiv GÖREVLER'de açılır")
	_check(menu._arch_grid.get_child_count() == Achievements.LIST.size(), "her görev bir satır")
	var cell: Node = menu._arch_grid.find_child("Ach_ilk_adim", false, false)
	var claim: Button = cell.find_child("Claim", true, false) if cell else null
	_check(claim != null and claim.text == "AL +30", "alınabilir ödül düğmesi")
	var locked: Node = menu._arch_grid.find_child("Ach_kitap3", false, false)
	_check(locked != null and locked.find_child("Claim", true, false) == null, "bitmemiş görevde düğme yok")
	claim.pressed.emit()
	for i in 4:
		await get_tree().process_frame
	_check(Save.total_coins == 30, "ödül cüzdanda")
	_check(menu._archive.visible and menu._arch_book == menu.ACH_TAB, "ödülden sonra GÖREVLER'de kalır")
	var again: Node = menu._arch_grid.find_child("Ach_ilk_adim", false, false)
	_check(again != null and again.find_child("Claim", true, false) == null, "alınan ödülün düğmesi kalkar")
	btn = menu.find_child("ArchiveButton", true, false)
	_check(btn != null and btn.text == "KANIT ARŞİVİ · 1 ÖDÜL", "ana menü sayacı güncellenir")
	## Görev satırları panelden taşmamalı (1280 genişlikte iki sütun).
	var row: Control = menu._arch_grid.get_child(0)
	_check(row.size.x > 300.0 and row.get_global_rect().end.x <= get_viewport().get_visible_rect().size.x - 40.0,
		"görev satırı ekranda: %s" % row.get_global_rect())
	menu.queue_free()
	await get_tree().process_frame
