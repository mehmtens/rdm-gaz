## Transition — sahneler arası siyah geçiş perdesi (autoload "Transition", Görev 24).
##
## `Transition.go("res://...")` → karar → sahne değiştir → aç. Açılışta bir kez
## siyahtan açılır. Her zaman en üstte (layer 100), girdi geçirmez perde.
extends CanvasLayer

const DUR := 0.28

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 1)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_rect)
	# açılışta siyahtan gel
	var tw := create_tween()
	tw.tween_property(_rect, ^"color:a", 0.0, DUR)
	tw.tween_callback(func() -> void: _rect.mouse_filter = Control.MOUSE_FILTER_IGNORE)


## Perde kapat → sahne değiştir → perde aç.
func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_rect, ^"color:a", 1.0, DUR)
	await tw.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_rect, ^"color:a", 0.0, DUR)
	await tw2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
