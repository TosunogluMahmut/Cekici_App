import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';
import '../models/location_point.dart';
import '../services/location_service.dart';

/// Kullanıcının haritadan sürükleyerek veya adres yazarak
/// hedef konum (aracın götürüleceği yer) seçtiği ekran.
class LocationPickerScreen extends StatefulWidget {
  final LocationPoint initialPoint;

  const LocationPickerScreen({super.key, required this.initialPoint});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  late LatLng _selectedLatLng;
  String _selectedAddress = '';
  bool _resolvingAddress = false;
  Timer? _moveDebounce;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialPoint.latLng;
    _selectedAddress = widget.initialPoint.address;
  }

  @override
  void dispose() {
    _moveDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    _selectedLatLng = camera.center;

    // Harita hareket ederken sürekli adres sorgulamamak için
    // hareket durduktan bir süre sonra adresi çöz (debounce).
    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 500), () {
      _resolveAddressForCurrentPin();
    });
  }

  Future<void> _resolveAddressForCurrentPin() async {
    setState(() => _resolvingAddress = true);
    final address = await _locationService.getAddressFromLatLng(_selectedLatLng);
    if (!mounted) return;
    setState(() {
      _selectedAddress = address;
      _resolvingAddress = false;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 700), () async {
      if (value.trim().isEmpty) return;
      final latLng = await _locationService.getLatLngFromAddress(value);
      if (latLng == null || !mounted) return;
      _mapController.move(latLng, 16);
      setState(() => _selectedLatLng = latLng);
      _resolveAddressForCurrentPin();
    });
  }

  void _confirmSelection() {
    Navigator.pop(
      context,
      LocationPoint(latLng: _selectedLatLng, address: _selectedAddress),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 15,
              onPositionChanged: _onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.osmTileUrlTemplate,
                userAgentPackageName: AppConfig.androidPackageName,
              ),
            ],
          ),

          // Sabit ortada duran pin (harita hareket eder, pin sabit kalır)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_pin, size: 46, color: Colors.deepOrange),
              ),
            ),
          ),

          // Üst arama çubuğu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      elevation: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Adres veya konum ara',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Alt onay kartı
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu konumu seç',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _resolvingAddress
                              ? const Text('Adres bulunuyor...')
                              : Text(
                                  _selectedAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resolvingAddress ? null : _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Bu Konumu Onayla'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
