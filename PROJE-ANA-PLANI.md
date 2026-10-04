# REDMOUNT — Proje Ana Planı

> **Eylül 2026 kampanya revizyonu:** İlk beş bölümlük prototip, dört perde ve
> on iki ana bölümlük yapıya genişletilmiştir. Güncel sıra, süre hedefleri ve
> hikâye işlevleri için [`redmount/docs/12-BOLUM-KAMPANYA.md`](redmount/docs/12-BOLUM-KAMPANYA.md)
> esas alınır; aşağıdaki beş bölümlük plan tarihsel prototip kapsamıdır.

## 1. Proje özeti

Bu proje; retro piksel sanat estetiğine sahip, hızlı tempolu, yan görünümlü bir aksiyon-platform ve beat ’em up oyunudur. Oynanışın merkezinde Redmount bulunur. Redmount parkur engellerini aşar, düşmanlarla yakın ve uzak dövüşür, haritadaki ekipmanları ve güçlendirmeleri kullanır, coin toplar ve düşmanın elindeki Gazelle’i kurtarmaya çalışır.

Temel ilham, `Dan the Man` benzeri okunaklı piksel animasyonları, kısa tepki süreleri, platform geçişleri ve arcade dövüş akışıdır. Karakterler, dünya, hikâye ve görsel kimlik özgün olacaktır.

## 2. Temel proje kararları

- Oyunun kesin adı: **REDMOUNT**.
- Oyun motoru: **Godot 4**.
- Programlama dili: **GDScript**.
- Grafik türü: **2D piksel sanat**.
- Ana kamera: **yan görünüm**.
- Oynanış türü: platform, parkur, yakın dövüş, ateşli silahlar, bölüm bazlı ilerleme.
- Ana karakter: **Redmount**.
- Kurtarılacak hikâye karakteri: **Gazelle**.
- Otoriter ana karakter/karşı güç: **Karahanlı**.
- Hedef platform: önce Windows PC; sonraki aşamada Android değerlendirilebilir.
- Kare hücresi: karakter animasyonlarında başlangıç standardı **128 × 256 px**.
- Çalışma aracı: Aseprite önerilir; Pixelorama ücretsiz alternatiftir.

## 3. Oyun vizyonu

Oyunun güçlü tarafları şunlar olmalıdır:

- Kontroller ilk dakikada anlaşılmalı.
- Hareketler hızlı, net ve tepkisel hissettirmeli.
- Her düşman yalnız görünüşüyle değil, davranışıyla da ayrışmalı.
- Silah ve güçlendirme seçimleri oynanışı değiştirmeli.
- Parkur ile dövüş birbirinden kopuk olmamalı.
- Gizli alanlar ve bonus coinler keşfi ödüllendirmeli.
- Gazelle’in esareti, bölüm ilerleyişinin sürekli görünen hikâye motivasyonu olmalı.
- Karahanlı, doğrudan bağırıp çağıran değil; sakin, hesapçı ve otoriter bir tehdit olarak sunulmalı.

## 4. Hikâye çerçevesi

### 4.1 Başlangıç durumu

Gazelle düşmanlar tarafından kaçırılmıştır ve oyunun başından itibaren onların elindedir. Gazelle savaşçı değildir; kaçmaz, düşmanlarla dövüşmez ve oynanabilir karakter değildir. Hikâyedeki işlevi, kurtarılmayı bekleyen merkez hedef olmaktır.

Redmount, Gazelle’e ulaşmak için şehir sokaklarından başlayarak giderek daha güvenli ve daha ağır korunan bölgelere ilerler. Haritadaki düşman grupları, ajanlar ve muhafızlar Redmount’ı durdurmaya çalışır.

### 4.2 Karahanlı

Karahanlı; sakin, hesapçı, otoriter ve stratejik bir karakterdir. Dış görünüş ve konuşma ağırlığı açısından klasik Türk suç-draması otorite figürlerinden esinlenir ancak birebir bir karakter kopyası değildir.

