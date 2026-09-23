/// Uygulama genelinde kullanılan sabitler ve konfigürasyon değerleri.
///
/// Harita: OpenStreetMap (flutter_map) - API anahtarı GEREKMEZ.
/// Rota/mesafe: OSRM (ücretsiz, herkese açık demo sunucusu).
/// Adres arama / reverse geocoding: Nominatim (ücretsiz, OpenStreetMap).
class AppConfig {
  AppConfig._();

  // ---------------- HARİTA (OpenStreetMap) ----------------

  /// OSM standart tile sunucusu. Yoğun kullanımda kendi tile
  /// sunucunuzu (ör. MapTiler, Stadia Maps) kullanmanız önerilir.
  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// flutter_map'in tile isteklerinde göndereceği User-Agent paket adı.
  /// android/app/build.gradle.kts içindeki applicationId ile aynı olmalı.
  static const String androidPackageName = 'com.met.cekici_app';

  // ---------------- ROTA (OSRM) ----------------

  static const String osrmBaseUrl = 'https://router.project-osrm.org';

  // ---------------- ADRES ARAMA (Nominatim) ----------------

  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Nominatim kullanım politikası gereği geçerli bir User-Agent
  /// veya iletişim bilgisi göndermek zorunludur.
  static const String nominatimUserAgent =
      'cekici_app/1.0 (iletisim@sirketiniz.com)';

  // ---------------- FİYATLANDIRMA ----------------

  /// Km başına temel çekici ücreti (TL)
  static const double pricePerKm = 35.0;

  /// Çağrı açma / minimum hizmet ücreti (TL)
  static const double baseFee = 20.0;

  /// Standart (Full) pakette dahil olan VIP taksi hizmeti için
  /// km başına ek ücret (TL). İleride biTaksi entegrasyonu ile
  /// bu ücret gerçek zamanlı biTaksi tarifesinden çekilecek.
  static const double vipTaxiPerKmSurcharge = 20.0;

  /// VIP taksi hizmeti için sabit ek ücret (TL)
  static const double vipTaxiBaseFee = 15.0;

  /// OSRM/Nominatim'e erişilemezse (ör. internet yok) kullanılacak
  /// ortalama şehir içi hız (km/sa) - süre tahmini için.
  static const double averageCitySpeedKmh = 30.0;
}
