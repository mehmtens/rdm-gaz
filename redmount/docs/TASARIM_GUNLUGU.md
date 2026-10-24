# REDMOUNT — Tasarım günlüğü

Otomatik "oyun tasarımcısı" turlarının tarihli kayıtları. Her tur tek tutarlı
iyileştirme yapar; sayılar insan testi gelene kadar hipotezdir.

## Tasarım birikimi

Sıradaki adaylar (üstteki önce). Yol haritasında açık madde varken önce o yapılır.

- Kaldırım taşı: havada (zıplarken) fırlatmada elde taş görünmüyor (jump sayfası
  silahsız) — insan testinde fark edilirse `tas_jump`. Taş yalnız 2 ve 5'teki büfede;
  insan testinde taş çok seçiliyorsa diğer büfelerde de denenebilir.
- Günün dalgası: GÜNLÜK sekmesine 21/28. gün kareleri (insan testinde seri 14'ü geçen
  oyuncu çıkarsa).
- Pantolon maskesi kalıntıları: tekmenin (kick 2–3) diz arkasında ve koşuda ayakkabının arka
  kenarında 2–4 piksel ceket rengi (kontura yapışık, kırıntı birleştirmesine girmiyor).
- Şemsiyeyle havaya kaldırılan düşmanı ikinci şemsiye vuruşunun tekrar kaldırması sonsuz
  dizi yaratabilir mi? İnsan testinde bakılacak; gerekirse havadaki düşmana kaldırma yok.

- Kitap şeridinde karelere küçük hareket: kare açılırken portrenin 1–2 sanat pikseli
  kayması ya da konuşma balonu (DTM çizgi romanlarındaki canlılık).
- Hız yıldızının par süresi bölüm başına ayarlanmalı: 34 bölümde düz 240 sn, bot
  ~80 sn'de bitiriyor. İnsan testinden gelen ortanca sürenin ~0,8'i hedef (ilk koşuda
  zor, ikinci koşuda alınabilir); `par_time` her `Bolum*.tscn`'de elle.
- Bıçak savuruşu (`knife_attack` 4) kalıntısı: şapkanın üstünde 1–2 sanat pikseli koyu nokta
  kalıyor (iz ön parçasının içinde ya da ≥ 8 px). İnsan testinde fark edilirse ön parçadan da
  tutam kenarı ayıkla.
- Telefonda dokunmatik ölçüm: yanlış/kaçırılan basış sayacı (insan testi formuyla bağlanacak).
- KAY düğmesinin yeri gerçek cihazda başparmak erişimiyle doğrulanacak; gerekirse
  oyuncu düğme düzenini sürükleyerek kaydedebilsin (Save'e `touch_layout`).

## Tur kayıtları

### 2026-10-24 (22) — Seri rozeti sıradaki arşiv karesini söylüyor

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin en üstündeki taş maddesi insan
testi koşullu, ikincisi (rozette arşiv karesi) koşulsuz ve küçük. Seri rozeti yalnız coin
söylüyordu; 3/7/14. gün aynı zamanda Kanıt Arşivi'nde kalıcı bir kare açıyor ama oyuncu bunu ancak
kare açıldığında öğreniyordu. Coin harcanıp biter, kare koleksiyonda kalır — DTM'de olduğu gibi
"yarın dön" çağrısının en güçlü hâli kalıcı ödülü önceden göstermek.

**Oyuncu ne hissedecek:** Ana menüde `SERİ 4 GÜN · 7. günde +100 coin + kare`. Kare daha önce
açıldıysa (en uzun seri o güne zaten ulaştıysa) ya da 21+ gibi kare vermeyen ödül günündeyse
`+ kare` yazmaz — yalan vaat yok.

**Yapılan:** `DailyWave.day_opens_photo(day, best_streak)` (gün `ARCHIVE_DAYS` içinde ve en uzun
seriden büyük); `main_menu.gd` rozet metnine ekleme. Yeni kayıt alanı yok.

**Test:** `tests/daily_wave.tscn` PASS (rozet durumları: kare açacak / kare zaten açık / 21. gün /
kopuk seri / seri yok), derleme temiz, `tests/dtm_gaps.tscn` PASS, 36 sahne smoke çıkış 0, Bölüm 1
bot CLEARED. 1280×720 ekran görüntüsünde rozet piksel çerçeveye sığıyor (sağda ~100 px pay).

**Sıradaki öneri:** Birikimdeki koşulsuz madde kalmadı sayılır (hepsi insan testi/cihaz
koşullu); bir sonraki tur TASARIM DENETİMİ — Kitap 2'den bir bölümü (ör. 15) bot ile oynatıp
ritim/set-piece/ödül karşılaştırması ve yeni birikim.

### 2026-10-24 (21) — Kanıt Arşivi'nde kitap sonu şeridini yeniden izleme

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin üstündeki maddeler insan testi
koşullu. Önceki turun önerisi buydu. Kitap sonu çizgi roman şeridi bir kez oynuyor, sonra
kayboluyordu — DTM'de bölüm arası çizgi romanlar yeniden izlenebilir; hikâyeyi unutup ara
verip dönen mobil oyuncu "nerede kalmıştık?" sorusunu arşivden yanıtlar.

**Oyuncu ne hissedecek:** Kanıt Arşivi'nde her kitap sekmesinin altında, GERİ'nin yanında
`▸ KİTAP 1 ŞERİDİ` düğmesi; basınca dört kare aynı çakılma ritmiyle oynar, kapanınca odak
düğmeye döner (arşivden çıkmaz). Bitirilmemiş kitapta düğme soluk: `ŞERİT · KİTAP 2'Yİ BİTİR`
(hedef). GÜNLÜK sekmesinde düğme yok.

**Yapılanlar:**
- `book_comic.gd`: `end_of(book)`, `is_unlocked(book)` — yeni kayıt alanı açmadım: son bölümün
  bitiş süresi, skoru ya da sonraki bölümün açık olması yeterli (eski kayıtlarda da çalışır;
  birikimdeki "Save alanı" fikrinden daha basit ve geriye uyumlu).
- `main_menu.gd`: arşiv alt satırı `GERİ` + `ComicReplay`; sayfaya bir `BookComic` katmanı;
  şerit açıkken menünün `ui_cancel` geri dönüşü yutulmaz (şerit ESC ile kapanır, sayfa kalır).
- Kayıt formatı değişmedi.

**Testler:** `--import` hatasız; yeni `tests/archive_comic.tscn` PASS (açılma kuralları, eski
kayıt, kapalı/açık/GÜNLÜK düğme durumları, ikinci basış baştan başlatmıyor, kapanınca arşiv
açık); `book_comic.tscn` PASS; `daily_wave.tscn` PASS (aynı menü); `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 12 CLEARED (71,8 sn) — oyun içi şerit yolu değişmedi,
kitap sonu bölümü kontrol için.

**Görsel kanıt:** 1280×720 pencereli üç görüntü: açık düğme altın çerçeveli, kapalı düğme gri
ve Türkçe ekle okunuyor, taşma yok; şerit arşivin üstünde tam karartmayla oynuyor. Telefonda
görülmedi. (Pencereli koşuda görülen `pixel_ui_boot._pixelize` "Object to Object" hatası
aynı karede iki kez sekme kurulmasından; önceden de var, bu turla ilgisiz.)

**Sonraki öneri:** Birikimde insan testine bağlı olmayan somut iş: kitap şeridinde karelere
küçük hareket (kare açılırken portrenin 1–2 sanat pikseli kayması). Ya da birikim yalnız
insan testi koşullu kaldıysa yeni bir tasarım denetimi turu.

### 2026-10-24 (20) — Sonuç kartında önceden kazanılmış yıldız soluk okra

**Neden şimdi:** Yol haritası ve P1 maddeleri oyunda; birikimin ilk iki maddesi insan testi
koşullu. Önceki turun önerisi buydu ve küçük, kendi başına tamamlanan bir okunurluk işi.
Şimdiye kadar tekrar koşuda alınmayan yıldız boş yuva olarak görünüyordu — oyuncu "kaybettim mi?"
diye düşünebiliyordu; kayıt aslında yıldızları birleştiriyor.

**Oyuncu ne hissedecek:** Sonuç kartında bu koşuda kazanılan yıldızlar eskisi gibi altın
çakılır; daha önce kazanılmış ama bu koşuda alınmamış olanlar baştan sönük okra (parıltısız)
durur, hiç alınmamışlar boş mürdüm yuva. Üç durum bir bakışta ayrılıyor: "bu koşu / kalıcı /
eksik". DTM'deki "hedef kalıcı, tekrar koşu ek şans" hissi.

**Yapılanlar:**
- `tools/gen_pixel_stars.py`: `faded` modu → `yildiz_soluk[_kucuk].png` (dolu/boş bayt bayt
  aynı kaldı).
- `hud.gd`: `STAR_FAINT`, `earned_stars` (Main doldurur, `_reveal` tüketip sıfırlar — sonraki
  karta sızmaz).
- `main.gd`: iki bitiş yolunda `record_stars` öncesi `_hud.earned_stars = Save.stars_of(...)`.
- Kayıt formatı değişmedi.

**Testler:** `--import` hatasız; `level_stars.tscn` PASS (yeni: önceki HASARSIZ soluk, hiç
alınmamış HIZ boş, bu koşunun yıldızı yine dolu, maske sonraki karta sızmıyor); `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 CLEARED (78,9 sn), Bölüm 13 (77,3), Bölüm 25 (83,9)
— bitiş yolu (`main.gd`) ortak olduğu için.

**Görsel kanıt:** 1280×720 pencereli görüntü: iki soluk + bir altın yıldız; soluk okra
altından açıkça ayrılıyor, boş yuvayla karışmıyor, taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Bölüm seçme kartındaki küçük yıldızlarda da aynı dil hazır
(`yildiz_soluk_kucuk.png`) ama orada "bu koşu" yok; kullanılmadı. Birikimden hız yıldızı par
süreleri insan testi bekliyor; insan testi verisi yoksa Kanıt Arşivi'nde kitap şeritlerini
yeniden izleme sekmesi sıradaki somut iş.

### 2026-10-24 (19) — Günün Dalgası beşinci dilim: Kanıt Arşivi'nde seri kareleri

**Neden şimdi:** Yol haritasında açık madde yok, P1 maddelerinin hepsi oyunda; birikimin ilk
maddesi (taşın havada görünmemesi) insan testi koşullu, sıradaki somut iş buydu. Seri şimdiye
kadar yalnız coin veriyordu; coin ekonomisi kostümlerden sonra doyuyor. DTM'de günlük ödülün
kalıcı bir izi olur — oyuncu "o haftayı" bir koleksiyonda görür.

**Oyuncu ne hissedecek:** Seri 3., 7. ve 14. güne ulaşınca sonuç kartında coin ödülünün
yanında `ARŞİVE KARE` yazar. Kanıt Arşivi'nde yeni GÜNLÜK sekmesinde arenanın akşamüstü
tonlu kareleri, köşede kırmızı piksel gün damgası; kilitliyse altında `14 GÜN SERİ` hedefi.
Seri kopsa da kare gitmez (en uzun seri saklanır).

**Yapılanlar:**
- `DailyWave.ARCHIVE_DAYS = [3, 7, 14]`, `archive_photos(best)`.
- `Save.daily_best_streak` (`[daily] best_streak`; eski kayıtta `max(0, streak)` →
  geriye uyumlu, mevcut seriyle başlar), `finish_daily` günceller, `wipe` sıfırlar.
- `survival.gd`: puanlı koşu öncesi/sonrası açık kare sayısı karşılaştırılır (`_new_photo`);
  yazı kısa coin satırına konur (seri satırı skorla birlikte kartı dolduruyordu).
- `main_menu.gd`: arşivde 4. sekme GÜNLÜK, `_daily_archive_cell()`.
- `tools/gen_photos.py daily_photo`: survival arenasının atlasından (`level06_backstreets`)
  3 kare, mor-turuncu akşamüstü tonu (kitap karelerinin sepyasından ayrılsın), 3×5 piksel
  rakamlı gün damgası. Mevcut 108 kare yeniden üretildi, bayt bayt aynı kaldı.

**Sayılar (hipotez):** Kare günleri ilk üç coin ödülüyle aynı — "ödül anı" tek yerde toplanır,
oyuncu iki ayrı takvim öğrenmez. 14'ten sonra kare yok: koleksiyon kapanır, sonsuz kovalamaca
yaratmaz; insan testinde 14'ü geçen oyuncu olursa 21/28 eklenir.

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: eski kayıtta en uzun seri
0 / yalnız `streak` varsa ondan, `archive_photos` sınırları, kare dosyaları, arşivde GÜNLÜK
sekmesi ve seri 7'de 2 açık + 1 kilitli, puanlı 3. gün koşusunda `ARŞİVE KARE` ve kayıttan
okuma); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `survival_mode` OK; bot Bölüm 1
CLEARED (79,7 sn), Bölüm 13 (77,6), Bölüm 25 (82,4) — kayıt sistemi ortak olduğu için.

