## CostumeAccessory — kostümün piksel başlığı (kasket, bere, kaptan şapkası, bandana).
##
## Redmount'un AnimatedSprite2D'sine çocuk olarak eklenir; her karede ebeveynin o anki
## sayfa hücresinin baş çapasını (`head_anchors.json`, `tools/gen_costume_accessory.py`)
## okuyup oraya oturur. Dönüş/eğim/ölçek ebeveynden gelir; yön `flip_h` ile aynalanır.
## Ana menüdeki, ara sahnedeki ve oyundaki Redmount aynı yolu kullanır.
## Gece bölümünde rig fener konturu taşıyorsa başlık da konturlanır: kontur kopyası
## rig'in ARKASINA çizilir, böylece yalnız silüetin dışında kalan kenar parlar (başlığın
## saça bindiği alt kenarda kontur yüze taşmaz).
## Baş üstü savuruşta kol/silah başın önünden geçer: o karelerin başa ait olmayan
## pikselleri `head_front.png` atlasından başlığın ÜSTÜNE, rig'in kostüm malzemesiyle
## (kontursuz) yeniden çizilir; böylece şapka sopayı/eli yutmaz.
class_name CostumeAccessory
extends Sprite2D

const ANCHORS_PATH := "res://assets/anim/redmount/head_anchors.json"
const ACC_DIR := "res://assets/anim/costume_acc/"
const NODE_NAME := &"CostumeAccessory"
## Görüntüde çapaya oturan nokta (araçtaki PIVOT ile aynı).
const PIVOT := Vector2(36, 30)
## Başlık saç tepesinin bu kadar altına oturur (hücre pikseli); bandana alnın üstüne.
const TOP_DROP := 16
const BROW_LIFT := 2
const RIM_NAME := &"CostumeAccessoryRim"
const RIM_SHADER := preload("res://shaders/dark_rim.gdshader")
const FRONT_NAME := &"CostumeAccessoryFront"
const FRONT_PATH := ACC_DIR + "head_front.png"
## Başlığın tepesinden taşan saçı gizleyen sayfa işaretinin biti (araçtaki HAIR_BITS);
## kostüm shader'ı `hair_bit` ile bu bitli pikselleri saydam sayar. Bandana saçı örtmez.
const HAIR_BITS := {"vapurcu": 1, "hamal": 2, "kahveci": 4}

## Gövde kareleri başka sayfanın kopyası olan sayfalar: ad → [kaynak sayfa, hücre kayması].
## Elde taş sayfaları (`gen_pixel_weapons.py gen_tas_sheets`) yalnız yumruğa taş ekler;
## çapa ve ön parça kaynağınkiyle aynıdır.
const SHEET_ALIAS := {
	"tas_idle": ["idle", 0],
	"tas_walk": ["walk", 0],
}

static var _anchors: Dictionary = {}
static var _fronts: Dictionary = {}

## "crown" (saç tepesi) | "brow" (alın)
var attach := "crown"
var _sprite: AnimatedSprite2D
var _key := ""
## Rig'in kardeş çocuğu, `show_behind_parent`; yalnız gecede görünür.
var _rim: Sprite2D
## Rig'in kardeş çocuğu, başlıktan SONRA eklenir (üstüne çizilir); ön parçası olan karede görünür.
var _front: Sprite2D
var _front_mat_src: Material


## Kostümün başlığının sayfa saç işareti biti; başlıksız ya da saçı örtmeyen kostümde 0.
static func hair_bit(costume_id: String) -> int:
	return int(HAIR_BITS.get(costume_id, 0))


## Kostümün başlığını sprite'a takar; başlıksız kostümde eskisini çıkarır.
static func apply(sprite: AnimatedSprite2D, costume_id: String) -> CostumeAccessory:
	if sprite == null:
		return null
	var old := sprite.get_node_or_null(NodePath(NODE_NAME))
	if old != null:
		sprite.remove_child(old)
		old.queue_free()
	var it := Shop.costume(costume_id)
	var tex := texture_for(costume_id)
	if tex == null:
		return null
	var acc := CostumeAccessory.new()
	acc.name = NODE_NAME
	acc.texture = tex
	acc.attach = String(it.get("attach", "crown"))
	acc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.add_child(acc)
	acc._follow()
	acc._sync_rim()
	return acc


static func texture_for(costume_id: String) -> Texture2D:
	var it := Shop.costume(costume_id)
	if not it.has("accessory"):
		return null
	var path := ACC_DIR + String(it.accessory) + ".png"
	return load(path) if ResourceLoader.exists(path) else null


## Sayfa adı + hücre sırası → [cx, top, brow] (hücre pikseli); yoksa boş.
static func anchor(sheet: String, index: int) -> Array:
	if _anchors.is_empty():
		var res = load(ANCHORS_PATH) if ResourceLoader.exists(ANCHORS_PATH) else null
		if res is JSON and res.data is Dictionary:
			_anchors = res.data.get("sheets", {})
	if not _anchors.has(sheet) and SHEET_ALIAS.has(sheet):
		index += int(SHEET_ALIAS[sheet][1])
		sheet = SHEET_ALIAS[sheet][0]
	var cells: Array = _anchors.get(sheet, [])
	return cells[index] if index >= 0 and index < cells.size() else []


## Çapanın, başlık pivotunun gideceği hücre noktası.
## Sayfa adı + hücre sırası → [atlas_x, atlas_y, w, h, hücre_x, hücre_y]; yoksa boş.
static func front_piece(sheet: String, index: int) -> Array:
	if _fronts.is_empty():
		var res = load(ANCHORS_PATH) if ResourceLoader.exists(ANCHORS_PATH) else null
		if res is JSON and res.data is Dictionary:
			_fronts = res.data.get("front", {})
	if not _fronts.has(sheet) and SHEET_ALIAS.has(sheet):
		index += int(SHEET_ALIAS[sheet][1])
		sheet = SHEET_ALIAS[sheet][0]
	var cells: Dictionary = _fronts.get(sheet, {})
	return cells.get(str(index), [])


