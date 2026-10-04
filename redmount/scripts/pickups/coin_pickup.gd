## Coin — standart coin (Görev 4). Skor + mağaza parası (ana plan md. 11.1).
extends PickupBase

@export var value: int = 1


func _ready() -> void:
	# Tek ve okunaklı ekonomi: her coin aynı görünür ve aynı değeri verir.
	value = 1
	kind = "coin"
	super()
	add_to_group(&"coin")


func _collect(_player: Node) -> void:
	GameState.add_coins(1)
	Sfx.play(&"coin")
	Fx.spark(global_position, Vector2.ZERO, 5, Color(1, 0.9, 0.5), 0.7)