**Görsel kanıt:** 1280×720 pencereli görüntü: GÜNLÜK sekmesinde 4 sekme başlığa sığıyor, iki
açık kare okunur, damga görünür; sonuç kartında `ARŞİVE KARE` coin satırında, taşma yok.
İlk denemede not seri satırına eklenmişti ve satır kartın kenarına dayanıyordu — taşındı.
Telefonda görülmedi.

**Sonraki öneri:** Hız yıldızı par sürelerinin bölüm başına ayarı için insan testi verisi
gelene kadar, sonuç kartında önceki koşulardan kazanılmış yıldızı soluk altınla gösterme.

### 2026-10-24 (18) — Kaldırım taşı dördüncü dilim: varilden ve büfeden taş

**Neden şimdi:** Yol haritasında açık madde yok, P1 ilk dilimleri oyunda; birikimin başı
taşın dördüncü dilimiydi. Taş yalnız Bölüm 2'deki tek yığından ve duraklat cephaneliğinden
geliyordu; oyuncu bölüm içinde taşa ulaşamıyordu. Üstelik silahsız oyuncu için varilden çıkan
cephane kutusu (%35) hiçbir işe yaramıyordu — DTM'de kırılan her kap "değdi" hissi verir.

**Oyuncu ne hissedecek:** Elinde ateşli/fırlatılan silah yokken varil kırınca cephane kutusu
yerine taş yığını düşer: bir sonraki kalabalığa üç taşla girer. Tabancalıyken varil yine
cephane verir. Bölüm 2 ve 5 büfelerinde `TAŞ · 14 C` kartı var. Taş elindeyken cephane kutusu
alırsa 16 değil 3 taş kazanır.

**Yapılanlar:**
- `BreakableProp.adapt_loot(scene, player)`: zar cephane çıkarırsa ve oyuncunun silahı yoksa
  `TasPickup` döner; diğer ganimetler değişmez. `_break` zarı bundan geçirir.
- `LevelShop.CATALOG["tas"]` (14 coin); `bolum02.gd` ve `bolum05.gd` büfelerine 4. kart.
- `redmount.gd add_ammo`: yerçekimli (fırlatılan) silahta ekleme `mag_size + starting_reserve`
  ile sınırlı.

**Sayılar (hipotez):** 14 coin: cephanelik (15) ile aynı düzeyde, can (15) ile yan yana en
ucuz seçenek; duraklat menüsüne gitmeden bölüm içinden alınabildiği için 1 coin indirim.
Kutu taşa 3 ekler (bir yığın): 16 taş, 22 hasarlı yay atışla tabancayı (16 mermi) geçerdi.
Varil zarı (%35) değişmedi; yalnız ne düştüğü değişti — ganimet sıklığı aynı kalır.

**Testler:** `--import` hatasız; `tests/kaldirim_tasi.tscn` PASS (yeni: silahsızken varil →
taş, tabancalıyken cephane, boş zar/yiyecek değişmez, kutu taşa +3, büfe kataloğu, Bölüm 2
bakkalında taş); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `new_melee_weapons` PASS;
`survival_mode` OK; bot Bölüm 2 CLEARED (74,3 sn), Bölüm 5 (96,6), Bölüm 1 (84,5), Bölüm 13 (77,4), Bölüm 25 (83,6) — büfe değişen iki bölüm + ortak varil/oyuncu sistemi için 0, 12, 24.

**Görsel kanıt:** 1280×720 pencereli görüntü, Bölüm 2 bakkalı: 4 kart (CAN/BIÇAK/TAŞ/ZIRH)
panele sığıyor, taş ikonu piksel art ve okunur, coin yetmeyen kart kırmızı. Telefonda görülmedi.

**Sonraki öneri:** Günün dalgası 5. dilim (7. gün Kanıt Arşivi karesi).

### 2026-10-24 (17) — Kaldırım taşı üçüncü dilim: elde görünen taş + fırlatma kareleri

**Neden şimdi:** Yol haritasında açık madde yok, P1 ilk dilimleri oyunda; birikimin başı
kaldırım taşıydı. Taş kuşanılınca Redmount boş elle duruyor, atış da düz yumruk (combo_a
1–5) oynuyordu: oyuncu elinde ne olduğunu ve kaç atış kaldığını yalnız HUD'dan okuyordu.
DTM'de eldeki eşya her zaman karakterin silüetinde görünür.

