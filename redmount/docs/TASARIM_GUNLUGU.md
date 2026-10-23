# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

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
