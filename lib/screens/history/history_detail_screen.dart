import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../models/service_history.dart';
import '../../config/app_config.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ServiceHistory history;

  const HistoryDetailScreen({super.key, required this.history});

  String _formatDate(DateTime date) {
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${date.day} ${months[date.month]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tamamlandı':
        return Colors.green;
      case 'İptal Edildi':
        return Colors.red;
      case 'Devam Ediyor':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(history.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yolculuk Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: history.pickupLatLng != null && history.dropoffLatLng != null
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter: history.pickupLatLng!,
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: AppConfig.osmTileUrlTemplate,
                            userAgentPackageName: AppConfig.androidPackageName,
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [history.pickupLatLng!, history.dropoffLatLng!],
                                color: theme.colorScheme.primary,
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: history.pickupLatLng!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.circle, color: Colors.green, size: 24),
                              ),
                              Marker(
                                point: history.dropoffLatLng!,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.map, size: 50, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  history.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Rota Bilgileri
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rota Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 16),
                            Container(height: 30, width: 2, color: Colors.grey.shade300),
                            const Icon(Icons.location_on, color: Colors.red, size: 18),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(history.pickupAddress, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 24),
                              Text(history.dropoffAddress, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Yolculuk Bilgileri
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Yolculuk Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tarih', _formatDate(history.date)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Mesafe', '${history.distanceKm.toStringAsFixed(1)} km'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Süre', '${history.durationMinutes} dk'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Paket', '${history.packageType} Paket'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Araç Bilgileri
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Araç Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Marka / Model', '${history.vehicle.brand} ${history.vehicle.model}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Yıl', '${history.vehicle.year}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Plaka', history.vehicle.plateNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow('Renk', history.vehicle.color),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sürücü Bilgileri
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sürücü Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildInfoRow('İsim', history.driverName ?? 'Bilgi mevcut değil'),
                    const SizedBox(height: 8),
                    if (history.driverRating != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Puan', style: TextStyle(color: Colors.grey)),
                          Row(
                            children: [
                              Text('${history.driverRating}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                        ],
                      )
                    else
                      _buildInfoRow('Puan', 'Değerlendirilmedi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Ücret Bilgileri
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      '₺${history.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tekrar Çağır', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yakında!')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
                side: BorderSide(color: theme.colorScheme.secondary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Fatura İndir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
