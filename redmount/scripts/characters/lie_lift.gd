## LieLift — yatış eğiminde gövde zemine gömülmesin (tur 271, görsel denetim).
##
## Karakter sprite'ları ayak noktası (origin) çevresinde döndürülerek yere yatırılır.
## 200 px genişlikli hücrede çizim ortalandığı için 80–90° eğimde gövdenin yarısı
## zemin çizgisinin altına iniyordu (Bölüm 19 ekran görüntüsünde ~60 px). Bu yardımcı
## o anki karenin opak silüetinden, dönmüş hâldeki en alt pikselin dik duruşa göre
## ne kadar aşağıda kaldığını ölçer; sprite o kadar yukarı alınır, gövde zemine yaslanır.
##
## Silüet, her satırın en sol ve en sağ opak pikselinden oluşur (dışbükey zarfın tüm
## köşeleri bunların içindedir, dönmüş en alt nokta da zarf köşesidir). Doku başına
## bir kez hesaplanıp önbelleğe alınır.
class_name LieLift
extends RefCounted

## Opaklık eşiği (yarı saydam kenar pikselleri silüete sayılmaz).
const ALPHA_MIN := 0.5

## doku örnek kimliği → PackedVector2Array (doku pikseli, sol üst köşe 0,0)
static var _cache := {}
## (doku, aynalama, ölçek, eğim derecesi) → kaldırma. Eğim tam dereceye yuvarlanır
## (~120 px gövdede ≤2 px fark); yatan düşman her kare yeniden taranmaz.
static var _lifts := {}


## `rot` eğiminde sprite'ın ne kadar (ebeveyn uzayında px) yukarı alınması gerektiği.
## Dik duruşa (rot = 0) göre fark alınır; eğimsizken 0 döner, geçiş süreklidir.
static func lift(spr: AnimatedSprite2D, rot: float) -> float:
	if absf(rot) < 0.01 or spr.sprite_frames == null:
		return 0.0
	var tex := spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
	if tex == null:
		return 0.0
	var key := [tex.get_instance_id(), spr.flip_h, spr.scale, spr.offset, spr.centered, roundi(rad_to_deg(rot))]
	if _lifts.has(key):
		return _lifts[key]
	var pts := _outline(tex)
	if pts.is_empty():
		_lifts[key] = 0.0
		return 0.0
	rot = deg_to_rad(float(key[5]))
	var size := tex.get_size()
	## Doku pikseli → sprite yerel uzayı (aynalama doku dikdörtgeni içinde yapılır).
	var origin := (size * 0.5 if spr.centered else Vector2.ZERO) - spr.offset
	var c := cos(rot)
	var s := sin(rot)
	var low_rot := -INF
	var low_up := -INF
	for p in pts:
		var px := size.x - p.x if spr.flip_h else p.x
		var lx := (px - origin.x) * spr.scale.x
		var ly := (p.y - origin.y) * spr.scale.y
		low_up = maxf(low_up, ly)
		low_rot = maxf(low_rot, lx * s + ly * c)
	var v := maxf(0.0, low_rot - low_up)
	## Oyuncunun esneme (squash) ölçeği sürekli değişir; önbellek sınırsız büyümesin.
	if _lifts.size() > 4096:
		_lifts.clear()
	_lifts[key] = v
	return v


static func _outline(tex: Texture2D) -> PackedVector2Array:
	var key := tex.get_instance_id()
	if _cache.has(key):
		return _cache[key]
	var out := PackedVector2Array()
	var img := tex.get_image()
	if img != null and not img.is_empty():
		if img.is_compressed():
			img = img.duplicate()
			img.decompress()
		var w := img.get_width()
		for y in img.get_height():
			var l := -1
			var r := -1
			for x in w:
				if img.get_pixel(x, y).a >= ALPHA_MIN:
					if l < 0:
						l = x
					r = x
			if l >= 0:
				## Piksel köşeleri: alt kenar y + 1, sağ kenar r + 1.
				out.append(Vector2(l, y + 1))
				out.append(Vector2(r + 1, y + 1))
				out.append(Vector2(l, y))
				out.append(Vector2(r + 1, y))
	_cache[key] = out
	return out
