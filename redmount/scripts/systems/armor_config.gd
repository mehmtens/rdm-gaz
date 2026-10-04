## Zırh ayarları — TEK KAYNAK (Görev 8).
##
## Redmount kuşanınca gelen darbelerin hasarını azaltır, birkaç darbe emer ve
## koşu/yürüme hızını hafifçe düşürür (ana plan md. 7.4). Dayanıklılık bitince
## kırılır ve silahsız/zırhsız duruma dönülür.
class_name ArmorConfig
extends Resource

@export var display_name: String = "Zırh"
## Gelen hasarı bu oranda azaltır (0..1).
@export var damage_reduction: float = 0.5
## Kaç darbe emer.
@export var durability: int = 6
## Koşu/yürüme hızından kesilen oran (0..1).
@export var speed_penalty: float = 0.15
