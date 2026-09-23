import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleService vehicleService;

  const AddVehicleScreen({super.key, required this.vehicleService});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _brand = '';
  String _model = '';
  int _year = DateTime.now().year;
  String _color = '';
  String _plateNumber = '';
  VehicleType _selectedType = VehicleType.car;

  bool _isSaving = false;

  void _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final newVehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: _brand,
      model: _model,
      year: _year,
      color: _color,
      type: _selectedType,
      plateNumber: _plateNumber,
    );

    await widget.vehicleService.addVehicle(newVehicle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç başarıyla eklendi!')),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildTypeCard(VehicleType type, IconData icon, String label, Color primaryColor) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.grey.shade600, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Araç Ekle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey, // Fixed missing key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Araç Tipi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTypeCard(VehicleType.motorcycle, Icons.two_wheeler, 'Motosiklet', primaryColor),
                        _buildTypeCard(VehicleType.car, Icons.directions_car, 'Otomobil', primaryColor),
                        _buildTypeCard(VehicleType.pickup, Icons.local_shipping, 'Kamyonet', primaryColor),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Plaka',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) => value == null || value.isEmpty ? 'Plaka giriniz' : null,
                      onSaved: (value) => _plateNumber = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Marka',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.branding_watermark),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Marka giriniz' : null,
                      onSaved: (value) => _brand = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Model giriniz' : null,
                      onSaved: (value) => _model = value!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Yıl',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty ? 'Yıl giriniz' : null,
                            onSaved: (value) => _year = int.tryParse(value!) ?? DateTime.now().year,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Renk',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.color_lens),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Renk giriniz' : null,
                            onSaved: (value) => _color = value!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveVehicle,
                        child: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
