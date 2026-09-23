enum VehicleType {
  motorcycle,
  car,
  pickup,
}

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final VehicleType type;
  final String plateNumber;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.type,
    required this.plateNumber,
  });

  String get typeName {
    switch (type) {
      case VehicleType.motorcycle:
        return 'Motosiklet';
      case VehicleType.car:
        return 'Otomobil';
      case VehicleType.pickup:
        return 'Kamyonet';
    }
  }
}

