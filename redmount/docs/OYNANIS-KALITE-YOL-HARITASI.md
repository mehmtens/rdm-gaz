# REDMOUNT — Oynanış Kalitesi ve Tamamlama Yol Haritası

**Tarih:** 30 Eylül 2026  
**Ürün hedefi:** Mobil oyun olarak çıkış; gerçek telefon oynanışı ana kabul ölçütü.  
**Kapsam:** `redmount/` içindeki 3 kitap, 36 bölümlük Godot kampanyasının mobil sürümü. `mobile/` tek bölümlük prototip, dokunmatik kontrol ve sunum için teknik referanstır.  
**Amaç:** Bölümlerin yalnızca tamamlanabilir olmasıyla yetinmeyip hareketi, dövüşü, seviye ritmini ve dokunmatik kontrolü telefonda keyifli, okunabilir ve tutarlı hâle getirmek. Dan the Man bir tür/tempo referansıdır; REDMOUNT'un karakteri, dünyası, görsel dili ve bölüm fikirleri özgün kalır.

> Bu belge yapılmış işleri yeniden “tamamlandı” saymaz. Kod ve kayıtlar üzerinden görülen durum ile insan oyuncu testinde doğrulanması gereken kalite ayrı tutulur. Hedef sayılar **önerilen kabul eşikleridir**; ilk testlerden sonra gerçek verilere göre güncellenir.

**İlk uygulama durumu (30 Eylül 2026):** `redmount/` ana oyununa dokunmatik düğmeler, mobil yönlendirme metinleri, duraklatma/ölüm/bölüm sonucu dokunmatik akışı ve yatay ekran ayarı eklendi. `OYNA_MOBIL.cmd` artık bu ana oyunun masaüstü dokunmatik önizlemesini açıyor. Eş zamanlı iki dokunma, duraklatma, TEKRAR ve SONRAKİ testi geçti; 36 sahne smoke testi geçti. **Android paketi, gerçek telefon oynanışı ve performans kapısı açık:** bu makinede Android SDK/ADB ve Godot 4.7 dışa aktarma şablonları bulunamadı; telefon kanıtı oluşmadı.

## 23 Ekim 2026 — karşılaştırma sonrası entegrasyon durumu

Dan the Man ile hedeflenen fark, REDMOUNT'un kendi karakter ve İstanbul kimliğini korurken **telefonda ilk bakışta anlaşılır hareket, okunur dövüş, tutarlı piksel sunum ve kısa sürede ödül veren bölüm ritmi** kurmasıdır. Aşağıdaki satırlar kod, proje ayarı ve depodaki görüntülerle görülen durumdur; telefonda ölçülmüş kalite iddiası değildir.

| Alan | Bu turda ana oyuna işlenen | Hâlâ eksik / kabul kanıtı |
|---|---|---|
| İki başparmak kontrolü | Düğmeler ekran yüksekliğine göre ölçekleniyor; çentik ve alt güvenli alan hesaba katılıyor. Görünmeyen eylemin basılı durumu bırakılıyor; sonuç düğmesi son bölümde `BAŞTAN` oluyor. | Üç gerçek cihazda hareket + zıplama + saldırı, parmak kaydırma, yanlış basma ve el yorgunluğu videosu. Oyuncunun düğme yerini/ölçeğini ayarlaması henüz yok. |
| Arka plan ve duraklatma | Oyun odağı kaybolunca eylemler bırakılıyor ve oynanış duraklatılıyor; Survival da aynı akışı kullanıyor. | Çağrı, ekran kilidi ve uygulama değiştirme sonrası çoklu dokunma ile dönüş testi. |
| HUD ve boss | Mobilde ilk bölüm paneli küçüldü; diğer bölümlerde bilgi sola toplandı, uzun etiketler kısaldı. Boss canı alt eylem düğmelerinin üzerinden üst sağa taşındı ve genişliği HUD alanına uyuyor. Bölüm değişiminde ilk bölüme özel portre gizleniyor. | 16:9, 19.5:9, 20:9 cihazlarda boss, altyazı, mağaza, HUD, sonuç ve kontrol çakışması; metin taşması. |
| Kamera | Mobilde yatay bakış payı 64'ten 88 piksele çıktı; koşarken öndeki engel için biraz daha alan gösteriliyor. | Her bölümde iniş noktası, çukur ve menzilli saldırının görülmesi; gerektiğinde bölüm bazlı kamera sınırı/zoom düzeltmesi. |
| Kayıt ve sonuç | C rütbesinin ilk kayıtta atlanması düzeltildi; yazma hatası artık günlükte görünür. Eski kayıtlarla uyum için `KOŞU REKORU` metriği koşu toplamı olarak kaldı; sonuç ekranı bölümde kazanılan ve toplam skoru ayırıyor. | Eski kayıtla yükseltme, bozuk dosya, yazma kesintisi ve gerçek koşu sonunda skor/coin/rütbe doğrulaması. Gelecekte bölüm rekoru istenirse sürümlü ayrı kayıt alanı gerekir. |
| Görsel dil | Kodda yeni resim/animasyon üretilmedi. Depodaki `screenshots/showcase-01-vazo-giris.png` görselinde ayrıntılı arka plan ve karaktere karşı büyük, düz gri ön plan blokları dikkat çekiyor; `_showcase/menu.png` eski menü sürümüdür. | Güncel sürümden aynı anda oyun/menü/duraklatma/sonuç ekranı yakalanıp palet, kontur, ölçek, ışık ve hiyerarşi kararı verilmeli. Eski ekran görüntüsü güncel kusurun kesin kanıtı sayılmaz. |
| Dövüş ve seviye ritmi | Mevcut kombo, hitstop, sarsıntı, düşman uyarısı, kontrol noktası ve gizli alan altyapısı korunuyor. Bu turda his veya düşman sayıları veri olmadan yeniden ayarlanmadı. | İlk 10 dakikanın oyuncu videosunda isabet/hasar nedenini anlama, ölüm nedeni, tekrar süresi ve düğme yorgunluğu; sonra 36 bölümün bölüm bölüm ritim/tekrar denetimi. |

**Doğrulama durumu:** `git diff --check` temiz. Godot 4.7 komut satırı bu ortamda hem ana oyun hem `mobile/` için sahne açılırken aynı signal 11 çökmesini veriyor; bu değişikliklerin çalıştığına dair test sonucu değildir. `build/redmount-debug.apk` bu değişikliklerden önce oluşturulmuştur. Cihaz ve oynanış kabulü açık kalır.

**Sıradaki uygulama dilimi:** Önce Godot açılış çökmesini ve güncel Android paketini çöz; ardından tek bir Bölüm 1 telefon kaydı al. Kayıtta görülen kontrol/HUD kusurunu düzeltip aynı kesiti yeniden oyna. Bundan sonra hareket/dövüş his ayarı, ön planın görsel dili ve 36 bölümün ritim denetimi sırayla ilerler.

### 23 Ekim — ikinci kod ve görüntü denetimi

