import '../models/vehicle.dart';

class VehicleService {
  final List<Vehicle> _mockVehicles = [
    Vehicle(
      id: 'veh_1',
      brand: 'Honda',
      model: 'Civic',
      year: 2020,
      color: 'Beyaz',
      type: VehicleType.car,
      plateNumber: '34 ABC 123',
    ),
    Vehicle(
      id: 'veh_2',
      brand: 'Yamaha',
      model: 'MT-07',
      year: 2022,
      color: 'Siyah',
      type: VehicleType.motorcycle,
      plateNumber: '07 XYZ 98',
    ),
  ];

  Future<List<Vehicle>> getMyVehicles() async {
    await Future.delayed(const Duration(seconds: 1));
    return [..._mockVehicles];
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockVehicles.add(vehicle);
  }
}

