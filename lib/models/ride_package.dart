import 'package:flutter/material.dart';

/// İki paket türü: sadece çekici hizmeti veya çekici + VIP taksi.
enum PackageType { ekonomik, standart }

/// Kullanıcıya sunulan bir hizmet paketini temsil eder.
class RidePackage {
  final PackageType type;
  final String title;
  final String subtitle;
  final List<String> features;
  final double price;
  final IconData icon;
  final bool includesVipTaxi;

  const RidePackage({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.price,
    required this.icon,
    required this.includesVipTaxi,
  });
}
