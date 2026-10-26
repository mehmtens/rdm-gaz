## Kitap sonu boss'u (Bölüm 12, Karahanlı) arenada doğar: dövüş boyunca HUD can
## çubuğu görünmeli, öfke evresinde gelen yardımcılar dalga sayacına eklenmeli.
## Eski Level05'ten kalma "x ≥ 237000" koşulu çubuğu dövüş boyunca gizliyordu.
##
##  REDMOUNT_PROBE_LEVEL=11 godot --headless --path . --fixed-fps 60 res://tests/story_boss_bar.tscn
extends "res://tests/bolum_play.gd"

var _boss_seen := 0
var _bar_hidden := 0
var _max_count := 0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var bar := get_tree().root.find_child("BossBar", true, false) as Control
	if bar == null:
		return
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if e.config != null and e.config.is_story_boss and not e.is_dead():
			_boss_seen += 1
			if not bar.visible:
				_bar_hidden += 1
	# Rozetin gösterdiği sayı (HUD yazısı), arenanın iç listesi değil.
	var label := bar.get_parent().get("_arena_label") as Label
	if label != null and bar.get_parent().get("_arena_panel").visible:
		var m := RegEx.create_from_string("([0-9]+) DÜŞMAN").search(label.text)
		if m != null:
			_max_count = maxi(_max_count, m.get_string(1).to_int())


func _finish_level(msg: String) -> void:
	print("BOSS BAR: boss kare=%d gizli kare=%d rozetteki en çok düşman=%d" % [_boss_seen, _bar_hidden, _max_count])
	if _boss_seen < 60 or _bar_hidden > 2 or _max_count < 3:
		push_error("BOSS BAR: FAIL")
		get_tree().quit(1)
		return
	print("BOSS BAR: PASS")
	super._finish_level(msg)
