import 'package:flutter/material.dart';

import '../models/ride_package.dart';

/// Ekonomik / Standart paketleri gösteren, Uber'in araç sınıfı
/// seçim kartlarına benzeyen bileşen.
class PackageCard extends StatelessWidget {
  final RidePackage ridePackage;
  final bool selected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.ridePackage,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  selected ? Colors.black : Colors.grey.shade200,
              child: Icon(
                ridePackage.icon,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ridePackage.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ridePackage.subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                  ),
                  if (ridePackage.includesVipTaxi) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'biTaksi ile VIP taksi',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${ridePackage.price.toStringAsFixed(0)} ₺',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
