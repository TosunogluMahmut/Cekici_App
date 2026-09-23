import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/ride_package.dart';

/// Verilen mesafeye (km) göre Ekonomik ve Standart paket
/// fiyatlarını hesaplar.
///
/// Ekonomik  = başlangıç ücreti + (mesafe * km_ücreti)
/// Standart  = Ekonomik fiyat + VIP taksi sabit ücreti
///             + (mesafe * VIP taksi km ek ücreti)
class PriceCalculatorService {
  List<RidePackage> calculatePackages(double distanceKm) {
    final ekonomikPrice =
        AppConfig.baseFee + (distanceKm * AppConfig.pricePerKm);

    final standartPrice = ekonomikPrice +
        AppConfig.vipTaxiBaseFee +
        (distanceKm * AppConfig.vipTaxiPerKmSurcharge);

    return [
      RidePackage(
        type: PackageType.ekonomik,
        title: 'Ekonomik',
        subtitle: 'Sadece çekici hizmeti',
        features: const [
          'Aracınız çekici ile taşınır',
          'Çekici sürücüsü ile canlı takip',
        ],
        price: _round(ekonomikPrice),
        icon: Icons.local_shipping_outlined,
        includesVipTaxi: false,
      ),
      RidePackage(
        type: PackageType.standart,
        title: 'Standart (Full)',
        subtitle: 'Çekici + VIP taksi hizmeti',
        features: const [
          'Aracınız çekici ile taşınır',
          'Sizi istediğiniz konuma VIP taksi götürür',
          'biTaksi entegrasyonu ile anlık taksi eşleştirme',
        ],
        price: _round(standartPrice),
        icon: Icons.workspace_premium_outlined,
        includesVipTaxi: true,
      ),
    ];
  }

  double _round(double value) => (value * 100).round() / 100;
}
