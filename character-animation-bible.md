# Karakter Animasyon Planı — Yan Görünümlü Beat ’em Up

Bu plan, hızlı okunabilir silüet, belirgin hazırlık pozu ve net temas kareleri temelinde hazırlanmıştır.
Tüm değerler başlangıç hedefidir; her hareket soldan sağa oynanır ve ters yönde aynalanır.

## Ortak hareket kuralları

- Her saldırıda sıra: **hazırlık → temas → geri dönüş**. Temas karesi en güçlü ve en okunur pozdur.
- 1 oyun karesi = 16,67 ms (60 FPS). Aşağıdaki süreler gerçek animasyon kareleri değil, sprite’in ekranda kaldığı oyun kareleridir.
- Vuruş alanı sadece `active` karelerde açılır. Hazırlıkta ve geri dönüşte kapalıdır.
- Sıçrama saldırılarında yatay momentum korunur; karakter yere değmeden tekrar saldırı başlatamaz.

## Redmount

Kimlik: kontrollü, güçlü ve teknik ana oyuncu karakteri. Haritadan coin ve ekipman toplar; yumruk dövüşü yalnızca silahsız kaldığındaki temel seçenektir. Sopa, bıçak, ateşli silah ve zırh kullanır.

### Temel döngüler

- `idle` — 6 sprite, 8 oyun karesi: göğüs nefesi, omuzda küçük gerilim, bakış sabit.
- `walk` — 8 sprite, sprite başına 5 oyun karesi: ağır fakat ritmik; ceket hafif sallanır.
- `run` — 8 sprite, sprite başına 3 oyun karesi: gövde önde, kollar kompakt.
- `jump` — 5 sprite: 2 kalkış, 1 tepe, 2 iniş hazırlığı.
- `land` — 3 sprite, 5 oyun karesi: diz kırılır, sonra hemen nötr duruş.

### Dövüş seti

#### Silahsız yedek set

- `punch_1` — 5 sprite: 2 hazırlık / 1 temas / 2 geri dönüş. Düz sağ yumruk.
- `punch_2` — 6 sprite: 2 hazırlık / 2 temas / 2 geri dönüş. Gövdeye sol kroşe.
- `punch_3` — 7 sprite: 3 hazırlık / 1 güçlü temas / 3 geri dönüş. Dönüşlü sağ kroşe; hafif geri itme.
- `air_knee` — 6 sprite: havada diz çekme; 2 temas karesi.

#### Toplanabilir ekipman seti

- `coin_pickup` — 4 sprite: eğilme, coin parlama, coin sayacına eklenme; hareketi kısa süre keser.
- `item_pickup` — 5 sprite: silah/sopa/bıçak/zırhı yerden alma ve kuşanma.
- `bat_idle` / `bat_walk` / `bat_swing` — 5 / 8 / 8 sprite: sopa ile geniş yatay savuruş ve yukarıdan indirme varyantı.
- `knife_idle` / `knife_walk` / `knife_slash` / `knife_throw` — 5 / 8 / 7 / 6 sprite: hızlı kısa menzil saldırısı; atış sonrası silahsız sete döner.
- `gun_idle` / `gun_walk` / `aim` / `shoot` / `reload` — 5 / 8 / 4 / 4 / 8 sprite: kısa kontrollü atışlar; mermi bittiğinde yeniden doldurma gerekir.
- `armor_equip` / `armor_idle` / `armor_hit` — 6 / 6 / 4 sprite: zırh alınca silüet genişler, hasar tepkisi azalır; ağırlaşma nedeniyle koşu hızı düşer.
- `weapon_drop` — 4 sprite: silah dayanıklılığı bittiğinde veya ağır darbede ekipmanın düşmesi.

#### Hava ve geçiş hareketleri

- `air_bat` — 7 sprite: havada sopa savurma.
- `air_knife` — 6 sprite: havada ileri bıçak hamlesi.
- `air_shot` — 5 sprite: havada tek atış; geri tepme yatay hareketi hafif azaltır.
- `quick_swap` — 4 sprite: envanterdeki kullanılabilir ekipmana kısa geçiş.

### Toplanabilirler ve bonus animasyonları

#### Coinler

- `coin_standard` — 6 sprite döngü: parkur boyunca havada dönen standart coin; skor ve mağaza parasına eklenir.
- `coin_bonus` — 8 sprite döngü: daha parlak, daha büyük nadir coin; gizli platform veya kırılabilir duvar arkasında görünür ve yüksek değer verir.
- `coin_pickup` — 4 sprite: Redmount coinle temas ettiğinde kısa parlama, coin kaybolur ve HUD coin sayacı artar.

