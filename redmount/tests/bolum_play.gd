## Yeniden yapılan (DtmLevel) bölümlerin ortak bot testi. Bölüm, GameState.LEVELS
## indeksiyle verilir; hikâye sahneleri geçilir, bölüm takılmadan bitmelidir.
##
##  REDMOUNT_PROBE_LEVEL=1 godot --headless --path . --fixed-fps 60 res://tests/bolum_play.tscn
extends "res://_autoplay.gd"


func _ready() -> void:
	Save.purchased = []
	_time_limit = 900.0
	assert(not OS.get_environment("REDMOUNT_PROBE_LEVEL").is_empty(), "REDMOUNT_PROBE_LEVEL verilmeli")
	await super._ready()


func _finish_level(msg: String) -> void:
	_note_stall()
	if not msg.begins_with("CLEARED") or _longest_stall > 45.0:
		push_error("BASARISIZ Bölüm %d: %s  stall=%.0fs@%.0f" % [_level_idx + 1, msg, _longest_stall, _stall_at])
		get_tree().quit(1)
		return
	super._finish_level(msg)


## Oyun testi kaydı: REDMOUNT_SNAP_DIR verilirse (pencereli çalıştırmada) her
## REDMOUNT_SNAP_EVERY saniyede bir ekran görüntüsü alınır (t0000.png ...).
var _snap_next := 0.0


func _process(_delta: float) -> void:
	var folder := OS.get_environment("REDMOUNT_SNAP_DIR")
	if folder.is_empty() or _player == null or _run_t < _snap_next:
		return
	var every := OS.get_environment("REDMOUNT_SNAP_EVERY").to_float()
	_snap_next = _run_t + (every if every > 0.0 else 3.0)
	var img := get_viewport().get_texture().get_image()
	img.resize(640, 360, Image.INTERPOLATE_NEAREST)
	img.save_png(folder.path_join("t%04d_x%d.png" % [int(_run_t), int(_player.global_position.x)]))
