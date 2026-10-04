## Güçlendirme ayarları — TEK KAYNAK (Görev 8).
##
## Süreli (veya tek kullanımlık) Redmount efektleri (ana plan md. 12).
## Anlık etkili can takviyesi ayrı tutulur (HealthPickup + Redmount.heal).
class_name PowerupConfig
extends Resource

enum Kind {
	DAMAGE_X2,     ## verilen hasar `magnitude` katı
	SPEED,         ## hareket hızı `magnitude` katı
	INVISIBILITY,  ## düşmanlar Redmount'ı algılamaz
	SHIELD,        ## bir sonraki darbeyi tamamen engeller (tek kullanımlık)
}

@export var kind: Kind = Kind.DAMAGE_X2
@export var display_name: String = "Güçlendirme"
## Etki süresi (sn). SHIELD için süre dolmadan darbe gelirse erken tükenir.
@export var duration: float = 12.0
## DAMAGE_X2 / SPEED için çarpan. Diğerlerinde kullanılmaz.
@export var magnitude: float = 2.0
