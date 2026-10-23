# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

- Günün dalgası üçüncü dilim: kural dağılımını bir yılda ölçüp eşitlemek (şu an tohum
  modülü; 9 kural); seri kırılınca "dün kaçırdın" uyarısı; seri ödülü olarak arşiv karesi.
- Kostümlerin ikinci dilimi: ceket ile pantolonu ayrı boyamak (sprite'ta y bandı ya da
  parlaklık eşiğiyle iki rampa) ve küçük piksel aksesuar katmanı (kasket, atkı, önlük).
  Kostüm bonusları sonuç kartında/mağazada "giyili" rozetiyle hatırlatılabilir.
- Yeni silahların ikinci dilimi: fırlatılabilir kaldırım taşı (tek kullanımlık, mermi sistemi
  yeniden kullanılır) ve pause CEPHANELİK'e ANAHTAR/ŞEMSİYE.
- Şemsiyeyle havaya kaldırılan düşmanı ikinci şemsiye vuruşunun tekrar kaldırması sonsuz
  dizi yaratabilir mi? İnsan testinde bakılacak; gerekirse havadaki düşmana kaldırma yok.

- Kanıt Arşivi'nde açılmış kitap şeritlerini yeniden izleme sekmesi (kitap sonu
  kayıtta işaretli; `Save` alanı varsayılan boş).
- Kitap şeridinde karelere küçük hareket: kare açılırken portrenin 1–2 sanat pikseli
  kayması ya da konuşma balonu (DTM çizgi romanlarındaki canlılık).
- Hız yıldızının par süresi bölüm başına ayarlanmalı: 34 bölümde düz 240 sn, bot
  ~80 sn'de bitiriyor. İnsan testinden gelen ortanca sürenin ~0,8'i hedef (ilk koşuda
  zor, ikinci koşuda alınabilir); `par_time` her `Bolum*.tscn`'de elle.
- Sonuç kartında önceki koşularda kazanılmış ama bu koşuda alınamamış yıldızı soluk
  altınla göstermek (oyuncu neyin kalıcı olduğunu görsün).
