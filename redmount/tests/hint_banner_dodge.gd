## İpucu balonu mekân/sır duyurusunun altına iner (tur 280, Bölüm 4 denetimi): film rulosu
## plakası Kalkanlı Zabıta ipucunun üst satırlarını örtüyordu. Duyuru sönünce balon
## yerine döner; balon hiçbir zaman oyuncunun başına inmez.
##
##  godot --headless --path . res://tests/hint_banner_dodge.tscn
##  REDMOUNT_SNAP=<png> ile pencereli çalıştırılırsa çakışma anının görüntüsünü kaydeder.
extends Node

var _fails := 0


func _ready() -> void:
	var who := CharacterBody2D.new()
	who.collision_layer = 2
	who.add_to_group(&"player")
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(30, 80)
	cs.shape = r
	cs.position = Vector2(0, -40)
	who.add_child(cs)
	who.position = Vector2(0, 0)
	var cam := Camera2D.new()
	cam.position = Vector2(0, -230)  ## oyundaki gibi zemin ekranın ~590. pikselinde
	add_child(cam)
	cam.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud: Control = load("res://scenes/ui/HUD.tscn").instantiate()
	layer.add_child(hud)
	## Bölüm 4'teki gibi telsiz açık: üst bant (duyuru dahil) aşağı kayar.
	RadioPanel.say(get_tree(), "telsiz", "KONTROL KULESİ (telsiz)", "Bariyer kapalı. Kim gelirse gelsin, kum torbalarının arkasından ateş.")
	var hint: HintTrigger = preload("res://scenes/systems/HintTrigger.tscn").instantiate()
	hint.text = "Kalkanlı Zabıta: arkasından vur, çömel tekmesiyle altından gir, ağır yumrukla (K) düşür ya da boru anahtarıyla del."
	hint.button = "heavy_attack"
	add_child(hint)
	add_child(who)
	await get_tree().create_timer(1.0).timeout
	var rest := hint._bubble.position.y
	_check(hint._push == 0.0, "duyuru yokken balon yerinde (push %.1f)" % hint._push)

	hud.show_place("FİLM RULOSU 1 / 3", "Gazelle'in kanıt fotoğrafı bulundu  ·  +10 coin\nKanıt Arşivi'ne eklendi", Color("ffd34e"))
	await get_tree().create_timer(1.0).timeout
	var plate: Rect2 = hud._place.screen_rect()
	var xf := hint.get_global_transform_with_canvas()
	var top := (xf * hint._bubble.position).y
	var bottom := (xf * (hint._bubble.position + Vector2(0, hint._bubble.size.y))).y
	print("plaka alt %.0f · balon üst %.0f · alt %.0f · push %.1f" % [plate.end.y, top, bottom, hint._push])
	_check(top >= plate.end.y, "balon plakanın altında (üst %.0f, plaka %.0f)" % [top, plate.end.y])
	_check(hint._bubble.position.y + hint._bubble.size.y <= HintTrigger.LOWEST_BOTTOM + 0.5, "balon başın üstünde")
	var snap := OS.get_environment("REDMOUNT_SNAP")
	if not snap.is_empty():
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(snap)

	await get_tree().create_timer(6.0).timeout
	_check(absf(hint._bubble.position.y - rest) < 0.5, "duyuru sönünce balon yerine döndü (%.1f / %.1f)" % [hint._bubble.position.y, rest])
	print("HINT BANNER DODGE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
