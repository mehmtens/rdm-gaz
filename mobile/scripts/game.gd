## Game — oyun durumu, kayıt, girdi haritası ve sahne geçişleri (autoload).
extends Node

const LEVELS: Array[Dictionary] = [
	{"id": "L01", "name": "Bölüm 1 — Mahalle", "scene": "res://scenes/levels/Level01.tscn"},
]
const SAVE_PATH := "user://save.cfg"

## Fizik katmanları (project.godot layer_names ile aynı sıra).
const L_WORLD := 1
const L_PLAYER := 2
const L_ONEWAY := 4
const L_ENEMY := 8
const L_ARENA := 16

var wallet: int = 0 ## Kalıcı coin cüzdanı.
var best: Dictionary = {} ## level_id -> {stars, coins}
var level_index: int = 0
var testing := false ## Test botları kayıt dosyasına yazmasın.

## Bölüm içi koşu durumu; kontrol noktasından yeniden doğunca korunur.
var run: Dictionary = {}

var _fade: ColorRect
var _stop_until: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	_load()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.05, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)


func _setup_input() -> void:
	var keys := {
		"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT], "down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE, KEY_W, KEY_UP], "attack": [KEY_J, KEY_Z], "special": [KEY_K, KEY_X], "shoot": [KEY_L, KEY_C],
		"pause": [KEY_ESCAPE, KEY_P],
	}
	var pads := {"jump": JOY_BUTTON_A, "attack": JOY_BUTTON_X, "special": JOY_BUTTON_Y, "shoot": JOY_BUTTON_RIGHT_SHOULDER,
		"pause": JOY_BUTTON_START, "left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT,
		"down": JOY_BUTTON_DPAD_DOWN}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.3)
		for k in keys[action]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(action, e)
		if pads.has(action):
			var j := InputEventJoypadButton.new()
			j.button_index = pads[action]
			InputMap.action_add_event(action, j)
	for pair in [["left", -1.0], ["right", 1.0]]:
		var m := InputEventJoypadMotion.new()
		m.axis = JOY_AXIS_LEFT_X
		m.axis_value = pair[1]
		InputMap.action_add_event(pair[0], m)


# --- Bölüm akışı ------------------------------------------------------------

func start_level(index: int) -> void:
	level_index = index
	run = {"coins": 0, "collected": {}, "cleared": {}, "secrets": {}, "kills": 0,
		"time": 0.0, "deaths": 0, "checkpoint": null, "weapon": "", "ammo": 0,
		"damage": 0, "smashed": 0}
	goto(LEVELS[index]["scene"])


func respawn() -> void:
	run["deaths"] = int(run.get("deaths", 0)) + 1
	goto(LEVELS[level_index]["scene"])


func finish_level(stars: int, coins: int) -> void:
	var id: String = LEVELS[level_index]["id"]
	var prev: Dictionary = best.get(id, {"stars": 0, "coins": 0})
	best[id] = {"stars": maxi(stars, int(prev["stars"])), "coins": maxi(coins, int(prev["coins"]))}
	wallet += coins
	_save()


func goto(path: String) -> void:
	get_tree().paused = false
	_stop_until = 0
	Engine.time_scale = 1.0
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.22)
	tw.tween_callback(func(): get_tree().change_scene_to_file(path))
	tw.tween_property(_fade, "color:a", 0.0, 0.3)


# --- Vuruş duraklaması (hitstop) ---------------------------------------------

func hitstop(ms: int) -> void:
	_stop_until = maxi(_stop_until, Time.get_ticks_msec() + ms)
	Engine.time_scale = 0.05


func _process(_dt: float) -> void:
	if _stop_until > 0 and Time.get_ticks_msec() >= _stop_until:
		_stop_until = 0
		Engine.time_scale = 1.0


# --- Kayıt ------------------------------------------------------------------

func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	wallet = int(cf.get_value("p", "wallet", 0))
	best = cf.get_value("p", "best", {})


func _save() -> void:
	if testing:
		return
	var cf := ConfigFile.new()
	cf.set_value("p", "wallet", wallet)
	cf.set_value("p", "best", best)
	cf.save(SAVE_PATH)