- Telefonda dokunmatik ölçüm: yanlış/kaçırılan basış sayacı (insan testi formuyla bağlanacak).
- KAY düğmesinin yeri gerçek cihazda başparmak erişimiyle doğrulanacak; gerekirse
  oyuncu düğme düzenini sürükleyerek kaydedebilsin (Save'e `touch_layout`).

## Tur kayıtları

### 2026-10-23 (8) — Günün Dalgası ikinci dilim: seri ödülü, seri rozeti, 3 yeni kural

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 listesi bitti; birikimin en üstündeki
madde. Günlük kipin seri sayacı vardı ama hiçbir şey vermiyordu ve menüde görünmüyordu —
"yarın da gel" çağrısı yoktu. 6 kural haftada bir tekrarlanıyordu.

**Oyuncu ne hissedecek:** Ana menüde sağ üstte istatistik panelinin altında piksel
çerçeveli `SERİ 6 GÜN · 7. günde +100 coin` rozeti (seri canlıyken). Ödül gününde sonuç
kartında `SERİ ÖDÜLÜ +40`. Üç yeni gün türü: HIZLI ADIM (düşmanlar %30 hızlı, kaçma/
pozisyon günü), ERKEN PATRON (3. dalga tek başına Mini Boss, sonra iki normal dalga ve
final boss), BIÇAK GÜNÜ (bıçakla başla, her dalgada bıçaklı).

**Yapılanlar:**
- `DailyWave`: `STREAK_REWARDS` 3→40, 7→100, 14→200, sonra her 7 günde 100;
  `streak_reward/next_streak_reward/streak_alive`; isteğe bağlı kural alanları `must`,
  `speed`, `boss_at` (eski kurallar varsayılanla okunur; nişancı `must: rifle`a taşındı).
- `Save.finish_daily` ödülü cüzdana ekleyip döndürür; aynı gün ikinci çağrı ödül vermez.
  Kayıt formatı değişmedi.
- `survival.gd`: bıçak başlangıcı, hızlı günde düşman config'inin kopyası hızlandırılır
  (paylaşılan .tres bozulmaz), ara patron dalgasında "PATRON DALGASI" yazısı, sonuç kartında
  seri ödülü.
- `main_menu.gd`: seri rozeti istatistik panelinin altında (ilk denemede ana sütuna
  konmuştu; ÇIKIŞ düğmesini alttaki tuş yardım satırına bindirdi → taşındı).

**Sayılar (hipotez):** 3. gün 40 ≈ günlük tamamlamanın üçte ikisi (erken, kısa vadeli
kanca); 7. gün 100 ≈ bir kostümün yarısı; 14. gün 200 ≈ en pahalı kostüm. Bir haftalık
seri günlük 60+~45'in üstüne toplam 140 ekler — kampanyayı gölgelemez, geri dönmeyi
ödüllendirir. Hızlı gün çarpanı 1,3: koşan oyuncu ~ düşman hızı farkını hisseder ama
eşkıya yine de oyuncudan yavaş; insan testinde "kaçamadım" ölümü artarsa 1,2.
Kural seçimi artık 9'da bir; değişiklik aynı tarih için eski sürümden farklı plan verir
(sunucu olmadığından sorun değil).

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: bir yılda 9 kuralın
hepsi çıkıyor, `must` vaadi her dalgada, erken patron 3. dalgada tek, seri ödül tablosu,
aynı gün ödül tekrarlanmıyor, hızlı günde gerçek sahnede düşmanlar ×1,3 ve paylaşılan
config değişmiyor, seri 2→3 koşusunda +40 ve sonuç kartı metni); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; `tests/costumes.tscn` PASS; bot Bölüm 1 (84,7 sn),
13 (77,4 sn), 25 (98,6 sn) CLEARED. 1280×720 ekran görüntüsünde menü rozeti ve sonuç
kartı kontrol edildi. Telefonda görülmedi.

**Sonraki öneri:** Birikimin başı artık kostümlerin ikinci dilimi (ceket/pantolon ayrı
rampa + küçük piksel aksesuar).

### 2026-10-23 (7) — Survival arenası piksel art'a çevrildi (birikim 1. madde)

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 sırası (1–7) bitti; birikimin en
üstündeki madde. Survival ve yeni Günün Dalgası, `_draw()` ile çizilen koyu düz dikdörtgen
+ eğik çizgilerden ibaret bir boşlukta oynanıyordu — piksel art kuralına aykırı ve
kampanya bölümlerinin yanında "bitmemiş prototip" gibi duruyordu. Günlük kip her gün
açılan ekran olacağı için ilk izlenim önemli.

**Oyuncu ne hissedecek:** Survival akşamüstü bir Balat arka sokağında: boyalı gökyüzü,
arkada karartılmış ev sırası, kaldırım + taş dolgulu zemin, üç sokak feneri, büfe ve
saksılar. Günün Dalgası aynı süslerle ama pazar sokağı/kemer arka planında — iki kip ilk
bakışta ayrılır.

**Yapılanlar:** `survival.gd` yeni sistem yazmadan DtmLevel'in çizim sınıflarını
kullanıyor: `DtmLevel._Sky` + `_BackRow` (`level` = Survival düğümü; okudukları
`sky_*`/`back_*` alanları Survival'a eklendi), zemin `_Art.A_TERRAIN` (zemin gövdesi
bölümlerdeki gibi 520 px derin; çarpışma üstü y=0, değişmedi), `_Lantern`, mahalle
süsleri (`BUFE`, `TREE_POT`, `PLANT`, `POTS`) ve `_night()` ile aynı hafif
`CanvasModulate`. Atlas: `level06_backstreets_atlas.png` hücre 0 (Survival) / 1 (Günlük).
`_draw()` kaldırıldı.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; `tests/daily_wave.tscn` PASS; `tests/survival_mode.tscn` OK. 1280×720 pencereli
ekran görüntüsü (iki kip, orta ve sol kenar): taşma/boşluk yok, HUD/pankart okunuyor;
sol kenarda arka sıra evler x≈-600'den başlıyor, arkada gökyüzü dolu (sorun görülmedi).
Kampanya bölümleri değişmediği için bot koşusu yapılmadı. Telefonda görülmedi.

