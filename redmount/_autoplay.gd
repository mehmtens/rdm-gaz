## Otonom bölüm testi — her bölümü "sağa koş + zıpla + tıkanınca dash + yakın
## düşmana saldır" botuyla oynatır, ilerlemeyi ve bitişi raporlar.
extends Node

var _main: Node
var _player: CharacterBody2D
var _level_idx := 0
var _max_x := -1e9
var _stuck_t := 0.0
var _last_x := 0.0
var _run_t := 0.0
var _report: Array = []
var _respawns := 0
var _prev_x := 0.0
## İlerlemesiz en uzun süre (sn): en uzak x 50 px artmadan geçen zaman. Süre penceresi
## genişse gerçek takılma gizlenmesin diye testler bunu ayrıca sınırlar.
var _longest_stall := 0.0
var _stall_at := 0.0
var _progress_x := -1e9
var _progress_t := 0.0
var _time_limit := 360.0
## Patron telegrafından kaçış (tur 326): son atılmanın hedefi/zamanı ve sayısı.
var _evade_id := 0
var _evade_t := -10.0
var _boss_evades := 0
## Atılmadan sonraki 1 sn içinde yine de yenen darbe sayısı (kaçışın işe yarayıp yaramadığı).
var _evade_hits0 := -1
var _boss_evade_fails := 0
## Can arama (tur 332): insan oyuncu canı azken arkada kalan, ekranda görünen can paketine
## döner (çoğunlukla arena ödülü: kapılar açılınca arena ortasına düşer, bot ise son dalgayı
## sağ kapıda bitirip ileri koşuyordu). Bu eksik, denetimlerdeki can eğrilerini kötümser yapıyordu.
var _heal_target: Node2D = null
var _heal_t := 0.0
var _heal_scan := 0.0
var _heal_skip: Array = []
var _heals := 0
## Arena düşmanı alt kattayken aynı kotta inemeden geçen süre (tur 334).
var _below_t := 0.0
var _below_y := 0.0
## Son ilerlemeden beri ölüm sayısı (tur 334 döngü kırıcı).
var _deaths_here := 0
## Pres okuma (tur 404): bot eskiden presi hiç okumuyordu; altına yürüyüp ezilir, iniş
## halindeki başlığı duvar sanıp dash+zıplamayla üstüne çıkar, iki pres arasında sıkışırdı
## (Bölüm 22 pompa salonu 3 koşunun 2'sinde ölüm). İnsan telegraf + gümleme sesiyle okur;
## bot da artık presin önünde durup yükselişin arkasından geçer. `_press_hits` pres hasarı sayısı.
var _crushers: Array = []
var _crusher_scan := 0.0
var _crusher_lock := {}
var _press_hits := 0
var _press_waits := 0
var _press_waiting := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_main = load("res://scenes/Main.tscn").instantiate()
	add_child(_main)
	await get_tree().process_frame
	_player = _main.get_node(^"Redmount")
	GameState.level_path_override = OS.get_environment("REDMOUNT_LEVEL_PATH")
	var probe_level := OS.get_environment("REDMOUNT_PROBE_LEVEL")
	_start_level(probe_level.to_int() if not probe_level.is_empty() else 0)


