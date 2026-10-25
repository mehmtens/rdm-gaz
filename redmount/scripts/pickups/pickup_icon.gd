## PickupIcon — toplanabilir ikonu (Görev 22): `kind`'e göre 48x48 piksel art ikon,
## altında piksel gölge, değerli eşyada nabız atan piksel hâle; coin döner.
extends Node2D

## coin / health / ammo / armor / bat / knife / anahtar / semsiye / tas / pistol / rifle /
## pu_damage / pu_speed / pu_invis / pu_shield
@export var kind: String = "coin"

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


## Tasarlanmış 48x48 piksel ikonlar (assets/pickups). Bilinmeyen tür coin ikonunu kullanır.
const ART := {
	"coin": preload("res://assets/pickups/placeholder_coin.png"),
	"health": preload("res://assets/pickups/placeholder_health.png"),
	"ammo": preload("res://assets/pickups/placeholder_ammo.png"),
	"armor": preload("res://assets/pickups/placeholder_armor.png"),
	"pu_shield": preload("res://assets/pickups/placeholder_shield.png"),
	"bat": preload("res://assets/pickups/placeholder_bat.png"),
	"knife": preload("res://assets/pickups/placeholder_knife.png"),
	"anahtar": preload("res://assets/pickups/placeholder_anahtar.png"),
	"semsiye": preload("res://assets/pickups/placeholder_semsiye.png"),
	"tas": preload("res://assets/pickups/placeholder_tas.png"),
	"pistol": preload("res://assets/pickups/placeholder_pistol.png"),
	"rifle": preload("res://assets/pickups/placeholder_rifle.png"),
	"pu_damage": preload("res://assets/pickups/placeholder_dmg2x.png"),
	"pu_speed": preload("res://assets/pickups/placeholder_speed.png"),
	"pu_invis": preload("res://assets/pickups/placeholder_invis.png"),
}

const GOLGE := preload("res://assets/environment/pixel/golge.png")
const HALE := preload("res://assets/environment/pixel/fener_hale.png")


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Sanat ikonu: piksel gölge + hafif nabız; coin kendi ekseninde döner (genişlik salınır).
func _draw() -> void:
	var tex: Texture2D = ART.get(kind, ART["coin"])
	var size := 34.0 if kind == "coin" else 44.0
	var gw := size * 0.7
	var gh := gw * GOLGE.get_height() / GOLGE.get_width()
	draw_texture_rect(GOLGE, Rect2(-gw * 0.5, size * 0.5 + 4.0 - gh * 0.5, gw, gh), false, Color(1, 1, 1, 0.8))
	var w := size
	if kind == "coin":
		w = size * (0.3 + 0.7 * absf(cos(_t * 4.0)))
	else:
		# Değerli eşya: arkada nabız atan sıcak piksel hâle (fener hâlesiyle aynı doku).
		var p := 0.5 + 0.5 * sin(_t * 3.0)
		var hs := size * 1.3
		draw_texture_rect(HALE, Rect2(-hs * 0.5, -hs * 0.5, hs, hs), false, Color(1.0, 0.9, 0.6, 0.45 + 0.3 * p))
	draw_texture_rect(tex, Rect2(-w * 0.5, -size * 0.5, w, size), false)
