## PowerupPickup — süreli güçlendirme (Görev 8). Bkz. powerup_config.gd
extends PickupBase

@export var powerup: PowerupConfig

const _KIND_MAP := {
	PowerupConfig.Kind.DAMAGE_X2: "pu_damage",
	PowerupConfig.Kind.SPEED: "pu_speed",
	PowerupConfig.Kind.INVISIBILITY: "pu_invis",
	PowerupConfig.Kind.SHIELD: "pu_shield",
}


func _ready() -> void:
	if powerup != null:
		kind = _KIND_MAP.get(powerup.kind, "pu_damage")
	super()


func _collect(player: Node) -> void:
	if powerup != null and player.has_method(&"apply_powerup"):
		player.apply_powerup(powerup)
