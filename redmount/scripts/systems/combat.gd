## Combat — dövüş geri bildirimi + combo autoload'u (Görev 2 / Görev 19).
##
##   * hitstop(): vuruş anında oyunu çok kısa süre dondurur (gerçek zaman).
##   * shake() / dip() / zoom_punch(): kamera geri bildirimi (game_camera.gd dinler).
##   * flash(): tam ekran parlama (ScreenFx dinler).
##   * combo_hit() / combo_break(): ardışık vuruş sayacı — eşiklerde bonus skor +
##     "COMBO xN" bildirimi (HUD dinler).
##
## project.godot -> [autoload] altında "Combat" olarak kayıtlıdır.
extends Node

signal shake_requested(strength: float)
signal dip_requested(offset: Vector2)
signal zoom_requested(amount: float)
signal flash_requested(color: Color, duration: float)
## count: güncel combo; HUD anlık gösterir.
signal combo_changed(count: int)
## Combo bitti (darbe yendi / süre doldu). count >= 3 ise bonus verilir.
signal combo_finished(count: int, bonus: int)

## Combo zaman aşımı (son vuruştan bu kadar sonra sıfırlanır).
const COMBO_TIMEOUT := 1.6

var _hitstop_until_ms: int = 0
var _hitstop_running: bool = false

var _combo: int = 0
var _combo_timer: float = 0.0


func _process(delta: float) -> void:
	if _combo > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			combo_break()


# --- Hitstop ---------------------------------------------------------

func hitstop(seconds: float) -> void:
	if seconds <= 0.0:
		return
	var target := Time.get_ticks_msec() + int(seconds * 1000.0)
	_hitstop_until_ms = maxi(_hitstop_until_ms, target)
	if not _hitstop_running:
		_run_hitstop()


func _run_hitstop() -> void:
	_hitstop_running = true
	var previous_scale := Engine.time_scale
	Engine.time_scale = 0.0
	while Time.get_ticks_msec() < _hitstop_until_ms:
		await get_tree().create_timer(0.02, true, false, true).timeout
	Engine.time_scale = previous_scale
	_hitstop_running = false


# --- Kamera / ekran -------------------------------------------------

func shake(strength: float) -> void:
	if strength > 0.0:
		shake_requested.emit(strength)


## Yön belirli kamera itmesi (iniş = aşağı, ağır darbe = geri).
func dip(offset: Vector2) -> void:
	dip_requested.emit(offset)


## Kısa zoom "punch" (içeri yaklaş, geri dön). amount ~0.03-0.08.
func zoom_punch(amount: float) -> void:
	if amount > 0.0:
		zoom_requested.emit(amount)


func flash(color: Color, duration: float = 0.14) -> void:
	flash_requested.emit(color, duration)


func rumble(strength: float) -> void:
	if OS.has_feature("mobile"):
		var amount := clampf(strength, 0.0, 1.0)
		Input.vibrate_handheld(int(20.0 + amount * 45.0), amount)


# --- Combo sayacı --------------------------------------------------

func combo_hit() -> void:
	_combo += 1
	_combo_timer = COMBO_TIMEOUT
	combo_changed.emit(_combo)


func combo_break() -> void:
	if _combo <= 0:
		return
	var n := _combo
	_combo = 0
	_combo_timer = 0.0
	combo_changed.emit(0)
	var bonus := 0
	if n >= 3:
		bonus = n * 15 + (n / 5) * 60
		GameState.add_score(bonus)
	combo_finished.emit(n, bonus)


func get_combo() -> int:
	return _combo