Karahanlı’nın hikâyedeki kesin konumu aşağıdaki seçeneklerden biri olarak kilitlenmelidir:

- Ana düşman ve kaçırılma emrini veren kişi.
- Daha büyük yapının görünen yöneticisi.
- Son bölümde ortaya çıkan, Gazelle’i stratejik nedenle elinde tutan rakip.

Başlangıç üretiminde Karahanlı, düşman organizasyonunun en üst otoritesi kabul edilecektir. Hikâye metni yazılırken bu karar değiştirilebilir.

### 4.3 Bölüm sonu

Redmount, on ikinci bölümde kaleye/ana üsse ulaşır. Elit Muhafızları aşar, Karahanlı ile son karşılaşmaya girer ve Gazelle’in tutulduğu bölgeye erişir. Gazelle’in kurtarılması oynanış, kısa sahne ve karakter animasyonuyla gösterilir.

## 5. Ana oynanış döngüsü

Bir bölümün temel akışı:

1. Redmount bölüme girer.
2. Koşma, zıplama ve parkur engelleriyle ilerler.
3. Coin, silah, zırh, cephane veya güçlendirme toplar.
4. Düşman grubu alanı kilitler.
5. Redmount yakın dövüş, silah veya çevresel avantajla grubu temizler.
6. Gizli alan ve bonus coin rotası isteğe bağlı olarak keşfedilir.
7. Kontrol noktası veya kısa hikâye anı görülür.
8. Bölüm sonu çatışması tamamlanır.
9. Skor, coin ve bulunan gizli ödüller hesaplanır.

## 6. Kontroller

İlk PC kontrol taslağı:

- `A / D`: sola ve sağa hareket.
- `W / Space`: zıplama.
- `S`: çömelme veya aşağı platformdan inme.
- `J`: temel saldırı / kullanılan silahın saldırısı.
- `K`: ağır saldırı veya ikincil silah hareketi.
- `L`: ateş etme veya fırlatma.
- `E`: eşya alma, sandık açma, etkileşim.
- `Q`: ekipman değiştirme.
- `Shift`: koşma veya kısa dash; oynanış testinden sonra kesinleşir.
- `Esc`: duraklatma menüsü.

Mobil sürüm yapılırsa aynı işlevler sanal analog ve ekran düğmelerine dönüştürülecektir.

## 7. Redmount

### 7.1 Karakter kimliği

Redmount; geçmişi olan, yaklaşık orta yaş hissi taşıyan, yorgun görünmeyen, tecrübenin verdiği özgüvene sahip maskülen bir karakterdir. Mevcut karakter tasarımındaki saç, deri ceket, koyu pantolon ve beyaz ayakkabı kimliği korunacaktır.

Redmount yalnız yumruk kullanan bir karakter değildir. Yumruklar, ekipman kalmadığında kullanılan temel yedek dövüş setidir.

### 7.2 Temel hareketler

- Idle.
- Yürüme.
- Koşma.
- Zıplama.
- Havada kalma/düşme.
- İniş.
- Çömelme.
- Platform kenarından düşme.
- Hasar alma.
- Sersemleme.
- Yere düşme.
- Ayağa kalkma.
- Ölüm/başarısızlık.

### 7.3 Silahsız dövüş

- Üç vuruşluk yumruk kombosu.
- Havada diz darbesi.
- Ağır yumruk.
- Düşmana göre geri tepme ve combo kırılması.
- Vuruşların sırası: hazırlık, temas ve geri dönüş.
- Hitbox yalnız temas karelerinde aktif olacaktır.

### 7.4 Kullanılabilir ekipmanlar

#### Sopa

- Geniş yatay savuruş.
- Yukarıdan ağır vuruş.
- Havada sopa saldırısı.
- Dayanıklılık bittiğinde kırılma veya düşme.

#### Bıçak

- Hızlı yakın menzil kesme.
- İleri hamle.
- Fırlatma.
- Fırlatmadan sonra silahsız sete dönüş.

