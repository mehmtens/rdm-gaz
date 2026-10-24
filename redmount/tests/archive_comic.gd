## Kanıt Arşivi'nde kitap sonu şeridini yeniden izleme: bitirilmemiş kitapta düğme kapalı,
## son bölüm bitince açık; basınca şerit oynar, kapanınca düğmeye odak döner; GÜNLÜK'te yok.
## Eski kayıt (bitiş süresi olmadan açılmış sonraki bölüm) da şeridi açar.
##
##  godot --headless --path . res://tests/archive_comic.tscn
extends Node

const PATH := "user://archive_comic_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_check(BookComic.end_of(1) == 11 and BookComic.end_of(2) == 23 and BookComic.end_of(3) == 35 and BookComic.end_of(4) == -1, "kitap sonu indeksleri")
	_check(not BookComic.is_unlocked(1), "boş kayıtta şerit kapalı")
	Save.best_times[11] = 300.0
	Save.unlocked_level = 24  # eski kayıt: kitap 2 bitmiş, süre kaydı yok
	_check(BookComic.is_unlocked(1) and BookComic.is_unlocked(2) and not BookComic.is_unlocked(3), "açılma kuralları")

	var menu: Node = (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu.call(&"_show", menu.get(&"_archive"))
	var btn := menu.find_child("ComicReplay", true, false) as Button
	var comic := menu.find_child("ArchiveComic", true, false) as BookComic
	_check(btn != null and comic != null, "düğme ve şerit kuruldu")
	if btn != null and comic != null:
		menu.call(&"_select_arch", 2)
		_check(btn.visible and btn.disabled and "BİTİR" in btn.text, "kitap 3 kapalı: %s" % btn.text)
		menu.call(&"_select_arch", 3)
		_check(not btn.visible, "GÜNLÜK'te düğme yok")
		menu.call(&"_select_arch", 1)
		_check(btn.visible and not btn.disabled, "kitap 2 açık")
		btn.pressed.emit()
		_check(comic.is_active() and comic.shown_count() == 1, "şerit oynuyor")
		btn.pressed.emit()
		_check(comic.shown_count() == 1, "ikinci basış şeridi baştan başlatmaz")
		comic.advance()
		comic.advance()
		comic.advance()
		await get_tree().create_timer(BookComic.MIN_CLOSE + 0.1).timeout
		comic.advance()
		await get_tree().process_frame
		_check(not comic.is_active(), "şerit kapandı")
		_check(menu.get(&"_archive").visible, "arşiv sayfası açık kaldı")
	Save.wipe()
	print("ARCHIVE COMIC: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
