# Fabrika Çatısı — 2D Bölüm Taslağı

**Hedef süre:** İlk tamamlamada 5–7 dakika. **Tempo:** Yaklaşık 20–35 saniyelik parkur ve dövüş parçaları dönüşümlü gelir. Prototip süre, erişilebilirlik ve zorluk için oyuncu testleri gerektirir.

## Kabaca harita

```text
BAŞLANGIÇ
  │ güvenli koşu + iki görünür atlayış
  ▼
[A] Eğitim çatısı ── üst para hattı ──┐
  │                                   │
  ▼                                   ▼
[B] Tek hareketli platform ──────── birleşme
  │
  ▼
[C] Tek buhar çıkışı → buhar + hareketli platform
  │
  ▼
[D] Dar geçit: iki düşman → kontrol noktası
  │
  ├── ana rota: geniş iniş, tek tehlike ──┐
  └── üst rota: kısa atlayışlar + para ───┤
                                         ▼
[E] Kısa kovalamaca → [F] final dövüşü → ÇIKIŞ
```

## Engel sırası ve amaç

| Sıra | Durum | Ölçülmek istenen davranış |
|---|---|---|
| 1 | Düz koşu ve güvenli boşluklar | Kontrol ve zıplama mesafesini hatırlama |
| 2 | Sabit zeminden hareketli platforma geçiş | Platform hareketini okuma |
| 3 | Geniş zeminde tek buhar çıkışı | Görsel uyarıdan sonra zamanlama |
| 4 | Hareketli platform + buhar | Öğrenilen iki hareketi birleştirme |
| 5 | Dar geçitte iki düşman | Kısa dövüş, geri çekilme ve konum alma |
| 6 | Kontrol noktası ve iki rota | Ana rotada güven, üst rotada isteğe bağlı risk |
| 7 | Kısa kovalamaca | Akıcı hareketi baskı altında kullanma |
| 8 | Final karşılaşması | Buhar ve platformlarla birlikte dövüşme |

## Gri kutu kabul ölçütleri

- Kritik iniş yüzeyi, oyuncu atlamadan önce ekranda görünür.
- İlk kez görülen her tehlike güvenli bir alanda tek başına deneyimlenir.
- Düşüşten sonra son kontrol noktasına dönüş iki saniyeden kısa sürer.
- Ana rota ödül toplamadan tamamlanabilir; üst rota yalnızca para verir.
- Testte kesintisiz koşu veya kesintisiz dövüş aralığı 35 saniyeyi aşmaz.
- İlk oynayış ortalama 5–7 dakika hedefler; prototipte süre gerçek oyuncu testleriyle ayarlanır.