#### Ateşli silah

- Silahla idle ve yürüme.
- Nişan alma.
- Ateş etme.
- Geri tepme.
- Şarjör değiştirme.
- Cephane bittiğinde silahsız sete dönüş veya yeniden doldurma.

#### Zırh

- Zırhı kuşanma.
- Hasarı azaltma.
- Zırhlı hit tepkisi.
- Daha ağır silüet.
- Koşu hızında küçük düşüş.
- Dayanıklılık bittiğinde kırılma efekti.

### 7.5 Eşya geçişleri

- Yerden eşya alma.
- Ekipmanı kuşanma.
- Hızlı ekipman değiştirme.
- Silahı düşürme.
- Cephane alma.
- Coin alma.
- Sandık açma.

## 8. Gazelle

### 8.1 Karakter kimliği

Gazelle oyunun başından beri kaçırılmıştır. Düşmanın elinde, sabit bir alanda kurtarılmayı bekler. Dövüşmez, kaçmaz, geri çekilmez ve Redmount’ı takip eden bir eskort NPC’sine dönüşmez.

### 8.2 Animasyonlar

- Bağlı/sabit idle.
- Oturarak tedirgin bekleme.
- Uzak dövüş sesini duyunca başını kaldırma.
- Redmount’ı görünce umutlu bakış.
- Silah veya darbe sesinde bulunduğu yerde irkilme.
- Bağlarından kurtulmayı deneyip başarısız olma.
- Muhafızlar yenilince kurtarılma tepkisi.
- Bağların çözülmesi.
- Bileklerini ovuşturma.
- Sabit kurtarılma/kapanış pozu.

## 9. Karahanlı

### 9.1 Karakter kimliği

Karahanlı orta yaşlı, soğukkanlı, kontrollü ve otoriterdir. Koyu, kusursuz ve ağır bir giyim tarzı vardır. Konuşmaları kısa, ölçülü ve tehditkâr bir sakinlik taşır.

### 9.2 Görsel davranış

- Minimum nefes hareketli idle.
- Dik ve kontrollü yürüyüş.
- Ceketi düzeltme.
- Sakin bakış ve kısa baş hareketleri.
- Emir verme.
- Konuşma sırasında küçük el jestleri.
- Dövüşe girerse ağır düz yumruk, gövde kroşesi, dirsek ve itme.

Karahanlı’nın oynanabilir olup olmayacağı planlanmamıştır. İlk sürümde boss veya hikâye NPC’si olarak ele alınacaktır.

## 10. Düşman NPC kadrosu

### 10.1 Sokak Eşkıyası — Bölüm 1

- Yavaş hareket eder.
- Düşük cana sahiptir.
- Temel yakın dövüş kullanır.
- Grup halinde gelir.
- Oyuncuya temel combo ve kalabalık kontrolünü öğretir.

Gerekli animasyonlar: idle, yürüyüş, yumruk, yakalama denemesi, hasar, düşme, ayağa kalkma ve ölüm.

### 10.2 Bıçaklı Ajan — Bölüm 1–2

- Hızlı yakın dövüşür.
- Önce uzaklaşır, ardından dash saldırısı yapar.
- Kısa menzilde yüksek tehdit oluşturur.
- Oyuncuya saldırı hazırlığını okumayı öğretir.

Gerekli animasyonlar: bıçaklı idle, geri çekilme, dash, saplama, kesme, saldırı kaçırma, hasar, düşme ve ölüm.

### 10.3 Tüfekli Muhafız — Bölüm 2–3

- Uzak mesafeden ateş eder.
- Siper alır.
- Oyuncuyu engellerin arkasına saklanmaya zorlar.
- Yakın mesafede paniğe girer veya dipçik saldırısı kullanır.

Gerekli animasyonlar: tüfekli idle, sipere koşma, siper idle, nişan, seri ateş, şarjör değiştirme, yakın mesafe tepkisi, hasar ve ölüm.