**Sıradaki öneri:** birikimdeki günün dalgası ikinci dilimi (seri ödülü/rozeti, yeni kurallar).

### 2026-10-23 (6) — Günün Dalgası (OYNANIS-KALITE P1-7, ilk dilim)

**Neden şimdi:** Yol haritası bitti; P1 sırasında yeni silahlar ve kostümlerden sonra
sıradaki madde. Kampanya 36 bölüm ama telefonda "3 dakikam var" oturumuna uyan, her gün
yeni bir sebep veren kısa bir mod yoktu; Survival sonsuz ve her seferinde aynı.

**Oyuncu ne hissedecek:** Menüde GÜNÜN DALGASI'na basar, arenaya girer girmez pankartta
günün kuralı ("PAZAR KALABALIĞI · Her dalgada +2 eşkıya"). Beş kısa dalga, üstte
`DALGA 2/5 · 4 DÜŞMAN`, sonda Mini Boss. Bitince kartta büyük `5/5`, coin + tamamlama
ödülü ve seri. Tek hak olduğu için ilk deneme gerilimli; tekrar istediği kadar antrenman
yapar ama ödül yarın — yarın yeni kural ve dizi gelir.

**Yapılanlar:**
- `scripts/systems/daily_wave.gd` (`DailyWave`): FNV-1a tarih tohumu (Godot `hash()`
  sürümler arası değişebilir), 6 kural, 5 dalgalık plan, `next_streak` (ay/yıl sınırı).
- `survival.gd`: `GameState.daily_run` ile günlük kip; plan dalgaları kenarlardan
  dönüşümlü doğar, kural silah/zırh/iyileşme/cephanelik uygular, arena sayacı ve
  pankart HUD'un mevcut piksel parçalarıyla; sonuç kartında madalya çerçevesine `n/5`.
  Doğurma kodu `_spawn` olarak ortaklaştı (normal survival aynı).
- `Save`: `[daily] day/waves/clear_day/streak`, `begin_daily/record_daily_wave/finish_daily`.
- `main_menu.gd`: SURVIVAL ile GÜNÜN DALGASI yan yana (sütun 720 px'e sığsın).

**Sayılar (hipotez):** 5 dalga ≈ 2–4 dk (mobil oturum). Dalga başına 2+w (+kural ek)
düşman, en çok 8; dalga w'de havuzun ilk w+1 tipi açık, ilk dalga yalnız eşkıya/bıçaklı.
Tamamlama +60: dalga coin'leri (5–13, toplam 45) kadar — günde bir kez alınır, mağaza
kostümü (120–240) 2–4 günlük hedef olur, kampanyanın bölüm coin'ini gölgelemez. Hak
başlarken kullanılır: yarıda çıkıp yeniden denemek "puanlı tekrar" olmasın.

**Testler:** `--import` hatasız; yeni `tests/daily_wave.tscn` PASS (aynı gün aynı plan,
30 günde ≥4 kural ve ≥25 farklı dizi, boss yalnız son dalgada, seri ay/yıl sınırı, eski
kayıt uyumu, gerçek Survival sahnesinde 5 dalga: coin + 60, seri 2→3, sonuç kartı,
survival rekoru değişmez; ikinci deneme antrenman, coin yazmaz); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; `tests/costumes.tscn`, `tests/level_stars.tscn` PASS;
bot Bölüm 1 (78,0 sn), 13 (75,1 sn), 25 (88,2 sn) CLEARED; normal Survival 300 kare
hatasız. 1280×720 ekran görüntüsünde menü satırı, kural pankartı + dalga sayacı ve sonuç
kartı kontrol edildi (ilk denemede kural `Fx.popup` ile hemen sönüyordu → pankarta
taşındı; sonuç metni ipucu düğmesinin altına taşıyordu → 3 satıra indirildi). Telefonda
görülmedi; insan oyuncuyla günlük koşu süresi ölçülmedi.

**Sonraki öneri:** OYNANIS-KALITE P1 listesi ilk dilimleriyle bitti. Birikimin başı:
Survival arenasının arka planını piksel art'a çevirmek (günlük mod artık oraya oyuncu
çekiyor ve arena kurala aykırı biçimde kodla çiziliyor).