Referansın [Halfbrick tanıtımı](https://www.halfbrick.com/games/dan-the-man) hızlı dövüş, platform ve yoğun bölümleri öne çıkarıyor. Bu karşılaştırmada özellik sayısı yerine ilk temas, saldırı okunurluğu ve sahne başına karar çeşitliliği ölçülecek.

| Öncelik | Kanıtlanan yapı / gözlem | Oyuncu riski ve sonraki karar |
|---|---|---|
| P0 — sinematik giriş | `main.gd` dokunmatik düğmeleri sinematikte normal oynanış modunda tutuyordu; `cutscene.gd` yalnız `ESC` ile atlama metni gösteriyordu. Bu turda sinematik modu, `DEVAM` ve `ATLA` düğmeleri ve atlamanın duraklat menüsüne gitmeyen yolu eklendi. | Gerçek telefonda açılış sahnesini ilerletme, atlama ve tekrar deneme sırasında menü/oyun girdisi çakışması doğrulanmalı. |
| P0 — ilk oynanabilir ana kadar süre | Bölüm 1 açılışında 21 sıralı replik var. `Cutscene.say()` içindeki varsayılan süre ve özel beklemelerin toplamı yaklaşık **68 saniye**; hareket/kamera beklemeleri bunun dışındadır. Oyuncu `DEVAM` ile repliği ilerletebilir veya `ATLA` ile sahneyi geçebilir. | Yeni oyuncunun ilk kontrolü ne zaman aldığı ve atlamayı kendiliğinden keşfedip keşfetmediği kaydedilmeli. Uzun bulunursa hikâye bilgisini koruyarak ilk oynanabilir parçayı öne çekmek veya sahneyi iki kısa parçaya bölmek P0 tasarım kararıdır. |
| P0 — ilk 30 saniye | Önceden x=150'de gizli duvar ve x=640'ta kayma tekmesi anlatılıyordu; açılış oyuncuyu x=470'e bırakınca gizli duvar ipucu ana yolun gerisinde kalıyordu. Bu turda x=560 hareket, x=720 temel `VUR`, x=1120 zıplama ipuçları eklendi; kayma tekmesi x=2300'e taşındı. Mobil kayma etiketindeki var olmayan `KOŞ` düğmesi `YÖN` olarak düzeltildi. İlk düşmanlar x=820 ve 960. | Düğme adları gerçek ekranda okunuyor mu, ilk iki ipucu art arda yük bindiriyor mu ve oyuncu saldırıyı yardım almadan yapabiliyor mu telefonda ölçülmeli. Gizli duvar ipucu, geri keşif için x=150'de kaldı. İpuçları eklendi diye öğretim tamamlanmış sayılmaz. |
| P1 — erken ritim | Bölüm 1 ve 2'de ikişer, Bölüm 3'te bir kilitli arena var; beşinin de üçer dalgası bulunuyor. `battle_arena.gd` sonraki dalgayı efektle doğuruyor, ekranda `1/3` gibi ilerleme bilgisi yok. | İlk üç bölümde 15 dalga oyuncuya tekrar gibi gelebilir. Video üzerinde arena başına süre/ölüm ve “kaç dalga kaldı?” beklentisi ölçülsün; sonra dalga sayısı veya ara ödül düzenlensin. |
| P1 — oturum boyu | Bölüm 1 bitişi x=8650; Kitap 2 ve 3'ün ilk bölümleri x=110700/110900, son bölümleri x=286800/270500. Eski final bot koşusu 1096 saniye (18:16); insan ve mobil süresi bilinmiyor. | Uzunluk tek başına hata değildir; telefonda ara verme, geri dönme ve uzun düz geçişler ölçülmeli. Gerekirse bölümü kısaltmadan bölüm içi kısa hedef/ödül veya güvenli devam noktası düzenlenmeli. |
| P1 — görsel birlik | 24 Eylül tarihli `screenshots/level01-ingame-04-dolmus.png` ayrıntılı, resimsel araç/çevre ile büyük pikselli karakter/kutu/zemini yan yana gösteriyor; `level01-ingame-02-bufe-dis.png` büfenin çevreye göre daha düz renk blokları taşıdığını gösteriyor. | Güncel ekran kaydıyla doğrulandıktan sonra tek hedef palet, kontur kalınlığı, malzeme dokusu ve ışık yönü seçilmeli. Önce ilk bölümün giriş/büfe/arena/son sahnesi; ardından ortak atlaslar düzeltilmeli. |
| P1 — mobil menüler | `MainMenu`, `ShopMenu` ve `PauseMenu` sabit kenar payları ve minimum kart genişlikleri kullanıyor; güvenli alan hesabı şu an oyun HUD'u ile kontrol katmanında var. | Çentikli ve farklı oranlı telefonlarda menü, mağaza ve duraklatma için ekran görüntüsü alınmalı. Kesilen kart/sekme varsa tek ortak güvenli alan konteyneri ve dar ekran yerleşimi yapılmalı. |
| P1 — bitişik dokunma alanları | `TouchControls.BUTTONS` merkezleri ve `CircleShape2D` yarıçaplarıyla 1280×720 temel görünümde sol/sağ hareket alanları arasında yaklaşık 3,3, `ZIPLA`/`VUR` arasında yaklaşık 1 sanal piksel kalıyor. Görünür diskler arasındaki boşluk, gerçek dokunma şekillerinden daha büyük. | Bu sayılar fiziksel piksel veya dp değildir; cihaz ölçeğiyle değişir. Oyuncunun parmağını sağ/sol arasında kaydırırken ve zıplama+saldırı yaparken yanlış tetikleme sayısı ölçülsün; tekrarlanırsa merkezler ve çarpışma yarıçapı birlikte ayarlansın. |
| P1 — saldırı okunurluğu | `EnemyConfig` varsayılan yakın vuruş hazırlığı 0,32 sn, tüfek nişanı 0,4 sn. `EnemyBase` saldırı başında `!` efekti çıkarıyor; isabet sesi, sarsıntı ve kısa duraklama mevcut. | İşaretin küçük ekranda ve ayrıntılı arka planda fark edilip edilmediği, ilk hasarın nedeni ve eşzamanlı düşmanlar insan testinde gözlenmeli. Veriden sonra uyarı süresi, efekt kontrastı veya ses ayarlanmalı. |
| P1 — gerçek paket ve kare süresi | Kaynak klasördeki büyük PNG/WAV dosyaları tek başına Android paket boyutunu veya çalışma belleğini göstermez; ses ithalinde `compress/mode=2` kullanılıyor. 19 Ekim tarihli `build/redmount-debug.apk` yaklaşık 257 MB ve bu değişikliklerden eski. | Güncel **release** APK/AAB boyutu, üç hedef cihazda ilk açılış/sahne yükleme ve kalabalık arena kare süresi, bellek ve ısınma ölçülmeli. Darboğaz görülmeden kaliteyi düşüren toplu sıkıştırma yapılmamalı. |
| P2 — kontrol tercihleri | `TouchControls` düğmeleri ekran yüksekliğine göre ölçekliyor, ancak kullanıcı yerleşimi veya büyüklüğü ayarlayamıyor. Ana menü ayarlarında ana ses ve kayıt sıfırlama var. `Combat.rumble()` mobil titreşimi zaten destekliyor; ayarlarda aç/kapat seçeneği yok. | İlk 5 oyuncunun başparmak erişimi ve yanlış basma kayıtları toplanmalı. Tekrarlayan sorun varsa düğme boyutu/konumu ve titreşim seçeneği eklenmeli; varsayılan düzen önce testle iyileştirilmeli. |

**Bu turun kapsam sınırı:** Görüntüler 24 Eylül tarihli; 23 Ekim kodunun ekran çıktısı değildir. İlk üç bölümdeki arena ve ipucu sayıları koddan kesindir; sıkıcılık, zorluk ve estetik etki oyuncu gözlemi gerektirir. 68 saniye, repliklerin koddan hesaplanan otomatik bekleme toplamıdır; gerçek sahne ve oyuncunun replik geçme süresi değildir. Öncelik sırası: sinematik kontrol/süre testi → ilk 10 dakika öğretimi → mobil menü/HUD kadrajı → dövüş ve arena ritmi → ortak görsel üretim kuralı. Uygulamalı ölçüm formu `docs/INSAN-TESTI.md` içindedir.

### 23 Ekim — üçüncü denetim: Dan the Man'e göre özellik boşlukları

Karşılaştırma, Dan the Man'in herkese açık oynanış yapısına (hikâye modu, savaş/survival modu, beceri satın alma, kostümler, silah çeşitliliği, gizli alanlar, boss evreleri) göre yapıldı; kod tarafı `redmount/scripts` ve `resources` taramasından gelir. Amaç özellik kopyalamak değil, **oyuncunun DTM'de alıştığı karar ve ödül döngülerinden hangilerinin bizde hiç olmadığını** görmektir.

**Zaten karşılığı olanlar (yeniden yapılmayacak):** koşu/zıplama/duvar/dash/çömelme (`redmount.gd`); üçlü kombo, aparkat, dash vuruşu, havadan yere çakma ve **düşman yakalayıp fırlatma** (`_try_throw`); sopa/bıçak/tabanca/tüfek (`resources/weapons`); 4 güçlendirme (çift hasar, görünmezlik, kalkan, hız); zırh; kilitli üç dalgalı arenalar; kırılabilir nesne/duvar, çöken/hareketli platform, ezici, alev, düşen saksı, kopuk kablo; kontrol noktası; bölüm içi mağaza; gizli alan → Kanıt Arşivi; S/A… rütbe; Survival (10 dalgada bir boss); boss öfke evresi; minibüs kovalamacası.

| Öncelik | DTM'de oyuncunun alıştığı | REDMOUNT'ta kodda görülen | Eksik ve en küçük çözüm |
|---|---|---|---|
| P1 — düşmandan silah düşmesi | Silahlı düşman yenilince silahını bırakır; oyuncu sopa/kılıç/silahı düşmandan kapar, dövüş sürekli değişir. | `scripts/enemies/*` içinde hiçbir düşman `WeaponPickup`/`GunPickup` bırakmıyor; silahlar yalnız sahneye elle konmuş nesnelerden geliyor. | Bıçaklı/tüfekli/bombacı düşman ölünce kendi silahını düşürsün (düşük dayanıklılıkla). Mevcut pickup sahneleri yeniden kullanılır; yeni sistem gerekmez. Dövüş tekrarını en ucuz kıran madde. |
| P1 — silah çeşitliliği | Çok sayıda yakın/menzilli silah; her birinin farklı hızı, menzili, özel vuruşu. | 4 silah tanımı (2 yakın, 2 ateşli). | İstanbul'a özgü 3–4 yakın silah (ör. boru anahtarı, kepçe/kürek, kaldırım taşı fırlatma, şemsiye) `WeaponConfig` ile; her biri tek ayırt edici özellik (menzil, delme, fırlatılabilir). Piksel art şartı geçerli. |
| P1 — arena ilerleme göstergesi | Savaş alanında kaç dalga/düşman kaldığı belli. | `battle_arena.gd` 3 dalga tutuyor, HUD'a `1/3` yazmıyor (ikinci denetimde de not edildi). | HUD'da piksel "DALGA 2/3" + kalan düşman sayısı. Kodu küçük, oyuncu belirsizliğini doğrudan azaltır. |
| P1 — bölüm içi yıldız/hedef | Her bölümde toplanacak/kurtarılacak sabit sayıda hedef; menüde bölüm başına doluluk görülür, tekrar oynama sebebi olur. | `Save.secrets` ve rütbe var; bölüm seçiminde rütbe/gizli sayısının görünürlüğü ve "%100" hedefi zayıf. | Bölüm kartında rütbe + `gizli 2/3` + en iyi süre; üçünü tamamlayana küçük kalıcı ödül (coin/arşiv karesi). Yeni içerik değil, mevcut veriyi görünür kılmak. |
| P1 — kostüm / görünüm | Kostümler hem kozmetik hem küçük bonus; coin harcamanın ana hedefi. | `costume`/`skin` sistemi yok; mağazada 5 hamle + 7 kademe yükseltme var, hepsi bitince coin'in harcanacağı yer kalmıyor. | 4–6 piksel kıyafet (aynı rig, palet değişimi + küçük aksesuar) ve her birine tek küçük bonus. Coin ekonomisine uzun vadeli hedef verir. Önce palet takası; yeni animasyon seti gerekmez. |
| P1 — tekrar oynanan kısa mod | Günlük meydan okuma / özel kurallı kısa bölümler; birkaç dakikalık mobil oturuma uygun. | Yalnız Survival var; `daily`/`challenge` yok. | Survival'a tohum tabanlı "günün dalgası" (tarihten tohum, tek deneme ödülü, çevrimdışı çalışır). Sunucu gerektirmez. |
| P1 — iyileşme yiyeceği ve kırılan nesne ödülü | Kutu/dolap kırınca yiyecek, coin, bazen silah çıkar; can yönetimi kısa döngüde ödüllenir. | `health_pickup.gd` ve `breakable_prop.gd` var; kırılan nesnenin ne düşüreceği bölüm bölüm tutarlı mı belirsiz. | Kırılabilir nesne tipine göre sabit düşürme tablosu (büfe tezgâhı → simit/döner, kasa → coin, alet dolabı → silah). Oyuncu "neyi kırmaya değer" öğrenir. |
| P2 — savunma/kaçınma | DTM'de blok yok ama yuvarlanma/kayma ile kaçış ve düşmanı sersemletme var. | Kayma tekmesi ve dash var; ayrı kaçınma i-frame'i belirsiz. | Önce insan testinde "kaçamadım" ölümü ölçülsün; çıkarsa dash'e kısa dokunulmazlık penceresi. Yeni düğme ekleme. |
| P2 — başarımlar | Görev/başarım listesi uzun vadeli hedef verir. | `achievement` yok. | 15–20 başarım (ör. "10 düşmanı fırlat", "Bölüm 5'i hasarsız"); ödül arşiv karesi/kostüm. Google Play Games entegrasyonu yayın aşamasına bırakılır. |
| P2 — oynanabilir ikinci karakter | Birden çok oynanabilir karakter, farklı hareket seti. | Tek oynanabilir karakter; Gazelle hikâye NPC'si. | Çıkış için şart değil. Kampanya bitince Survival'da Gazelle (aynı rig, farklı kombo) düşünülebilir; P0/P1 bitmeden başlanmaz. |
| P2 — çevrimiçi/ödeme | Reklam, uygulama içi satın alma, bulut kayıt, liderlik tablosu. | Hiçbiri yok; kayıt yerel `ConfigFile`. | Ticari model kararı verilmeden kod yazılmaz. Karar verilirse önce bulut kayıt (kayıp kayıt P0 riskini azaltır), sonra gerisi. |
| P2 — dil | Çok dilli arayüz. | Metinler doğrudan Türkçe kodda; `tr()`/çeviri dosyası yok. | Yalnız Türkiye dışı yayın hedefleniyorsa: metinleri `tr()`'ye taşı, İngilizce CSV. Piksel font Türkçe/İngilizce karakter kapsamı kontrol edilir. |

**23 Ekim uygulama durumu — ilk dört madde kodda:** (1) `BattleArena.wave_changed` → HUD üst ortada piksel çerçeveli `DALGA 2/3 · 4 DÜŞMAN`, arena bitince gizlenir. (2) `EnemyConfig.drop_scene/drop_chance`: Bıçaklı Ajan bıçak %60, Tüfekli Muhafız tüfek %40, Elit Muhafız tabanca %30, Sokak Eşkıyası sopa %12; bırakılan silah tam dayanıklılıkla gelir. (3) `BreakableProp.LOOT`: kasa → yiyecek %30, varil → cephane %35, sandık → sopa/bıçak %50; saksı/vazo/tüp yalnız coin; tasarımcının elle verdiği ödül varsa tablo devre dışı. (4) Bölüm kartında en iyi süre + `GİZLİ n/m` + rütbe; S + bütün gizli alanlar `%100` rozeti ve bölüm başına bir kez +50 coin (`Save.best_times`, `Save.mastered`). Kanıt: `tests/dtm_gaps.tscn` PASS, 36 sahne smoke PASS, Bölüm 1 bot koşusu CLEARED (83,7 sn). Olasılıklar insan testi verisiyle ayarlanacak; telefonda görülmedi.

**23 Ekim (5. madde, ilk dilim) — yeni yakın silahlar:** `WeaponConfig` iki ayırt edici alan kazandı (`guard_break`, `launch_speed`; eski `.tres`'ler varsayılanla okunur). **Boru Anahtarı** (`anahtar.tres`): 20 hasar, yavaş (0,24 sn hazırlık), 10 kullanım; blok duruşunu ve blok şansını deler, Kalkanlı Zabıta'nın kalkanını indirip tam hasar verir ("KALKAN DELİNDİ!"). **Şemsiye** (`semsiye.tres`): 10 hasar, uzun menzil (104 px), 16 kullanım; isabette düşmanı 320 hızla havaya kaldırır, hava dizine açık. Sanat `tools/gen_pixel_weapons.py` ile sopa sayfalarından türetildi (aynı gövde kareleri, silah yeniden boyandı, anahtara çene eklendi) + 48 px ikonlar; `PlayerSprite` sayfaları çalışma anında `SpriteFrames`'e ekler. Yerleşim elle: Bölüm 3 şemsiyeci tezgâhı (ilk ikiliden önce), Bölüm 4 kalkanlı tanıtımından önce anahtar; Bölüm 7 dükkânı ANAHTAR, Bölüm 14 dükkânı ŞEMSİYE; sandık ganimetine ikisi de eklendi. Ayrıca eski hata: sayfası olmayan `weapon_swing` eylemi bütün silah savuruşlarının ilk 0,18 sn'sini silahsız duruşla örtüyordu, düzeltildi. Kalan: kaldırım taşı (fırlatılabilir) silah, pause cephaneliğine yeni silahlar. Kanıt: `tests/new_melee_weapons.tscn` PASS.

**23 Ekim (6. madde, ilk dilim) — kostümler:** `Shop.COSTUMES` 5 kostüm: SOKAK ÇEKETİ (varsayılan, bedava), VAPURCU (lacivert, azami can +10, 120 coin, Bölüm 3), HAMAL (haki, silah dayanıklılığı +%15, 150, Bölüm 8), KAHVECİ (kahve tonu, yiyecek iyileştirmesi +%25, 180, Bölüm 14), KIZIL DAĞ (kızıl, yumruk +%8, 240, Bölüm 20). Yeni animasyon yok: `shaders/player_costume.gdshader` giysinin doygunluğu düşük koyu-gri piksellerini parlaklığına göre kostümün koyu→açık rampasına eşler; ten, saç, kontur ve beyaz ayakkabı korunur. Malzeme oyuncu rig'ine, ara sahne oyuncusuna ve ana menüdeki Redmount'a uygulanır; gece bölümlerinin konturu kostüm shader'ında açılır (`rim_enabled`). Mağazada üçüncü sekme KOSTÜMLER: kostümle boyanmış önizleme (oyundaki 0,6 ölçek), fiyat / kilit / GİY / GİYİLDİ; alınan kostüm hemen giyilir. Kayıt: `[shop] costume` (eski kayıtta varsayılan), sahiplik `purchased` içinde `costume_<id>`. **İkinci dilim (24 Ekim):** ceket ↔ pantolon ayrımı — pantolon pikselleri sayfalarda alfa 254 ile işaretli (`tools/gen_costume_mask.py`), shader ikinci rampayı (`pants_shade/pants_light`) kullanır. Kalan: aksesuar katmanı (şapka/atkı, ayrı küçük piksel sprite). Kanıt: `tests/costumes.tscn` PASS.

**23 Ekim (7. madde, ilk dilim) — günün dalgası:** Ana menüde SURVIVAL'ın yanında `GÜNÜN DALGASI` (deneme yapıldıysa `GÜNLÜK n/5`). `DailyWave` tarih dizgesinden FNV-1a tohumla (sürümler arası kararlı, sunucusuz) 6 kuraldan birini ve 5 dalgalık düşman dizisini seçer; 5. dalga Mini Boss + iki koruma. Kurallar tek şeyi değiştirir: SOPA GÜNÜ (sopayla başla, +1 düşman), ZIRHLI GİR (zırh, yarım iyileşme), SİMİT YOK (dalga arası can yok), ÇIPLAK EL (cephanelik kapalı), NİŞANCI GÜNÜ (tabanca + her dalgada tüfekli), PAZAR KALABALIĞI (+2 eşkıya, yalnız eşkıya/bıçaklı). Kural, mekân pankartıyla 5,5 sn gösterilir; üst ortada `DALGA n/5 · k DÜŞMAN`. Günün **ilk denemesi puanlı**: başladığı anda hak kullanılır (yarıda bırakmak tekrar deneme olmaz), dalga coin'i + bitirince +60 tamamlama ve ardışık gün serisi; sonraki denemeler antrenman (coin yazılmaz). Survival rekorunu etkilemez. Kayıt: `[daily] day/waves/clear_day/streak` (eski kayıtta boş). Kanıt: `tests/daily_wave.tscn` PASS. **İkinci dilim (23 Ekim):** seri ödülü (3→40, 7→100, 14→200, sonra her 7 günde 100 coin), ana menüde seri rozeti, 3 yeni kural (HIZLI ADIM, ERKEN PATRON, BIÇAK GÜNÜ); survival arenası piksel art'a çevrildi. Kalan: kural dağılımı eşitleme, arşiv karesi ödülü.

**Uygulama sırası önerisi (P1 içinde):** 1) arena `DALGA 2/3` göstergesi → 2) düşmandan silah düşmesi → 3) kırılabilir nesne düşürme tablosu → 4) bölüm kartında rütbe/gizli/süre + %100 ödülü → 5) yeni yakın silahlar → 6) kostümler → 7) günün dalgası. İlk dördü mevcut sistemlerin bağlanmasıdır ve dövüş tekrarını, belirsizliği ve tekrar oynama isteğini doğrudan etkiler; 5–7 yeni piksel art üretimi gerektirir. Hepsi Aşama 1 telefon kapısını bloklamaz ama Aşama 2 insan testinden önce ilk üçünün oyuna girmesi, testin "dövüş tekrarlı" bulgusunu daha anlamlı yapar.

