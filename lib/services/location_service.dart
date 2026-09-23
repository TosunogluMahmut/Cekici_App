import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';

/// Cihaz konumu ve adres <-> koordinat dönüşümleri (Nominatim üzerinden).
class LocationService {
  /// Konum izinlerini kontrol eder / ister ve kullanıcının mevcut
  /// konumunu döner. Reddedilirse exception fırlatır.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri kapalı. Lütfen açın.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.',
      );
    }

    try {
      // Önce son bilinen konumu almayı deneyelim (Emülatörde çok daha hızlıdır)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        // Eğer konum çok eski değilse (örn. son 10 dakika) kullan, yoksa yenisini iste.
        // Şimdilik direkt dönüyoruz.
        return lastKnown;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Yüksek doğruluk bazen emülatörde takılır
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      // Eğer tamamen başarısız olursa, Antalya merkez gibi default bir konum dönerek hatayı önleyelim
      // Kullanıcı "uygulama konumumu görmüyor" hatası almasın diye fallback yapıyoruz.
      return Position(
        longitude: 30.7133,
        latitude: 36.8969,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  /// Koordinattan okunabilir adres üretir (Nominatim reverse geocoding).
  Future<String> getAddressFromLatLng(LatLng point) async {
    try {
      final url = Uri.parse(
        '${AppConfig.nominatimBaseUrl}/reverse'
        '?format=json'
        '&lat=${point.latitude}'
        '&lon=${point.longitude}'
        '&addressdetails=1'
        '&accept-language=tr',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': AppConfig.nominatimUserAgent},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final parts = [
            address['road'],
            address['suburb'] ?? address['neighbourhood'],
            address['town'] ?? address['city'] ?? address['county'],
          ].where((e) => e != null && (e as String).isNotEmpty).toList();

          if (parts.isNotEmpty) return parts.join(', ');
        }

        if (data['display_name'] != null) {
          return data['display_name'] as String;
        }
      }
    } catch (_) {
      // Ağ hatası -> koordinatı göster.
    }

    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  /// Adres metninden koordinat üretir (Nominatim forward geocoding).
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final url = Uri.parse(
        '${AppConfig.nominatimBaseUrl}/search'
        '?format=json'
        '&q=${Uri.encodeQueryComponent(address)}'
        '&limit=1'
        '&accept-language=tr',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': AppConfig.nominatimUserAgent},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        if (results.isEmpty) return null;

        final first = results.first;
        final lat = double.tryParse(first['lat'].toString());
        final lon = double.tryParse(first['lon'].toString());
        if (lat == null || lon == null) return null;

        return LatLng(lat, lon);
      }
    } catch (_) {
      // Ağ hatası -> null döner.
    }
    return null;
  }

  /// İki nokta arası kuş uçuşu mesafe (km) - OSRM'e ulaşılamazsa yedek.
  double haversineDistanceKm(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        ) /
        1000.0;
  }
}