### 2026-10-23 (5) — Kostümler (OYNANIS-KALITE P1-6, ilk dilim)

**Neden şimdi:** Yol haritası bitti; P1 sırasında yeni yakın silahların ilk dilimi yapıldı,
sıradaki madde kostümler. Mağazadaki 4 hareket + 7×3 yükseltme ~2.200 coin'de bitiyor;
sonrasında coin'in hiçbir karşılığı kalmıyordu. Kostüm hem uzun vadeli harcama hedefi
hem de oyuncunun karakterine sahip çıkma hissi verir.

**Oyuncu ne hissedecek:** Mağazada KOSTÜMLER sekmesinde Redmount'u beş giysiyle yan yana
görür; kilitli olanlar hangi bölümde açılacağını söyler. Alınca hemen giyer; bölüme
girince sahada, ara sahnede ve ana menü çatısında aynı renkte görür. Her kostümün tek
küçük bonusu oyun tarzına göre seçim yaptırır (tank / silahçı / yiyecekle toparlanan /
yumrukçu), ama hiçbiri zorunlu değil.

**Yapılanlar:**
- `shaders/player_costume.gdshader`: palet takası (doygunluk < 0,25 ve parlaklık
  0,035–0,62 arası pikseller rampaya; kontur, ten, saç, ayakkabı korunur) + isteğe
  bağlı gece konturu. Varsayılan kostümde malzeme yok (sıfır risk).
- `Shop.COSTUMES`, `Shop.costume/costume_bonus/costume_material`; adlar Türkçe büyük
  harfle (Godot `to_upper` "i"yi "I" yapıyordu).
- `Save.costume` + `owns_costume/buy_costume/set_costume`; eski kayıt uyumlu.
- `redmount.gd`: `apply_costume()`, can ve yumruk/silah kapasitesi çarpanlarına bonus;
  `health_pickup.gd`: yiyecek bonusu (Survival dalga iyileştirmesi etkilenmez).
- `dtm_level.gd`: gece konturu kostüm malzemesi varsa onun `rim_enabled`'ını açar/kapatır.
- `cutscene.gd`, `main_menu.gd`: Redmount kuklası da giyili kostümle.
- `shop_menu.gd`: üçüncü sekme ve kostüm kartı.

**Sayılar (hipotez):** Fiyatlar 120–240: en pahalı yükseltme kademesinden (140) yüksek,
böylece önce oynanışı değiştiren alımlar yapılır, kostüm "sonraki hedef" olur. Bonuslar
yükseltmenin tek kademesinden küçük ya da ona yakın (can +10 < +15; yumruk %8 < %12;
silah %15 < %20) — kostüm bir güç basamağı değil, tarz seçimi. Kahveci %25 yiyecek:
30'luk simit 37'ye çıkar, tek başına bir isabeti karşılar. Açılış bölümleri (3/8/14/20)
kitaplara yayılır, her kitapta yeni bir hedef görünsün.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; `tests/level_stars.tscn` PASS; `tests/new_melee_weapons.tscn` PASS; yeni
`tests/costumes.tscn` PASS (eski kayıt, bilinmeyen id, satın alma/giyme, palet
malzemesi + gece konturu parametresi, oyuncuya can/yumruk bonusu, mağaza sekmesi);
bot Bölüm 1 (77,1 sn), 13 (79,0 sn), 25 (89,5 sn) CLEARED. 1280×720 ekran görüntüsünde
mağaza sekmesi ve Bölüm 1 açılış sahnesinde lacivert Redmount kontrol edildi (ilk
görüntüde ara sahne kuklası siyah kalıyordu → `cutscene.gd` düzeltildi). Gece bölümü
ve telefon ekranında görülmedi.

