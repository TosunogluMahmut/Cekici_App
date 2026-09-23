import 'package:flutter/material.dart';
import '../../models/service_history.dart';
import '../../services/history_service.dart';
import 'history_detail_screen.dart';
import '../../widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<ServiceHistory>? _history;
  bool _loading = true;
  String _selectedFilter = 'Tümü';
  final List<String> _filters = ['Tümü', 'Tamamlandı', 'İptal Edildi', 'Devam Ediyor'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final history = await _historyService.getFilteredHistory(statusFilter: _selectedFilter);
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _loadHistory();
                      }
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              color: theme.colorScheme.primary,
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                  : _history == null || _history!.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            EmptyStateWidget(
                              icon: Icons.history,
                              title: 'Kayıt Bulunamadı',
                              subtitle: 'Bu kategoriye ait geçmiş işleminiz bulunmuyor.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history!.length,
                          itemBuilder: (context, index) {
                            final item = _history![index];
                            final statusColor = _getStatusColor(item.status);
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryDetailScreen(history: item),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 3,
                                shadowColor: Colors.black.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(item.date),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                            ),
                                            child: Text(
                                              item.status,
                                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              const Icon(Icons.circle, color: Colors.green, size: 14),
                                              Container(
                                                height: 30,
                                                width: 2,
                                                color: Colors.grey.shade300,
                                              ),
                                              const Icon(Icons.location_on, color: Colors.red, size: 16),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.pickupAddress,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  item.dropoffAddress,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        children: [
                                          Icon(
                                            item.vehicle.type.name == 'motorcycle' ? Icons.motorcycle : Icons.directions_car,
                                            size: 20,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${item.vehicle.brand} ${item.vehicle.model}',
                                            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.grey.shade400),
                                            ),
                                            child: Text(
                                              item.vehicle.plateNumber,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.packageType} Paket',
                                              style: TextStyle(
                                                color: theme.colorScheme.tertiary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₺${item.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
