import 'package:latlong2/latlong.dart';
import 'vehicle.dart';

class ServiceHistory {
  final String id;
  final DateTime date;
  final String pickupAddress;
  final String dropoffAddress;
  final LatLng? pickupLatLng;
  final LatLng? dropoffLatLng;
  final double amount;
  final Vehicle vehicle;
  final String status; // 'Tamamlandı', 'İptal Edildi', 'Devam Ediyor'
  final String packageType; // 'Ekonomik', 'Standart'
  final double distanceKm;
  final int durationMinutes;
  final String? driverName;
  final double? driverRating;

  ServiceHistory({
    required this.id,
    required this.date,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupLatLng,
    this.dropoffLatLng,
    required this.amount,
    required this.vehicle,
    required this.status,
    this.packageType = 'Ekonomik',
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.driverName,
    this.driverRating,
  });
}
