# REDMOUNT — Üç Dünyalı Kampanya Tasarımı (Dan the Man ölçeği)

> Durum: **TASARIM — henüz uygulanmadı.** Bu belge onay/ayarlama içindir; kod ve
> içerik üretimi bir sonraki adımdır. Mevcut [12-BOLUM-KAMPANYA.md](12-BOLUM-KAMPANYA.md)
> artık **Kitap I**'in ayrıntılı planı olarak kalır ve değişmeden yürürlükte kalır.

## Neden bu yapı

Dan the Man 3 "Episode" × 12 seviye ile ilerler; her bölüm kendi görsel kimliğine,
düşman rengine ve final patronuna sahiptir, ama hepsi tek bir kahramanın büyüyen
hikâyesidir. REDMOUNT'ta zaten 12 bölümlük **Kitap I** var (Şehir → Karahanlı).
Bunu tek seferde 3 katına çıkarmak yerine, aynı iskeleti (4 perde × 3 bölüm,
StoryBlockout üretim deseni, EnemyConfig veri-güdümlü düşman sistemi) **iki yeni
kitaba** klonluyoruz. Mimari değişmiyor, ölçek büyüyor.

## Üst anlatı — neden devam ediyoruz

Kitap I'in mevcut bitişi (Karahanlı yenilir, Gazelle kurtarılır, "Bir daha kimse
seni buradan alamayacak") **değişmiyor** — o an hâlâ gerçek bir zafer. Kancayı
Kitap II'nin AÇILIŞINA koyuyoruz: kaleden çıkarken ele geçirilen bir şifreli
telsiz/defter, Karahanlı'nın yalnızca bölgesel bir infaz memuru olduğunu, asıl
tedariğin sınır ötesinden geldiğini gösterir. Redmount ve Gazelle iziyle sınıra
gider. Kitap III'te iz, sınırdaki adamın da yalnızca bir ara kademe olduğunu ve
gerçek failin başkentte oturduğunu ortaya çıkarır. Klasik üç perdelik tırmanış:
**sokak suçu → askeri/lojistik ağ → siyasi güç**.

## Kitap I — ŞEHİR (mevcut, değişmedi)

Perde I–IV, Bölüm 1–12. Final: **Karahanlı** (kaba kuvvet, zırh+ağır saldırı
varyantı). Biome: Street/Industrial/Fortress/Keep. *Referans: 12-BOLUM-KAMPANYA.md.*

## Kitap II — SINIR HATTI (yeni, Bölüm 13–24)

**Tema:** Karahanlı'yı besleyen kaçakçılık hattını dağlık sınır bölgesine kadar
kovalamak. Ton: sokak baskınından askeri/lojistik operasyona geçiş — daha geniş
menzilli düşmanlar, çevresel tehlike (buz/rüzgâr), daha disiplinli birlikler.

**Final patron: Tuğrul** — sınır garnizonu komutanı. Kaba kuvvet değil, taktik:
zırh kırılma fazı + savunma (blok) + ağır saldırı kombinasyonu (mevcut
`EnemyConfig` alanlarıyla dogrudan kurulur: `block_chance`, `armor_break_hits`,
`slam_on_heavy` — yeni kod gerekmez, yeni `.tres` + yeni sprite atlası yeter).

| Perde | Ad | Hikâye işi | Görsel/biome |
|---|---|---|---|
| V | Sınır Karakolu | İlk temas — kaçakçılık ağının sınır ayağı | Soğuk endüstriyel (mevcut Industrial tonuna kar/buz eklenir) |
| VI | Buzul Hattı | Teleferik/tren hattı boyunca tedarik izleme | Yeni **Snow** biome |
| VII | Maden Ocakları | Silah deposu haline gelmiş maden — dikey/karanlık | Yeni **Mine** biome (yer altı, fenerli) |
| VIII | Tuğrul'un Kalesi | Garnizon komutanına son yürüyüş + patron | Snow + Mine karışımı, fırtınalı final |

**Yeni düşman rengi (hepsi mevcut `enemy_base.gd` + yeni `EnemyConfig.tres`,
sadece stat/anim reskin — yeni script yok):**
- *Kar Nişancısı* — RifleGuard'ın uzun menzilli, daha sabırlı varyantı.
- *Zırhlı Kar Muhafızı* — ArmoredBruiser'ın `block_chance` yükseltilmiş hâli.
- *Maden Suikastçısı* — AgileAssassin reskin, dar tünellerde sıçrama.
- (Opsiyonel tazelik) *Kalkanlı Öncü* — yüksek `block_chance` + düşük hasar,
  oyuncuyu ağır saldırıya veya arkadan dolanmaya zorlar. Yine sadece config.

## Kitap III — BAŞKENT (yeni, Bölüm 25–36)

**Tema:** İz, başkentteki gerçek faile çıkar — Karahanlı ve Tuğrul'u perde
arkasından besleyen kişi. Ton belirgin şekilde değişir: sokak/askeri kabalıktan
**saray/siyasi** zarafete. Bu bölümde duygusal gerilim de yükselir — Perde XI'de
Gazelle yeniden kaçırılır (orijinal öncülü yankılayan, bilinçli bir tekrar),
Redmount tek başına son perdeye girer.

