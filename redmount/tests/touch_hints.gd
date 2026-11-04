extends Node
## Telefonda sonuç kartı / ölüm ipucu klavye harfi (R, M) değil dokunmatik düğme adını gösterir.

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")


func _ready() -> void:
	var ok := true
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "1")
	var hud = HUD_SCENE.instantiate()
	add_child(hud)
	## Mağazaya yeni vuruş düşmeyen bir bölüm seç (o bölümde ipucu satırı mağazayı söyler).
	var plain := 1
	while Shop.ITEMS.any(func(it: Dictionary) -> bool: return int(it.get("unlock_level", 0)) == plain):
		plain += 1
	hud.show_stage_clear(plain, 0, 60.0, 4, 5, 1, 100)
	var hint: String = hud._results_hint.text
	ok = _check(ok, hint == "", "dokunmatik kart ipucu boş olmalı: " + hint)
	hud._tick_reveal(0.1)
	ok = _check(ok, not hud._results_hint.visible, "boş ipucu kutusu gizli")
	## Sonuç kipinde SONRAKİ/MENÜ kartın sağında, kartla kesişmiyor.
	var t := TouchControls.new()
	add_child(t)
	t.set_mode("results", true)
	var card_right := get_viewport().get_visible_rect().size.x * 0.5 + 330.0
	for key in ["next", "menu"]:
		ok = _check(ok, t._buttons[key].visible and t._buttons[key].position.x > card_right,
			"%s kartın sağında: %.0f > %.0f" % [key, t._buttons[key].position.x, card_right])
	t.set_mode("dead")
	ok = _check(ok, t._buttons["retry"].visible, "ölümde TEKRAR")
	t.queue_free()
	ok = _check(ok, "TEKRAR" in hud._death.text, "dokunmatik ölüm: " + hud._death.text)
	hud.queue_free()
	OS.set_environment("REDMOUNT_TOUCH_CONTROLS", "0")
	if not TouchControls.active_on_device():
		hud = HUD_SCENE.instantiate()
		add_child(hud)
		hud.show_stage_clear(3, 0, 60.0, 4, 5, 1, 100)
		ok = _check(ok, hud._results_hint.text.begins_with("R —") or "R — devam" in hud._results_hint.text,
			"klavye kart: " + hud._results_hint.text)
		ok = _check(ok, "R ile" in hud._death.text, "klavye ölüm: " + hud._death.text)
	print("TOUCH HINTS: ", "PASS" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)


func _check(ok: bool, cond: bool, what: String) -> bool:
	if not cond:
		push_error("FAIL " + what)
	return ok and cond