func _start_level(idx: int) -> void:
	_level_idx = idx
	GameState.level_index = idx
	_main._load_current_level()
	var probe_x := OS.get_environment("REDMOUNT_PROBE_X")
	if not probe_x.is_empty():
		_player.global_position = Vector2(probe_x.to_float(), -40.0)
	_max_x = -1e9
	_stuck_t = 0.0
	_run_t = 0.0
	_longest_stall = 0.0
	_progress_x = -1e9
	_progress_t = 0.0
	_last_x = _player.global_position.x
	get_tree().paused = false


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	_run_t += delta
	for i in range(_release_queue.size() - 1, -1, -1):
		if _run_t >= _release_queue[i][1]:
			Input.action_release(_release_queue[i][0])
			_release_queue.remove_at(i)
	var x := _player.global_position.x
	var y := _player.global_position.y
	if _player.get_health() <= 0:
		_main._respawn_player()
		_respawns += 1
		_deaths_here += 1
		# Geri ışınlanma sonraki karede ">150 px geri" kuralıyla ikinci kez sayılmasın.
		_prev_x = _player.global_position.x
		return
	if x < _prev_x - 150.0:
		_respawns += 1
		_deaths_here += 1
	_prev_x = x
	_max_x = maxf(_max_x, x)
	if _max_x > _progress_x + 50.0:
		_note_stall()
		_progress_x = _max_x
		_progress_t = _run_t
		_deaths_here = 0

	# diyalog kutusu açıksa geç
	var db = _main.get_node_or_null(^"DialogueBox")
	if db != null and db.is_active():
		db._advance()
		return

	# hikâye sahnesi: bot sahneyi geçer
	if Cutscene.active != null:
		Cutscene.active._skip = true
		Cutscene.active._advance = true
		return

	# Pencereli koşuda odak kaybı duraklatma menüsünü açar; bu bitiş değil, kapatıp sürdür.
	if _main._pause_menu.is_open() and not _main._finished:
		_main._pause_menu.close()
		return

	# bitiş?
	if get_tree().paused or _main._finished:
		_finish_level("CLEARED @%.0f  t=%.1fs" % [_max_x, _run_t])
		return
	if fmod(_run_t, 4.0) < delta:
		var hit := _player.get_last_slide_collision()
		var blocker := str(hit.get_collider().get_path()) if hit != null else "-"
		print("  L%d t=%.0f x=%.0f y=%.0f vx=%.0f floor=%s hit=%s maxx=%.0f hp=%d respawns=%d" % [
			_level_idx + 1, _run_t, x, y, _player.velocity.x, _player.is_on_floor(), blocker,
			_max_x, _player.get_health(), _respawns])
		if OS.get_environment("REDMOUNT_DEBUG_FOES") == "1":
			for e in get_tree().get_nodes_in_group(&"enemy_ai"):
				if is_instance_valid(e) and absf(e.global_position.x - x) < 1500.0:
					print("    foe %s %s (%.0f,%.0f) %s" % [e.name, e.get_state_name() if e.has_method(&"get_state_name") else "?",
						e.global_position.x, e.global_position.y, "dead" if e.has_method(&"is_dead") and e.is_dead() else ""])
	if _run_t > _time_limit:
		_finish_level("TIMEOUT maxx=%.0f" % _max_x)
		return

	var on_floor: bool = _player.is_on_floor()
	_count_press_hits()
	if _evade_hits0 >= 0 and _run_t - _evade_t >= 1.0:
		if int(_player.hits_taken) > _evade_hits0:
			_boss_evade_fails += 1
		_evade_hits0 = -1

	# yakın düşman: dön + yaklaş + vur (duvara koşmayı bırak)
	var foe: Node2D = null
	var foe_dx := 0.0
	var seek_radius := 155.0
	for arena in get_tree().get_nodes_in_group(&"battle_arena"):
		if arena.get("_active") and not arena.get("_done"):
			seek_radius = 1400.0
			break
	for e in get_tree().get_nodes_in_group(&"enemy_ai"):
		if not is_instance_valid(e) or (e.has_method(&"is_dead") and e.is_dead()):
			continue
		var dx: float = e.global_position.x - x
		# Yalnız aynı kattaki düşman: üstteki sandıkta dururken alttakine boşa vurmasın.
		if absf(dx) < seek_radius and absf(e.global_position.y - y) < 80.0:
			if foe == null or absf(dx) < absf(foe_dx):
				foe = e
				foe_dx = dx
	# Arena sürerken aynı katta düşman yoksa: arenanın içinde, üstteki iskeleye
	# çıkmış en yakın düşmana tırman (kapı dışındakiler hesaba katılmaz).
	var live_arena: Node = null
	for arena in get_tree().get_nodes_in_group(&"battle_arena"):
		if arena.get("_active") and not arena.get("_done"):
			live_arena = arena
	if foe == null and live_arena != null:
		var gl: float = live_arena.get("gate_left_x")
		var gr: float = live_arena.get("gate_right_x")
		var up: Node2D = null
		for e in get_tree().get_nodes_in_group(&"enemy_ai"):
			if not is_instance_valid(e) or (e.has_method(&"is_dead") and e.is_dead()):
				continue
			var ex: float = e.global_position.x
			var dy: float = e.global_position.y - y
			if ex < gl or ex > gr or absf(dy) < 60.0 or dy < -260.0:
				continue
			if up == null or absf(ex - x) < absf(up.global_position.x - x):
				up = e
		if up != null:
			var dx2: float = up.global_position.x - x
			Input.action_press(&"move_right" if dx2 > 0.0 else &"move_left")
			Input.action_release(&"move_left" if dx2 > 0.0 else &"move_right")
			var below := up.global_position.y > y + 60.0
			if below:
				# Düşman aşağıda: galeriden in (çömel + zıpla), ya da kenardan yürü.
				# Aynı katta 1,5 sn inemediyse (tur 334: Bölüm 35'te arena iskelesine doğan bot
				# her karede yeniden çömelip yerinde kaldı) 1 sn çömelmeden kenardan yürü.
				if on_floor and absf(y - _below_y) < 4.0:
					_below_t += delta
				else:
					_below_t = 0.0
					_below_y = y
				if on_floor and absf(dx2) < 220.0 and fmod(_below_t, 2.5) < 1.5:
					Input.action_press(&"crouch")
					_tap(&"jump")
					_release_queue.append([&"crouch", _run_t + 0.3])
				elif _below_t >= 1.5:
					Input.action_release(&"crouch")
			elif absf(dx2) < 110.0 and on_floor:
				_tap(&"jump")
			if absf(dx2) < 76.0:
				_tap(&"attack")
			return
	if foe != null:
		Input.action_release(&"run")
		# Patron telegrafı (tur 326): zırhlı patron saldırı hazırlığındayken ve menzildeyken
		# insan gibi ondan uzağa atıl (atılmanın kısa dokunulmazlığı vuruşu boşa çıkarır).
		# Her hazırlıkta bir kez; patron dışındaki düşmanlarda bot eskisi gibi tuşa basıcı.
		# Patron hücum hazırlığı: hücum bırakılmadan hemen önce üstünden zıpla.
		if _boss_charge_imminent(foe, foe_dx) and on_floor:
			_tap(&"jump")
			_evade_id = foe.get_instance_id()
			_evade_t = _run_t
			_boss_evades += 1
			_evade_hits0 = int(_player.hits_taken)
			return
		if _boss_windup_in_reach(foe, foe_dx):
			var away := &"move_left" if foe_dx > 0.0 else &"move_right"
			Input.action_press(away)
			Input.action_release(&"move_right" if away == &"move_left" else &"move_left")
			_tap(&"dash")
			_evade_id = foe.get_instance_id()
			_evade_t = _run_t
			_boss_evades += 1
			_evade_hits0 = int(_player.hits_taken)
			return
		# Atıldıktan sonra patron vuruşunu bitirene (RECOVERY) kadar menzil dışında bekle,
		# sonra açığa gir: DTM'deki "kaç, sonra cezalandır" ritmi.
		if foe.get_instance_id() == _evade_id and _run_t - _evade_t < 1.2 				and foe.get("_state") == 4 and foe.get("_phase") != 2:
			return
		if foe_dx > 14.0:
			Input.action_press(&"move_right"); Input.action_release(&"move_left")
		elif foe_dx < -14.0:
			Input.action_press(&"move_left"); Input.action_release(&"move_right")
		else:
			Input.action_release(&"move_right"); Input.action_release(&"move_left")
		if absf(foe_dx) < 76.0:
			_tap(&"attack")
		# Düşmanla arada siper / sandık varsa üstünden atla.
		if _player.is_on_floor() and _player.is_on_wall():
			_tap(&"jump")
		# Düşman çukurun öbür yakasındaysa insan gibi atla (tur 334): Bölüm 28 dikenli çukurunun
		# sağındaki Vurucuya yürüyen bot kenardan düşüp sonsuz yeniden doğma döngüsüne giriyordu.
		# Yalnız düşmanın ayağı da bu kattaysa: yüksek iskele kenarından boşluğa atlamasın.
		elif on_floor and absf(foe_dx) > 40.0 and not _ground_at(x + signf(foe_dx) * 30.0, y) \
				and _ground_at(foe.global_position.x, y):
			_tap(&"jump")
		return

	if _seek_heal(x, y, on_floor):
		return

	if _press_hold(x, y, on_floor):
		return

	# girdi botu
	Input.action_release(&"move_left")
	Input.action_press(&"move_right")
	# Aynı yerde art arda ölüyorsa (tur 334: Bölüm 28 kuleden dikenli çukura her doğuşta aynı yay)
	# insan gibi taktik değiştir: tek sayılı ölümlerden sonra yürüyerek dene.
	if _deaths_here % 2 == 1:
		Input.action_release(&"run")
	else:
		Input.action_press(&"run")

	if absf(x - _last_x) < 3.0:
		_stuck_t += delta
	else:
		_stuck_t = 0.0
	_last_x = x

	# kenar-farkında zıplama
	if on_floor and _ground_at(x + 8.0, y) and not _ground_at(x + 66.0, y):
		_tap(&"jump")
	elif on_floor and not _ground_at(x + 20.0, y):
		_tap(&"jump")
	# yerdeyken önünde alçak engel (tezgâh, sandık): zıpla
	elif on_floor and _player.is_on_wall():
		_tap(&"jump")
	# duvara yapıştıysa (havada, düşerken) duvar-zıplaması; tente sekişinin
	# yükselen kolunda zıplamak oyuncuyu duvardan geri iterdi.
	# Hareketli platformun yan yüzü duvar değildir: duvar-zıplaması oyuncuyu geri
	# iter. İnsan gibi sağı basılı tutup platformun üstüne iner.
	elif _player.is_on_wall() and not on_floor and _player.velocity.y > 0.0 and not _wall_is_moving():
		_tap(&"jump")
	# önünde kırılabilir duvar (verici, gizli oda kapısı) varsa vur
	if _player.is_on_wall():
		var hitc := _player.get_last_slide_collision()
		if hitc != null and hitc.get_collider() != null and hitc.get_collider().has_method(&"apply_hit"):
			_tap(&"attack")
			_stuck_t = 0.0
			return
	# tıkandıysa dash + zıpla — yükselen zıplamanın ortasında değil: havadaki
	# dash dikey hızı sıfırlar, zıplamayı duvarın dibinde öldürürdü.
	if _stuck_t > 0.3 and not (not on_floor and _player.velocity.y < 0.0):
		_tap(&"dash")
		_tap(&"jump")
		_stuck_t = 0.0