**Kapsam sınırı:** DTM özellikleri herkese açık oyun bilgisinden özetlenmiştir; birebir sayı/değer iddiası değildir. "Yok" denen maddeler kod aramasıyla (`grep`) bulunamayanlardır; farklı adla yazılmış bir karşılık varsa satır düzeltilir.

## 1. Şu an elimizde ne var?

| Alan | Kodda veya kayıtta görülen durum | Henüz bilinmeyen |
|---|---|---|
| Kampanya | `scripts/systems/game_state.gd` içinde 36 sahne sıralı. `tests/campaign_smoke.gd` 36 sahneyi ve menüyü yüklemeyi denetliyor. | Her bölümün yeni bir oyuncu tarafından rahatça geçilip geçilemediği. |
| Hareket | `redmount.gd` ve `MovementConfig` içinde koşu, değişken zıplama, coyote time, jump buffer, dash, duvar kayması/zıplaması ve çömelme var. | Bu hareketlerin gerçek girişlerde ve telefonda güvenilir/hızlı hissedip hissettirmediği. |
| Dövüş | Üçlü kombo, ağır yumruk, hava saldırısı, silahlar, mermi, zırh, güçlendirmeler, hitstop ve ekran sarsıntısı var. `tests/move_progression.gd` bazı yükseltme etkileşimlerini denetliyor. | İsabet okunurluğu, kombo ritmi, saldırı iptali beklentisi, düşman adaleti ve uzun oturum yorgunluğu. |
| Bölüm akışı | Arenalar, kontrol noktaları, mağazalar, kırılabilir nesneler, gizli yollar, bosslar ve sonuç ekranı mevcut. | 36 bölüm boyunca bunların çeşitlilik ve ödül değerinin yeterli olup olmadığı. |
| Tam koşu kanıtı | Bölüm 1: `tests/level01_play_verified.log` **6:03**; Bölüm 2: `tests/level02_play_baseline.log` **4:23**; Bölüm 3: `tests/level03_play_baseline.log` **5:09**. Kitap 3 finali: `tests/book03_final_verified.log` **18:16**. Bunlar otomatik girdilerle alınmış sürelerdir. | İnsan oyuncu süreleri, duraksama/keşif ve gerçek zorlanma noktaları. Diğer bölümlerin aynı yöntemle güncel sürümde uçtan uca geçtiği ayrıca doğrulanmalı. |
| Görsel/ses | Piksel karakterler, mekân atlasları, müzik ve SFX mevcut. Ekran görüntülerinde zengin mekânlar görülüyor; önceki görsel incelemede bazı tekrarlar ve üslup farkları not edilmiş. | Hareket sırasında okunurluk, katman ayrımı, animasyon kalitesi ve ses miksinin bütün kampanyadaki tutarlılığı. |
| Mobil | `mobile/` ayrı, tek bölümlük prototip. 36 bölümlük `redmount/` ana kampanyasında dokunmatik kontrol ve mobil HUD akışı uygulanmış durumda. | Ana kampanyanın gerçek telefondaki kontrol, performans, ekran oranı, kayıt ve paketleme davranışı. Bunlar mobil çıkış için P0. |
| Kayıt/ekonomi | `Save` ConfigFile ile ilerleme, coin, skor, mağaza alımları ve ana ses düzeyini tutuyor. | Kayıt bozulması, sürüm yükseltmesi, satın alma dengesi ve uzun kampanyada para akışı. |