**Oyuncu ne hissedecek:** Taşı alınca öndeki yumrukta gri bazalt taş görünür (bekleme ve
yürüme/koşu). L'ye basınca geri çekiş → kol önde bırakış → toparlanma oynar, taş anında
çıkar; el boşalır, yedek taş varsa 0,25 sn sonra elde yenisi belirir. Kostüm ne olursa
olsun taş gri kalır.

**Yapılanlar:**
- `tools/gen_pixel_weapons.py gen_tas_sheets`: `tas_idle`, `tas_walk` sayfaları silahsız
  sayfaların kopyası (pantolon/saç işaretleri korunur) + öndeki yumruğun (kalça altındaki en
  sağdaki ten lekesi) üstüne 2x taş ve kontur, silah işaretiyle (alfa 252) — kostüm shader'ı
  boyamaz. Uçan taşla aynı desen.
- `player_sprite.gd TAS_SHEETS`: taş animasyonları kaynak animasyonun bölge/zamanlamasıyla
  SpriteFrames'e eklenir; `tas_shoot` ayrı sayfa değil, `combo_a` 2–5. kareleri.
- İlk denemede fırlatma sayfası omuzda/geri çekişte elde taş taşıyordu; mermi tuşa basıldığı
  anda doğduğu için iki kare boyunca ekranda iki taş vardı. Atış gecikmesi eklemek dokunmatik
  tepkiyi bozacağından elde taş fırlatma karelerinden çıkarıldı (anında bırakış).
- `kaldirim_tasi.tres shoot_anim = &"shoot"`; `redmount.gd _play`: yerçekimli mermili
  silahın atış animasyonu 0,25 sn (4 kare × 16 fps).
- `CostumeAccessory.SHEET_ALIAS`: `tas_*` sayfaları kaynağın baş çapasını/ön parçasını
  kullanır (`head_anchors.json` yeniden üretilmedi; şapka taşla da doğru oturur).

**Sayılar (hipotez):** Taş 2x (20×14 sayfa pikseli ≈ 12×8 oyun pikseli): yumruktan büyük,
telefonda okunur, uçan taştan (20×14 oyun pikseli) küçük — "elde" ve "havada" aynı nesne gibi
okunuyor ama elde silüeti bozmuyor. Atış animasyonu 0,25 sn < atış aralığı 0,45 sn.

**Testler:** `--import` hatasız; `tests/kaldirim_tasi.tscn` PASS (yeni: her bekleme/yürüme
karesinde silah işaretli taş, başlık çapası paylaşımı, beklerken `tas_idle`, kare sayıları,
atışta `tas_shoot`); `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; `costumes`,
`new_melee_weapons`, `survival_mode` PASS; bot Bölüm 2 CLEARED (75,5 sn), Bölüm 1 (84,8),
Bölüm 13 (80,3), Bölüm 25 (85,5) — oyuncu sprite'ı ve kostüm çapası ortak olduğu için dört bölüm.

**Görsel kanıt:** 1280×720 pencereli görüntü, Bölüm 2, vapurcu kostümü: elde taş gri ve
okunur, şapka yerinde; atışta el boş, taş havada; ardından elde yeni taş. Telefonda görülmedi.

**Sonraki öneri:** Günün dalgası 5. dilim (7. gün arşiv karesi) ya da taşın dördüncü dilimi
(varil/dükkân kaynağı).

### 2026-10-24 (16) — Günün Dalgası dördüncü dilim: seri koruma ("dünü kurtar")

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; önceki tur
kostüm kalıntı turlarını kapatıp oynanış maddelerini öne aldı, birikimin başı günün dalgası.
Seri tek kaçırılan günde sıfırlanıyordu: 13 günlük seriyi bir gün unutan oyuncu 14. gün
ödülünü (200) ve rozetini kaybedip "baştan" uyarısını görüyordu — mobilde en çok bırakma
anlarından biri.

**Oyuncu ne hissedecek:** Yalnız dünü kaçırdıysa menüde rozet `SERİ KOPTU (6 GÜN) · dünü kurtar`
der, altında piksel `DÜNÜ KURTAR · 80 coin` düğmesi çıkar. Basınca coin düşer, rozet hemen
`SERİ 6 GÜN · 7. günde +100 coin`a döner; bugün dalgayı temizlerse seri 7 olur. Coin yetmezse
düğme kapalı görünür (hedef olarak).

**Yapılanlar:**
- `DailyWave.RESCUE_COST/RESCUE_COOLDOWN`, `rescue_available`, `yesterday`.
- `Save.daily_rescue_day` (yeni alan, eski kayıtta boş), `can_rescue_daily`, `rescue_daily`:
  coin düşer, `daily_clear_day` düne çekilir, seri sayısı artmaz (kaçırılan gün sayılmaz,
  yalnız köprü). Bugünün puanlı denemesi kullanıldıysa kurtarma yok (boşa coin harcatmasın).
- `main_menu.gd`: `StreakRescue` düğmesi rozetin altında; kurtarınca sayfalar `_rebuild()` ile
  yeniden kurulur (coin ve rozet anında güncellenir).

**Sayılar (hipotez):** 80 coin = bir günlük tamamlama (60) + üçte biri: bedava değil ama
14. gün (200) ve sonrasındaki her 7 günlük 100'lük ödülün altında, uzun seriyi korumak kârlı.
Yalnız 1 gün boşluk (2+ gün kaçıran zaten "geri dönen oyuncu", suçlama yok) ve 7 günde bir:
alışkanlığın yerine geçmesin. İnsan testinde kurtarma oranı çok yüksekse maliyet 100'e.

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: dün hesabı + yıl sınırı,
kurtarma koşulları, bekleme süresi, coin yetmezliği, kayıttan okuma, kurtarılan serinin bugün
7'ye çıkıp 100 ödül vermesi, denenmiş günde kurtarma yok, menüde kapalı/açık düğme ve basınca
rozetin canlı seriye dönmesi, eski kayıtta alan boş); `campaign_smoke.gd` çıkış 0;
`dtm_gaps` PASS; `costumes` PASS; bot Bölüm 1 CLEARED (76,9 sn; bölüm sistemleri değişmedi,
yalnız menü + kayıt).

**Görsel kanıt:** 1280×720 pencereli görüntü, kurtarma öncesi (rozet + düğme, coin 140) ve
sonrası (coin 60, altın seri rozeti, düğme yok): piksel düğme, taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Kaldırım taşı üçüncü dilim (elde görünür taş + fırlatma sayfası) — birikimde
oynanışa en çok değer katan madde; ardından günün dalgası 5. dilim (arşiv karesi).

### 2026-10-24 (15) — Bıçağın son kareleri de kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; birikimin başı
bıçaktaki son işaret boşluklarıydı. Ölçünce `knife_walk` 5–7'de bele inen bıçağın orta gri
kenarındaki 7–23 piksel **pantolon** işaretli çıktı (Vapurcu/Kızıl Dağ'da bıçakta mavi lekeler),
`knife_attack2` 0'da omuz üstündeki bıçağın tamamı (59 px) ceket rengine boyanıyordu.

**Oyuncu ne hissedecek:** Bıçakla yürürken ve ikinci savuruşun hazırlığında bıçak hep çelik gri;
kostüm rengi yalnız giyside.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` `KNIFE_POLYS`: bileşen kuralının kaçırdığı dört karede elle çizilmiş
  bıçak çokgeni (yürüyüş 5–7'de ağız + iki küçük uç parçası, `attack2` 0'da ağız + kabza ucu);
  işaret çokgendeki giysi pikselleri. RGB değişmedi (doğrulandı), yalnız alfa; yalnız bu iki
  sayfa değişti.