## Patron ağır saldırı hazırlığında (WINDUP) ve vuruş menzilinde mi? Aynı patrona 0,7 sn'de
## bir kez (0,5 sn'lik ağır hazırlık başına tek atılma).
func _boss_windup_in_reach(foe: Node2D, foe_dx: float) -> bool:
	var cfg = foe.get("config")
	if cfg == null or not cfg.is_boss:
		return false
	if foe.get_instance_id() == _evade_id and _run_t - _evade_t < 0.7:
		return false
	if foe.get("_state") != 4 or foe.get("_phase") != 0:	# State.ATTACK, Phase.WINDUP
		return false
	# Yalnız büyük telegraflı ağır vuruş (çekiç/yere vurma): hafif kombo darbesini bot,
	# çoğu insan gibi, değiş tokuş eder; her darbeden kaçmak dövüşü yapay uzatırdı.
	if not foe.get("_attack_heavy"):
		return false
	return absf(foe_dx) < float(cfg.attack_range) + 40.0


## Patron hücum (DASH) hazırlığının son 0,15 sn'si mi? Hücum menzilinde, hazırlık başına bir kez.
func _boss_charge_imminent(foe: Node2D, foe_dx: float) -> bool:
	var cfg = foe.get("config")
	if cfg == null or not cfg.is_boss or not foe.get("_dash_preparing"):
		return false
	if foe.get_instance_id() == _evade_id and _run_t - _evade_t < 0.7:
		return false
	return float(foe.get("_dash_timer")) < 0.15 and absf(foe_dx) < float(cfg.dash_trigger_range) + 40.0


