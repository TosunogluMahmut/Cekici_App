# Çekici Çağır Uygulaması

Uber tarzı arayüze sahip, kullanıcının seçtiği konuma göre çekici çağırabildiği
Flutter uygulaması. İki paket sunar:

- **Ekonomik** → sadece çekici hizmeti
- **Standart (Full)** → çekici hizmeti + aracı istenilen konuma götüren VIP taksi
  (ileride **biTaksi** entegrasyonu ile eşleştirilecek)

Fiyatlandırma mesafeye göre otomatik hesaplanır: **35 TL/km** (bkz.
`lib/config/app_config.dart`).

## Harita alt yapısı: OpenStreetMap (API anahtarı / kart GEREKMEZ)

Bu proje **Google Maps yerine OpenStreetMap** kullanır:

| İhtiyaç | Servis | Ücret |
|---|---|---|
| Harita görüntüleme | `flutter_map` + OSM tile sunucusu | Ücretsiz |
| Rota / mesafe hesaplama | OSRM (`router.project-osrm.org`) | Ücretsiz |
| Adres arama / reverse geocoding | Nominatim (`nominatim.openstreetmap.org`) | Ücretsiz |

Hiçbir API anahtarı, kredi kartı veya faturalandırma hesabı gerekmez.

---

## 1) Projeyi kurma

```bash
flutter create --project-name cekici_app --org com.met .
flutter pub get
```

Bu komut `android/` ve `ios/` klasörlerini otomatik oluşturur; mevcut
`lib/` ve `pubspec.yaml` dosyalarınız korunur (üzerine yazmaz).

## 2) Android izinleri

`android/app/src/main/AndroidManifest.xml` dosyasında `<manifest>` etiketi
içine (application'dan önce) şu izinleri ekleyin:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## 3) Çalıştırma

```bash
flutter pub get
flutter run
```

---

## Uygulama Akışı

1. **Ana ekran** (`home_map_screen.dart`): Kullanıcının anlık konumu
   OSM haritasında gösterilir, alt kartta "Aracınız nereye götürülecek?" araması.
2. **Konum seçimi** (`location_picker_screen.dart`): Kullanıcı Nominatim ile
   adres arar veya haritayı sürükleyerek hedef konumu seçer.
3. **Paket seçimi** (`package_selection_screen.dart`): OSRM ile hesaplanan
   rota haritada çizilir, mesafe/süre hesaplanır, **Ekonomik** ve **Standart**
   paket fiyatları gösterilir (kart seçilebilir).
4. **Onay ekranı** (`confirmation_screen.dart`): Seçilen paket özeti,
   toplam ücret ve — Standart paket seçildiyse — biTaksi entegrasyon notu.

## Fiyatlandırma mantığı (`price_calculator_service.dart`)

```
Ekonomik  = baseFee (20 TL) + mesafe(km) * 35 TL
Standart  = Ekonomik fiyatı + vipTaxiBaseFee (15 TL) + mesafe(km) * 20 TL
```

Tüm sabitler `lib/config/app_config.dart` içinden kolayca değiştirilebilir.

## OpenStreetMap kullanım politikası ve önemli notlar

- **Nominatim** (adres arama) ücretsiz ama **saniyede 1 istekle sınırlıdır**
  ve geçerli bir `User-Agent` göndermeniz zorunludur (zaten `app_config.dart`
  içinde tanımlı: `nominatimUserAgent`). Yoğun/production kullanımda kendi
  Nominatim sunucunuzu kurmanız veya bir sağlayıcıdan (LocationIQ, Geoapify
  vb. — genelde ücretsiz katmanları var) API anahtarı almanız önerilir.
- **OSRM demo sunucusu** (`router.project-osrm.org`) test/geliştirme
  amaçlıdır, production'da SLA garantisi yoktur. Yoğun kullanımda kendi OSRM
  sunucunuzu Docker ile ayağa kaldırabilir veya bir ücretli alternatif
  (Mapbox Directions, OpenRouteService vb.) kullanabilirsiniz.
- Harita üzerinde **"© OpenStreetMap katkıda bulunanlar"** atfı zorunludur;
  ana ekranda bu zaten eklenmiştir, kaldırmayın.

## biTaksi Entegrasyonu (İleri Seviye - TODO)

Şu an Standart pakette VIP taksi ücreti, `AppConfig` içindeki sabit
`vipTaxiPerKmSurcharge` ile hesaplanıyor. biTaksi entegrasyonu
eklendiğinde yapılacaklar:

1. `lib/services/` altına `bitaksi_service.dart` eklenip biTaksi
   partner API'si ile gerçek zamanlı tarife ve sürücü eşleştirme çağrısı
   yapılmalı.
2. `PriceCalculatorService` içindeki sabit `vipTaxi...` değerleri,
   biTaksi'den dönen gerçek tarife ile değiştirilmeli.
3. `ConfirmationScreen`'deki "geliştirme aşamasında" bilgi kutusu,
   gerçek sürücü/araç bilgisi gösteren bir bileşenle değiştirilmeli.

## İleride Google Maps'e geçmek isterseniz

Kod, servis katmanı (`LocationService`, `DirectionsService`) ile UI
katmanını (ekranlar) ayırdığı için ileride Google Maps'e (veya Mapbox'a)
geçmek isterseniz sadece bu iki servisi ve harita widget'larını
(`FlutterMap` → `GoogleMap`) değiştirmeniz yeterli olur; fiyatlandırma ve
paket mantığı (`PriceCalculatorService`, `RidePackage`) hiç değişmez.
