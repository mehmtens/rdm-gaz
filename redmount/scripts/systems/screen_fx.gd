## ScreenFx — tam ekran parlama katmanı (Görev 19).
## Main.tscn FxLayer altında; `Combat.flash_requested` dinler.
extends ColorRect

var _t: float = 0.0
var _dur: float = 0.0
var _col: Color = Color.WHITE


func _ready() -> void:
	color = Color(1, 1, 1, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Combat.flash_requested.connect(_on_flash)


func _on_flash(c: Color, d: float) -> void:
	_col = c
	_dur = maxf(d, 0.01)
	_t = _dur


func _process(delta: float) -> void:
	if _t <= 0.0:
		if color.a != 0.0:
			color = Color(_col.r, _col.g, _col.b, 0.0)
		return
	_t -= delta
	var k := clampf(_t / _dur, 0.0, 1.0)
	color = Color(_col.r, _col.g, _col.b, _col.a * k * k)