**Önemli ayrım:** Smoke test “sahne açılıyor” der. Otomatik oynama “belirli girdilerle bitişe ulaşılıyor” der. İnsan testi “oynamak anlaşılır ve eğlenceli” sorusuna yaklaşır. Gerçek cihaz testi ise dokunma, performans ve okunurluğu doğrular. Dördünün sonuçları birbirinin yerine yazılmayacak.

**Belgelerdeki tarih farkı:** `README.md` ve `3-DUNYA-KAMPANYA-TASARIMI.md` içinde eski 12 bölümlük veya “henüz uygulanmadı” ifadeleri bulunuyor. Güncel kampanya envanteri için `GameState.LEVELS`, sahneler ve güncel testler esas alınmalı. Bu yol haritasının ilk bakım işi, eski durum etiketlerini düzeltmektir.

## 2. Hedef oynanış: oyuncu ne hissetmeli?

1. **Hareket:** Karakter düğmeye basıldığı anda niyet edilen yöne gider; atlayış ve iniş tahmin edilebilir. Hata oyuncunun kararından kaynaklanır, girişin yutulmasından değil.
2. **Dövüş:** Oyuncu saldırısının neden tuttuğunu, kaçtığını veya bloklandığını görebilir. Her düşman karşılaşması aynı kombo tekrarına dönüşmez.
3. **Parkur:** Tehlike önceden okunur; kamera bir sonraki iniş noktasını gösterir. Kontrol noktası zor bölümü tekrar denerken zaman kaybını makul tutar.
4. **Ritim:** Hareket, çatışma, kısa nefes ve keşif art arda gelir. Uzun koridorlar ve aynı arena dalgaları yalnız süre doldurmaz.
5. **Ödül:** Gizli yol, zor platform ve isteğe bağlı dövüş somut bir karşılık verir; ana yol mağaza alışına mecbur bırakmaz.
6. **Dokunma:** İki başparmakla hareket ve eylem eş zamanlı yapılır; kontroller oyunu örtmez, yanlış basış ile kaçırılan basış açıkça ölçülür. Telefonda birkaç dakikalık oturumdan sonra devam etmek kolaydır.
7. **Kimlik:** İstanbul mekânları ve REDMOUNT karakterleri oyunun ayırt edici tarafı olur. Referans oyunun sahne, animasyon, karakter veya sesleri kopyalanmaz.

