import 'package:flutter/material.dart';

import '../models/location_point.dart';
import '../models/ride_package.dart';
import '../services/directions_service.dart';

/// Çağrı onaylandıktan sonra gösterilen özet ekran.
/// Gerçek sürücü eşleştirme / biTaksi entegrasyonu backend
/// tarafı geliştirildiğinde bu ekrana bağlanacak.
class ConfirmationScreen extends StatelessWidget {
  final LocationPoint pickup;
  final LocationPoint destination;
  final RidePackage selectedPackage;
  final RouteResult route;

  const ConfirmationScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.selectedPackage,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çağrınız Alındı')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                '${selectedPackage.title} paketiniz çağrılıyor',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'En yakın çekici size yönlendiriliyor. Tahmini varış: '
                '${(route.durationMinutes * 0.4).round()} dk',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _InfoRow(icon: Icons.my_location, label: 'Alınacak konum', value: pickup.address),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.flag, label: 'Hedef konum', value: destination.address),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.route,
                label: 'Mesafe',
                value: '${route.distanceKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.payments_outlined,
                label: 'Toplam Ücret',
                value: '${selectedPackage.price.toStringAsFixed(0)} ₺',
              ),
              if (selectedPackage.includesVipTaxi) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'VIP taksi hizmetiniz biTaksi entegrasyonu ile '
                          'eşleştirilecek. Bu entegrasyon şu an geliştirme '
                          'aşamasındadır.',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