### 10.4 Zırhlı Vurucu — Bölüm 3–4

- Yüksek cana sahiptir.
- Yavaş fakat güçlü vurur.
- Redmount’ın combosunu kırabilir.
- Bloklama veya doğru kaçış gerektirir.

Gerekli animasyonlar: ağır idle, ağır yürüyüş, zırhlı yumruk, guard-break, blok, sersemleme, düşme, ayağa kalkma ve ölüm.

### 10.5 Çevik Suikastçı — Bölüm 3–4

- Duvar sıçraması yapar.
- Ani hava saldırısı kullanır.
- Parkur becerisini test eder.
- Yerde uzun süre sabit kalmaz.

Gerekli animasyonlar: idle, koşu, duvar sıçraması, hava dash, yukarıdan saldırı, yer kesmesi, kaçınma, hasar ve ölüm.

### 10.6 Ağır Zırhlı Mini-boss — Bölüm 4

- Çok yüksek cana sahiptir.
- Ağır çekiç taşır.
- Geniş alan saldırıları kullanır.
- Zırhı kırılınca kısa süre savunmasız kalır.
- Bölüm 4 sonunda mini-boss olarak çıkar.

Gerekli animasyonlar: boss idle, ağır yürüyüş, çekiç süpürme, yere vurma, hücum, zırh kırılma-sersemleme, düşme, ayağa kalkma ve ölüm.

### 10.7 Elit Muhafız — Bölüm 5

- Yakın ve uzak saldırıları birleştirir.
- Kalede/ana üste grup halinde çıkar.
- Ateşli silah, dipçik ve yakın combo kullanır.
- Son bölümde oyuncunun bütün öğrendiklerini test eder.

Gerekli animasyonlar: elit idle, yürüyüş, nişan, tek atış, dipçik, yakın combo, blok, hasar, düşme ve ölüm.

## 11. Toplanabilirler

### 11.1 Standart Coin

- Parkur boyunca dağılır.
- Skor ve mağaza parası olarak kullanılabilir.
- Silah veya kozmetik satın almada harcanabilir.
- Altı karelik dönme animasyonu önerilir.

### 11.2 Bonus Coin

- Nadir ve daha değerlidir.
- Gizli platformlarda bulunur.
- Kırılabilir duvar veya alternatif parkur arkasına yerleştirilir.
- Standart coinden daha büyük, parlak ve farklı sesli olmalıdır.

## 12. Güçlendirmeler

### 12.1 Can takviyesi

- Kırmızı kalp veya iksir olarak görünür.
- Canı anlık doldurur.
- Süre göstergesi gerekmez.

### 12.2 İki kat hasar

- Kırmızı yumruk ikonu ve kırmızı aura kullanır.
- Hasarı iki katına çıkarır.
- Hedef süre: 10–15 saniye.

### 12.3 Hız artışı

- Şimşek ikonu kullanır.
- Hareket hızını 1.5x–2x artırır.
- Hedef süre: 10–15 saniye.
- Ayaklarda veya karakter arkasında kısa hız izi gösterilir.

### 12.4 Görünmezlik

- Hayalet ikonu kullanır.
- Düşmanların Redmount’ı algılamasını geçici olarak kapatır.
- Hedef süre: 8–10 saniye.
- Redmount yarı saydam görünür.

### 12.5 Mermi takviyesi

- Kutu veya şarjör ikonu kullanır.
- Menzilli silahın cephanesine anlık stok ekler.
- Süre göstergesi gerekmez.

### 12.6 Kalkan — ileri aşama

- Bir sonraki darbeyi engeller.
- Tek kullanımlıktır.
- Redmount çevresinde kısa kalkan halkası gösterilir.

## 13. HUD ve kullanıcı arayüzü

Oyun HUD’ında şunlar bulunmalıdır:

- Redmount can çubuğu.
- Zırh dayanıklılığı.
- Aktif silah ikonu.
- Mermi veya silah dayanıklılığı.
- Coin sayacı.
- Skor.
- Aktif güçlendirme ikonu.
- Süreli bonuslar için azalan zaman çubuğu.
- Boss savaşında boss can çubuğu.

Süre bitmeden hemen önce bonus ikonu üç kez yanıp sönmelidir. Coin, can ve cephane gibi anlık etkilerde zamanlayıcı gösterilmemelidir.

## 14. Bölüm planı

### Bölüm 1 — Başlangıç bölgesi

- Temel hareket ve zıplama öğretimi.
- Sokak Eşkıyası grupları.
- İlk sopa.
- Standart coinler.
- İlk gizli bonus coin.
- Bölüm sonunda Bıçaklı Ajan tanıtımı.

### Bölüm 2 — Silahlı kontrol bölgesi

- Bıçaklı Ajanlar daha sıklaşır.
- Tüfekli Muhafız tanıtılır.
- Siper kullanımı öğretilir.
- İlk ateşli silah ve mermi takviyesi verilir.
- Gizli yollar daha belirgin hale gelir.

### Bölüm 3 — Ağır güvenlik bölgesi

- Tüfekli Muhafız ve Zırhlı Vurucu birlikte kullanılır.
- Bloklama, kaçış ve guard-break mantığı önem kazanır.
- Çevik Suikastçı tanıtılır.
- Duvar sıçramalı parkur karşılaşmaları başlar.

### Bölüm 4 — Zırhlı üs

- Zırhlı Vurucu ve Çevik Suikastçı karma grupları.
- Daha zor platform ve çevresel tuzaklar.
- Ağır Zırhlı mini-boss savaşı.
- Mini-boss sonrası kaleye/ana üsse erişim açılır.

### Bölüm 5 — Kale / ana üs

- Elit Muhafız grupları.
- Yakın ve uzak saldırıların aynı arenada birleşmesi.
- Karahanlı ile hikâye karşılaşması veya boss savaşı.
- Gazelle’in bulunduğu son alan.
- Kurtarılma sahnesi ve oyun sonu.

Bölümlerin kesin mekân adları ve hikâye diyalogları daha sonra yazılacaktır.

## 15. Seviye tasarım ilkeleri

- Oyuncu yeni bir düşmanı önce güvenli ortamda tek başına görmelidir.
- Aynı anda çok sayıda farklı saldırı türü kullanılmamalıdır.
- Uzak menzil düşmanları için siper veya platform çözümü bulunmalıdır.
- Gizli coin yolu ana rotadan görsel ipucuyla sezdirilmelidir.
- Kırılabilir duvarlarda hafif çatlak veya farklı renk kullanılmalıdır.
- Ölümcül düşüşlerden önce kamera ve zemin dili açık olmalıdır.
- Kontrol noktaları zor arena veya boss öncesinde yer almalıdır.
- Gazelle final alanında arka planda görünerek oyuncunun hedefini pekiştirmelidir.

## 16. Animasyon ve sanat standardı

### 16.1 Karakter görünümleri

Her ana karakter ve düşman için en az:

- Önden tam boy.
- Arkadan tam boy.
- Sağ yan tam boy.
- Sağ görünümden aynalanmış sol yön.
- Gerekli karakterlerde önden ve yandan yüz portresi.

Arkadan görünüm; karakter turnaround’ı, sahneler ve gerekirse dikey/lane hareketi için hazırlanacaktır.

### 16.2 Hücre ve hizalama

- Başlangıç hücresi: 128 × 256 px.
- Her animasyon karesi aynı hücre ölçüsünü kullanır.
- Ayak tabanı bütün karelerde aynı baseline üzerinde tutulur.
- Karakterin origin noktası ayaklarının orta altıdır.
- Silahlar hücre dışına taşıyorsa saldırı animasyonları için daha geniş hücre kullanılabilir; bu karar tüm ilgili karelerde tutarlı olmalıdır.
- En yakın komşu filtreleme kullanılmalı; texture filtering kapatılmalıdır.