#### Sandık ve güçlendirmeler

- `chest_open` — 6 sprite: sandığa/ikona yaklaşma, açılma ve bonusun yukarı çıkması.
- `health_pickup` — 5 sprite: kırmızı kalp veya iksir alınır; Redmount kısa iyileşme parlaması alır ve canı anlık dolar.
- `damage_x2_pickup` — 6 sprite: yumruk ikonu, kırmızı aura başlangıcı; verilen hasar 10–15 saniye iki katına çıkar.
- `speed_pickup` — 6 sprite: şimşek ikonu, ayaklarda kısa hız izi; hareket hızı 10–15 saniye 1.5x–2x artar.
- `invisibility_pickup` — 7 sprite: hayalet ikonu, Redmount silüeti yarı saydamlaşır; düşman algısı 8–10 saniye kapanır.
- `ammo_pickup` — 5 sprite: kutu/şarjör ikonu alınır; menzilli silah cephanesine anlık stok eklenir.
- `shield_pickup` — 6 sprite: opsiyonel ileri aşama; Redmount çevresinde kısa kalkan halkası oluşur ve bir sonraki darbeyi engeller.

#### HUD geri bildirimi

- Süreli bonus alındığında ekranın üst köşesinde ilgili ikon ve azalan geri sayım çubuğu görünür.
- Süre bittiğinde ikon 3 kez kısa yanıp söner; aura/hız izi/görünmezlik aynı karede kapanır.
- Anlık bonuslarda zamanlayıcı görünmez: can, cephane ve coin sayacı doğrudan güncellenir.

### Tepkiler

- `hit_light` 3 sprite; `hit_heavy` 5 sprite; `knockdown` 6 sprite; `getup` 6 sprite.

## Gazelle

Kimlik: kaçırılmış sivil karakter. Savaşmaz, hareket alanından kaçmaz ve düşmanla karşılaşma animasyonuna ihtiyaç duymaz. Oyun boyunca düşmanın elinde, kurtarılmayı bekleyen "prenses" rolündedir; animasyonları yalnızca esaret, umut ve kurtarılma anını anlatır.

### Temel döngüler

- `idle_captive` — 6 sprite, 9 oyun karesi: temkinli nefes, çevreyi kontrol eden kısa bakışlar, saçta hafif hareket.
- `sit_captive` — 5 sprite, 10 oyun karesi: sabit noktada, dizleri çekili veya sandalyede tedirgin bekleyiş.
- `look_up` — 4 sprite: uzaktan gelen dövüş sesini fark edip başını kaldırma.
- `hopeful_glance` — 4 sprite: Redmount görünür olduğunda korkunun yerini kısa bir umut ifadesi alır.
- `bound_idle` — 6 sprite, 9 oyun karesi: bilekleri bağlı, küçük nefes ve hafif ağırlık değişimi.

### Hikâye tepkileri

- `flinch` — 3 sprite: yakındaki darbe veya silah sesi karşısında irkilme; yerini değiştirmez.
- `struggle_bound` — 8 sprite: bağları çözmeye çalışma; başarıya ulaşmaz, bekleme döngüsüne döner.
- `rescue_react` — 6 sprite: Redmount düşmanı alt ettiğinde şaşkınlık ve rahatlama.
- `freed` — 7 sprite: bağın çözülmesi, bilekleri ovuşturma, Redmount'a yönelme.
- `rescue_pose` — 5 sprite: kurtarılma anında sabit, güvenli ve duygusal kapanış pozu.

## Karahanlı

Kimlik: sakin, ölçülü ve otoriter. Az hareket eder; her saldırı kararlı ve ağır görünür.

### Temel döngüler

- `idle` — 6 sprite, 10 oyun karesi: nefes minimum; ceket kenarında ince hareket; bakış sabit.
- `walk` — 8 sprite, sprite başına 6 oyun karesi: dik duruş, küçük adım, eller kontrollü.
- `run` — 8 sprite, sprite başına 4 oyun karesi: gereksiz savrulma yok, gövde dik kalır.
- `jump` — 5 sprite: kısa kalkış, düz silüet, kontrollü iniş.
- `land` — 3 sprite, 6 oyun karesi: neredeyse sessiz iniş.

### Dövüş seti