## Arkada kalan can paketine dön (en az 25 can eksikken, 700 px geriye kadar, aynı kat ±150 px).
## 6 sn'de ulaşılamayan paketten vazgeçilir (yüksek raf, kapı ardı). Kumandayı aldıysa true.
func _seek_heal(x: float, y: float, on_floor: bool) -> bool:
	if _heal_target != null:
		if not is_instance_valid(_heal_target) or _heal_target.get("_collected"):
			_heals += 1
			_heal_target = null
		elif _run_t - _heal_t > 6.0:
			_heal_skip.append(_heal_target.get_instance_id())
			_heal_target = null
	if _heal_target == null:
		if _player.get_max_health() - _player.get_health() < 25 or _run_t < _heal_scan:
			return false
		_heal_scan = _run_t + 0.5
		var holder := _main.get_node_or_null(^"LevelHolder")
		if holder == null or holder.get_child_count() == 0:
			return false
		var best_dx := 1e9
		for c in holder.get_child(0).get_children():
			if not (c is Node2D) or not ("heal_amount" in c) or c.get("_collected"):
				continue
			if _heal_skip.has(c.get_instance_id()):
				continue
			var dx: float = c.global_position.x - x
			if dx < -700.0 or dx > 60.0 or absf(c.global_position.y - y) > 150.0:
				continue
			if absf(dx) < absf(best_dx):
				best_dx = dx
				_heal_target = c
		if _heal_target == null:
			return false
		_heal_t = _run_t
	var tdx: float = _heal_target.global_position.x - x
	var tdy: float = _heal_target.global_position.y - y
	Input.action_release(&"run")
	if tdx > 8.0:
		Input.action_press(&"move_right"); Input.action_release(&"move_left")
	elif tdx < -8.0:
		Input.action_press(&"move_left"); Input.action_release(&"move_right")
	else:
		Input.action_release(&"move_right"); Input.action_release(&"move_left")
	# Paket yukarıdaysa (iskele, sandık) altına gelince zıpla; önüne engel çıkarsa da.
	if on_floor and ((tdy < -70.0 and absf(tdx) < 90.0) or _player.is_on_wall()):
		_tap(&"jump")
	return true