### 16.3 Kare yaklaşımı

- Idle: 4–6 kare.
- Yürüme: 8 kare.
- Koşma: 6–8 kare.
- Zıplama: kalkış, yükseliş, tepe, düşüş ve iniş olarak ayrılır.
- Basit saldırı: hazırlık, temas ve geri dönüş.
- Ağır saldırı: daha uzun hazırlık ve güçlü temas silüeti.
- Hasar: saldırı yönünü açıkça gösteren kısa tepki.
- Sol yön için ayrı çizim yerine sağ sprite yatay çevrilir; asimetrik ekipman varsa özel düzeltme yapılır.

### 16.4 Animasyon hızı

- Idle: yaklaşık 6–8 FPS.
- Yürüme: yaklaşık 8–10 FPS.
- Koşma: yaklaşık 10–14 FPS.
- Hızlı saldırılar: yaklaşık 12–16 FPS.
- Ağır saldırılar: kare süreleri değişken olmalıdır; hazırlık uzun, temas kısa ve sert tutulur.

## 17. Ses planı

Gerekli temel sesler:

- Adım ve koşu.
- Zıplama ve iniş.
- Yumruk temas ve kaçırma.
- Sopa, bıçak ve silah saldırıları.
- Şarjör değiştirme.
- Zırh darbesi ve kırılması.
- Coin alma.
- Bonus coin alma.
- Sandık açma.
- Güçlendirme başlama ve bitme.
- Düşman uyarı sesleri.
- Gazelle irkilme ve kurtarılma tepkileri.
- Karahanlı konuşma ve sahne sesleri.
- Boss saldırı ve ölüm sesleri.

Müzik; bölümler ilerledikçe sokak, endüstriyel güvenlik ve kale/otorite atmosferine doğru ağırlaşmalıdır.

## 18. Godot teknik mimarisi

### 18.1 Ana sahneler

- `Main.tscn`: oyun akışı ve bölüm yükleme.
- `Player/Redmount.tscn`: oyuncu karakteri.
- `Characters/Gazelle.tscn`: esir/kurtarılma karakteri.
- `Characters/Karahanli.tscn`: hikâye karakteri veya boss.
- `Enemies/EnemyBase.tscn`: ortak düşman tabanı.
- Her düşman için EnemyBase’den türeyen ayrı sahne.
- `Weapons/WeaponBase.tscn`: sopa, bıçak ve ateşli silah tabanı.
- `Pickups/PickupBase.tscn`: coin, bonus, cephane ve zırh tabanı.
- `UI/HUD.tscn`: oyun arayüzü.
- `Levels/Level01.tscn` ile `Level05.tscn`: bölüm sahneleri.

### 18.2 Redmount düğüm yapısı

- `CharacterBody2D` kök.
- `AnimatedSprite2D`.
- `CollisionShape2D`.
- `Hurtbox` için `Area2D`.
- Saldırıya göre açılıp kapanan `Hitbox` alanları.
- `WeaponPivot`.
- `InteractionArea`.
- `AudioStreamPlayer2D` düğümleri.
- Kamera takibi için `Camera2D`.

### 18.3 Durum makinesi

Redmount için önerilen durumlar:

- Idle.
- Move.
- Run.
- Jump.
- Fall.
- Land.
- Attack.
- Shoot.
- Reload.
- Pickup.
- Hurt.
- Knockdown.
- Dead.
- Cutscene.

Düşmanlar için önerilen durumlar:

- Idle.
- Patrol.
- Alert.
- Chase.
- Attack.
- Retreat.
- TakeCover.
- Hurt.
- Knockdown.
- Dead.

### 18.4 Veri yapıları

Silah ve güçlendirme değerleri kod içine dağılmamalı; Godot `Resource` dosyalarıyla tutulmalıdır.

Silah verileri:

- Hasar.
- Saldırı hızı.
- Menzil.
- Dayanıklılık.
- Mermi kapasitesi.
- Geri tepme.
- Animasyon isimleri.
- Sesler.

Güçlendirme verileri:

- Etki türü.
- Etki miktarı.
- Süre.
- HUD ikonu.
- Başlangıç ve bitiş efektleri.

## 19. Kayıt ve ilerleme

İlk sürümde kaydedilecekler:

- Açılan bölüm.
- Toplam coin.
- Bölüm yüksek skorları.
- Bulunan bonus coinler.
- Satın alınan kozmetikler.
- Ses ve kontrol ayarları.

Bölüm ortası kayıt yerine kontrol noktası kullanılacaktır. Uygulama kapanırsa son tamamlanan bölümden devam edilir. Ara kayıt sistemi daha sonra değerlendirilebilir.

## 20. Mağaza ve ekonomi

İlk ekonomi taslağı:

- Coinler bölüm içinde skor ve bölüm dışında mağaza parasıdır.
- Mağazada başlangıç silahı, geçici ekipman avantajı veya kozmetik alınabilir.
- Oyuncunun ilerlemesi yalnız coin biriktirmeye bağlanmamalıdır.
- Para ile can veya güç satın alma dengesi, oyunu aşırı kolaylaştırmamalıdır.
- Bonus coinler yüzde yüz tamamlama ve özel kozmetik için kullanılabilir.

Mağaza ilk oynanabilir prototipte yapılmayacak; coin sayacı ve toplama sistemi hazırlandıktan sonra eklenecektir.

## 21. İlk oynanabilir sürüm — Vertical Slice

İlk hedef bütün oyunu yapmak değil, oyunun doğru hissedip hissetmediğini kanıtlayan kısa bir bölüm üretmektir.

Vertical slice içeriği:

- Redmount idle, yürüme, koşma, zıplama ve iniş.
- Silahsız üçlü combo.
- Sopa alma ve sopa saldırısı.
- Coin toplama.
- Can takviyesi.
- Bir kısa parkur bölümü.
- Sokak Eşkıyası.
- Bir Bıçaklı Ajan karşılaşması.
- Basit HUD.
- Kontrol noktası.
- Bölüm sonu sonuç ekranı.

Vertical slice başarılı sayılmak için:

- Kontroller gecikmesiz hissettirmeli.
- Vuruşlar görsel ve sesli olarak net olmalı.
- Düşman yapay zekâsı takılmamalı.
- Sprite ölçeği ve kamera doğru görünmeli.
- Coin ve eşya toplama sorunsuz çalışmalı.
- Windows için çalıştırılabilir build alınabilmeli.

## 22. Üretim aşamaları

### Aşama 1 — Ön üretim

- Hikâye özetini kilitle.
- Karahanlı’nın rolünü kesinleştir.
- Redmount sprite standardını tamamla.
- Renk paletini ve piksel yoğunluğunu sabitle.
- Godot projesini kur.

### Aşama 2 — Redmount prototipi

- Temel hareket kodu.
- Kamera ve çarpışma.
- Idle, walk, run, jump ve land animasyonları.
- Silahsız saldırı.
- Hasar ve ölüm.

### Aşama 3 — Vertical slice

- Bölüm 1 test haritası.
- Sokak Eşkıyası ve Bıçaklı Ajan.
- Sopa, coin, can bonusu ve HUD.
- Ses ve ekran sarsıntısı.
- İlk oynanabilir build.

### Aşama 4 — Sistem genişletme

- Bıçak.
- Ateşli silah.
- Cephane.
- Zırh.
- Bütün güçlendirmeler.
- Siper davranışı.
- Gizli alanlar ve kırılabilir duvarlar.

### Aşama 5 — Bölümler ve düşmanlar

- Bölüm 2–5 üretimi.
- Tüfekli Muhafız.
- Zırhlı Vurucu.
- Çevik Suikastçı.
- Ağır Zırhlı mini-boss.
- Elit Muhafız.