- `straight` — 6 sprite: 3 hazırlık / 1 temas / 2 geri dönüş. Az ama sert düz yumruk.
- `body_hook` — 7 sprite: gövde dönüşü belirgin; 2 temas karesi.
- `elbow_finish` — 7 sprite: yakın mesafe dirsek; kombonun bitiricisi.
- `heavy_push` — 8 sprite: iki el ile ileri itme; düşmanı uzaklaştırır.
- `step_kick` — 7 sprite: öne tek adım + alçak, kuvvetli tekme.
- `command_taunt` — 6 sprite: ceketi düzeltir, bir adım öne çıkar; saldırı değil, düşmanı kısa süre baskılar.

### Tepkiler

- `hit_light` 3 sprite; `hit_heavy` 5 sprite; `knockdown` 6 sprite; `getup` 6 sprite.

## Düşman NPC kadrosu

Tüm düşmanlar Redmount’ı alt etmeye çalışır. Tasarımlar ve bölüm dağılımı, sağlanan karakter sheet’ine sadıktır.

### 1. Sokak Eşkıyası — Bölüm 1

- Rol: yavaş, düşük can, temel yakın dövüş düşmanı; grup halinde gelir.
- Animasyonlar: `idle` 4, `walk` 8, `punch` 5, `grab_attempt` 6, `hit` 3, `knockdown` 6, `getup` 5, `death` 6 sprite.

### 2. Bıçaklı Ajan — Bölüm 1–2

- Rol: hızlı yakın dövüş; önce kısa süre kaçar, ardından dash ile bıçak saldırısı yapar.
- Animasyonlar: `idle_knife` 5, `retreat` 6, `dash` 6, `stab` 6, `slash` 7, `miss_recover` 4, `hit` 3, `knockdown` 6, `death` 6 sprite.

### 3. Tüfekli Muhafız — Bölüm 2–3

- Rol: uzak menzil ateş desteği; siper alarak Redmount’ı engellerin arkasına saklanmaya zorlar.
- Animasyonlar: `idle_rifle` 5, `move_to_cover` 7, `cover_idle` 4, `aim` 4, `burst_fire` 5, `reload` 8, `panic_close_range` 4, `hit` 3, `knockdown` 6, `death` 6 sprite.

### 4. Zırhlı Vurucu — Bölüm 3–4

- Rol: yüksek can; yavaş ama güçlü darbe. Comboyu kırma riski taşır ve bloklama gerektirir.
- Animasyonlar: `idle_heavy` 6, `walk_heavy` 8, `armored_punch` 10, `guard_break` 9, `block` 5, `stagger` 5, `knockdown` 9, `getup` 8, `death` 9 sprite.

### 5. Çevik Suikastçı — Bölüm 3–4

- Rol: duvar sıçraması ve ani saldırı; oyuncunun parkur becerisini test eder.
- Animasyonlar: `idle` 5, `run` 8, `wall_jump` 7, `air_dash` 6, `drop_strike` 8, `ground_slash` 7, `evade` 5, `hit` 3, `knockdown` 6, `death` 6 sprite.

### 6. Ağır Zırhlı (Mini-boss) — Bölüm 4 Sonu

- Rol: çok yüksek can ve alan saldırısı. Bölüm 4 sonunda mini-boss savaşı.
- Animasyonlar: `idle_boss` 7, `walk_boss` 8, `hammer_sweep` 11, `ground_slam` 12, `charge` 10, `armor_break_stagger` 6, `knockdown` 10, `getup` 9, `death` 12 sprite.

### 7. Elit Muhafız — Bölüm 5

- Rol: yakın ve uzak saldırıyı birleştirir; kalede grup halinde çıkar.
- Animasyonlar: `idle_elite` 6, `walk` 8, `rifle_aim` 4, `single_shot` 4, `butt_strike` 7, `close_combo` 8, `block` 5, `hit` 4, `knockdown` 7, `death` 7 sprite.

## İlk üretim sırası

1. Üç karakterin `idle`, `walk`, `run`, `jump` ve `land` sheet’leri.
2. Redmount: coin/eşya toplama, sopa, bıçak, silah ve zırh sheet’leri; silahsız üçlü combo yedek set olarak kalır.
3. Gazelle: captive idle + umut bakışı + bağ çözme + kurtarılma pozu.
4. Karahanlı: straight + body hook + elbow finish.
5. Sokak Eşkıyası ve Bıçaklı Ajan: temel saldırı, hasar, düşme, ayağa kalkma ve ölüm sheet’leri.
6. Tüfekli Muhafız, Zırhlı Vurucu, Çevik Suikastçı, Ağır Zırhlı ve Elit Muhafız: özel saldırı sheet’leri.
