extends Node
## Ana Vana Muhafızı ve Yayın Şefi kendi zırh sayfalarını kullanır (tur 240).


func _ready() -> void:
	var base: SpriteFrames = load("res://resources/anim/mini_boss_frames.tres")
	for item in [["res://scenes/enemies/WaterworksChief.tscn", "waterworks_chief"],
			["res://scenes/enemies/BroadcastDirector.tscn", "broadcast_director"]]:
		var e: Node = load(item[0]).instantiate()
		var f: SpriteFrames = e.frames
		assert(f != null and f != base)
		assert(f.resource_path.ends_with(item[1] + "_frames.tres"))
		## Aynı iskelet: animasyon adları ve kare sayıları Ağır Zırhlı ile bire bir.
		for anim in base.get_animation_names():
			assert(f.has_animation(anim))
			assert(f.get_frame_count(anim) == base.get_frame_count(anim))
			var tex := f.get_frame_texture(anim, 0) as AtlasTexture
			assert(tex != null and ("/" + item[1] + "/") in tex.atlas.resource_path)
		e.free()
	## Sinematikte Ana Vana kendi sayfasıyla.
	var cs := Cutscene.new()
	add_child(cs)
	var a: Node2D = cs.actor("mh", "waterworks", Vector2.ZERO, -1)
	var body := a.get_node(^"Body") as AnimatedSprite2D
	assert(body != null and body.sprite_frames.resource_path.ends_with("waterworks_chief_frames.tres"))
	print("BOSS SHEETS: PASS")
	get_tree().quit(0)
