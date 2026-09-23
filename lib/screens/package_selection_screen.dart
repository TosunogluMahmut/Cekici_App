import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../config/app_config.dart';
import '../models/location_point.dart';
import '../models/ride_package.dart';
import '../services/directions_service.dart';
import '../services/price_calculator_service.dart';
import '../widgets/package_card.dart';
import 'confirmation_screen.dart';

/// Pickup ve hedef konum belirlendikten sonra rotayı haritada
/// gösterir, mesafeyi hesaplar ve iki paket teklifini sunar.
class PackageSelectionScreen extends StatefulWidget {
  final LocationPoint pickup;
  final LocationPoint destination;

  const PackageSelectionScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  final DirectionsService _directionsService = DirectionsService();
  final PriceCalculatorService _priceCalculator = PriceCalculatorService();
  final MapController _mapController = MapController();

  RouteResult? _route;
  List<RidePackage> _packages = [];
  PackageType? _selectedType;
  bool _loading = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final route = await _directionsService.getRoute(
      origin: widget.pickup.latLng,
      destination: widget.destination.latLng,
    );

    final packages = _priceCalculator.calculatePackages(route.distanceKm);

    if (!mounted) return;
    setState(() {
      _route = route;
      _packages = packages;
      _selectedType = packages.first.type; // varsayılan: Ekonomik seçili
      _loading = false;
    });

    _fitCameraToRoute();
  }

  void _fitCameraToRoute() {
    if (!_mapReady || _route == null || _route!.polylinePoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(_route!.polylinePoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(40, 100, 40, 320),
      ),
    );
  }

  void _confirmCall() {
    if (_selectedType == null || _route == null) return;

    final selectedPackage =
        _packages.firstWhere((p) => p.type == _selectedType);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          pickup: widget.pickup,
          destination: widget.destination,
          selectedPackage: selectedPackage,
          route: _route!,
        ),
      ),
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
              initialCenter: widget.pickup.latLng,
              initialZoom: 14,
              onMapReady: () {
                _mapReady = true;
                _fitCameraToRoute();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.osmTileUrlTemplate,
                userAgentPackageName: AppConfig.androidPackageName,
              ),
              if (_route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route!.polylinePoints,
                      color: Colors.black87,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.pickup.latLng,
                    width: 42,
                    height: 42,
                    child: const Icon(Icons.trip_origin, color: Colors.green, size: 30),
                  ),
                  Marker(
                    point: widget.destination.latLng,
                    width: 42,
                    height: 42,
                    child: const Icon(Icons.location_on, color: Colors.deepOrange, size: 34),
                  ),
                ],
              ),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
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
            ),
          ),

          // Alt panel: mesafe bilgisi + paket kartları
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.route, size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(
                                '${_route!.distanceKm.toStringAsFixed(1)} km · '
                                '≈ ${_route!.durationMinutes} dk',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ..._packages.map(
                            (pkg) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: PackageCard(
                                ridePackage: pkg,
                                selected: _selectedType == pkg.type,
                                onTap: () =>
                                    setState(() => _selectedType = pkg.type),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirmCall,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Çekiciyi Çağır',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
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