static func attach_point(a: Array, mode: String) -> Vector2:
	if mode == "brow":
		return Vector2(a[0], a[2] - BROW_LIFT)
	return Vector2(a[0], a[1] + TOP_DROP)


func _ready() -> void:
	_sprite = get_parent() as AnimatedSprite2D
	centered = true
	_key = ""
	_follow()


func _process(_delta: float) -> void:
	_follow()
	_sync_rim()


func _exit_tree() -> void:
	if _rim != null and is_instance_valid(_rim):
		_rim.queue_free()
	_rim = null
	if _front != null and is_instance_valid(_front):
		_front.queue_free()
	_front = null


## Bu karenin ön parçasını başlığın üstüne yerleştirir; yoksa gizler.
func _sync_front(sheet: String, idx: int, region: Rect2) -> void:
	var f := front_piece(sheet, idx)
	if f.is_empty() or not ResourceLoader.exists(FRONT_PATH):
		if _front != null and is_instance_valid(_front):
			_front.visible = false
		return
	if _front == null or not is_instance_valid(_front):
		_front = Sprite2D.new()
		_front.name = FRONT_NAME
		_front.texture = load(FRONT_PATH)
		_front.region_enabled = true
		_front.centered = true
		_front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_sprite.add_child(_front)
	_sync_front_material()
	var size := Vector2(f[2], f[3])
	_front.region_rect = Rect2(f[0], f[1], f[2], f[3])
	var c := Vector2(f[4], f[5]) + size * 0.5
	var local := c - region.size * 0.5 if _sprite.centered else c
	if _sprite.flip_h:
		local.x = -local.x if _sprite.centered else region.size.x - c.x
	_front.position = local + _sprite.offset
	_front.flip_h = _sprite.flip_h
	_front.visible = visible


## Ön parça rig'in kostüm boyasını taşır ama kontursuz: kesik kenarda fener konturu
## kolun ortasına çizgi çekerdi (rig'in kendi konturu altta zaten var).
func _sync_front_material() -> void:
	var src := _sprite.material
	if src == _front_mat_src:
		return
	_front_mat_src = src
	if src is ShaderMaterial and (src as ShaderMaterial).has_meta(&"costume"):
		var m := (src as ShaderMaterial).duplicate() as ShaderMaterial
		m.set_shader_parameter(&"rim_enabled", false)
		_front.material = m
	else:
		_front.material = null


## Rig'in malzemesinden gece konturu açık mı ve rengi: kostüm malzemesi `rim_enabled`,
## kostümsüz gecede `night_rim` meta'lı dark_rim. Kapalıysa şeffaf renk.
static func rig_rim(sprite: CanvasItem) -> Color:
	var m := sprite.material as ShaderMaterial if sprite != null else null
	if m == null:
		return Color.TRANSPARENT
	if m.has_meta(&"night_rim") or (m.has_meta(&"costume") and m.get_shader_parameter(&"rim_enabled") == true):
		var c = m.get_shader_parameter(&"rim_color")
		# DtmLevel.HERO_NIGHT_RIM ile aynı; sınıfa bağlanmaz (döngüsel bağımlılık, -s derlemesi).
		return c if c is Color else Color(0.62, 0.74, 1.0, 0.85)
	return Color.TRANSPARENT


func _sync_rim() -> void:
	var c := rig_rim(_sprite)
	if c.a <= 0.0:
		if _rim != null:
			_rim.visible = false
		return
	if _rim == null or not is_instance_valid(_rim):
		_rim = Sprite2D.new()
		_rim.name = RIM_NAME
		_rim.show_behind_parent = true
		_rim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := ShaderMaterial.new()
		mat.shader = RIM_SHADER
		mat.set_shader_parameter(&"rim_only", true)
		_rim.material = mat
		_sprite.add_child(_rim)
	var rm := _rim.material as ShaderMaterial
	if rm.get_shader_parameter(&"rim_color") != c:
		rm.set_shader_parameter(&"rim_color", c)
	_rim.texture = texture
	_rim.centered = centered
	_rim.position = position
	_rim.offset = offset
	_rim.flip_h = flip_h
	_rim.visible = visible


func _follow() -> void:
	if _sprite == null:
		_sprite = get_parent() as AnimatedSprite2D
	if _sprite == null or _sprite.sprite_frames == null:
		return
	var tex := _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame) as AtlasTexture
	if tex == null or tex.atlas == null:
		visible = false
		return
	var region: Rect2 = tex.region
	var sheet := tex.atlas.resource_path.get_file().get_basename()
	var cols := maxi(1, int(tex.atlas.get_width() / region.size.x))
	var idx := int(region.position.y / region.size.y) * cols + int(region.position.x / region.size.x)
	var key := "%s:%d:%s" % [sheet, idx, _sprite.flip_h]
	if key == _key:
		return
	_key = key
	var a := anchor(sheet, idx)
	visible = not a.is_empty()
	_sync_front(sheet, idx, region)
	if a.is_empty():
		return
	var p := attach_point(a, attach)
	var local := p - region.size * 0.5 if _sprite.centered else p
	if _sprite.flip_h:
		local.x = -local.x if _sprite.centered else region.size.x - p.x
	position = local + _sprite.offset
	flip_h = _sprite.flip_h
	# pivot görüntünün ortasında değilse aynalanınca öbür yana düşer
	var half := texture.get_size() * 0.5
	offset = Vector2((half.x - PIVOT.x) * (-1.0 if flip_h else 1.0), half.y - PIVOT.y)
