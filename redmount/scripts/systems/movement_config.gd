## Redmount hareket ayarlari — TEK KAYNAK.
##
## Butun degistirilebilir hareket degerleri burada tutulur (ana plan md. 12 / 18.4).
## Sahnede `res://resources/movement/redmount_movement.tres` olarak baglanir;
## degerleri Godot Inspector'dan kod degistirmeden ayarlayabilirsin.
class_name MovementConfig
extends Resource

@export_group("Yatay hiz")
## Yurume hizi (px/sn).
@export var walk_speed: float = 200.0
## Kosma hizi (px/sn) — "run" tusu basiliyken.
@export var run_speed: float = 340.0

@export_group("Hizlanma / yavaslama")
## Yerde hedef hiza ulasma ivmesi (px/sn^2).
@export var acceleration: float = 2000.0
## Yerde durma sürtünmesi (px/sn^2).
@export var friction: float = 2600.0
## Havadayken yatay kontrol ivmesi (px/sn^2).
@export var air_acceleration: float = 1400.0

@export_group("Zıplama / yerçekimi")
## Zıplama kuvveti — yukari dogru oldugu icin negatif (px/sn).
@export var jump_velocity: float = -520.0
## Zıplama tuşu yükselirken bırakılınca dikey hızın çarpanı (değişken yükseklik).
## 1.0 = kapalı; ~0.4 = kısa dokunuş çok alçak zıplar.
@export_range(0.2, 1.0) var jump_cut: float = 0.42
## Yerçekimi (px/sn^2).
@export var gravity: float = 1400.0
## Düşerken yerçekimi çarpanı (daha net iniş hissi için > 1).
@export var fall_gravity_multiplier: float = 1.3
## Maksimum düşme hızı (px/sn).
@export var max_fall_speed: float = 1200.0

@export_group("His ayarlari")
## Zıplama tuşuna zeminden ayrıldıktan sonra kaç saniye daha basılabilir (coyote).
@export var coyote_time: float = 0.10
## Zıplama tuşu yere değmeden kaç saniye önce hafızada tutulur (buffer).
@export var jump_buffer_time: float = 0.10
## "land" durumunun ekranda kalma süresi (sn).
@export var land_duration: float = 0.12
## Bu hızın altında yatay hareket "duruyor" sayılır (px/sn).
@export var move_threshold: float = 8.0

@export_group("Parkur — dash (Görev 15)")
## Dash hızı (px/sn).
@export var dash_speed: float = 620.0
## Dash süresi (sn).
@export var dash_duration: float = 0.17
## Dash bitince tekrar dash'e kadar bekleme (sn).
@export var dash_cooldown: float = 0.45
## Dash sırasında dokunulmazlık (sn). 0 = kapalı.
@export var dash_invuln: float = 0.14
## Havada kaç dash hakkı (yere değince yenilenir).
@export var air_dashes: int = 1
## Yön tuşuna çift basma dash aralığı (sn). 0 = çift basma kapalı.
@export var double_tap_time: float = 0.28

@export_group("Parkur — duvar (Görev 15)")
## Duvara yapışıp kayarken maksimum düşme hızı (px/sn).
@export var wall_slide_speed: float = 120.0
## Duvardan zıplarken yataydaki itme (px/sn).
@export var wall_jump_push: float = 340.0
## Duvar zıplamasından sonra yatay kontrolün kilitli kaldığı süre (sn).
@export var wall_jump_lock: float = 0.16
## Çömelme hızı (px/sn). 0 = çömelince duramaz, sadece sabit.
@export var crouch_speed: float = 90.0