- `tests/costumes.gd`: dört karede bıçak kutusunda en az silah işareti ve ≤ 1 pantolon pikseli.

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 (77,8 sn), 13 (77,5 sn), 25 (85,6 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, Kızıl Dağ ve Vapurcu × dört kare: bıçaklar gri,
kırmızı/mavi leke yok.

**Sonraki öneri:** Kostüm görsel kalıntı turları burada kapanmalı. Birikimin yeni başı pantolon
maskesi kalıntıları (2–4 px, düşük etki); ondan önce oynanış maddeleri (günün dalgası 4. dilim,
kaldırım taşı fırlatma sayfası) daha çok değer katar — birikim sırası buna göre değiştirildi.

### 2026-10-24 (14) — Şarjör değiştirirken de silah kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritası ve P1 ilk dilimleri bitti; birikimin başı silah işaretinin
üçüncü dilimiydi. Ölçünce şarjör değiştirme karelerinde tüfeğin ve tabancanın tamamı (ve
yere düşen şarjör) ceket rengine, tüfeğin bir kısmı (1169 px) pantolon rengine boyanıyordu.
Cephane bitince her seferinde oynayan animasyon olduğu için kostümün en görünür kalan kusuruydu.

**Oyuncu ne hissedecek:** Kızıl Dağ ya da Vapurcu giyerken şarjör değiştirmek tüfeği bir
anlığına kırmızı/lacivert yapmıyor; silah ve şarjör hep siyah-gri metal.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` `RELOADS`: silah karede döndüğü ve şarjör elden ayrıldığı için
  ilk kareden taşıma işe yaramıyor; her karenin elle çizilmiş çokgeni var (tabanca 1. karede
  düşen şarjör ayrı parça). Kare kare aynı bileşen kuralı; bileşen silahın yarısından azını
  bulursa (gövde önünde kontur ceketle birleşik) o parça çokgenin kendisi.
- İşaret: `pistol_reload` 192–364 px/kare, `rifle_reload` 1066–1574 px/kare (3. kare yalnız
  elde şarjör: 280 px). RGB değişmedi (doğrulandı), yalnız alfa; araç diğer sayfalarda aynı sonucu
  üretiyor (git farkı yok).
- `tests/costumes.gd`: şarjör sayfalarında kare başına alt/üst sınır (tabanca 150–450,
  tüfek 200–1800; üst sınır ceketin işarete karışmadığını gösterir).

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0; bot Bölüm 1 (80,9 sn), 13 (80,7 sn), 25 (86,6 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, Vapurcu ve Kızıl Dağ × iki şarjör sayfasının 8
karesi: silahlar ve düşen şarjör her karede gri; kostüm rengi yalnız ceket/pantolonda.

**Sonraki öneri:** Birikimin yeni başı pantolon maskesi kalıntıları (tekmede diz arkası) ya da
bıçağın kalan iki karesi; ikisi de küçük. Görsel kalıntı turları doygunluğa yaklaştı, sonraki
turlarda oynanış maddelerine (günün dalgası 4. dilim, kaldırım taşı fırlatma sayfası) geçilmeli.

### 2026-10-24 (13) — Yakın silahlar da kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritası ve P1 ilk dilimleri bitti; birikimin başı silah işaretinin ikinci
dilimiydi. Ölçünce kostümlü oyuncunun en sık gördüğü yakın silah kareleri bozuktu: sopa
savuruş izi ve bıçak ağzının kenarı pantolon rengine (Vapurcu'da lacivert iz), anahtar çenesi
ve şemsiye ucunun koyu çelik tonları ceket rengine boyanıyordu (sayfa başına 80–1700 px).

**Oyuncu ne hissedecek:** Hangi kostümle olursa olsun sopa ahşap, anahtar kırmızı-çelik,
şemsiye bordo, bıçak ve savuruş izi gümüş okunur; kostüm rengi yalnız giyside.

**Yapılanlar:**
- `tools/gen_weapon_mask.py` yakın silah bölümü (çokgen yok, savuruşta silah dönüyor):
  sopa = `bat_*` ile `anahtar_*` sayfalarının RGB farkı (anahtar sopadan türetildiği için
  fark tam olarak sopa + iz); anahtar/şemsiye = aynı fark + `gen_pixel_weapons.py`
  rampalarıyla birebir aynı renkler (çıplak sayfalarda ≤ 2 px, yani güvenli). Bıçak renkle
  ayrılmıyor (b−r dağılımı ceketle aynı); ağız ve iz açık gri olduğundan, açık bileşenlerin
  (≥ 10 px, ayakkabı hizası y < 200 üstünde) 2 px yakınında, en az yarısı ağza değen küçük
  (≤ 150 px) giysi bileşenleri işaretlenir. 60 px sınırı ağzın üst kenarını (62 px) kaçırdı,
  150'ye çıkarıldı; ceket/pantolon parçaları yüzlerce piksel.
- 16 sayfa işaretlendi: sopa/şemsiye 2,6k–5,5k, anahtar 2,8k–5,9k, bıçak 106–860 px/sayfa.
  Shader değişmedi (kod 3 zaten boyanmıyor), yalnız yorumu güncellendi.
- `tests/costumes.gd`: yakın silah sayfalarında toplam işaret alt sınırı + kare başına üst
  sınır (ceket/pantolon işarete karışmasın: sopa ≤ 1000, bıçak ≤ 400).

**Testler:** `--import` hata yok; `costumes` (genişletildi) PASS, `dtm_gaps` PASS;
`campaign_smoke.gd` çıkış 0 (36 sahne); bot Bölüm 1 (75,4 sn), 13 (80,7 sn), 25 (80,8 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü, kırmızı ceket + lacivert pantolon kostümüyle
bıçak saldırısı, sopa saldırısı 2, anahtar yürüme, şemsiye saldırısı: silahlar ve izler
kendi renginde; kostüm rengine geçen silah pikseli görülmedi.

**Sonraki öneri:** Pantolon maskesi kalıntıları (tekmede diz arkası, koşuda ayakkabı arkası)
ya da şarjör değiştirme karelerinin silah işareti.

### 2026-10-24 (12) — Ateşli silahlar kostüm rengine boyanmıyor

**Neden şimdi:** Yol haritasında açık madde yok, P1'lerin ilk dilimleri oyunda; birikimin başı
buydu. Ölçünce en görünür kısım tüfek ve tabancaydı: shader'ın giysi eşiği (doygunluk < 0,25)
koyu gri metali de giysi sayıyor, Kızıl Dağ kostümüyle kırmızı, Vapurcu ile lacivert tüfek
çıkıyordu. Ateşli silah alınınca her karede elde göründüğü için kostümün en çok bozulduğu yer.

**Oyuncu ne hissedecek:** Hangi kostümü giyerse giysin tabanca/tüfek silah gibi okunur
(siyah-gri metal); kostüm rengi yalnız ceket ve pantolonda kalır.

**Yapılanlar:**
- Önce otomatik ayrım denendi ve atıldı: renk tonu ayırmıyor (aynı tüfek bir karede nötr,
  ötekinde ceket kadar sıcak, r−b dağılımları örtüşüyor), kalınlık da ayırmıyor (morfolojik
  açma r=5 sopa ve tüfek gövdesini de gövde sayıyor).
- `tools/gen_weapon_mask.py` (yeni): her sayfanın ilk karesinde silah elle çizilmiş çokgen;
  diğer karelere RGB+alfa şablon eşleştirmesiyle kaydırılarak taşınır (±26 px). Giysi
  pikselleri 4-komşulu bileşenlere ayrılır, pikselinin ≥ %60'ı çokgende olan bileşen silahtır
  (piksel art konturu silahı koldan ayırdığı için sınırı kontur çizer). Silah ceketle tek
  bileşen olduğunda (tüfek gövde önünde: `rifle_idle`/`rifle_walk`, nişanda omza dayanan
  dipçik, iki tekil kare) çokgenin kendisi kullanılır. İşaret alfa 252 = kod 3 (pantolon 1,
  saç bitleri çift; çakışmaz, saç ve pantolon araçları bu değere dokunmuyor).
- 8 sayfa / 46 kare: `pistol_{aim,idle,shoot,walk}` kare başına 140–327 px, `rifle_{aim,idle,
  shoot,walk}` 833–1492 px.
- `shaders/player_costume.gdshader`: kod 3 boyanmaz. `tests/costumes.gd` `_weapon_mask`:
  her karede silah işareti (tabanca ≥ 100, tüfek ≥ 600 px), `idle` sayfasında hiç yok.

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`, `costumes`
(genişletildi), `costume_accessory`, `costume_badge` PASS; bot Bölüm 1 (83,5 sn), 13 (77,4 sn),
25 (80,8 sn) CLEARED.

**Görsel kanıt:** 1280×720 pencereli görüntü (kızıl/vapurcu/hamal × tüfek nişan, yürüme,
ateş, tabanca nişan, bekleme): silahlar her kostümde gri; ilk geçişte kırmızı kalan dipçik
ayrı parçayla düzeltildi. Çokgen sınırında ceket üzerinde 1–2 px gri kalıntı olabilir.

**Sonraki öneri:** Silah işaretinin ikinci dilimi (şarjör değiştirme kareleri + yakın
silahlar; bıçak ağzı şu an pantolon rengine boyanıyor).

### 2026-10-24 (11) — Pantolon maskesindeki kaçaklar giderildi

**Neden şimdi:** Yol haritası ve P1 maddelerinin ilk dilimleri bitti; birikimin başı bu
kusurdu. Önce/sonra görselleştirmesinde (ceket mor, pantolon camgöbeği) koşu karelerinin
üçünde ceketin parlak fermuar/etek yamaları pantolon rengine geçiyor (bir karede 387 px),
gölgedeki arka bacak ise ceket renginde kalıyordu; kostümlü koşu en çok görülen kare
olduğu için oyuncunun kostümü "lekeli" görünüyordu.

**Oyuncu ne hissedecek:** Vapurcu/Kızıl Dağ gibi kostümlerde ceket tek parça renk, pantolon
koşarken de tek parça; ayakkabının gri gölgesi artık ceket rengine boyanmıyor.

**Yapılanlar:**
- `tools/gen_costume_mask.py`: parlaklık eşiği tek başına yetmiyordu (siyah deri ceketin
  parlak yamaları kot kadar açık). Ölçünce asıl ayırt edici doku çıktı: 7×7 pencerede
  çok koyu (≤ 22) giysi pikseli oranı ceket derisinde ~0,4–0,8, kotta (gölgedeki arka bacak
  dahil) ~0–0,1. Aday = yerel ortalama ≥ 26 **ve** koyu oran ≤ 0,2 (eski: ortalama ≥ 36).
  Pantolona değen < 25 px giysi kırıntıları ve ayakkabıya 2 px yakın açık gri (≥ 90)
  gölge pantolona katılır. İşaretli piksel 756 797 → 735 791; yalnız alfa 254/255 değişti
  (RGB ve saç bitleri aynen, doğrulandı).
- İşaretçili watershed (ayakkabı/el tohumları) de denendi; ceket arkasına taşıyordu, atıldı.
- `tests/costumes.gd`: koşu ve yürüme karelerinde gövdenin üst %45'inde ≤ 10 pantolon
  pikseli ve alt dörtte birin ≥ %68'i pantolon (eski maske ikisinde de düşüyordu).

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`, `costumes`
(genişletildi), `costume_accessory`, `costume_badge` PASS; bot Bölüm 1 (85,8 sn), 13 (76,0 sn), 25 (86,5 sn) CLEARED.

**Görsel kanıt:** 38 sayfanın mor/camgöbeği önizlemesi ve 1280×720 pencereli oyun içi
görüntü (vapurcu + kızıl, koşu 4 kare + tekme 2 kare): ceket ve pantolon temiz ayrılıyor.
Kalan 2–4 px kalıntı ve silahların ceket rengine boyanması birikime yazıldı.

**Sonraki öneri:** Birikimin yeni başı: kostüm shader'ının sopa/tüfek gibi koyu gri
silahları ceket rengine boyaması.

### 2026-10-24 (10) — Bıçak savuruşunda şapkanın üstündeki tutamlar

**Neden şimdi:** Yol haritasında açık madde yok, P1 maddelerinin hepsinin ilk dilimleri
oyunda; birikimin başı bu kusurdu. Ölçünce sorun notta sanılandan büyük çıktı: bu karede
sivri tutamlar neredeyse siyah çizildiği için doygun saç maskesine girmiyor, bıçak izi
tutamların dibinden geçtiği için de baştan kopuk duruyor; iz ile tek parça olunca **ön
parça** sayılıp şapkanın ÖNÜNE çiziliyordu (kaptan şapkasında yalnız 2 piksel gizliydi).

**Oyuncu ne hissedecek:** Başlıklı kostümle bıçak sallarken saç şapkayı delmiyor; şapka
silüeti diğer karelerle aynı, savuruş izi şapkanın üstünden geçmeye devam ediyor.

**Yapılanlar:**
- `tools/gen_costume_accessory.py` `_tufts()`: baş lekesine HAIR_REACH (8 px) içinde
  yaklaşan, 40–400 px boyunda, çoğu sıcak koyu (r − b ≥ 6, en parlak kanal < 70) ayrı
  koyu leke saç tutamıdır. `front_mask` bunu başa katar (ön parça olmaz); `hair_over_hat`
  bunları korumadan çıkarır, izle karışan gri-kahve kenarlarını (3 px, < 160) ve tutam
  yanında kalan < 8 px görünür kırıntıları da gizler.
- İlk deneme (baştan koyu pikseller boyunca geodezik büyüme) sopa/anahtar/şemsiye
  karelerinde el ve sopanın ön parçasını yiyordu (bat_attack2/0: 178 → 0 px); ikinci
  denemede 40 px alt sınır yokken kol kıvrımı kırıntıları tutam sayılıp kolu şapkanın
  arkasına atıyordu. Son hâlde 236 hücrenin ön parça/işaret sayılarını önce/sonra
  karşılaştırdım: **yalnız `knife_attack/4` değişiyor** (ön parça 525 → 126 px; gizli
  tutam vapurcu 2 → 396, hamal 8 → 309, kahveci 62 → 535 px).
- `tests/costume_accessory.gd`: bıçak karesinde kaptan şapkası bitli > 300 piksel.

**Testler:** `--import` hata yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costumes` PASS; bot Bölüm 1 (95,3 sn), 13 (78,7 sn),
25 (80,2 sn) CLEARED.

**Görsel kanıt:** Araç önce/sonra önizlemesi (3 başlık, 3× büyütme) ve 1280×720 pencereli
oyun içi görüntü (üç kostüm, `knife_attack` 4. kare): tırtıklı tutamlar gitti, iz duruyor;
şapka üstünde 1 piksellik koyu nokta kaldı (birikimde).

**Sonraki öneri:** Pantolon maskesindeki kaçaklar (birikimin yeni başı).

### 2026-10-24 (9) — Şapkanın üstünden taşan saç gizlendi

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı "başlık ön katmanı gece
konturu" denetimiydi. 1280×720 pencereli görüntüde (dört başlık × sopa/şemsiye/anahtar
saldırı ve bekleme kareleri, gece konturu açık, 5× büyütme) ön parçanın konturu SORUNSUZ
çıktı: rig'in konturu rig'in saydam piksellerinde, ön parça yalnız opak silah/el
piksellerini taşıdığı için konturu örtmüyor; kesik kenar başlığın içinde kalıyor. Aynı
görüntüde asıl kusur görüldü: başlık saç tepesinin 16 px altına oturduğu için sivri saç
tutamları kaptan şapkasının ve kasketin tepesinden dışarı taşıyor, gece konturu bunları
şapkanın üstünde tırtıklı bir hâle olarak çiziyordu (saç şapkayı delmiş gibi; gündüz de
koyu kırıntı olarak görünüyordu).

