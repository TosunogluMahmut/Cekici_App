import 'package:latlong2/latlong.dart';

/// Haritada seçilen bir noktayı (konum + adres metni) temsil eder.
class LocationPoint {
  final LatLng latLng;
  final String address;

  const LocationPoint({
    required this.latLng,
    required this.address,
  });

  LocationPoint copyWith({LatLng? latLng, String? address}) {
    return LocationPoint(
      latLng: latLng ?? this.latLng,
      address: address ?? this.address,
    );
  }

  @override
  String toString() => address;
}
