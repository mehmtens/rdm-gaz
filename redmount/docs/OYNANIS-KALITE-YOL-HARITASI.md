# REDMOUNT — Oynanış Kalitesi ve Tamamlama Yol Haritası

**Tarih:** 30 Eylül 2026  
**Ürün hedefi:** Mobil oyun olarak çıkış; gerçek telefon oynanışı ana kabul ölçütü.  
**Kapsam:** `redmount/` içindeki 3 kitap, 36 bölümlük Godot kampanyasının mobil sürümü. `mobile/` tek bölümlük prototip, dokunmatik kontrol ve sunum için teknik referanstır.  
**Amaç:** Bölümlerin yalnızca tamamlanabilir olmasıyla yetinmeyip hareketi, dövüşü, seviye ritmini ve dokunmatik kontrolü telefonda keyifli, okunabilir ve tutarlı hâle getirmek. Dan the Man bir tür/tempo referansıdır; REDMOUNT'un karakteri, dünyası, görsel dili ve bölüm fikirleri özgün kalır.

> Bu belge yapılmış işleri yeniden “tamamlandı” saymaz. Kod ve kayıtlar üzerinden görülen durum ile insan oyuncu testinde doğrulanması gereken kalite ayrı tutulur. Hedef sayılar **önerilen kabul eşikleridir**; ilk testlerden sonra gerçek verilere göre güncellenir.

**İlk uygulama durumu (30 Eylül 2026):** `redmount/` ana oyununa dokunmatik düğmeler, mobil yönlendirme metinleri, duraklatma/ölüm/bölüm sonucu dokunmatik akışı ve yatay ekran ayarı eklendi. `OYNA_MOBIL.cmd` artık bu ana oyunun masaüstü dokunmatik önizlemesini açıyor. Eş zamanlı iki dokunma, duraklatma, TEKRAR ve SONRAKİ testi geçti; 36 sahne smoke testi geçti. **Android paketi, gerçek telefon oynanışı ve performans kapısı açık:** bu makinede Android SDK/ADB ve Godot 4.7 dışa aktarma şablonları bulunamadı; telefon kanıtı oluşmadı.

## 1. Şu an elimizde ne var?

| Alan | Kodda veya kayıtta görülen durum | Henüz bilinmeyen |
|---|---|---|
| Kampanya | `scripts/systems/game_state.gd` içinde 36 sahne sıralı. `tests/campaign_smoke.gd` 36 sahneyi ve menüyü yüklemeyi denetliyor. | Her bölümün yeni bir oyuncu tarafından rahatça geçilip geçilemediği. |
| Hareket | `redmount.gd` ve `MovementConfig` içinde koşu, değişken zıplama, coyote time, jump buffer, dash, duvar kayması/zıplaması ve çömelme var. | Bu hareketlerin gerçek girişlerde ve telefonda güvenilir/hızlı hissedip hissettirmediği. |
| Dövüş | Üçlü kombo, ağır yumruk, hava saldırısı, silahlar, mermi, zırh, güçlendirmeler, hitstop ve ekran sarsıntısı var. `tests/move_progression.gd` bazı yükseltme etkileşimlerini denetliyor. | İsabet okunurluğu, kombo ritmi, saldırı iptali beklentisi, düşman adaleti ve uzun oturum yorgunluğu. |
| Bölüm akışı | Arenalar, kontrol noktaları, mağazalar, kırılabilir nesneler, gizli yollar, bosslar ve sonuç ekranı mevcut. | 36 bölüm boyunca bunların çeşitlilik ve ödül değerinin yeterli olup olmadığı. |
| Tam koşu kanıtı | Bölüm 1: `tests/level01_play_verified.log` **6:03**; Bölüm 2: `tests/level02_play_baseline.log` **4:23**; Bölüm 3: `tests/level03_play_baseline.log` **5:09**. Kitap 3 finali: `tests/book03_final_verified.log` **18:16**. Bunlar otomatik girdilerle alınmış sürelerdir. | İnsan oyuncu süreleri, duraksama/keşif ve gerçek zorlanma noktaları. Diğer bölümlerin aynı yöntemle güncel sürümde uçtan uca geçtiği ayrıca doğrulanmalı. |
| Görsel/ses | Piksel karakterler, mekân atlasları, müzik ve SFX mevcut. Ekran görüntülerinde zengin mekânlar görülüyor; önceki görsel incelemede bazı tekrarlar ve üslup farkları not edilmiş. | Hareket sırasında okunurluk, katman ayrımı, animasyon kalitesi ve ses miksinin bütün kampanyadaki tutarlılığı. |
| Mobil | `mobile/` ayrı, dokunmatik kontrollü **tek bölümlük prototip**. 36 bölümlük `redmount/` kampanyası PC girişleriyle kurulmuş. | Ana kampanyanın telefondaki kontrol, performans, ekran oranı, kayıt ve paketleme davranışı. Bunlar mobil çıkış için P0. |
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