## 3. Başarıyı nasıl ölçeceğiz?

Her testte **oyun sürümü/commit**, telefon modeli/işletim sistemi, ekran oranı, kontrol yerleşimi, bölüm, oyuncu deneyimi, video, toplam süre, ölüm, tekrar deneme, satın alma, takılma noktası ve kısa yorum tutulur. PC bot sonuçları teknik regresyon için ayrı tutulur. Test eden kişiye “Dan the Man gibi mi?” diye yönlendirici soru sorulmaz; önce kendi sözcükleriyle anlatması istenir.

| Ölçüm | İlk önerilen eşik | Nasıl yorumlanacak? |
|---|---:|---|
| İlk 3 dakikada temel hareket ve saldırıyı yardımsız öğrenme | 5 yeni oyuncunun en az 4'ü | Başaramazsa önce kontrol/öğretici düzeltilir. |
| Bölüm 1'i dış yardım olmadan bitirme | 5 yeni oyuncunun en az 4'ü | Nerede ve neden kaldıkları videodan işaretlenir. |
| Giriş “basıldı ama olmadı” şikâyeti | Oyuncu başına en fazla 1 ciddi olay | Tekrarlanıyorsa seviye zorluğu artırılmaz; kontrol düzeltilir. |
| İki başparmakla eş zamanlı koşu + zıplama + saldırı | 5 mobil oyuncunun en az 4'ü yardım almadan | Eylem düğmesi çakışması ve kaybolan dokunma videoda işaretlenir. |
| HUD veya kontrolün kritik sahneyi kapatması | 0 kritik olay | Küçük ekran ve farklı oranlarda ayrıca bakılır. |
| Arka plana geçip oyuna dönünce kontrol/kayıt kaybı | 0 kritik olay | Çağrı, uygulama değiştirme ve ekran kilidiyle denenir. |
| Ana yoldaki görünmeyen/okunmayan ölüm | 0 | Çukur, mermi ve boss saldırısı kamera ve görsel uyarıyla anlaşılır olmalı. |
| Zorunlu mağaza alımı olmadan bölüm bitirme | Tüm ana yol | Test temiz kayıtla yapılır. |
| Kontrol noktasından aynı engeli yeniden deneme | Çoğu durumda 30–60 saniye içinde | Boss ve final gibi özel yerlerde ayrı değerlendirilir. |
| Normal bölüm süresi | İlk oyuncuda çoğunlukla 6–10 dk **tasarım hipotezi** | Otomatik bot süresine göre bölüm uzatılmaz; gerçek oyuncu verisi kullanılır. |
| Büyük final süresi | İlk oyuncuda yaklaşık 18–25 dk **tasarım hipotezi** | Finalin yaklaşık 18:16 bot kaydı insan süresini kanıtlamaz. |
| Çökme, kilit, kayıp kayıt, sonuç ekranı tutarsızlığı | 0 kritik olay | Yayın engeli. |

**Test grubu:** Önce ekip dışından 5 kişiyle gerçek telefonlarda Bölüm 1, 2, 3 ve bir geç kampanya örneği. İlk değişikliklerden sonra aynı kişiler değil, 5 yeni kişiyle tekrar. Farklı el/telefon boyutlarını içeren en az 3 cihaz kullanılır. Küçük örnek sonuçları yön gösterir; yüzdeler pazarlama iddiası olarak kullanılmaz.

## 4. İş sırası ve kapılar

| Aşama | Öncelik | Teslimat | Geçiş koşulu |
|---|---|---|---|
| 0 — Temel kayıt | P0 | Sabit sürüm, temiz kayıt, test formu ve ilk cihaz ölçümleri | Sorunlar aynı telefonda tekrar üretilebiliyor. |
| 1 — Mobil dikey kesit | P0 | `redmount/` Bölüm 1'in dokunmatik kontrolle gerçek telefonda çalışan paketi | Hareket, dövüş, duraklatma, kayıt ve dönüş çalışıyor. |
| 2 — Çekirdek his | P0 | İlk 10 dakikanın dokunma, hareket ve dövüş ayarı | 5 yeni mobil oyuncunun 4'ü temel akışı yardımsız oynuyor. |
| 3 — Bölüm tasarımı | P0 | 36 bölümün mobil oynanış denetimi ve sorunlu kesitlerin düzenlenmesi | Her ana yol cihazda ve otomatik testte tamamlanıyor. |
| 4 — Düşman/boss/ekonomi | P1 | Telefon ekranında adil karşılaşmalar, yükseltmeler, güvenli kayıt | Temiz kayıt ve yükseltmesiz ana yol geçiliyor. |
| 5 — Sunum, performans ve ses | P0/P1 | Küçük ekranda okunur sanat/UI, dengeli ses, hedef cihaz performansı | Yoğun sahneler hedef cihazda oynanabilir. |
| 6 — Mobil yayın adayı | P0 | Cihaz regresyonu, paket, dağıtım kontrolleri | Kritik hata yok; mobil kabul listesi imzalı. |

**P0:** Oyunu bitirmeyi, temel kontrolü veya güvenli kaydı engeller. **P1:** Eğlence, açıklık veya süreklilikte belirgin kayıp yaratır. **P2:** Cila; P0/P1 bitmeden büyük kapsamlı P2 yapılmaz. Her aşama için tek bir sorumlu, tarih ve kanıt bağlantısı iş panosunda tutulur.

### Aşama 0 — Kanıt tabanı ve tekrar üretilebilir test

