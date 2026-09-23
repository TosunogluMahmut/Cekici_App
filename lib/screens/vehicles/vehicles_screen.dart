import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import 'add_vehicle_screen.dart';
import '../../widgets/empty_state_widget.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getMyVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.pickup:
        return Icons.local_shipping;
    }
  }

  void _deleteVehicle(int index) {
    setState(() {
      _vehicles.removeAt(index);
    });
    // In a real app, you would also call _vehicleService.deleteVehicle(id) here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Araç silindi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlarım'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _vehicles.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.directions_car_outlined,
                  title: 'Henüz Araç Eklenmedi',
                  subtitle: 'Araçlarınızı ekleyerek çekici çağırırken kolayca seçim yapabilirsiniz.',
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _loadVehicles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return Dismissible(
                        key: Key(vehicle.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => _deleteVehicle(index),
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Large vehicle type icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getVehicleIcon(vehicle.type),
                                    size: 32,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Vehicle info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.plateNumber,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${vehicle.brand} ${vehicle.model} (${vehicle.year})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Color dot
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _getColorFromName(vehicle.color),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVehicleScreen(vehicleService: _vehicleService),
            ),
          );
          if (result == true && mounted) {
            setState(() => _isLoading = true);
            _loadVehicles();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('beyaz')) return Colors.white;
    if (name.contains('siyah')) return Colors.black;
    if (name.contains('kırmızı')) return Colors.red;
    if (name.contains('mavi')) return Colors.blue;
    if (name.contains('gri')) return Colors.grey;
    if (name.contains('sarı')) return Colors.yellow;
    if (name.contains('yeşil')) return Colors.green;
    return Colors.grey.shade400; // Default
  }
}
