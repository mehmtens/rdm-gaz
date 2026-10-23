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
	# kostüm değişince değişir; başlıksız kostümde çıkar
	CostumeAccessory.apply(rig, "kizil")
	await get_tree().process_frame
	acc = rig.get_node_or_null(NodePath(CostumeAccessory.NODE_NAME)) as CostumeAccessory
	_check(acc != null and acc.attach == "brow", "kızıl bandana alına bağlı")
	CostumeAccessory.apply(rig, Shop.DEFAULT_COSTUME)
	await get_tree().process_frame
	_check(rig.get_node_or_null(NodePath(CostumeAccessory.NODE_NAME)) == null, "sokak ceketinde başlık yok")
	p.queue_free()


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