**Oyuncu ne hissedecek:** Kasket, bere ve kaptan şapkası başın üstünde temiz bir silüet;
gece fener konturu şapkanın düzgün kenarını izler. Sopa/eller şapkanın üstüne çıktığında
kesilmez. Bandana saçı örtmediği için değişmedi.

**Yapılanlar:**
- `tools/gen_costume_accessory.py` 1c: her hücrede her taç başlık için başlığın sütun
  sütun tepe çizgisinin üstünde kalan baş pikselleri (saç lekesi, `HAIR_REACH` = 8 px
  içindeki koyu tutam/kontur pikselleri; ten hariç) sayfa alfasına bit olarak gömülür:
  alfa = 255 − 2·bit (vapurcu 1, hamal 2, kahveci 4; pantolon işareti 254 tek sayı,
  çakışmaz). Baş dışındaki ≥ 60 px parçalar (el, silah) saç olmayan pikseller boyunca
  baş bölgesine doğru büyütülerek korunur (ilk denemede sopanın şapkaya yakın ucu
  kırpılıyordu). Başlığın önüne çizilen ön parçalar (`front_mask`) ve 2 px kenarları da
  korunur (yoksa şapka üstünde silah/kol konturu siliniyordu). 38 sayfada 31 949
  piksel/bit; araç idempotent (eski işaretleri siler, ön parçaları işaretsiz keser).
  Çapa ve ön parça çıktıları değişmedi.
- `player_costume.gdshader`: `hair_bit`; kendi bitini taşıyan piksel saydam sayılır,
  konturda da (kontur yeni silüeti, yani şapkanın kenarını izler). Pantolon ayrımı
  artık kodla (`255 − alfa == 1`).
- `CostumeAccessory.HAIR_BITS` / `hair_bit()`, `Shop.costume_material` bunu malzemeye
  yazar. Malzemesiz (varsayılan) çizimde işaretli saç alfası ≥ 241/255, fark edilmez.
- `tests/costume_accessory.gd`: malzemelerde doğru bit, bandanada 0; koşu sayfasında üç
  başlığın da işareti var ve hepsi başlık tepesinin üstünde.
- Eşikler (8 px erişim, 60 px koruma) önce/sonra önizlemesiyle seçildi: 2 px erişimde
  koyu tutamlar kalıyordu, korumasız sopa ucu kırpılıyordu.