## Bölümdeki presleri 2 sn'de bir tarar; her presin vuruş kilidi yeni kurulduysa (oyuncuya
## çarptı) `_press_hits` artar. Dövüş dalı erken döndüğü için her karede çağrılır.
func _count_press_hits() -> void:
	if _run_t >= _crusher_scan:
		_crusher_scan = _run_t + 2.0
		_crushers = []
		for n in _main.find_children("*", "AnimatableBody2D", true, false):
			if n is Crusher:
				_crushers.append(n)
	for c in _crushers:
		if not is_instance_valid(c):
			continue
		var id: int = c.get_instance_id()
		var lock: float = c.get("_hit_lock")
		if lock > float(_crusher_lock.get(id, 0.0)) + 0.5:
			_press_hits += 1
		_crusher_lock[id] = lock


## Önündeki pres yolu kesiyorsa insan gibi bekle: başlık oyuncu boyunun (112 px) üstüne
## çekilmeden ya da geçiş süresi içinde inecekse presin önünde dur; uzaktaysa yürüyerek yaklaş.
## Presin altındayken asla durma. true: bu kare girdi verildi.
func _press_hold(x: float, y: float, on_floor: bool) -> bool:
	var was := _press_waiting
	_press_waiting = false
	if not on_floor:
		return false
	for c in _crushers:
		if not is_instance_valid(c):
			continue
		var base: Vector2 = c.get("_base")
		var drop: float = c.get("drop_height")
		var w: float = c.get("width")
		var ground: float = base.y + drop + float(c.get("thickness")) * 0.5
		if absf(ground - y) > 40.0:
			continue
		var front: float = c.global_position.x - w * 0.5 - x
		if front < 12.0 or front > 150.0:
			continue
		var p: float = c.get("period")
		var t: float = c.get("_t")
		var tel: float = c.get("telegraph")
		## Başlığın tam inişe varacağı ana kalan süre (crusher.gd: telegraf + 0,12 periyot iniş).
		var to_down := fposmod(tel + 0.12 * p - t, p)
		var raised: bool = c.position.y - base.y < drop - 120.0
		var clear_t := (front + w + 40.0) / 260.0
		if raised and to_down > clear_t + 0.1:
			return false
		_press_waiting = true
		if not was:
			_press_waits += 1
		Input.action_release(&"run")
		Input.action_release(&"move_left")
		if front > 45.0:
			Input.action_press(&"move_right")
		else:
			Input.action_release(&"move_right")
		return true
	return false


