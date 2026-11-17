## BackButton — Android geri tuşu / hareketi (autoload "BackButton").
##
## Godot varsayılanı (`quit_on_go_back`) geri tuşunda uygulamayı anında kapatır;
## bölüm ortasında yanlışlıkla basılan geri tuşu bütün koşuyu siler. Ayar
## kapatıldı; geri isteği burada yönlendirilir:
##  1) Etkin sahnede `handle_back() -> bool` varsa önce o sorulur (ana menü
##     anasayfada çıkar, bitmiş bölüm/survival kartı menüye döner).
##  2) Sahne üstlenmezse masaüstündeki ESC'nin aynısı üretilir: ESC hem `pause`
##     hem `ui_cancel` olduğundan oyunda duraklat menüsünü açar/kapatır,
##     sinematiği atlar, büfe/mağaza/alt sayfayı kapatır — yeni bir yol yok,
##     masaüstünde zaten sınanan akış.
extends Node

## Arka arkaya gelen iki geri isteğini tek basış saymak için (bazı cihazlar
## hareket + tuş olarak iki kez bildirir).
const GAP_MS := 180

var _last_ms := -100000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		request_back()


## Geri isteğini işler. Test ve dokunmatik dışı kaynaklar da çağırabilir.
## Dönen değer: "scene" (sahne üstlendi), "esc" (ESC üretildi), "ignored".
func request_back() -> String:
	var now := Time.get_ticks_msec()
	if now - _last_ms < GAP_MS:
		return "ignored"
	_last_ms = now
	var scene := get_tree().current_scene
	if scene != null and scene.has_method(&"handle_back") and scene.handle_back():
		return "scene"
	_press_escape()
	return "esc"


func _press_escape() -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = KEY_ESCAPE
		ev.physical_keycode = KEY_ESCAPE
		ev.pressed = pressed
		Input.parse_input_event(ev)