**Testler:** `--import` SCRIPT/SHADER ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`
PASS; `costume_accessory` (genişletildi), `costumes`, `costume_badge`,
`new_melee_weapons`, `kaldirim_tasi`, `dark_rim_scope` PASS; bot Bölüm 1 (80,7 sn),
3 (gece, 67,7 sn), 13 (81,7 sn), 25 (95,8 sn) CLEARED.

**Görsel kanıt:** Araç önce/sonra önizlemesi (3 başlık × 12 kare) ve 1280×720 pencereli
oyun içi gece konturlu görüntü: kaptan şapkası ve kasketin tepesindeki tırtıklı hâle
gitti, kontur şapka kenarını izliyor; sopa/şemsiye/eller kesilmedi.

**Sonraki öneri:** Birikimin yeni başı: bıçak savuruşu karesindeki kalan tutamlar (küçük),
ardından pantolon maskesindeki kaçaklar.

### 2026-10-24 (8) — Gece konturu bölüm kapsamında

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. `main.gd` bölüm
değiştirirken eskisini `queue_free` edip yenisini aynı karede ekliyor; düşman konturu
ertelenmiş kurulduğu için o karede ağaçta iki bölüm var ve `get_first_node_in_group`
eski bölümü döndürüyordu. Test bunu doğruladı: gece bölümünden (ör. 12, 19) sonra gelen
gündüz bölümünün düşmanları fener konturuyla doğuyordu; gece→gece geçişte de eski
bölümün kenar ışığı alınıyordu.

**Oyuncu ne hissedecek:** Gündüz bölümünde düşman silüeti gündüz gibi temiz; turuncu
gece hâlesi yalnız gece bölümlerinde. Bölüm sırasına göre "bazen parlayan" düşman yok.

**Yapılanlar:**
- `Level.dark_scene_of(n)`: düğümün ata zincirindeki bölümü bulur; bölüm gündüzse null.
  Bölüm dışındaki düğümde (test/önizleme) ağaçta TEK gece bölümü varsa onu kabul eder.
- `enemy_base._apply_dark_rim` ve `one_way_platform.draw_dark_edge` bu yardımcıyı
  kullanıyor (iskele kenar ışığı da aynı geçiş karesinde yanlış bölüme bakabiliyordu).
- `tests/dark_rim_scope.gd`: main.gd'nin değişimini taklit eder (eskiyi queue_free +
  yeniyi aynı karede ekle) — gece→gündüz kontursuz, gündüz→gece konturlu, gece→gece
  yeni bölümün rengi, bölüm dışı düğüm kuralları. Eski kodla 2 denetim düşüyor.
- Görsel kanıt ekran görüntüsü yerine deterministik testle: değişiklik kontur
  görünümünü değil hangi bölüme bakıldığını etkiliyor.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`dark_rim_scope` PASS; bot Bölüm 1 (80,8 sn), 3 (gece, 66,6 sn), 13 (77,6 sn),
20 (geceden sonraki gündüz, 92,0 sn), 25 (86,4 sn) CLEARED.

**Sonraki öneri:** Başlık ön katmanının gece konturu denetimi (birikimin yeni başı).

### 2026-10-24 (7) — Başlığın önünden geçen kol ve silah

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Başlıklı kostümle sopa/
şemsiye/anahtarın baş üstü savuruşunda (ikinci vuruş ve hazırlık kareleri) şapka eli ve
silahı örtüyordu: oyuncu vuruşun hangi karede tepeye kalktığını göremiyor, silah şapkanın
içinden çıkıyormuş gibi okunuyordu. Ayrıca sopalı bir karede sopa ahşabı saç sanıldığı
için başlık başın 45 px üstünde havada asılı kalıyordu.

**Oyuncu ne hissedecek:** Kasketle sopayı tepeye kaldırınca eller ve sopa şapkanın önünde;
şapka başta kalır, savuruşun tepe noktası okunur. Kostüm boyası kolda da sürer.

**Yapılanlar:**
- `tools/gen_costume_accessory.py`: saç maskesine doygunluk eşiği (> 0,46; saç ≥ ~0,52,
  sopa ahşabı ≤ ~0,41 ölçüldü) — `bat_attack2` 0. karede çapa 15→54. Yeni "ön parça"
  çıktısı: her hücrede dört başlığın birleşik izdüşümüne düşen, başa (saç lekesi + ona
  değen yüz ten lekesi, delikler dolu, 4 px genişletilmiş) ait olmayan, ≥ 30 px opak
  bölgeler `costume_acc/head_front.png` atlasına kesilir; tablo `head_anchors.json`
  `front` alanında. 236 hücreden 40'ında parça var (sopa/şemsiye/anahtar saldırı,
  bekleme ve yürüme kareleri, bıçak savuruş izi).
- `CostumeAccessory`: ön parçayı rig'in çocuğu olarak başlıktan SONRA ekler (üstte),
  aynı çapa/aynalama hesabıyla yerleştirir; malzeme rig'in kostüm malzemesinin
  kontursuz kopyası. Parçası olmayan karede gizli; başlık çıkınca silinir.
- `tests/costume_accessory.gd`: sopalı karede çapa doğrulaması, ön parçanın başlığın
  üstünde/hizalı/aynalı, kostüm boyalı-kontursuz ve parçasız karede gizli olması.
- Eşikler (0,46 doygunluk, 30 px, 4 px) önizleme sayfasında elle seçildi: 12 px / 2 px
  ile saç tutamı uçları şapkanın üstüne leke olarak çıkıyordu.

**Görsel kanıt:** Araç önizlemesi (kasket/kaptan, 8 silah sayfası) ve 1280×720 pencereli
oyun içi görüntü (kasketle `bat_attack2` 0/1/7, `bat_attack` 7, `bat_walk` 3): sopa ve
eller şapkanın önünde, şapka başta.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costumes`, `costume_badge`, `kaldirim_tasi`,
`new_melee_weapons` PASS; bot Bölüm 1 (83,2 sn), 13 (81,8 sn), 25 (80,8 sn) CLEARED.

**Sonraki öneri:** Gece geçişinde düşman konturu denetimi (birikimin yeni başı).

### 2026-10-24 (6) — Gece bölümlerinde kostüm başlığına fener konturu

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Kitap 1'in yarısı gece
(Bölüm 3, 4, 6, 7, 8…); başlıklı kostümde gövde fener ışığıyla konturlanırken başlık
konturuz kalıyor, gövdenin kontur çizgisi de şapkanın altından saça doğru görünüyordu.

**Oyuncu ne hissedecek:** Gece pazarında kaptan şapkası, bere, kasket gövdeyle aynı
sıcak kontur içinde; karakter tek parça silüet olarak okunur, başlık "yapıştırılmış"
görünmez.

**Yapılanlar:**
- `dark_rim.gdshader`: `rim_only` (yalnız kontur, gövde saydam). `CostumeAccessory`
  rig'in malzemesinden gece konturunu okur (`rig_rim`: kostüm `rim_enabled` ya da
  `night_rim`), açıksa başlık dokusunun kontur kopyasını rig'in kardeşi olarak
  `show_behind_parent` ile ARKAYA çizer: yalnız silüetin dışına taşan kenar parlar,
  şapkanın saça bindiği alt kenarda kontur yüze binmez. Başlık çıkınca kopya da silinir.
- **Önceden var olan hata düzeltildi:** `main.gd` eski bölümü yenisi eklendikten sonra
  siler; eski bölümün `_exit_tree`'si yeni gece bölümünün açtığı oyuncu konturunu
  kapatıyordu (kostümsüzde malzemeyi bile siliyordu). Kontur yalnız menüden doğrudan
  girişte görünüyordu; bölüm geçişinde ve TEKRAR'da kayboluyordu. `_owns_night_rim()`:
  yalnız gece olan ve ağaçta başka gece bölümü kalmamış bölüm konturu kapatır.
- `tests/costume_accessory.gd`: gece konturu açılınca kopya arkada/hizalı/aynı doku ve
  renkte, kapanınca gizli, başlık çıkınca silinmiş denetimleri. Kayıt formatı değişmedi.

**Görsel kanıt:** Bölüm 3 (gece) 1280×720 pencereli, vapurcu kostümü, ara sahne
geçildikten sonra 5× büyütme; önce/sonra karşılaştırıldı.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS;
`costume_accessory` (genişletildi), `costume_badge` PASS; bot Bölüm 1 (79,0 sn), 3 (gece,
63,4 sn), 13 (77,2 sn), 25 (86,5 sn) CLEARED.

**Sonraki öneri:** Birikimdeki başlık kol-önü kareleri ya da gece geçişinde düşman konturu
denetimi.