**Final patron: Vezir** — tahtın arkasındaki güç. Kaba kuvvet değil düellocu:
yüksek `evade_chance` + `is_agile` sıçrama + hassas zamanlamalı karşı saldırı.
İki fazlı his: faz 1 kılıç/yakın dövüş üstünlüğü, faz 2 (can eşiği altında)
`armor_break` sonrası çaresizce daha tehlikeli bir varyant.

| Perde | Ad | Hikâye işi | Görsel/biome |
|---|---|---|---|
| IX | Dış Surlar | Başkent savunmasına sızış | Yeni **Palace-dış** (mermer + tuğla) |
| X | Saray Bahçeleri | Törensel alanlar, ilk siyasi ipucu/ihanet | Palace-dış, gündüz/akşam kontrastı |
| XI | Zindanlar | Gazelle yeniden kaçırılır — duygusal dip | Yeni **Dungeon** (taş, meşale) |
| XII | Taht Odası | Final gauntlet + Vezir + gerçek son | Yeni **Palace-iç** (altın/kırmızı) |

**Yeni düşman rengi (yine yalnızca config + sprite):**
- *Saray Muhafızı* — EliteGuard'ın disiplinli/parry-hissi varyantı (yüksek
  `block_chance` + `heavy_attack_chance`).
- *Gölge Suikastçısı* — AgileAssassin'in `evade_chance` yüksek, sık sıçrayan
  versiyonu.
- *Onur Muhafızı* (mini-boss, Perde XI kapanışı) — ArmoredBruiser + boss
  bayrağı, Gazelle'in tekrar kaçırılışını fiziksel olarak engelleyen blok.

## Mimariye etkisi (uygulama aşamasında yapılacaklar — şimdi değil)

Kod tarafında **yeni bir sistem gerekmiyor**, mevcut 4 katman genişletiliyor:

1. **`GameState.LEVELS`** — 12 → 36 giriş. `ACT_NAMES` düz dizi yerine
   `WORLD_NAMES` (3) + dünya başına 4 perde adı olacak şekilde yeniden
   yapılandırılır (`world_index()`, `act_index()` iki seviyeli hesap).
2. **`Level.biome` enum + `Backdrop.Biome` enum** (şu an ikisi de
   Street/Industrial/Fortress/Keep) — `Snow`, `Mine`, `PalaceOuter`, `Dungeon`,
   `PalaceInner` eklenir. Her yeni değer için: `BIOME_EDGE`/`BIOME_TINT`
   (level.gd), `_VIGNETTE_TINT` (main.gd), `Backdrop._draw_layer` içindeki
   yeni-biome çizim dalı, ve yeni bir `_make_X()` prosedürel doku üreticisi
   (level.gd — mevcut `_make_asphalt/_make_metal/_make_stone` deseniyle aynı).
3. **`Music.play_for_biome()`** — Görev 26'daki prosedürel chiptune sistemine
   (`tools/gen_music.py`) yeni biome'lar için yeni per-biome parça üretimi.
3. **Yeni düşman `.tres` dosyaları** — sadece veri; **yeni script gerekmiyor**
   (`EnemyConfig` zaten blok/ağır-saldırı/kaçma/sıçrama/menzilli-ateş hepsini
   kapsıyor). Yeni sprite atlasları gerekir (placeholder üretici script'i
   mevcut — bkz. hafıza notu "REDMOUNT Godot workflow").
4. **İki yeni final boss sahnesi** (`Tugrul.tscn`, `Vezir.tscn`) — Karahanlı ile
   birebir aynı desen: `enemy_base.gd` + yeni `.tres` + yeni frames + diyalog
   portresi.
5. **24 yeni `StoryBlockout`-tarzı bölüm** — mevcut `story_blockout.gd`
   deseninin devamı (ya `chapter` aralığını 8/12'ye genişletmek ya da her
   kitap için ayrı bir `_chapterN()` script dosyası — ikincisi daha okunur,
   çünkü tek dosya 36 fonksiyona şişmez).

## Önerilen üretim sırası

Tek seferde 24 yeni bölüm + 6 yeni düşman + 2 patron + 5 yeni biome çok büyük
bir yığın. Önerim: **Kitap II'yi tam bitirip oynanabilir hâle getirmek, sonra
Kitap III'e geçmek** — Kitap I'in 7 bölümü nasıl tek seferde teslim edildiyse
o desende, ama bu sefer bloklardan önce biome/düşman altyapısını (madde 1-4)
kurup üstüne 12 bölümü inşa etmek. Bu; yarı yolda "biome enum'unu genişletirken
12 sahneyi de değiştirmek" gibi geri dönüşleri önler.

## Açık kararlar (onayınızı bekliyor)

- Dünya adları / patron adları (Tuğrul, Vezir) — ton olarak uygunsa sabitlenir,
  değişsin isterseniz alternatif öneririm.
- Gazelle'in Perde XI'de yeniden kaçırılması — duygusal tekrar riskli
  olabilir; istenirse Kitap III'te farklı bir gerilim kaynağı (ör. Redmount'un
  yaralanıp yarı gücünde final'e girmesi) ile değiştirilebilir.
- Üretim sırası önerisi (önce altyapı, sonra Kitap II tam, sonra Kitap III) —
  onaylanırsa bir sonraki adım GameState/biome/enemy-config genişletmesiyle
  başlar.