- Çalışan Godot sürümünü, ana sahneyi, test komutlarını ve temiz kayıt yolunu `README.md` içinde güncelle. Kodun mevcut durumuyla çelişen eski 12 bölüm ifadelerini “tarihsel” diye işaretle veya kaldır.
- Mevcut değişiklikleri koruyarak bir başlangıç commit'i/sürüm etiketi oluştur; testler hangi sürüme ait açık olsun. Test dosyalarının timeout veya hata hâlini başarı saymadığını gözden geçir.
- 36 sahne smoke testi, Bölüm 1–3 tam otomatik koşu, final koşusu, kayıt/mağaza testi ve sonuç/epilog akışını aynı sürümde yeniden çalıştır. Önceki logları başlangıç kanıtı say, yeni çalıştırma gibi sunma.
- En az üç gerçek telefonu (küçük ekran, hedef orta sınıf, daha güçlü cihaz) kaydet; işletim sistemi, çözünürlük/oran ve ölçüm yöntemi belirle. İlk Android paketinin açılış, giriş, sahne geçişi ve kayıt durumunu belgeye işle. iOS da yayın hedefiyse aynı kapıları iPhone için ayrıca uygula.
- Bölüm başına tek satırlık denetim kaydı aç: süre, ölüm, tıkanma, zorunlu düşman, gizli alan, mağaza, kontrol noktası, görsel kusur, ses kusuru, test türü, son kontrol tarihi. Video üzerine zaman damgası koy.
- Sonuç ekranındaki süre/coin/düşman sayısını gerçek oynama sonucuyla karşılaştır. Önceki final ekran görüntüsünde `0:00` ve `0/27` görüldüğü için bu akış özellikle yeniden doğrulanmalı; eski görüntü güncel hata kanıtı sayılmaz.
- Headless kapanışında görülen ses kaynağı sızıntı uyarılarını tekrarlanabilir mi diye kontrol et. Gerçek çalışma sırasında artan bellek/çökme yaratıyorsa P0; yalnız test kapanışıysa P1.

**Bitti sayılma koşulu:** Her kritik bulgu için sürüm, yeniden üretim adımı, beklenen/gerçek sonuç ve video veya log var. “Test geçti” ifadesinde testin kapsamı yazıyor.

### Aşama 1 — Gerçek telefonda oynanabilir dikey kesit

**Ürün yönü sabit:** Oyunun çıkışı mobil olacak. 36 bölümlük `redmount/` kampanyası ana içerik kaynağı kabul edilir; `mobile/` içindeki tek bölümün dokunmatik kontrol fikirleri incelenir. İki projenin tamamı birleştirilmez. Önce `redmount/` Bölüm 1 için küçük bir telefon paketi hazırlanır. Bu yaklaşım teknik olarak işlemezse nedenleri ölçülüp tek bir mobil ana proje seçilir; iki ayrı kampanya paralel geliştirilmez.

1. Dokunmatik girişleri mevcut InputMap eylemlerine bağla: hareket, zıplama, saldırı, ağır/özel, dash, çömelme, duraklatma. Çoklu dokunuş, basılı tutma, parmağı kaydırma ve parmağı ekran dışına çıkarma hâlleri test edilir. Fizik ve kombo kodunu ikinci kez yazma.
2. Kontrol yerleşimini sol hareket ve sağ eylem alanı olarak gerçek başparmaklarla dene. Sabit/uyarlanabilir düğme konumu ve boyutu yalnız oyuncu denemesiyle seçilir. Düğme, can barı, boss uyarısı veya iniş platformunu örtmemeli.
3. `redmount/project.godot` içindeki 1280×720 viewport ve integer ölçek ayarının telefon oranlarında etkisini ölç. Kamera görüşü, piksel keskinliği, HUD güvenli alanı ve yatay kullanım için tek bir yaklaşım seç. 16:9, 19.5:9 ve 20:9 ekranlarda kırpılan bilgi kalmamalı.
4. Telefon arka plana alındığında oyun duraklar; geri dönünce girişler takılı kalmaz. Çağrı, ekran kilidi ve uygulama değiştirme durumları denenir. Bölüm ortasında devam tasarımı netleşir: mevcut kontrol noktası esas alınacaksa oyuncuya açıkça söylenir; kayıt güvenli biçimde tamamlanır.
5. Cihazda Bölüm 1 baştan sona oynanır; arena, ölüm, yeniden doğma, mağaza, sonuç ve menü dönüşü kapsanır. PC fareyle dokunma taklidi yalnız hızlı ön kontrol olarak kullanılır.
6. Yoğun karşılaşmada kare zamanı/FPS, bellek, ısınma ve pil etkisi ölçülür. Kabul eşiği hedef cihaz ölçümünden sonra kesinleştirilir; tek hızlı telefondaki başarı kampanya için yeterli sayılmaz.

**Geçiş koşulu:** Gerçek telefon paketi kurulup Bölüm 1 baştan sona iki başparmakla oynanır; duraklatma/geri dönüş/kayıt çalışır. Bu kapı geçmeden kalan 35 bölümü mobil sahneye topluca taşımaya başlanmaz.

### Aşama 2 — İlk 10 dakikayı mükemmelleştir

Önce telefondaki Bölüm 1'den en fazla 10 dakikalık bir **oynanış kesiti** seç. 36 sahneyi aynı anda değiştirmek yerine dokunma, hareket ve dövüş kararlarını bu kesitte doğrula; sonra ortak sistemlere uygula.

**Hareket denetimi**

- Parmağı kaldırınca durma, yön değiştirme, havada yön verme, kısa/uzun zıplama, zıplama tamponu ve kenardan ayrıldıktan sonraki toleransı videoda kare kare incele. Mevcut değerleri `resources/movement/redmount_movement.tres` üzerinden ayarla; yeni hareket sistemi yazma.
- Oyuncunun iniş platformunu göremediği yerde kamera bakışı veya sahne düzenini düzelt. Dash yalnızca isteğe bağlı ödül rotasında mı, ana yolda mı gerekli, açıkça belirt ve öğreticiyi buna göre güncelle.
- Tek yön platformdan iniş, duvar zıplaması ve çukurdan doğma sırasında oyuncunun komutlarının kaybolmadığını denetle. Her birine gerçek girişli tek regresyon senaryosu yeter.
- Dokunmatik düğme simgeleri, ekrandaki ipuçları ve gerçek InputMap aynı olmalı. `README.md` içindeki “K yalnız silahsızken” gibi tarihsel satırlar kodla karşılaştırılmalı; mobil öğreticide klavye tuşu gösterilmemeli.

**Dövüş denetimi**

- Her vuruş için hazırlık, aktif temas ve toparlanma anını; düşman tepkisi, ses ve hasar sayısı ile eşleştir. Görsel vuruş ile gerçek hitbox ayrı karelerdeyse önce bu düzeltilir.
- Hızlı dokunuşlarda ve aynı anda hareket ederken kombo zinciri, ağır saldırı ve hava saldırısı girişini test et. Mevcut saldırı tamponu (`redmount.gd`) çalışıyorsa korunur; ek katman ancak testte somut eksik çıkarsa eklenir.
- Yumruk, silah, tabanca ve zırhın rolünü netleştir: hangi tehdide karşı yararlı, ne zaman tükenir, oyuncuya nasıl anlatılır. Her rol için kısa bir güvenli tanıtım anı olmalı.
- Düşman vuruş hazırlığı, menzili, isabet ve oyuncu hasarı aynı anda okunmalı. Çoklu düşman saldırısında kaçış penceresi kalmalı. Ekran sarsıntısı ve hitstop okunurluğu artırmalı; kontrolü geciktirdiği hissedilirse azaltılmalı.
- Aynı düşmanla 3 farklı oyuncunun serbest karşılaşmasını izle: gereksiz hasar, güvenli tek tuş stratejisi ve bekleme süresi not edilir. Sayısal dengeleme bundan sonra yapılır.

**Dikey kesit kabulü:** Oyuncu telefon kontrolünü, hareketi ve dövüşü yardım almadan öğrenir, başarısızlığını açıklayabilir ve aynı kesiti tekrar denemek ister. Bu nitel gözlem kaydı, yalnız FPS veya bot süresiyle ikame edilmez.

### Aşama 3 — 36 bölümün mobil ritim ve geçilebilirlik denetimi

Her bölüm, aşağıdaki sırayla incelenir: **sahne yükleme → otomatik tam rota → gerçek telefonda insan oyuncu → görsel/ses geçişi → tekrar test**. Yalnız botun kullandığı yol değil; isteğe bağlı rota, mağaza, gizli ödül ve ölüm sonrası yol da görülür.

**Her bölüm için aynı kontrol listesi**

