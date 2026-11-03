## GÖREVLER dördüncü dilim: büyük görevlerin Kanıt Arşivi kareleri. Kare dosyaları var ve
## piksel boyutu doğru; görev bitince açılır (kayıttan türer, eski kayıtta yeni alan yok);
## arşiv satırında açık/kilitli kare, HUD tabelasında "kare" başlığı.
##
##  godot --headless --path . res://tests/achievement_photos.tscn
extends Node

const PATH := "user://achievement_photos_test.cfg"
const LOCKED := "res://assets/ui/photos/kilitli.png"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_definitions()
	_unlock()
	await _menu()
	await _toast()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("ACHIEVEMENT PHOTOS: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _definitions() -> void:
	_check(Achievements.PHOTOS.size() == 3, "üç görev karesi")
	for id in Achievements.PHOTOS:
		_check(not Achievements.find(id).is_empty(), "%s görev listesinde" % id)
		var tex: Texture2D = load(Achievements.photo_path(id))
		## Bölüm ve günlük kareleriyle aynı ölçü: 72x48 + 1 px kontur.
		_check(tex != null and tex.get_size() == Vector2(74, 50), "%s karesi 74x50" % id)
	_check(Achievements.photo_path("ilk_adim") == "", "küçük görevde kare yok")
	_check(Achievements.photos_open() == 0, "boş kayıtta kare kapalı")


func _unlock() -> void:
	Save.stat_flawless_bosses = 1
	_check(Achievements.photos_open() == 1, "hasarsız patron TEMİZ İŞ karesini açar")
	## Eski kayıt: alan yok, görev ilerlemesinden türer; yükleme sonrası da açık.
	Save.save_game()
	Save.load_game()
	_check(Achievements.photos_open() == 1, "kare yeniden yüklemede açık")


func _photo_of(menu: Node, id: String) -> TextureRect:
	var cell: Node = menu._arch_grid.find_child("Ach_" + id, false, false)
	return cell.find_child("Photo", true, false) if cell else null


func _menu() -> void:
	var menu: Node = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	## Sekme odağı ertelenmiş gelir ve seçimi yeniden yapar: önce sekmeyi ayarla, sonra aç.
	menu._arch_book = menu.ACH_TAB
	menu._show(menu._archive)
	for i in 3:
		await get_tree().process_frame
	_check(menu._arch_grid.get_child_count() == Achievements.LIST.size(), "satır sayısı değişmedi")
	var open := _photo_of(menu, "temiz_is")
	_check(open != null and open.texture.resource_path == Achievements.photo_path("temiz_is"), "bitmiş görevde kare açık")
	var shut := _photo_of(menu, "kitap3")
	_check(shut != null and shut.texture.resource_path == LOCKED, "bitmemiş görevde kilitli kare")
	_check(_photo_of(menu, "ilk_adim") == null, "küçük görev satırında kare yok")
	## Satır ve AL düğmesi panelden taşmaz.
	var cell: Control = menu._arch_grid.find_child("Ach_temiz_is", false, false)
	var claim: Control = cell.find_child("Claim", true, false)
	_check(claim != null and claim.get_global_rect().end.x <= cell.get_global_rect().end.x + 0.5,
		"AL düğmesi satırda: %s / %s" % [claim.get_global_rect() if claim else "yok", cell.get_global_rect()])
	_check(open.get_global_rect().size.x >= 70.0, "kare sıkışmıyor")
	menu.queue_free()
	await get_tree().process_frame


func _toast() -> void:
	Save.wipe()
	var hud: Control = (load("res://scenes/ui/HUD.tscn") as PackedScene).instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.show_achievement("temiz_is")
	_check(hud._ach._head.text.contains("kare"), "büyük görev tabelası kareyi söyler")
	await get_tree().process_frame
	## Tabela 460 px tasarım genişliğinde kalır (soldaki can paneline binmesin).
	_check(hud._ach.size.x <= 462.0, "tabela genişliği %.0f" % hud._ach.size.x)
	await get_tree().create_timer(3.4).timeout
	hud.show_achievement("ilk_adim")
	_check(not hud._ach._head.text.contains("kare"), "küçük görev tabelasında kare yok")
	hud.queue_free()
	await get_tree().process_frame
