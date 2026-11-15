## Diyalog kutusu sığma denetimi: oyundaki her replik (bölüm tetikleri, bölüm sonu
## konuşmaları, betiklerdeki sabit konuşmalar) tam metniyle kutuya basılır; kutu ekranın
## altından taşmamalı, gövde yazısı ipucu satırının üstünde kalmalı. Masaüstü ve dokunmatik
## (DEVAM düğmesi için 100 px dar) genişlikte ölçülür.
##
##  godot --headless --path . res://tests/dialogue_fit.tscn
extends Node

const GAME_STATE_SCRIPT := preload("res://scripts/systems/game_state.gd")
const SCAN := ["res://scripts/systems/main.gd", "res://scripts/systems/bolum36.gd",
	"res://scripts/systems/book03_level12.gd"]

var _fails := 0


func _ready() -> void:
	# Başsızda pencere dikey açılabiliyor; oyunun tasarım boyutu 1280×720.
	get_tree().root.size = Vector2i(1280, 720)
	var lines := _collect()
	await _collect_levels(lines)
	print("DIALOGUE FIT: %d replik" % lines.size())
	var box: Node = (load("res://scenes/ui/DialogueBox.tscn") as PackedScene).instantiate()
	add_child(box)
	await get_tree().process_frame
	await get_tree().process_frame
	var panel := box.get_node(^"Panel") as PanelContainer
	var vh := get_viewport().get_visible_rect().size.y
	var worst := 0.0
	for right in [-90.0, -190.0]:
		panel.offset_right = right
		for l in lines:
			box.call(&"play", [l])
			box.call(&"_advance")  # tam metni göster
			await get_tree().process_frame
			await get_tree().process_frame
			var r := panel.get_global_rect()
			worst = maxf(worst, r.end.y)
			# Kutu tasarım yüksekliğini (220−24 = 196 px) aşarsa alttan ekran dışına uzar.
			if r.end.y > vh - 4.0 or r.size.y > 197.0:
				_fails += 1
				print("TAŞMA (%d): alt=%.0f boy=%.0f %s: %s" % [int(right), r.end.y, r.size.y, l["speaker"], l["text"]])
			box.call(&"_advance")
	print("en alt kenar %.0f / %.0f (genişlik %.0f)" % [worst, vh, get_viewport().get_visible_rect().size.x])
	print("DIALOGUE FIT: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _collect() -> Array:
	var out: Array = []
	for i in GAME_STATE_SCRIPT.LEVELS.size():
		out.append_array(StoryData.outro(i))
	var re := RegEx.create_from_string(r'{"speaker": "([^"]*)", "text": "([^"]*)"}')
	for path in SCAN:
		var src := FileAccess.get_file_as_string(path)
		for m in re.search_all(src):
			out.append({"speaker": m.get_string(1), "text": m.get_string(2).replace("\n", "\n")})
	return out


func _collect_levels(out: Array) -> void:
	for path in GAME_STATE_SCRIPT.LEVELS:
		var level: Node = (load(path) as PackedScene).instantiate()
		add_child(level)
		await get_tree().process_frame
		for t in get_tree().get_nodes_in_group(&"dialogue_trigger"):
			if not level.is_ancestor_of(t):
				continue
			var sp: PackedStringArray = t.get("speakers")
			var tx: PackedStringArray = t.get("texts")
			for i in tx.size():
				out.append({"speaker": sp[i] if i < sp.size() else "", "text": tx[i]})
		level.queue_free()
		await get_tree().process_frame
