import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';
import '../services/location_service.dart';

/// OSRM (Open Source Routing Machine) sonucunu taşıyan basit veri sınıfı.
class RouteResult {
  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> polylinePoints;

  const RouteResult({
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
  });
}

/// İki nokta arasındaki yol mesafesini ve rota çizgisini ücretsiz
/// OSRM demo sunucusu üzerinden hesaplar. Erişilemezse kuş uçuşu
/// mesafe ile devam eder (fallback).
class DirectionsService {
  final LocationService _locationService = LocationService();

  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      '${AppConfig.osrmBaseUrl}/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];

          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toInt();

          final coordinates =
              route['geometry']['coordinates'] as List; // [lon, lat] çiftleri

          final polylinePoints = coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          return RouteResult(
            distanceKm: distanceMeters / 1000.0,
            durationMinutes: (durationSeconds / 60).round(),
            polylinePoints: polylinePoints,
          );
        }
      }
    } catch (_) {
      // Ağ hatası -> fallback kullanılacak.
    }

    // FALLBACK: kuş uçuşu mesafe + ortalama hız ile tahmini süre.
    final km = _locationService.haversineDistanceKm(origin, destination);
    final estimatedMinutes =
        ((km / AppConfig.averageCitySpeedKmh) * 60).round();

    return RouteResult(
      distanceKm: km,
      durationMinutes: estimatedMinutes < 1 ? 1 : estimatedMinutes,
      polylinePoints: [origin, destination],
    );
  }
}
