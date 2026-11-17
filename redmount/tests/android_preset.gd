extends Node
## Android paket ön ayarı (tur 242): titreşim izni manifestte olmalı — yoksa
## Godot `Input.vibrate_handheld`'i sessizce yutar (dokunmatik tık + isabet
## titreşimi telefonda hiç çalışmaz). Geri tuşu uygulamayı kapatmamalı.


func _ready() -> void:
	var cfg := ConfigFile.new()
	assert(cfg.load("res://export_presets.cfg") == OK)
	var found := false
	for s in cfg.get_sections():
		if s.begins_with("preset.") and not s.ends_with(".options") \
				and cfg.get_value(s, "platform", "") == "Android":
			var opts := s + ".options"
			assert(cfg.get_value(opts, "permissions/vibrate", false) == true)
			found = true
	assert(found)
	assert(not ProjectSettings.get_setting("application/config/quit_on_go_back", true))
	print("ANDROID PRESET OK")
	get_tree().quit(0)
