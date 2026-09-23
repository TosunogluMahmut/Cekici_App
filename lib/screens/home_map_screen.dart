import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/location_point.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../widgets/main_drawer.dart';
import 'location_picker_screen.dart';
import 'package_selection_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LocationPoint? _pickup;
  bool _loading = true;
  bool _locatingUser = false;
  String? _error;

  static const _defaultCenter = LatLng(36.8969, 30.7133); // Antalya

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      final address = await _locationService.getAddressFromLatLng(latLng);

      if (mounted) {
        setState(() {
          _pickup = LocationPoint(latLng: latLng, address: address);
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _pickup = const LocationPoint(
            latLng: _defaultCenter,
            address: 'Konum alınamadı - varsayılan konum',
          );
          _loading = false;
        });
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_locatingUser) return;
    setState(() => _locatingUser = true);
    try {
      final position = await _locationService.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      final address = await _locationService.getAddressFromLatLng(latLng);

      if (mounted) {
        setState(() {
          _pickup = LocationPoint(latLng: latLng, address: address);
          _error = null;
          _locatingUser = false;
        });
        _mapController.move(latLng, 15);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locatingUser = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum alınamadı: $e')));
      }
    }
  }

  Future<void> _openDestinationPicker() async {
    if (_pickup == null) return;

    final destination = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialPoint: _pickup!),
      ),
    );

    if (destination == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageSelectionScreen(
          pickup: _pickup!,
          destination: destination,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final userInitials = context.watch<AuthProvider>().currentUser?.initials ?? '';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickup?.latLng ?? _defaultCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.osmTileUrlTemplate,
                userAgentPackageName: AppConfig.androidPackageName,
              ),
              if (_pickup != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickup!.latLng,
                      width: 46,
                      height: 46,
                      child: Icon(
                        Icons.my_location,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Üst bilgi çubuğu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _RoundIconButton(
                    child: userInitials.isNotEmpty 
                      ? Text(userInitials, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16))
                      : Icon(Icons.menu, color: primaryColor),
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const Spacer(),
                  if (_error != null)
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _loading = true);
                          _initCurrentLocation();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Hata - Tekrar dene',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.refresh,
                                  color: theme.colorScheme.onErrorContainer, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Konum Bulma Butonu
          Positioned(
            right: 16,
            bottom: 250,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              elevation: 4,
              onPressed: _goToCurrentLocation,
              child: _locatingUser
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Alt "Nereye gidiyorsun?" kartı (Uber tarzı)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(2), // for gradient border effect
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.5), theme.colorScheme.secondary.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Çekici Çağır',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _pickup?.address ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _openDestinationPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Aracınız nereye götürülecek?',
                                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          '© OpenStreetMap katkıda bulunanlar',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _RoundIconButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
