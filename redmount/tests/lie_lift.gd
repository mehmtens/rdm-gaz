extends Node

## Yatış eğiminde gövde zemine gömülmez (tur 271). Yenilen düşman ayak noktası
## çevresinde 80° döndürülünce hücrenin yarısı zemin çizgisinin altına iniyordu.
## LieLift'in kaldırması uygulandığında dönmüş karenin en alt opak pikseli dik
## duruştaki en alt piksel hizasında olmalı: ne gömülü ne havada.

const FRAMES := ["res://resources/anim/street_thug_frames.tres", "res://resources/anim/armored_bruiser_frames.tres",
	"res://resources/anim/agile_assassin_frames.tres"]


## Tüm opak pikselleri (köşeleriyle) dönüştürüp en alt y'yi bulur — yardımcıdan bağımsız ölçüm.
func _lowest(spr: AnimatedSprite2D, rot: float, lift: float) -> float:
	var tex := spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
	var img := tex.get_image()
	var size := tex.get_size()
	var origin := size * 0.5 - spr.offset
	var low := -INF
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a < 0.5:
				continue
			for d in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]:
				var px: float = (size.x - (x + d.x)) if spr.flip_h else (x + d.x)
				var l := Vector2((px - origin.x) * spr.scale.x, (y + d.y - origin.y) * spr.scale.y)
				low = maxf(low, l.rotated(rot).y - lift)
	return low


func _ready() -> void:
	var ok := true
	for path in FRAMES:
		var spr := AnimatedSprite2D.new()
		spr.sprite_frames = load(path)
		spr.centered = true
		spr.offset = Vector2(0, -(240.0 * 0.5 - 6.0))
		spr.scale = Vector2(0.6, 0.6)
		add_child(spr)
		spr.play(&"dead")
		spr.frame = 1
		spr.pause()
		for flip in [false, true]:
			spr.flip_h = flip
			var upright := _lowest(spr, 0.0, 0.0)
			for deg in [-80.0, 80.0, -90.0, 12.0]:
				var rot := deg_to_rad(deg)
				var t0 := Time.get_ticks_usec()
				var lift := LieLift.lift(spr, rot)
				var dt := (Time.get_ticks_usec() - t0) / 1000.0
				var raw := _lowest(spr, rot, 0.0)
				var fixed := _lowest(spr, rot, lift)
				print("%s flip=%s rot=%d  gömülme önce=%.1f sonra=%.1f  (%.2f ms)" % [path.get_file(), flip, deg,
					raw - upright, fixed - upright, dt])
				if absf(fixed - upright) > 0.75:
					ok = false
		spr.queue_free()
	var bare := AnimatedSprite2D.new()
	assert(LieLift.lift(bare, 1.0) == 0.0, "Karesiz sprite kaldırılmamalı.")
	bare.free()
	print("LIE LIFT: %s" % ("PASS" if ok else "FAIL"))
	get_tree().quit(0 if ok else 1)
