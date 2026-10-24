## Kostüm başlıkları (birikim: kostümlerin üçüncü dilimi): her oyuncu karesinin baş
## çapası, başlığın oyuncu rig'inde başa oturması, yönle aynalanması, kostüm
## değişince takılıp çıkarılması ve mağaza önizlemesi.
##
##  godot --headless --path . res://tests/costume_accessory.tscn
extends Node

const PATH := "user://costume_accessory_test.cfg"

var _fails := 0


func _ready() -> void:
	Save._path = PATH
	Save.wipe()
	_textures()
	_every_frame_has_anchor()
	_hair_over_hat()
	await _on_player()
	await _shop_preview()
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	print("COSTUME ACCESSORY: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


func _textures() -> void:
	_check(CostumeAccessory.texture_for(Shop.DEFAULT_COSTUME) == null, "varsayılan kostüm başlıksız")
	for id in ["vapurcu", "hamal", "kahveci", "kizil"]:
		var t := CostumeAccessory.texture_for(id)
		_check(t != null and t.get_width() == 72 and t.get_height() == 44, "%s başlığı 72×44" % id)


## Oyuncunun bütün animasyon karelerinde çapa olmalı; saç tepesi alnın üstünde ve
## hücrenin üst yarısında (baş aşağı/yerde kareler hariç makul aralık).
func _every_frame_has_anchor() -> void:
	var frames: SpriteFrames = load("res://resources/anim/redmount_frames.tres")
	var n := 0
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			var at := frames.get_frame_texture(anim, i) as AtlasTexture
			if at == null:
				continue
			var sheet := at.atlas.resource_path.get_file().get_basename()
			var cols := int(at.atlas.get_width() / at.region.size.x)
			var idx := int(at.region.position.y / at.region.size.y) * cols + int(at.region.position.x / at.region.size.x)
			var a := CostumeAccessory.anchor(sheet, idx)
			_check(a.size() == 3, "%s/%d çapası var" % [anim, i])
			if a.size() == 3:
				_check(a[1] < a[2] and a[2] - a[1] < 46, "%s/%d alın saçın altında: %s" % [anim, i, a])
				_check(a[0] > 40 and a[0] < 170 and a[1] >= 0 and a[1] < 180, "%s/%d çapa hücrede: %s" % [anim, i, a])
			n += 1
	_check(n > 150, "kare sayısı %d" % n)


## Şapkanın tepesinden taşan saç: sayfada başlık bitiyle işaretli, işaretler başlığın
## tepe çizgisinin üstünde; kostüm malzemesi kendi başlığının bitini taşır.
func _hair_over_hat() -> void:
	for id in CostumeAccessory.HAIR_BITS:
		var m := Shop.costume_material(id)
		_check(m != null and m.get_shader_parameter(&"hair_bit") == CostumeAccessory.HAIR_BITS[id], "%s malzemesinde hair_bit" % id)
	var mk := Shop.costume_material("kizil")
	_check(mk != null and mk.get_shader_parameter(&"hair_bit") == 0, "bandana saçı gizlemez")
	var img: Image = (load("res://assets/anim/redmount/run.png") as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()
	var marked := {1: 0, 2: 0, 4: 0}
	var above := 0
	var total := 0
	var cols := img.get_width() / 200
	for i in cols * (img.get_height() / 240):
		var a := CostumeAccessory.anchor("run", i)
		var ox := (i % cols) * 200
		var oy := (i / cols) * 240
		for y in 240:
			for x in 200:
				var al := roundi(img.get_pixel(ox + x, oy + y).a * 255.0)
				var code := 255 - al
				if al < 241 or al > 253 or code % 2 != 0:
					continue
				for b in marked:
					if (code / 2) & b:
						marked[b] += 1
				total += 1
				if y < int(a[1]) + 16:
					above += 1
	_check(marked[1] > 0 and marked[2] > 0 and marked[4] > 0, "koşu sayfasında üç başlığın saç işareti: %s" % marked)
	_check(total > 0 and above == total, "saç işaretleri başlığın tepesinin üstünde (%d / %d)" % [above, total])
	## bıçak savuruşu 4. kare: iz tutamların dibinden geçiyor, kopuk koyu tutamlar da gizlenmeli
	## (eskiden ön parça sayılıp şapkanın önüne çiziliyordu; yalnız 2 piksel işaretliydi)
	var kimg: Image = (load("res://assets/anim/redmount/knife_attack.png") as Texture2D).get_image()
	if kimg.is_compressed():
		kimg.decompress()
	var kcols := kimg.get_width() / 200
	var kox := (4 % kcols) * 200
	var koy := (4 / kcols) * 240
	var knife := 0
	for y in 240:
		for x in 200:
			var al := roundi(kimg.get_pixel(kox + x, koy + y).a * 255.0)
			if al >= 241 and al <= 253 and (255 - al) % 2 == 0 and ((255 - al) / 2) & 1:
				knife += 1
	_check(knife > 300, "bıçak savuruşunda kaptan şapkası üstü tutamlar gizli (%d px)" % knife)


func _on_player() -> void:
	Save.total_coins = 1000
	Save.unlocked_level = 35
	Save.buy_costume("vapurcu", 120)
	Save.set_costume("vapurcu")
	var p: Node2D = (load("res://scenes/characters/Redmount.tscn") as PackedScene).instantiate()
	add_child(p)
	await get_tree().process_frame
	await get_tree().process_frame
	var rig: AnimatedSprite2D = p.get_node(^"Rig")
	var acc := rig.get_node_or_null(NodePath(CostumeAccessory.NODE_NAME)) as CostumeAccessory
	_check(acc != null and acc.visible, "vapurcu: rig'de başlık")
	if acc != null:
		# zeminsiz test sahnesinde oyuncu düşer: idle'ın ilk karesinde ölç
		p.set_physics_process(false)
		rig.play(&"idle")
		rig.frame = 0
		acc._follow()
		# rig yerelinde: ayak 0, baş ~ -190 (hücre 240, ayak payı 6, saç tepesi ~41 + 16)
		_check(acc.position.y < -160 and acc.position.y > -200, "başlık baş hizasında: %s" % acc.position)
		var right := acc.position.x
		rig.facing = -1
		acc._follow()
		_check(acc.flip_h and is_equal_approx(acc.position.x, -right), "sola bakınca aynalanır: %s / %s" % [right, acc.position.x])
		rig.facing = 1
		_front_layer(rig, acc)
	# kostüm değişince değişir; başlıksız kostümde çıkar
	CostumeAccessory.apply(rig, "kizil")
	await get_tree().process_frame
	acc = rig.get_node_or_null(NodePath(CostumeAccessory.NODE_NAME)) as CostumeAccessory
	_check(acc != null and acc.attach == "brow", "kızıl bandana alına bağlı")
	await _night_rim(rig)
	CostumeAccessory.apply(rig, Shop.DEFAULT_COSTUME)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(rig.get_node_or_null(NodePath(CostumeAccessory.NODE_NAME)) == null, "sokak ceketinde başlık yok")
	_check(rig.get_node_or_null(NodePath(CostumeAccessory.RIM_NAME)) == null, "başlık çıkınca kontur kopyası da gider")
	p.queue_free()


## Baş üstü savuruş: sopanın/elin başın önünden geçtiği karede ön parça başlığın
## ÜSTÜNDE (rig'de başlıktan sonra), kostüm boyalı ama kontursuz; aynalanır; ön parçası
## olmayan karede gizlenir. Sopa ahşabı saç sanılıp çapa havaya kaçmamalı.
func _front_layer(rig: AnimatedSprite2D, acc: CostumeAccessory) -> void:
	_check(CostumeAccessory.anchor("bat_attack2", 0)[1] > 40, "sopalı karede çapa sopada değil: %s" % [CostumeAccessory.anchor("bat_attack2", 0)])
	var hit := _find_frame(rig.sprite_frames, true)
	var miss := _find_frame(rig.sprite_frames, false)
	_check(not hit.is_empty() and not miss.is_empty(), "ön parçalı ve parçasız kare bulundu")
	if hit.is_empty() or miss.is_empty():
		return
	rig.animation = hit[0]
	rig.frame = hit[1]
	acc._follow()
	var front := rig.get_node_or_null(NodePath(CostumeAccessory.FRONT_NAME)) as Sprite2D
	_check(front != null and front.visible, "%s/%d: ön parça görünür" % hit)
	if front == null:
		return
	_check(front.get_index() > acc.get_index() and not front.show_behind_parent, "ön parça başlığın üstüne çizilir")
	var fm := front.material as ShaderMaterial
	_check(fm != null and fm.has_meta(&"costume") and fm.get_shader_parameter(&"rim_enabled") == false, "ön parça kostüm boyalı, kontursuz")
	_check(absf(front.position.y - acc.position.y) < 50 and absf(front.position.x - acc.position.x) < 60, "ön parça başlığın üstünde: %s / %s" % [front.position, acc.position])
	var x := front.position.x
	rig.facing = -1
	acc._follow()
	_check(front.flip_h and is_equal_approx(front.position.x, -x), "ön parça aynalanır")
	rig.facing = 1
	rig.animation = miss[0]
	rig.frame = miss[1]
	acc._follow()
	_check(not front.visible, "%s/%d: ön parça gizli" % miss)


## [animasyon, kare]: ön parçası olan (want) ya da olmayan ilk kare.
func _find_frame(frames: SpriteFrames, want: bool) -> Array:
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			var at := frames.get_frame_texture(anim, i) as AtlasTexture
			if at == null:
				continue
			var cols := int(at.atlas.get_width() / at.region.size.x)
			var idx := int(at.region.position.y / at.region.size.y) * cols + int(at.region.position.x / at.region.size.x)
			if CostumeAccessory.front_piece(at.atlas.resource_path.get_file().get_basename(), idx).is_empty() != want:
				return [anim, i]
	return []


## Gece: rig'in kostüm malzemesi konturu açınca başlığın kontur kopyası rig'in arkasında,
## başlıkla aynı yerde ve aynı renkte görünür; kapanınca gizlenir.
func _night_rim(rig: AnimatedSprite2D) -> void:
	var acc := rig.get_node(NodePath(CostumeAccessory.NODE_NAME)) as CostumeAccessory
	var mat := rig.material as ShaderMaterial
	_check(mat != null and mat.has_meta(&"costume"), "rig'de kostüm malzemesi")
	if mat == null:
		return
	_check(rig.get_node_or_null(NodePath(CostumeAccessory.RIM_NAME)) == null, "gündüz kontur kopyası yok")
	var c := Color(1.0, 0.82, 0.52, 0.9)
	mat.set_shader_parameter(&"rim_enabled", true)
	mat.set_shader_parameter(&"rim_color", c)
	await get_tree().process_frame
	var rim := rig.get_node_or_null(NodePath(CostumeAccessory.RIM_NAME)) as Sprite2D
	_check(rim != null and rim.visible and rim.show_behind_parent, "gece: başlık konturu rig'in arkasında")
	if rim != null:
		_check(rim.position == acc.position and rim.offset == acc.offset and rim.flip_h == acc.flip_h, "kontur başlıkla hizalı")
		_check(rim.texture == acc.texture, "kontur aynı başlık dokusundan")
		var rm := rim.material as ShaderMaterial
		_check(rm != null and rm.get_shader_parameter(&"rim_only") == true and rm.get_shader_parameter(&"rim_color") == c, "yalnız kontur, fener rengi")
	mat.set_shader_parameter(&"rim_enabled", false)
	await get_tree().process_frame
	_check(rim == null or not rim.visible, "gündüze dönünce kontur gizli")


func _shop_preview() -> void:
	var shop: Control = (load("res://scenes/Shop.tscn") as PackedScene).instantiate()
	add_child(shop)
	await get_tree().process_frame
	shop._select(2)
	await get_tree().process_frame
	var hats := 0
	for tr in shop.find_children("*", "TextureRect", true, false):
		if tr.texture != null and tr.texture.resource_path.begins_with(CostumeAccessory.ACC_DIR):
			hats += 1
	_check(hats == 4, "mağazada 4 başlıklı önizleme: %d" % hats)
	shop.queue_free()
