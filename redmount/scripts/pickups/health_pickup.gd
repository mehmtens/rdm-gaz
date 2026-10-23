## HealthPickup — can takviyesi (Görev 4). Canı anlık doldurur (ana plan md. 12.1).
extends PickupBase

@export var heal_amount: int = 30


func _collect(player: Node) -> void:
	if player.has_method(&"heal"):
		# Kahveci kostümü yiyeceği daha doyurucu yapar.
		player.heal(int(roundf(float(heal_amount) * (1.0 + Shop.costume_bonus("heal")))))
