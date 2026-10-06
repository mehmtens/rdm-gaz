# İnsan testi rehberi (kısa oturum)

Bu rehber Haliç'te Şafak, Bölüm 6, Vaniköy ve Son Yayın'daki parkur ve dövüş
değişikliklerini insan gözüyle denemek içindir. Toplam süre 30–45 dakikadır.

Bot testleri insan oynanışı yerine geçmez. Bu oturumun amacı, botun ölçemediği
şeyleri (zamanlama hissi, okunurluk, adalet, sıkıcılık) görmektir.

## Kurulum

Gerekenler: Godot **4.7** (proje `config/features` = 4.7), Git, depo.

```
git clone https://github.com/mehmtens/rdm-gaz.git
cd rdm-gaz
git checkout claude/optimistic-bohr-ql1uss
cd redmount
godot --headless --path . --import          # ilk açılışta bir kez (2–5 dk)
```

Normal oyun (ana menüden): `godot --path .`

## Test başlatma: bölüm ve kontrol noktası seçimi

```
godot --path . res://scenes/Main.tscn -- --bolum=33 --bayrak=17
```

- `--bolum=N`: 1–36 arası bölüm. Ana menüdeki kilitleri atlar.
- `--bayrak=K`: bölümün x'e göre K. kontrol noktasından başlar. Verilmezse bölüm başından.
  Konsola o bölümün bütün bayrakları yazılır (`TEST bayrak K: x=...`).
- Bayraktan başlamak, oyunun `R` (son kontrol noktası) yolunun aynısıdır: tam can, o
  noktaya yerleşme. Bölüm kuralları, düşmanlar ve hasar değişmez.
- **Fark:** bölümün o noktaya kadarki silah, zırh ve coin'leri alınmamış olur.
- **Kayıt:** test başlatmada gerçek kayıt (`redmount_save.cfg`) okunmaz ve yazılmaz.
  Ayrı ve boş bir `redmount_test_save.cfg` kullanılır, yani mağaza yükseltmesi olmayan
  yeni bir oyuncu gibi başlarsın. Bot testleri de böyle çalışır.

Windows'ta `godot` yerine Godot exe'sinin tam yolunu yaz. Komutlar `redmount` klasöründen
çalıştırılır.

## Tuşlar

| Tuş | İşlev |
|---|---|
| `A`/`D` veya `←`/`→` | Hareket |
| `Shift` (basılı) | Koş |
| `Space`/`W`/`↑` | Zıpla. Tente üstünde basılı tutarsan daha yükseğe fırlatır |
| `J` / `K` / `L` | Vuruş / ağır yumruk / ateş |
| `Ctrl` | Dash |
| `S`+`Space` | Tek yön platformdan aşağı in |
| Duvara doğru bas, havada `Space` | Duvar zıplaması |
| `R` | Son kontrol noktasına dön (tam can) |
| `Esc` | Duraklat |

## Bakılacak sahneler ve kontrol listeleri

Her maddeye **evet / hayır / emin değilim** ile cevap ver ve bir cümle not al. "Hayır"
cevapları en değerli geri bildirimdir.

### 1. Haliç'te Şafak (Bölüm 13): parkur fikirlerinin tanıtımı

| Komut | Sahne |
|---|---|
| `--bolum=13` | baştan: ilk çatı zinciri (tek nöbetçi) |
| `--bolum=13 --bayrak=3` | balkon tırmanışı + zırh ödülü |
| `--bolum=13 --bayrak=5` | tente sekmesi, iki aralıkta düşman |
| `--bolum=13 --bayrak=15` | ikinci çatı zinciri (iki nöbetçi) |

- [ ] Tentenin fırlatacağını ilk denemede anladım mı (çizgili kumaş, coin yayı)?
- [ ] Tenteye basılı tutarak zıplamanın farkı hissediliyor mu?
- [ ] Çatıdaki düşmanı yerden görüp ona göre plan yapabildim mi?
- [ ] Ara sokağa düşünce yeniden çıkış yolu (iki balkon) açık mıydı?
- [ ] Balkonların tek yön olduğu (alttan geçilir) belli mi?
- [ ] Ödül (zırh) görünüyor ve ulaşılabilir mi?
- [ ] Sahnede ölünce `R` ya da ölüm beni sahnenin hemen önüne mi getirdi?

### 2. Bölüm 6, Ağır Güvenlik Bölgesi: bu turda düzeltilen hatalar

| Komut | Sahne |
|---|---|
| `--bolum=6 --bayrak=3` | arenaya yürüyerek gir (kapılar kilitlenir) |
| `--bolum=6 --bayrak=5` | arena sonrası boşluk ve uzun rotanın başı |

- [ ] Arenadaki iki siper (90 px'e indirildi) zıplanarak aşılıyor mu? Hâlâ siper gibi
      duruyor mu, yoksa anlamsız mı kaldı?
- [ ] Yalnız yumrukla arenayı temizleyebildim mi? Bir yerde sıkıştım mı?
- [ ] Arenadan sonra rota açık mı (eski bitiş duvarı kaldırıldı)?
- [ ] 200 px'lik boşluk koşarak rahatça atlanıyor mu? Boşluk önceden görülüyor mu?
- [ ] Bölüm sonuna kadar (~49.000 px) gidebildim mi?

### 3. Vaniköy Gece Sevkiyatı (Bölüm 33): gece okunurluğu ve sandık nöbetçisi

| Komut | Sahne |
|---|---|
| `--bolum=33` | baştan: gece çatı zinciri |
| `--bolum=33 --bayrak=13` | iskele barikatı, tüfekli üstte |
| `--bolum=33 --bayrak=17` | sandık yığını, seçkin muhafız iniş tarafında |

- [ ] Karanlık iç mekânda düşmanları rahatça görebildim mi (ince sarı kontur)?
- [ ] Kontur göze batıyor mu ya da oyunun piksel diline yabancı mı duruyor?
- [ ] İnce iskele ve rafların basılacak kenarı belli mi (açık kenar çizgisi)?
- [ ] Sandık yığınındaki seçkin muhafızla dövüş adil mi? Yığından üstüne inmek işe yarıyor mu?
- [ ] Tüfeklinin mermilerini karanlıkta görüp kaçabildim mi?
- [ ] Ölünce dönüş noktası sahnenin hemen önü müydü?

### 4. Son Yayın (Bölüm 36): final temposu

| Komut | Sahne |
|---|---|
| `--bolum=36 --bayrak=20` | iskele sahnesi (makine dairesi) |
| `--bolum=36 --bayrak=28` | sandık siperi |
| `--bolum=36 --bayrak=41` | final düellosu (boss) |

- [ ] Makine dairesinde düşman, iskele ve coin birbirinden ayrılıyor mu?
- [ ] İç mekân sahneleri (iskele, siper, sandık) arka arkaya geldiğinde tekrar gibi
      hissettiriyor mu? Hangi noktada sıkıldım?
- [ ] Boss'un saldırılarını okuyup kaçabiliyor muyum? Arena içinde ölünce arena girişine
      mi dönüyorum?
- **Not:** Bitiş kapısı ancak üç yayın hattı kesilince açılır. `--bayrak=41` ile yalnız boss
  denenir; bitiş görülmez. Bitişi görmek için bölümü baştan (`--bolum=36`) oyna.

## Geri bildirim şablonu

```
Bölüm / bayrak:
Ne yaptım:
Ne bekliyordum:
Ne oldu:
Kaç denemede geçtim / kaç kez öldüm:
Sıkıcı / haksız / güzel bulduğum an:
```