**Sonraki öneri:** OYNANIS-KALITE P1-7 — günün dalgası (Survival'a tarih tohumlu kısa mod).

### 2026-10-23 (4) — Yeni yakın silahlar: Boru Anahtarı ve Şemsiye (OYNANIS-KALITE P1-5, ilk dilim)

**Neden şimdi:** Yol haritası bitti; OYNANIS-KALITE P1 sırasında ilk açık madde yeni yakın
silahlar. 4 silahın ikisi yakın ve ikisi de "daha çok hasar" farkıyla ayrılıyordu; silah
seçimi bir karar değildi. Kalkanlı Zabıta ve blok yapan muhafızlar dövüşün en sinir bozucu
anlarıydı, havada takip (AIR_KNEE) ise neredeyse yalnız bitiriciden sonra açılıyordu.

**Oyuncu ne hissedecek:** Bölüm 4'te kalkanlıdan hemen önce yerde kırmızı saplı bir boru
anahtarı; alınca "BLOK DELER" yazar, kalkana vurunca kalkan iner ve "KALKAN DELİNDİ!".
Bölüm 3 pazarında bordo bir şemsiye: alınca "HAVAYA KALDIRIR"; her isabet düşmanı kaldırır,
zıplayıp dizle karşılamak cazip olur. Ağır-yavaş-az kullanım ↔ hafif-uzun-çok kullanım.

**Yapılanlar:**
- `WeaponConfig.guard_break` / `launch_speed` (varsayılan kapalı, eski kaynaklar aynı).
- `EnemyBase.apply_guard_break_hit` (blok duruşu + blok şansı yok sayılır),
  `ShieldGuard` geçersiz kılması (önden kalkanı indirir, tam hasar). `Redmount._deal_attack_hit`
  silah özelliğine göre çağırır; kuşanınca özellik yazısı.
- `tools/gen_pixel_weapons.py`: sopa sayfalarında sopa pikselleri renk maskesi + bağlı
  bileşen ile bulunur, sap ucu el pikseline yakınlıktan seçilir, sap→uç boyunca yeniden
  boyanır (anahtar: kırmızı sap + çelik baş + çene; şemsiye: siyah sap, bordo katlı kumaş,
  gümüş uç); savuruş izi bileşeni çene almaz. 24 px elle yerleştirilmiş ikonlar 2x.
- `PlayerSprite._register_bat_variants`: yeni sayfalar sopa bölgeleri/zamanlamasıyla eklenir.
- Hata düzeltmesi: `play_action("weapon_swing")` sayfası olmayınca "idle"a düşüp savuruşun
  hazırlık karelerini silahsız duruşla örtüyordu (sopa ve bıçakta da).
- Elle yerleşim: Bölüm 3 (x=760), Bölüm 4 (x=2620, ipucu metni güncellendi); dükkân:
  Bölüm 7 ANAHTAR (34 coin), Bölüm 14 ŞEMSİYE (26 coin); sandık ganimeti 4 silahtan biri.

**Sayılar (hipotez):** Anahtar 20 hasar / 0,24 sn hazırlık / 10 kullanım — sopadan (16/0,16/12)
ağır ve yavaş; kalkanı deldiği için kalabalıkta değil hedefli kullanılmalı. Şemsiye 10 hasar /
0,12 sn / 16 kullanım, menzil 104 px (sopa 74); kaldırma hızı 320 — aparkat 430, bitirici 260
arası: dize zaman bırakır ama tek başına aparkat kadar güçlü değil. Dükkân fiyatları sopa (22)
ile bıçak (30) çizgisinde.

**Testler:** `--import` hatasız; yeni `tests/new_melee_weapons.tscn` PASS (kaynak alanları,
pickup/ikon/dükkân/sandık, 8 yeni animasyon kare sayısı, kalkan delme, blok delme, kaldırma +
hava dizine açıklık, hazırlık karesi düzeltmesi); `tests/dtm_gaps.tscn` PASS;
`tests/level_stars.tscn` PASS; `tests/campaign_smoke.gd` çıkış 0; bot Bölüm 1, 3, 4, 13, 25
CLEARED (87,7 / 70,1 / 109,3 / 76,0 / 85,6 sn). 1280×720 ekran görüntüsünde yerdeki anahtar ikonu, anahtar
savuruşu, şemsiye duruşu kontrol edildi; telefonda görülmedi.

**Sonraki öneri:** Kostümler (P1-6) — ya da bu maddenin ikinci dilimi: fırlatılabilir
kaldırım taşı + pause cephaneliğine yeni silahlar (birikime yazıldı).

### 2026-10-23 (3) — Kitap geçiş sinematikleri (Yol haritası 10)

**Neden şimdi:** Yol haritasındaki son açık madde. Kitap 1 ve 2'nin son bölümleri
oyun içi sahneyle bitip doğrudan sonuç kartına düşüyordu; oyuncu bir kitabın
kapandığını, sıradakinin neden başladığını hissetmiyordu. DTM bölüm aralarını
çizgi roman kareleriyle bağlar — bu bir "nefes" ve ödül anıdır.

**Oyuncu ne hissedecek:** Bölüm 12 / 24 / 36'nın son konuşması biter, ekran kararır,
"KİTAP n SONU · ad" başlığının altında dört kare soldan sağa küçük bir sarsılmayla
yerine çakılır; her karenin altında krem kutuda tek cümle. Son karede sarı
"SIRADAKİ · KİTAP n+1 · ad" (finalde "SON · TEŞEKKÜRLER"). Sabırsız oyuncu J/dokunuşla
kareleri öne alır, ESC bütün şeridi atlar.

**Yapılanlar:**
- `tools/gen_comic_panels.py` → `assets/ui/comic/k{1,2,3}_{0..3}.png`: bölümün kendi
  atlasından kesit (96×56, kutu filtresi, 22 renk) + 48×48 piksel portreler (karşılıklı
  bakış için aynalı) + elle boyanmış defter, Kâtip'in notu ve simit; 1 px mürekkep + krem
  çerçeve. Tekrar eden ikili yakın planlar azaltıldı (matbaa genel planı, simit kapanışı).
- `scripts/ui/book_comic.gd` (`BookComic`, CanvasLayer 8): metinler sahnelerdeki son
  konuşmalarla aynı olayları özetler; `present/advance/is_active`.
- `main.gd`: `_on_goal_reached` içinde oyun içi bitişten sonra, yalnız `story_scenes`
  açıkken (menüden oyun) ve kitap sonu bölümde; `_ending_in_progress` dokunmatik
  düğmeleri gizler ve ESC'nin duraklatma menüsünü açmasını engeller.

**Sayılar (hipotez):** Kareler arası 1,1 sn (bir cümle okunur; tüm şerit ~4,5 sn,
izleyen oyuncuyu sıkmaz), çakılma 0,18 sn; son kareden sonra 0,5 sn kapanma kilidi
(basılı tutulan saldırı tuşu şeridi yutmasın). 3x ölçek: dört kare 1280'e 22 px
pay ile sığar, alt yazı 24 px piksel yazıyla en fazla 3 satır.

**Testler:** `--import` hatasız; yeni `tests/book_comic.tscn` PASS (yalnız 12/24/36,
12 kare dokusu 100×60, otomatik akış, girdiyle öne alma, erken basış kilidi, ESC
atlama); `tests/dtm_gaps.tscn` PASS; `tests/campaign_smoke.gd` çıkış 0; bot Bölüm 1 (81,3 sn), 12 (91,5 sn),
13 (77,5 sn), 24 (193,1 sn), 25 (81,6 sn) CLEARED (bot `story_scenes` kapalı
koştuğu için şerit yolunu değil, ortak bitiş akışını doğrular). 1280×720 ekran görüntüsünde üç şerit kontrol edildi (Kitap 2'nin son alt
yazısı 4 satıra taşıyordu, kısaltıldı; kutular eşit boya getirildi). Telefonda görülmedi.

**Sonraki öneri:** Yol haritası tamamlandı. Sıradaki tur OYNANIS-KALITE P1:
yeni yakın silahlar.

### 2026-10-23 (2) — Bölüm sonu yıldızları (Yol haritası 9)

**Neden şimdi:** Yol haritasındaki ilk açık madde. S/A/B/C harfi 5 ağırlıklı
etkenden (süre, hasar, düşman, coin) puanla çıkıyordu; oyuncu neden A aldığını,
S için ne yapması gerektiğini göremiyordu. Üç ayrı, adı konmuş hedef tekrar oynama
sebebini açıkça söyler ve yıldız koşular arası birikir — her koşu tek bir hedefe
odaklanabilir.

**Oyuncu ne hissedecek:** Bölüm biter, kart açılır, kazanılan yıldızlar soldan
sağa bir coin sesiyle büyükten yerine "çakılır"; kazanılmayan yuva oyulmuş mürdüm
yıldız olarak kalır ve altındaki yazı (HIZ / HASARSIZ / GİZLİ ALAN) eksiği söyler.
Bölüm seçmede her kartta 3 küçük yıldız, başlıkta toplam ★ x/108.

**Yapılanlar:**
- `tools/gen_pixel_stars.py` → `assets/ui/pixel/yildiz_{dolu,bos}.png` (15×14,
  sonuç kartında 4×) ve `_kucuk` (9×8, menüde 3×); altın 4 ton + parıltı pikseli.
- `Save.stars` (index → bit maskesi; `progress/stars`, eski kayıtta `{}`),
  `record_stars` (birleştirir, geçersiz bitleri atar), `stars_of`, `star_count`,
  `total_stars`. `is_complete` artık "3 yıldız" (eski S + gizli alan kuralının yerine;
  önceden alınmış ustalık ödülleri `mastered`'da kalır).
- `main.gd`: `_compute_rank` → `_compute_stars`; iki bitiş yolu da yıldızı kaydeder.
- `hud.gd`: harf rütbesi gizli, madalya paneli genişledi, 3 yıldız + alt yazı, sıralı
  açılış animasyonu; `show_stage_clear/show_results` artık maske alır (-1 = yok).
  Uzun "Yeni vuruş mağazada" ipucu kartın dışına taşıyordu, kısaltıldı.
- `main_menu.gd`: rütbe rozeti yerine 3 küçük yıldız, BÖLÜM SEÇ başlığında toplam.

**Sayılar (hipotez):** HIZ = `elapsed ≤ par_time` (mevcut par; 34 bölümde 240 sn).
HASARSIZ = 0 isabet — kesin ve okunur bir hedef; yıldız kalıcı olduğundan ayrı bir
koşuda denenebilir, bu yüzden "≤1" gibi gevşetme yapılmadı. GİZLİ ALAN = kayıtlı en
iyi bulunan sayısı ≥ toplam (gizli alansız bölümde bedava). Açılış 0,45 sn sonra,
yıldızlar arası 0,32 sn — kart okunurken ritim, R'ye basmayı geciktirmeyecek kadar kısa.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS (ustalık testi yıldızlara uyarlandı); yeni `tests/level_stars.tscn` PASS
(birleştirme, geçersiz bit, eski kayıt uyumu, kartta doğru yıldızların dolması,
survival'da gizli); bot Bölüm 1 (78,7 sn), 13 (81,6 sn), 25 (80,7 sn) CLEARED.
1280×720 ekran görüntüsünde sonuç kartı ve bölüm seçme kontrol edildi (boş yıldız
ilk hâlinde okunmuyordu, tonu açıldı; orta yıldız başlık şeridine değiyordu, indirildi).

**Sonraki öneri:** Yol haritası 10 — kitap geçiş sinematikleri (piksel çizgi roman
panelleri).

### 2026-10-23 — Dokunmatik kontrol cilası (Yol haritası 8)

**Neden şimdi:** Yol haritasındaki ilk açık madde. Dokunmatik düğmeler hâlâ
yumuşak degrade daire + sistem yazı tipiydi; oyunun geri kalanı piksel art.
Telefonda kayma tekmesi pratikte erişilemezdi: koşarken (sol başparmak ◀/▶'da)
aynı başparmakla ▼'a basmak gerekiyordu.

**Oyuncu ne hissedecek:** Düğmeler HUD ve menülerle aynı piksel ailesinden
(koyu mürdüm gövde, altın halka, basılınca ateş rengine dönüp bir piksel
gömülme). Sağ başparmakla tek dokunuşta `KAY` → kayma tekmesi. Her eylem
düğmesinde çok kısa bir titreşim tıkı; istemeyen duraklatma menüsünden kapatır.

**Yapılanlar:**
- `tools/gen_pixel_touch.py` → `assets/ui/pixel/touch_{buyuk,kucuk,mini,genis}[_basili].png`
  ve `touch_ikon_{sol,sag,asagi,durdur}.png`; oyunda NEAREST, ~4x ölçek.
- `TouchControls`: degrade `_disc` kaldırıldı; piksel dokular, `PixelUI.font()`,
  ok/duraklat için piksel ikon, basılıyken ikon/yazı 1 sanat pikseli iner.
- Yeni `slide` girdi eylemi + `KAY` düğmesi; `redmount.gd` yerdeyken `slide`
  basılınca koşu şartı olmadan `slide_kick` başlatır (hamle kendi 640 hızını verir).
  İpucu rozeti dokunmatikte `KAY`.
- `Save.vibration` (`settings/vibration`, eski kayıtta varsayılan açık);
  `Combat.rumble` buna uyar; duraklatma menüsünde yalnız dokunmatik cihazda
  `TİTREŞİM: AÇIK/KAPALI`.

**Sayılar (hipotez):** Tık 12 ms / güç 0.3 — fark edilir ama isabet titreşimini
(20–65 ms) bastırmayacak kadar kısa. Hareket oklarında tık yok: başparmak oklar
arasında kayarken (`passby_press`) sürekli vızıldamasın. KAY düğmesi sağ kümenin
iç üst köşesinde (zıpla merkezinden ~150 px), oyun alanını kapatmayacak yükseklikte.

**Testler:** `--import` hatasız; `tests/campaign_smoke.gd` çıkış 0;
`tests/dtm_gaps.tscn` PASS; yeni `tests/touch_polish.tscn` PASS (piksel doku +
yazı tipi, KAY → slide_kick, titreşim ayarı kayıt uyumu, menü düğmesi);
bot Bölüm 1 (83,4 sn), 13 (77,4 sn), 25 (91,8 sn) CLEARED. 1280×720 ekran
görüntüsünde düğmeler ve menü kontrol edildi; telefonda görülmedi.

**Sonraki öneri:** Yol haritası 9 — bölüm sonu 3 yıldız (hız, hasarsızlık, gizli
alan) + menüde toplam yıldız.
