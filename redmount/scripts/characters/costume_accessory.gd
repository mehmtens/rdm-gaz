## CostumeAccessory — kostümün piksel başlığı (kasket, bere, kaptan şapkası, bandana).
##
## Redmount'un AnimatedSprite2D'sine çocuk olarak eklenir; her karede ebeveynin o anki
## sayfa hücresinin baş çapasını (`head_anchors.json`, `tools/gen_costume_accessory.py`)
## okuyup oraya oturur. Dönüş/eğim/ölçek ebeveynden gelir; yön `flip_h` ile aynalanır.
## Ana menüdeki, ara sahnedeki ve oyundaki Redmount aynı yolu kullanır.
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

static var _anchors: Dictionary = {}

## "crown" (saç tepesi) | "brow" (alın)
var attach := "crown"
var _sprite: AnimatedSprite2D
var _key := ""


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
	var cells: Array = _anchors.get(sheet, [])
	return cells[index] if index >= 0 and index < cells.size() else []


## Çapanın, başlık pivotunun gideceği hücre noktası.
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