1. İlk 30 saniyede hedef ve tehlike anlaşılır mı? Yeni fikir güvenli alanda tek başına gösteriliyor mu?
2. Ana yol kayboluyor mu? Ok, ışık, mimari ve kamera oyuncuyu aşırı metin olmadan yönlendiriyor mu?
3. Son 60 saniyede yapılan eylem, önceki 60 saniyeden anlamlı biçimde farklı mı? Üç ardışık boş koridor veya özdeş arena varsa kısalt/birleştir.
4. Zıplama ve dövüş aynı dar platformda zorlanıyorsa oyuncunun bilinçli seçim alanı var mı? Diken üstünde kilitli dövüş bulunmamalı.
5. Ölümden sonra geri dönüş, sağlık/cephane durumu ve arena sıfırlaması tutarlı mı? Kontrol noktası beklenen yerde mi?
6. Gizli alanı fark etmeye yetecek ipucu var mı? Ödülü gitmeye değer mi? Ana yolu gizli eşya zorunluluğuna bağlama.
7. Sahneye özgü bir an var mı: yeni parkur kombinasyonu, düşman etkileşimi, mekân sürprizi veya anlatı kararı? Sadece arka plan değişimi “yeni bölüm” sayılmaz.
8. Bitiş kapısı, sonuç, ödül kaydı ve sonraki bölüm geçişi doğru mu? Yeniden başlatma ve ana menü dönüşü çalışıyor mu?

**Kampanya denetim sırası ve ilk bakış noktaları**  
Adlar sahne dosyalarından; “ilk bakış” bir hata iddiası değil, test odağıdır. Tüm satırlarda otomatik ve insan oynama durumu ayrıca doldurulacaktır.

| Sıra | Bölüm | İlk bakış noktası |
|---|---|---|
| K1-01 | Kayıp İz · Mahalle | İlk 10 dakika, temel öğretim, uzun rota, final arena |
| K1-02 | Arka Sokak İzi | Parkur/dövüş geçişleri, 4:23 bot koşusunun insan karşılığı |
| K1-03 | Gece Pazarı Baskını | Pazar arka plan birleşimleri, ilk yoğun dövüş, 5:09 bot koşusu |
| K1-04 | Silahlı Kontrol Bölgesi | Menzilli saldırı uyarısı, siper ve kamera |
| K1-05 | Demiryolu Ablukası | Hareketli platform, tren tehlikesi, yeniden doğma |
| K1-06 | Ağır Güvenlik Bölgesi | Zırhlı düşman tanıtımı ve karşı oyun |
| K1-07 | Karahanlı Haddehanesi | Isı/endüstri tehlikesi ve arena çeşitliliği |
| K1-08 | Yeraltı Sevkiyatı | Karanlıkta rota okunurluğu, gizli yol |
| K1-09 | Zırhlı Üs | Uzun menzilli + zırhlı birleşiminin adaleti |
| K1-10 | Kuzey Surları | Dikey parkur, görünür iniş ve kontrol noktası |
| K1-11 | Sessiz Koridor | Sessizlik/gerilim ritmi, tekrar eden mücadele |
| K1-12 | İç Kale / Karahanlı | Boss öğrenme döngüsü, sonuç ve Kitap 2 geçişi |
| K2-01 | Haliç'te Şafak | Yeni kitabın güç düzeyi ve açılış temposu |
| K2-02 | Sahte Mühür | Hedefin anlatılması, keşif ödülleri |
| K2-03 | Zeyrek Su Hattı | Su hattı tehlikesi, zemin okunurluğu |
| K2-04 | Süleymaniye Arşivi | İç/dış mekân ayrımı, rota kararı |
| K2-05 | Beyazıt Posta Hattı | Menzilli baskı ve siper bolluğu |
| K2-06 | Kapalıçarşı Arka Hanı | Kalabalık görselde oyuncu/düşman silueti |
| K2-07 | Çemberlitaş Külhanı | Tehlike telegrafı ve arena alanı |
| K2-08 | Samatya Taş Depoları | Ağır düşman ve platform genişliği |
| K2-09 | Yenikapı Gece Vardiyası | Gece kontrastı ve mermi görünürlüğü |
| K2-10 | Aksaray Pompa İstasyonu | Mekanik tanıtım/tekrar dengesi |
| K2-11 | Saraçhane Ana Vana | Son bölüm öncesi güç/ikmal dengesi |
| K2-12 | Bozdoğan Kemeri | Uzun finalde tempo, boss ve kayıt |
| K3-01 | Cağaloğlu'nda İlk Baskın | Üçüncü kitap açılışı, yeni hedefin netliği |
| K3-02 | Sirkeci Sevkiyatı | Tren/istasyon mekânında siluet ve kamera |
| K3-03 | Galata Telgrafı | İletişim hedefi ile oynanış ilişkisi |
| K3-04 | Üsküdar Yedek Hattı | Önceki kitapla mekanik tekrar |
| K3-05 | Kuzguncuk Kıyı Deposu | Dar sahilde çatışma güvenliği |
| K3-06 | Beylerbeyi İskele Arşivi | Üst rota/alt rota ödül dengesi |
| K3-07 | Çengelköy Sahil Konağı | İç mekân temposu ve kamera |
| K3-08 | Kuleli Gözetleme Hattı | Menzilli düşman telegrafı |
| K3-09 | Vaniköy Gece Sevkiyatı | Gece tonunda mermi/çukur okunurluğu |
| K3-10 | Kandilli Verici Sırtı | Dikey rota ve rüzgâr/tehlike adaleti |
| K3-11 | Anadoluhisarı Kale İçi | Finale hazırlık ve ikmal |
| K3-12 | Son Yayın | Üç bağlantı, üç boss evresi, epilog, gerçek sonuç kaydı |

**Düzenleme kuralı:** Önce bölümü kısaltma, düşman yerini değiştirme veya kontrol noktası kaydırma gibi mevcut araçlarla düzelt. Yeni mekanik/asset yalnız aynı sorunun birkaç bölümde sürdüğü ve mevcut sistemle çözülemediği durumda üretilir. Hedef, her bölümün aynı piksel uzunluğuna ulaşması değildir.

### Aşama 4 — Düşmanlar, bosslar, yükseltmeler ve para

- Mevcut `EnemyConfig` ailelerini tek tek denetle: farkları yalnız HP/hasar mı, yoksa oyuncudan farklı karar istiyorlar mı? Birbirine benzeyenleri yeniden isimlendirmek yerine mevcut davranış/yerleşimi iyileştir.
- Her düşman için “uyarı → eylem → kaçış/karşı saldırı” kaydı oluştur. Özellikle bıçaklı atılım, tüfekli hedefleme, bloklu/zırhlı ve boss ağır saldırılarının uyarı süresi ölçülür. Oyuncu ilk karşılaşmada en az bir kez güvenli gözlem fırsatı bulur.
- İki veya üç düşmanın birlikte saldırdığı arenaları değerlendir: görünmeyen mermi, üst üste binen saldırı, çıkışı kapatan gövde ve düşen ödülün erişilemez kalması P0/P1 adayıdır.
- Bosslar için temiz kayıtla ve yükseltmesiz test yap. Yeni evre aynı saldırının yalnız hızlandırılmış hâli olmamalı; görsel/ses işareti ve yeni karar alanı sunmalı. Her evreden hemen önce veya boss önünde makul kontrol noktası olmalı.
- Mağaza ürünleri için fiyat, kazanılma zamanı, kullanım zamanı ve ana yol etkisini tabloya dök. Satın alınan yükseltmenin ilk kullanımını oyun açıkça gösterir. `Save.owns()` ile koşu içi kaynakların ayrımı kontrol edilir.
- Coin ekonomisini üç örnekle dene: yalnız ana yol, ortalama keşif, çoğu sırrı bulan oyuncu. Hiçbir örnekte yanlışlıkla kalıcı yükseltme kilidi oluşmamalı. Kaydı silmeden eski sürümden yeni sürüme açılışı dene.
- Skor/rank ölçütleri oyuncuya görünür hedeflerle uyumlu olsun. Süreye aşırı ceza, keşif yapmayı cezalandırıyorsa değiştir; otomatik bot performansını denge referansı alma.

### Aşama 5 — Küçük ekran sunumu, performans ve ses

