import 'package:latlong2/latlong.dart';

import '../models/service_history.dart';
import '../models/vehicle.dart';

class HistoryService {
  Future<List<ServiceHistory>> getServiceHistory() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ServiceHistory(
        id: 'sh_1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        pickupAddress: 'Konyaaltı Sahili, Antalya',
        dropoffAddress: 'Muratpaşa Sanayi Sitesi',
        pickupLatLng: const LatLng(36.8778, 30.6300),
        dropoffLatLng: const LatLng(36.9081, 30.7061),
        amount: 850.0,
        status: 'Tamamlandı',
        packageType: 'Standart',
        distanceKm: 8.5,
        durationMinutes: 20,
        driverName: 'Ahmet Yılmaz',
        driverRating: 4.8,
        vehicle: Vehicle(
          id: 'veh_1',
          brand: 'Honda',
          model: 'Civic',
          year: 2020,
          color: 'Beyaz',
          type: VehicleType.car,
          plateNumber: '34 ABC 123',
        ),
      ),
      ServiceHistory(
        id: 'sh_2',
        date: DateTime.now().subtract(const Duration(days: 15)),
        pickupAddress: 'Kepez, Antalya',
        dropoffAddress: 'Eski Sanayi, Antalya',
        pickupLatLng: const LatLng(36.9200, 30.6800),
        dropoffLatLng: const LatLng(36.9081, 30.7061),
        amount: 400.0,
        status: 'Tamamlandı',
        packageType: 'Ekonomik',
        distanceKm: 4.2,
        durationMinutes: 12,
        driverName: 'Mehmet Kaya',
        driverRating: 4.5,
        vehicle: Vehicle(
          id: 'veh_2',
          brand: 'Yamaha',
          model: 'MT-07',
          year: 2022,
          color: 'Siyah',
          type: VehicleType.motorcycle,
          plateNumber: '07 XYZ 98',
        ),
      ),
      ServiceHistory(
        id: 'sh_3',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        pickupAddress: 'Lara Plajı, Antalya',
        dropoffAddress: 'Özel Antalya Servisi',
        pickupLatLng: const LatLng(36.8450, 30.8200),
        dropoffLatLng: const LatLng(36.8800, 30.7300),
        amount: 950.0,
        status: 'Devam Ediyor',
        packageType: 'Standart',
        distanceKm: 12.0,
        durationMinutes: 25,
        driverName: 'Caner Şahin',
        driverRating: 4.9,
        vehicle: Vehicle(
          id: 'veh_3',
          brand: 'Ford',
          model: 'Transit',
          year: 2019,
          color: 'Sarı',
          type: VehicleType.pickup,
          plateNumber: '07 DEF 45',
        ),
      ),
      ServiceHistory(
        id: 'sh_4',
        date: DateTime.now().subtract(const Duration(days: 5)),
        pickupAddress: 'Havalimanı Yolu, Antalya',
        dropoffAddress: 'Ev',
        pickupLatLng: const LatLng(36.9100, 30.7900),
        dropoffLatLng: const LatLng(36.8800, 30.7000),
        amount: 1200.0,
        status: 'İptal Edildi',
        packageType: 'Standart',
        distanceKm: 15.0,
        durationMinutes: 30,
        driverName: null,
        driverRating: null,
        vehicle: Vehicle(
          id: 'veh_4',
          brand: 'Renault',
          model: 'Clio',
          year: 2018,
          color: 'Kırmızı',
          type: VehicleType.car,
          plateNumber: '07 KLM 67',
        ),
      ),
      ServiceHistory(
        id: 'sh_5',
        date: DateTime.now().subtract(const Duration(days: 45)),
        pickupAddress: 'Kemer Yolu',
        dropoffAddress: 'Antalya Merkez',
        pickupLatLng: const LatLng(36.6500, 30.5500),
        dropoffLatLng: const LatLng(36.8969, 30.7133),
        amount: 2500.0,
        status: 'Tamamlandı',
        packageType: 'Standart',
        distanceKm: 40.0,
        durationMinutes: 50,
        driverName: 'Kemal Öztürk',
        driverRating: 4.7,
        vehicle: Vehicle(
          id: 'veh_5',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2021,
          color: 'Gümüş',
          type: VehicleType.car,
          plateNumber: '07 ABC 99',
        ),
      ),
    ];
  }

  Future<List<ServiceHistory>> getFilteredHistory({String? statusFilter}) async {
    final all = await getServiceHistory();
    if (statusFilter == null || statusFilter == 'Tümü') return all;
    return all.where((h) => h.status == statusFilter).toList();
  }
}