func _wall_is_moving() -> bool:
	for i in _player.get_slide_collision_count():
		var c := _player.get_slide_collision(i)
		if absf(c.get_normal().x) > 0.7 and c.get_collider() is AnimatableBody2D:
			return true
	return false


## Ayak kotuna yakın zemin var mı? Daha aşağıdaki platform boşluğu gizlememeli.
func _ground_at(px: float, y: float) -> bool:
	var space := _player.get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(
		Vector2(px, y - 10.0), Vector2(px, y + 42.0), 1)
	q.exclude = [_player.get_rid()]
	return not space.intersect_ray(q).is_empty()


var _release_queue: Array = []

func _tap(a: StringName) -> void:
	if Input.is_action_pressed(a):
		return
	Input.action_press(a)
	# zıplama tuşunu uzun tut (erken bırakınca jump_cut ile cılız hop olur)
	_release_queue.append([a, _run_t + (0.24 if a == &"jump" else 0.06)])


## Süre penceresi geniş tutulsa da gerçek takılma testi düşürsün.
func _assert_no_stall(limit := 45.0) -> void:
	_note_stall()
	assert(_longest_stall <= limit, "%.0f sn ilerlemesiz takılma (x=%.0f)" % [_longest_stall, _stall_at])


func _note_stall() -> void:
	if _run_t - _progress_t > _longest_stall:
		_longest_stall = _run_t - _progress_t
		_stall_at = _progress_x


func _finish_level(msg: String) -> void:
	_note_stall()
	print("PROBE Bölüm %d: %s  stall=%.0fs@%.0f respawns=%d boss_evades=%d/%d isabet heals=%d press=%d/%d" % [
		_level_idx + 1, msg, _longest_stall, _stall_at, _respawns, _boss_evades, _boss_evade_fails, _heals,
		_press_waits, _press_hits])
	Input.action_release(&"move_right")
	Input.action_release(&"run")
	if not OS.get_environment("REDMOUNT_PROBE_LEVEL").is_empty():
		get_tree().quit()
		return
	if _level_idx < 4:
		_start_level(_level_idx + 1)
	else:
		print("PROBE DONE")
		get_tree().quit()