### Aşama 6 — Hikâye ve final

- Gazelle sahneleri.
- Karahanlı diyalogları ve karşılaşması.
- Kurtarılma sahnesi.
- Oyun sonu.

### Aşama 7 — Polish ve yayın

- Denge.
- Performans.
- Hata düzeltme.
- Ses miksajı.
- Menü ve ayarlar.
- Kayıt sistemi.
- Windows build.
- Mağaza sayfası ve tanıtım materyalleri.

## 23. Dosya ve isimlendirme düzeni

Önerilen proje düzeni:

```text
project/
  assets/
    characters/
      redmount/
      gazelle/
      karahanli/
    enemies/
    weapons/
    pickups/
    environments/
    ui/
    audio/
  scenes/
    characters/
    enemies/
    weapons/
    pickups/
    levels/
    ui/
  scripts/
    characters/
    enemies/
    systems/
  resources/
    weapons/
    powerups/
  saves/
```

Animasyon isimleri küçük harf ve alt çizgi kullanmalıdır:

- `idle`
- `walk`
- `run`
- `jump_start`
- `jump_air`
- `fall`
- `land`
- `attack_01`
- `attack_02`
- `hit_light`
- `knockdown`
- `getup`

## 24. Kalite kontrol listesi

Her yeni animasyonda:

- Karakter boyu diğer karelerle uyumlu mu?
- Ayak baseline üzerinde mi?
- Silüet hareketi anlatıyor mu?
- Hazırlık ve temas kareleri ayırt ediliyor mu?
- Sol yön aynalandığında ekipman bozuluyor mu?
- Transparan arka plan doğru mu?
- Kenarlarda yarı saydam veya bulanık piksel var mı?
- Godot’ta filtreleme kapalı mı?
- Animasyon doğru hızda mı?
- Hitbox yalnız doğru karelerde mi açılıyor?

Her yeni düşmanda:

- Saldırı önceden okunabiliyor mu?
- Oyuncunun karşı hamlesi var mı?
- Aynı anda fazla saldırı gerçekleşiyor mu?
- Düşman platformlarda takılıyor mu?
- Ölüm veya düşme durumu tekrar tetikleniyor mu?

## 25. Açık kararlar

Üretim ilerlemeden önce kesinleştirilmesi gerekenler:

- Karahanlı’nın ana boss mu, hikâye yöneticisi mi olduğu.
- Gazelle’in kaçırılma nedeni.
- Bölümlerin kesin mekân ve isimleri.
- Redmount’ın başlangıç canı ve temel hasarı.
- Silah dayanıklılık değerleri.
- Coin ekonomisi ve mağaza fiyatları.
- Bloklama/dash kontrolünün kesin şekli.
- Windows dışındaki hedef platformlar.
- Karakterlerin arkadan görünümünün yalnız sahnelerde mi, oynanışta mı kullanılacağı.

## 26. Bir sonraki somut adım

Bir sonraki adım Redmount’ın gerçek, elle çizilmiş temel sprite setidir:

1. 128 × 256 px hücrede sağ yan idle ana pozu.
2. Altı kare idle.
3. Sekiz kare yürüme.
4. Altı–sekiz kare koşma.
5. Zıplama, düşme ve iniş kareleri.
6. Godot’a aktarım ve hareket prototipi.

Bu hareket seti Godot içinde doğru görünmeden diğer karakterlerin bütün animasyonlarına geçilmemelidir. Redmount’ın ölçeği, baseline’ı, kamera mesafesi ve animasyon hızı projenin kalan bütün karakterleri için standart olacaktır.

## 27. İlgili mevcut dosya

- Ayrıntılı kare sayıları ve ilk animasyon notları: `outputs/character-animation-bible.md`.

Bu belge projenin ana planıdır. Yeni kararlar alındıkça önce bu dosya güncellenmeli; alt planlar bu belgeyle çelişmemelidir.