### 2026-10-24 (5) — Sonuç kartında "giyili" kostüm künyesi

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Bir önceki turda
duraklat menüsüne eklenen rozetin eşi: bölüm sonucunu okuyan oyuncu o koşuyu hangi
bonusla oynadığını da görsün (ör. HASARSIZ yıldızı VAPURCU'nun +10 canıyla alındı).

**Oyuncu ne hissedecek:** Sonuç kartının hemen altında tek satırlık piksel künye:
başlık ikonu + `GİYİLİ: HAMAL · SİLAH ÖMRÜ +%15`. Sokak ceketinde künye yok.

**Yapılanlar:**
- `hud.gd`: `_build_costume_badge()` / `_refresh_costume_badge()`; künye kartın
  dışında (kart alt kenarı +258..318), `panel_hud` piksel çerçeve, piksel yazı tipi,
  her `_reveal`'da yenilenir. Kart içine konmadı: oyun sonu istatistiği masaüstünde
  7 satıra çıkıyor, iç boşluk değişken. Metin ve ikon `Shop` tek kaynağından.
- Önceden kalan taşma: "Yeni vuruş mağazada!" ipucu kartın sağ çerçevesine
  biniyordu; `R — devam` olarak kısaltıldı.
- `tests/costume_badge.gd`: HUD sonuç kartında görünürlük/bonus/ikon ve sokak
  ceketinde gizlilik denetimi eklendi. Kayıt formatı değişmedi.

**Testler:** `--import` SCRIPT ERROR yok; `campaign_smoke.gd` çıkış 0; `dtm_gaps`
PASS; `costume_badge` (genişletildi), `level_stars`, `touch_polish` PASS; bot Bölüm 1
(80,7 sn), 13 (80,9 sn), 25 (85,4 sn) CLEARED. 1280×720 pencereli görüntüde vapurcu ve
hamal künyesi incelendi: ilk hâlde bonus yazısı çerçeveye değiyordu ve ad ile bonus
bitişikti; iç pay 20'ye çıkarıldı, araya `·` kondu.

**Sonraki öneri:** Başlık katmanı eksikleri (gece kontur, kolun önünden geçtiği kareler).

### 2026-10-24 (4) — Duraklat menüsünde "giyili" kostüm rozeti

**Neden şimdi:** Yol haritası ve P1 sırası bitti; birikimin başı. Kostüm bonusu (can,
yumruk, silah ömrü, yiyecek) sahada hiçbir yerde yazmıyordu; oyuncu 240 coin verdiği
KIZIL DAĞ'ın ne kazandırdığını mağazaya dönmeden hatırlayamıyordu. Küçük, okunurluğu
doğrudan artıran iş.

**Oyuncu ne hissedecek:** Duraklatınca menünün başında HUD çerçeveli küçük bir rozet:
kostümün piksel başlığı + `GİYİLİ: VAPURCU` + altın `CAN +10`. Bonussuz sokak ceketinde
rozet yok (menü eskisi gibi).

**Yapılanlar:**
- `Shop.costume_bonus_text(id)`: `bonus` sözlüğünden kısa metin (`CAN +10`,
  `SİLAH ÖMRÜ +%15`, `YİYECEK +%25`, `YUMRUK +%8`); sayılar tek kaynaktan.
- `PauseMenu`: `Costume` rozeti (`panel_hud` piksel çerçeve, başlık ikonu 1x NEAREST),
  her açılışta `refresh_costume()`. Kayıt formatı değişmedi.

**Testler:** `--import` SCRIPT ERROR yok; yeni `tests/costume_badge.tscn` PASS (dört bonus
metni, varsayılanda gizli, kızıl dağda ad/bonus/ikon); `touch_polish` PASS;
`campaign_smoke.gd` çıkış 0; `dtm_gaps` PASS; bot Bölüm 1 CLEARED (80,3 sn). 1280×720
pencereli görüntüde hamal/kızıl/vapurcu rozeti incelendi: ilk denemede `kart` çerçevesinin
kırmızı başlık şeridi yazıyla çakışıyordu, `panel_hud`'a geçildi; bandana çerçeveye
değiyordu, iç pay 22'ye çıkarıldı.

**Sonraki öneri:** Başlık katmanı eksikleri (gece kontur, kolun önünden geçtiği kareler)
ya da günün dalgası dördüncü dilim.

### 2026-10-24 (3) — Kostümlerin üçüncü dilimi: piksel başlıklar

**Neden şimdi:** Yol haritası ve OYNANIS-KALITE P1 sırası (1–7) bitti; birikimin başı.
Kostümler yalnız giysi paletini değiştiriyordu: siluet aynıydı, oyun ölçeğinde (0,6) ve
kalabalık arenada kostüm "renk farkı" olarak kalıyordu. DTM'de kıyafetin ilk okunan
yeri baş/şapkadır.

**Oyuncu ne hissedecek:** Satın aldığı kostüm sahada uzaktan tanınır: VAPURCU beyaz
tepeli kaptan şapkası (altın çapa rozetli), HAMAL haki yün bere, KAHVECİ tüvit kasket,
KIZIL DAĞ alında kırmızı bandana (arkada düğüm ve sarkan uçlar). Başlık her karede başla
birlikte oynar, sola dönünce aynalanır; mağaza önizlemesinde, ana menüde ve ara
sahnelerde de görünür.

**Yapılanlar:**
- `tools/gen_costume_accessory.py`: 38 sayfanın 236 hücresinde baş çapası `[cx, top,
  brow]` (saç = doygun koyu kahve, ten = doygun açık turuncu; en büyük saç lekesi baş,
  tek sivri tutam tepeyi yukarı çekmesin diye ≥4 piksellik ilk satır) →
  `assets/anim/redmount/head_anchors.json`. Dört başlık 72×44, sayfalarla aynı piksel
  yoğunluğunda (1 sanat pikseli = 1 hücre pikseli), palet + 4 ton gölge + kontur →
  `assets/anim/costume_acc/*.png`. Araç tekrar çalıştırılabilir.
- `CostumeAccessory` (Sprite2D): AnimatedSprite2D'ye çocuk; o anki AtlasTexture'ın
  sayfa/hücresinden çapayı okur (sopa varyantları gibi kodla eklenen animasyonlar da
  çalışır), dönüş/eğim/ölçek/modülasyon ebeveynden gelir. `apply(sprite, id)` tek giriş:
  `Redmount.apply_costume`, ana menü, ara sahne. Mağaza önizlemesine `TextureRect` başlık;
  önizleme bölgesi başlığa yer açmak için 12 px yukarı uzatıldı.
- `Shop.COSTUMES`: `accessory` + `attach` ("crown"/"brow"). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Başlık saç tepesinin 16 px altına oturur (saç ~20 px kabarık; tepe
örter, yanlardan kıvırcık saç taşar — karakterin saçı korunur); bandana alın çizgisinin
2 px üstünde. Başlıklar ~54 px genişlik: saç lekesiyle aynı, siluete en fazla siper kadar
(~15 px) ekler.

**Testler:** `--import` SCRIPT ERROR yok; yeni `tests/costume_accessory.tscn` PASS (dört
başlık dokusu, oyuncunun bütün animasyon karelerinde makul çapa, rig'de baş hizası ve
sola dönünce aynalama, kostüm değişince değişme / sokak ceketinde çıkma, mağazada 4
başlıklı önizleme); `tests/costumes.tscn` PASS; `survival_mode` OK; `campaign_smoke.gd`
çıkış 0; `dtm_gaps` PASS; bot Bölüm 1 CLEARED (82,9 sn), Bölüm 13 (80,8), Bölüm 25 (90,8) —
oyuncu rig'i ortak olduğu için üç bölüm. 1280×720 pencereli görüntüde 4 kostüm × 5 poz
(idle/koşu/kombo/aynalı tekme/zıplama) oyun ölçeğinde ve 1,5x, ayrıca mağaza sekmesi
incelendi; taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Pantolon maskesi kaçakları ya da günün dalgası dördüncü dilim (arşiv
karesi ödülü, seri koruma); kostüm bonusunun duraklat menüsünde hatırlatılması küçük iş.

### 2026-10-24 (2) — Yeni silahların ikinci dilimi: kaldırım taşı ve tam cephanelik

**Neden şimdi:** OYNANIS-KALITE P1 sırasında "yeni yakın silahlar" maddesinin kalanı açıktı
(fırlatılabilir silah + duraklat cephaneliğinde yeni silahlar yok). Tüfekli muhafız gibi
menzilli düşmana karşı oyuncunun yakın dövüşten başka cevabı yalnız tabancaydı; DTM'deki
"yerden bir şey kapıp fırlat" kararı eksikti.

**Oyuncu ne hissedecek:** Bölüm 2'nin alt sokağında tüfekliden önce sökük kaldırım
yığını: üç taş, L ile kısa bir yay çizerek fırlatılır, ağır vurur ve düşmanı iter; taşlar
bitince el boşalır. Duraklat menüsünde artık Anahtar, Şemsiye ve Taş da satılır; her
kartın kuşanma notu silahın tek ayırt edici özelliğini söyler.

**Yapılanlar:**
- `GunConfig` "Fırlatma" grubu: `ammo_label`, `projectile_gravity`, `throw_lift`,
  `projectile_scene`, `fire_sfx` (eski `.tres`'ler varsayılanla okunur). Yeni ateş/fırlatma
  sistemi yazılmadı: taş bir GunConfig (`kaldirim_tasi.tres`, şarjör 1 + yedek 2; "yeniden
  doldurma" yerden yeni taş almak).
- `Projectile.arc_gravity` (Area2D'nin kendi `gravity` özelliğiyle çakışmasın diye bu ad):
  yay + dönüş; zemine çarpınca toz ve tok ses. `spawn()` artık mermiyi döndürür ve isteğe
  bağlı sahne alır; düşman çağrıları değişmedi.
- Sanat (`tools/gen_pixel_weapons.py main_tas`): 48 px üç taşlık yığın ikonu, 12×10 uçan
  bazalt taş (oyunda 2x NEAREST, `scenes/systems/TasMermi.tscn`). Yüz gibi okunan ilk
  çatlak deseni değiştirildi.
- HUD: fırlatılan silahta `TAŞ 3` / `Taş: 3` (toplam adet), ateşli silahta eskisi gibi
  `MERMİ m/r`. `ammo_changed` sinyaline `label` eklendi.
- Cephanelik tek kaynak: `PauseMenu.ARMORY` (kimlik, ad, fiyat, kaynak, not); Main ve
  Survival aynı listeyi ve `armory_equip` kullanır (Survival'daki çift `knife` dalı ve
  "Kuşanıldı: Anahtar" gibi ham kimlikli mesaj gitti).

**Sayılar (hipotez):** Taş hasarı 22 (sopa 16, anahtar 20): üç atışla sınırlı ve nişan
istiyor. Hız 760, kaldırış 0,35, yerçekimi 1100 → yayın tepesi ~29 px, aynı yükseklikte
~330 px menzil: ayaktaki düşmana yol boyunca isabet eder, ekranın yarısını aşmaz. Geri
itme 360 (tüfekliyi siperinden düşürecek kadar). Fiyatlar: taş 15 (en ucuz, tek
kullanımlık), şemsiye 25, anahtar 30 (bölüm dükkânından ucuz, çünkü yalnız bu can için).

**Testler:** `--import` SCRIPT ERROR yok; `tests/kaldirim_tasi.tscn` PASS (yeni: kaynak
değerleri, pickup/ikon, 9 kartlı tek kaynak cephanelik, Bölüm 2 yığını, 15 coin alım, HUD,
yay + 260 px'teki düşmana isabet, üç atıştan sonra el boşalır); `campaign_smoke.gd` çıkış 0;
`dtm_gaps` PASS; `survival_mode`, `new_melee_weapons`, `daily_wave`, `costumes` PASS;
bot Bölüm 2 CLEARED (70,9 sn), Bölüm 1 (81,0), Bölüm 13 (80,5), Bölüm 25 (85,9) — ortak
mermi/HUD/cephanelik değiştiği için dört bölüm. 1280×720 pencereli görüntüde yığın, uçan
taş ve 9 kartlı cephanelik incelendi; taşma yok. Telefonda görülmedi.

**Sonraki öneri:** Kostüm aksesuar katmanı (birikimin başı) ya da kaldırım taşı için gerçek
fırlatma sayfası.

### 2026-10-24 — Kostümlerin ikinci dilimi: ceket ve pantolon ayrı renk

**Neden şimdi:** Yol haritası ve P1 listesi bitti; birikimin başı. Kostümler tek rampayla
boyandığı için VAPURCU baştan ayağa lacivert, KIZIL DAĞ baştan ayağa kırmızı bir tulum
gibi duruyordu; giysi değil "renk filtresi" okunuyordu. 240 coin'lik hedefin kıyafet gibi
görünmesi gerekiyor.

**Oyuncu ne hissedecek:** Kostüm giyince ceket rengini alır, pantolon ayrı ve daha sakin
bir tonda kalır (lacivert ceket + füme pantolon, kızıl ceket + kömür pantolon); mağaza
önizlemesi ve oyundaki karakter aynı.

**Yapılanlar:**
- `tools/gen_costume_mask.py`: her 200×240 karede pantolon piksellerinin alfasını 255→254
  yapar (RGB'ye dokunmaz; kostümsüz çizimde fark yok). Ayrım: giysi gri pikselinin 7×7
  yerel ortalaması ≥ 36 (ceket ~30, pantolon ~45), büyük beyaz lekeden (ayakkabı ≥ 30 px;
  fermuar parıltısı elenir) başlayıp adaylar boyunca en fazla 60 adım (bacak boyu) büyüme,
  sonra kıvrım/kontur deliklerinin kapatılması. 38 sayfanın tamamı işlendi; araç tekrar
  çalıştırılabilir.
- `player_costume.gdshader`: `pants_shade`/`pants_light`; alfa < 0,998 olan giysi pikseli
  ikinci rampaya, alfa 1'e. `Shop.COSTUMES` dört kostüme pantolon rampası; alan yoksa
  ceket rampası kullanılır (eski veri bozulmaz). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Eşik 36 / 60 adım, kopya sayfalarda 3 denemeyle seçildi: 40 arka
bacağı kaybediyor, 74 adım koşuda ceket eteğine taşıyordu. Pantolon rampalarının koyu
ucu ceketinkine yakın: maskenin kaçırdığı gölgeli bacak pikseli gölge gibi okunur.

**Testler:** `--import` hatasız; `tests/costumes.tscn` PASS (yeni: idle karesinde bacakta
>1000 işaretli piksel, baş/omuzda 0; malzemede pantolon rampası); `tests/campaign_smoke.gd`
çıkış 0; `tests/dtm_gaps.tscn` PASS; bot Bölüm 1 CLEARED (80,4 sn), Bölüm 13 CLEARED (81,7 sn), Bölüm 25 CLEARED (103,4 sn) — ortak oyuncu sayfaları değiştiği için üç bölüm. 1280×720 pencereli görüntüde 5
kostüm × 4 poz (idle/koşu/tekme/kombo) incelendi: ayrım net, kızılda tekme dizinde
birkaç kırmızı piksel kalıyor (birikime yazıldı). Telefonda görülmedi.

**Sonraki öneri:** Kostüm aksesuar katmanı ya da günün dalgası dördüncü dilim (arşiv
karesi ödülü, seri koruma).

### 2026-10-23 (9) — Günün Dalgası üçüncü dilim: eşit kural rotasyonu, "seri koptu" uyarısı

**Neden şimdi:** Yol haritası ve P1 listesi bitti; birikimin en üstündeki madde. Kural
`randi_range` ile tohumdan seçiliyordu: 365 günde bazı kurallar ~50, bazıları ~30 kez
çıkıyor, aynı kural art arda iki gün gelebiliyordu (dün SOPA GÜNÜ, bugün yine SOPA GÜNÜ
"günlük" hissini öldürür). Seri koptuğunda ise rozet sessizce kayboluyordu — oyuncu
neyi kaybettiğini ve geri dönebileceğini görmüyordu.

**Oyuncu ne hissedecek:** Her gün bir öncekinden farklı kural; 9 günde 9 kuralın hepsi
bir kez. Bir günü kaçıran oyuncu menüde seri rozetinin yerinde ateş renginde
`SERİ KOPTU (6 GÜN) · yeniden başla` görür; bugün temizleyince rozet seri 1 ile altına döner.

**Yapılanlar:**
- `DailyWave.rule_index`: günler 9'luk bloklara bölünür, her blokta kurallar tohumlu
  Fisher–Yates ile karışık sırada birer kez; blok sınırında önceki bloğun son kuralı
  tekrar gelirse ilk ikisi takas edilir. Dalga dizisi hâlâ tarih tohumundan.
- `DailyWave.streak_broken` + `BROKEN_NOTICE_DAYS = 7`; menüde aynı piksel panelde
  uyarı (`StreakBadge`). Kayıt formatı değişmedi.

**Sayılar (hipotez):** Uyarı kopuştan sonra 7 gün gösterilir: haftalık oynayan oyuncuya
hatırlatma, aylarca sonra dönen oyuncuya suçlama yok. Rotasyonla aynı kural en erken
2, en geç 17 gün sonra döner. Kural değişimi aynı tarihe eski sürümden farklı plan
verir (sunucu yok, sorun değil).

**Testler:** `--import` hatasız; `tests/daily_wave.tscn` PASS (yeni: bir yılda kural
sayıları arasında en fazla 2 fark, art arda tekrar 0, blokta her kural bir kez, kopuş sınırları, menüde
canlı/kopan/boş seri rozeti); `tests/campaign_smoke.gd` çıkış 0; `tests/dtm_gaps.tscn`
PASS; bot Bölüm 1 CLEARED (82,0 sn; ortak sistem değişmedi, yalnız menü + günlük kip).
1280×720 ekran görüntüsünde uyarı rozeti kontrol edildi (ilk metin panelin sağ kenarına
değiyordu, kısaltıldı). Telefonda görülmedi.

**Sonraki öneri:** Birikimin başı kostümlerin ikinci dilimi (ceket/pantolon ayrı rampa +
küçük piksel aksesuar).

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