- Her biyom için oyuncu ve düşmanın arka plandan ayrıldığı 3 örnek ekran seç: boş, kalabalık arena, karanlık/efektli an. Karakter, mermi, tehlike ve etkileşimli nesne silueti küçük ekranda da seçilmeli.
- Sprite ölçeği, ışık yönü, çizgi kalınlığı, palet ve animasyon kare ritmini kampanya boyunca karşılaştır. Özellikle önceki incelemede fark edilen dolmuş tekrarları ve şantiye dokusu öncelikli görsel denetim örneği olsun.
- Arka plan atlası birleşimlerini kamera hareketiyle izle; statik ekran görüntüsü yeterli değil. Zemin kenarı ve gerçek çarpışma çizgisi birbirine uyumlu olmalı.
- Eksik hasar/ölüm/knockdown animasyonları ve boss'a özel evre tepkileri için önce görünür eksikleri listele, sonra üret. Aynı animasyonu her karaktere körlemesine uygulama.
- HUD can, silah dayanıklılığı, mermi, zırh, güçlendirme, boss canı ve hedef bilgisini yalnız karar vermek gerektiğinde öne çıkar. Sonuç ekranı değerleri gerçek koşudan gelmeli; metin kontrastı ve Türkçe taşmaları test edilmeli.
- Dokunmatik düğmeler için görsel basılı durum, yeterli dokunma alanı ve gerektiğinde yerleşim ayarı sağla. Sol/sağ el kullanımı veya düğme boyutu ihtiyacı gerçek oyuncu testinden çıkan bulguya göre ele alınır.
- Sesler için vuruş, ağır vuruş, hasar alma, tehlike uyarısı, coin ve kontrol noktası seslerinin birbirine karışmadığı bir miks yap. Müzik/efekt/arayüz için ayrı ses ayarları ancak oyuncu testinde ihtiyaç doğrulanırsa eklenir. Uzun oturumda adım ve yumruk sesinin yoruculuğu dinlenir.
- Ekran sarsıntısı, flaş ve yoğun efektler için azaltılmış efekt seçeneği düşün; önce mevcut efektleri ölç, erişilebilirlik ihtiyacı çıkarsa seçenek aç.
- Sahne açılışı, ilk saldırı, yoğun arena ve boss sırasında kare zamanı/FPS ile bellek izle. Önce görünmeyen nesne çizimi, büyük atlas ve ses yükünü ölç; ölçülen darboğazı düzelt. Uzun oturumda ısınma, pil ve arka plana dönüş kontrol edilir.

### Aşama 6 — Mobil tam kampanya regresyonu ve yayın adayı

- Temiz kayıtla Kitap 1→2→3 bölüm açma zinciri, her kitap finali, sonuç ekranı, mağaza ve epilog baştan sona denetlenir. Mevcut otomatik testler bunun hızlı güvenlik ağıdır; en az bir insan tüm kritik akışı oynar.
- Her bölüm için başlangıç, orta kontrol noktası, ölüm/yeniden doğma ve bitiş kaydı kontrol edilir. Bitişten hemen sonra uygulama kapanırsa açılan bölüm/coin kaybı yaşanmamalı.
- En az bir düşük ve bir hedef telefonda uzun oturum: bellek artışı, ses sızıntısı, yükleme beklemesi, FPS düşüşü, ısınma ve pil etkisi kaydedilir.
- 16:9, 19.5:9 ve 20:9 oranlarında menü, oyun, altyazı, HUD, dokunmatik düğmeler, mağaza ve sonuç ekranı denetlenir. Ekran çentiği/yuvarlatılmış köşe altında kritik bilgi kalmaz.
- Uygulama arka plana geçişi, çağrı, ekran kilidi, ses odağı, internet yokluğu ve düşük depolama durumları gerçek cihazda denenir. Oyunun çevrim dışı çalışması hedefleniyorsa tüm kampanya bu koşulda bitirilebilir olmalı.
- Android dışa aktarma, paket kimliği, ikon, açılış, gerekli izinler, imzalama, sürüm yükseltmesi ve kurulumdan sonra kayıt korunması kontrol edilir. iOS çıkışı da planlanıyorsa iPhone paketleme, güvenli alan ve mağaza kontrolleri ayrıca aynı yayın kapısına eklenir.
- Kritik hata listesi boş, önemli hata listesi kabul kararıyla kayıtlı olur. Test edilmemiş özellik “tamam” diye işaretlenmez.
- Son kullanıcı metni, kontrol şeması, kayıt sıfırlama uyarısı ve erişilebilirlik seçenekleri yayın paketindeki gerçek davranışla eşleşir.

## 5. Önerilen çalışma takvimi

Bu bir teslim sözü değil; **tek geliştirici + gerektiğinde sanat/ses desteği** için sıralama taslağıdır. İlk hafta çıkan sorun sayısına göre tarihler yeniden tahmin edilir.

| Pencere | Odak | Somut çıktı |
|---|---|---|
| Hafta 1 | Aşama 0 | Sabit test sürümü, 36 satırlık denetim kaydı, hedef telefon listesi ve ilk cihaz ölçümü |
| Hafta 2–3 | Aşama 1 | `redmount/` Bölüm 1'in gerçek telefonda çalışan dokunmatik paketi |
| Hafta 3–4 | Aşama 2 | Mobil ilk 10 dakika, hareket/dövüş düzeltmeleri, iki yeni oyuncu turu |
| Hafta 5–9 | Aşama 3 | Kitap 1→2→3 mobil bölüm denetimi ve sorunlu rotaların düzeltmesi |
| Hafta 7–10 | Aşama 4 | Düşman/boss/mağaza dengesi; temiz kayıt ve dokunmatik testler |
| Hafta 9–12 | Aşama 5 | Küçük ekran okunurluğu, animasyon/ses ve hedef cihaz performansı |
| Hafta 13+ | Aşama 6 | Tam cihaz regresyonu, paketleme ve mobil yayın adayı |

**Paralel yapılabilecekler:** Sanat atlası incelemesi ile kod tabanlı kayıt testleri. **Sırayla yapılması gerekenler:** Gerçek telefonda Bölüm 1 oynanmadan 36 bölümü taşımak; dokunmatik hareket/dövüş hissi netleşmeden tüm arenaları dengelemek; tam kampanya cihaz ve insan testinden önce yayın kararı vermek.

## 6. İş panosu için hazır kayıt biçimi

```text
Kimlik: K1-03 / gece pazarı / arena 2
Sürüm ve cihaz:
Öncelik: P0 | P1 | P2
Beklenen davranış:
Gerçek davranış:
Tekrar üretim adımları + video zamanı:
Oyuncu etkisi: ölüm | bekleme | belirsizlik | yalnız görsel
En küçük çözüm:
Sorumlu ve hedef tarih:
Yeniden test: bot | insan | gerçek cihaz
Durum: açık | yapılıyor | düzeltildi | doğrulandı
```

Bir iş yalnız kod değiştiğinde değil, **aynı koşulda tekrar oynanıp sorun giderildiğinde** kapatılır. Sorunların yüzde kaçı kod, bölüm düzeni, sanat veya açıklama kaynaklı zaman içinde görülür; yol haritası buna göre güncellenir.

## 7. Hemen başlanacak ilk beş iş

1. `GameState.LEVELS` içindeki 36 bölümü güncel Godot sürümünde smoke testten geçir, sonucu sürüm numarasıyla kaydet.
2. Bölüm 1, 2, 3 ve finalin var olan bot testlerini aynı sürümde tekrar çalıştır; timeout, sonuç, kayıt ve ses kapanış uyarılarını ayrı raporla.
3. `redmount/` Bölüm 1'i mevcut InputMap üstünden dokunmatik girişle Android telefonda paketleyip baştan sona oyna; `mobile/` prototipinden yalnız işe yarayan kontrol fikirlerini al.
4. Beş yeni oyuncuya Bölüm 1'i gerçek telefonda açıklama yapmadan oynat; video, cihaz ve kontrol yerleşimini kaydet. İlk düzeltilecek üç sürtünme noktasını seç.
5. Dokunma/hareket/dövüş sorunlarını ortak sistemlerde çöz ve Bölüm 1'i yeniden test et. Bu kabul kapısını geçmeden 36 bölüme toplu aktarım ve denge yapma.

**“Tamamlandı” tanımı:** 36 bölüm mobil pakette açılıyor ve ana yollar telefonda bitiyor + yeni oyuncular dokunmatik sistemi yardımsız öğreniyor + farklı ekran ve hedef cihazlarda akış/performans kabul ediliyor + arka plana geçiş ve sürüm yükseltmesinde kayıt kaybı yok + yayın paketi kurulup doğrulanıyor. Bunlardan biri eksikse oyun içerikçe geniş olabilir, fakat mobil çıkışa hazır değildir.
