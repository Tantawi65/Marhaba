import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_location.dart';
import '../services/location_service.dart';

class ServicesMapScreen extends StatefulWidget {
  const ServicesMapScreen({super.key});

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen> {
  ServiceType _selectedServiceType = ServiceType.hospital;
  Position? _userLocation;
  List<ServiceLocation> _currentServices = [];
  ServiceLocation? _nearestService;
  bool _isLoading = false;
  String _searchQuery = '';
  
  // Simple map view properties for Turkey
  double _mapCenterLat = 39.9334; // Turkey center
  double _mapCenterLng = 32.8597;
  double _mapZoom = 6.0;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _getCurrentLocation();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadServices();
    setState(() => _isLoading = false);
  }

  Future<void> _loadServices() async {
    try {
      print('🔍 Loading ${_selectedServiceType.displayName} services for Turkey');
      
      List<ServiceLocation> services = await LocationService.getServicesByType(
        Country.turkey, 
        _selectedServiceType
      );
      
      // If user location is available, sort by distance and find nearest
      if (_userLocation != null && services.isNotEmpty) {
        services.sort((a, b) {
          final distanceA = LocationService.calculateDistance(
            _userLocation!.latitude, _userLocation!.longitude,
            a.latitude, a.longitude
          );
          final distanceB = LocationService.calculateDistance(
            _userLocation!.latitude, _userLocation!.longitude,
            b.latitude, b.longitude
          );
          return distanceA.compareTo(distanceB);
        });
        
        // Set nearest service
        _nearestService = services.first;
        print('📍 Nearest ${_selectedServiceType.displayName}: ${_nearestService!.name}');
      }
      
      print('✅ Loaded ${services.length} ${_selectedServiceType.displayName} services');
      
      setState(() {
        _currentServices = services;
      });
    } catch (e) {
      print('❌ Error loading services: $e');
      setState(() {
        _currentServices = [];
        _nearestService = null;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 Location permissions denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Location permissions permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      print('📍 Got user location: ${position.latitude}, ${position.longitude}');
      
      setState(() {
        _userLocation = position;
        _mapCenterLat = position.latitude;
        _mapCenterLng = position.longitude;
        _mapZoom = 12.0;
      });
      
      // Reload services with location for sorting
      await _loadServices();
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  void _onServiceTypeChanged(ServiceType serviceType) {
    setState(() {
      _selectedServiceType = serviceType;
    });
    _loadServices();
  }

  List<ServiceLocation> get _filteredServices {
    if (_searchQuery.isEmpty) return _currentServices;
    
    return _currentServices.where((service) {
      return service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             service.fullAddress.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showServiceDetails(ServiceLocation service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildServiceDetailsSheet(service),
    );
  }

  Widget _buildServiceDetailsSheet(ServiceLocation service) {
    final distance = _userLocation != null 
        ? LocationService.calculateDistance(
            _userLocation!.latitude, _userLocation!.longitude,
            service.latitude, service.longitude
          )
        : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Service Icon and Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D59).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getServiceIcon(_selectedServiceType),
                            color: const Color(0xFF2E7D59),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _selectedServiceType.displayName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Address
                    _buildDetailRow(Icons.location_on, 'Address', service.fullAddress),
                    const SizedBox(height: 12),
                    
                    // Distance (if user location available)
                    if (distance != null) ...[
                      _buildDetailRow(
                        Icons.straighten,
                        'Distance',
                        '${distance.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Action Buttons
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Center map view on this service
                              setState(() {
                                _mapCenterLat = service.latitude;
                                _mapCenterLng = service.longitude;
                                _mapZoom = 15.0;
                              });
                            },
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Show on Map'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2E7D59),
                              side: const BorderSide(color: Color(0xFF2E7D59)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDirections(service),
                            icon: const Icon(Icons.navigation),
                            label: const Text('Get Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D59),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 250,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDirections(ServiceLocation service) {
    Navigator.pop(context); // Close bottom sheet
    
    if (_userLocation != null) {
      // Simple directions display
      final distance = LocationService.calculateDistance(
        _userLocation!.latitude, _userLocation!.longitude,
        service.latitude, service.longitude
      );
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Directions to ${service.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distance: ${distance.toStringAsFixed(1)} km'),
              const SizedBox(height: 8),
              Text('Address: ${service.fullAddress}'),
              const SizedBox(height: 8),
              Text('Coordinates: ${service.latitude.toStringAsFixed(4)}, ${service.longitude.toStringAsFixed(4)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission required for directions'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  IconData _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.hospital:
        return Icons.local_hospital;
      case ServiceType.school:
        return Icons.school;
      case ServiceType.shelter:
        return Icons.home;
      case ServiceType.foodBank:
        return Icons.restaurant;
    }
  }

  // Simple offline map view using containers and positioning
  Widget _buildOfflineMapView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!,
            Colors.green[100]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background map representation
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green[50],
            ),
            child: CustomPaint(
              painter: TurkeyMapPainter(),
            ),
          ),
          
          // Service markers
          ..._filteredServices.take(20).map((service) {
            final screenPos = _latLngToScreenPosition(service.latitude, service.longitude);
            return Positioned(
              left: screenPos['x']! - 20,
              top: screenPos['y']! - 20,
              child: GestureDetector(
                onTap: () => _showServiceDetails(service),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getServiceIcon(_selectedServiceType),
                    color: const Color(0xFF2E7D59),
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
          
          // User location marker
          if (_userLocation != null) ...[
            () {
              final userScreenPos = _latLngToScreenPosition(_userLocation!.latitude, _userLocation!.longitude);
              return Positioned(
                left: userScreenPos['x']! - 15,
                top: userScreenPos['y']! - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }

  Map<String, double> _latLngToScreenPosition(double lat, double lng) {
    // Turkey bounds: approximately 36°N to 42°N latitude, 26°E to 45°E longitude
    final screenSize = MediaQuery.of(context).size;
    
    // Clamp coordinates to Turkey bounds
    final clampedLat = lat.clamp(36.0, 42.0);
    final clampedLng = lng.clamp(26.0, 45.0);
    
    // Normalize coordinates to 0-1 range
    final normalizedLat = (clampedLat - 36.0) / (42.0 - 36.0);
    final normalizedLng = (clampedLng - 26.0) / (45.0 - 26.0);
    
    // Calculate zoom factor
    final zoomFactor = (_mapZoom / 10.0).clamp(0.5, 3.0);
    
    // Calculate center offset based on current map center
    final centerLatNorm = (_mapCenterLat - 36.0) / (42.0 - 36.0);
    final centerLngNorm = (_mapCenterLng - 26.0) / (45.0 - 26.0);
    
    // Apply zoom and pan
    final screenX = (normalizedLng - centerLngNorm) * screenSize.width * zoomFactor + screenSize.width / 2;
    final screenY = (centerLatNorm - normalizedLat) * screenSize.height * zoomFactor + screenSize.height / 2;
    
    return {
      'x': screenX.clamp(0.0, screenSize.width),
      'y': screenY.clamp(0.0, screenSize.height),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with search and service type selector
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D59),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Title and nearest service info
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Turkey Services Map',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_nearestService != null && _userLocation != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Nearest: ${LocationService.calculateDistance(
                            _userLocation!.latitude, _userLocation!.longitude,
                            _nearestService!.latitude, _nearestService!.longitude
                          ).toStringAsFixed(1)}km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search ${_selectedServiceType.displayName.toLowerCase()}...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Service Type Tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ServiceType.values.map((serviceType) {
                  final isSelected = serviceType == _selectedServiceType;
                  return GestureDetector(
                    onTap: () => _onServiceTypeChanged(serviceType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2E7D59) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getServiceIcon(serviceType),
                            size: 20,
                            color: isSelected ? Colors.white : const Color(0xFF2E7D59),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            serviceType.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF2E7D59),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Map Area
          Expanded(
            child: Stack(
              children: [
                _buildOfflineMapView(),
                
                // Loading Indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D59)),
                      ),
                    ),
                  ),
                
                // Services Count Badge
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_filteredServices.length} ${_selectedServiceType.displayName.toLowerCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D59),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                // Location Button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: const Color(0xFF2E7D59),
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                
                // Nearest Service Card
                if (_nearestService != null)
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 80,
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          _getServiceIcon(_selectedServiceType),
                          color: const Color(0xFF2E7D59),
                        ),
                        title: Text(
                          _nearestService!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Nearest ${_selectedServiceType.displayName}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showServiceDetails(_nearestService!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple painter for Turkey map outline
class TurkeyMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    
    // Simple Turkey outline approximation
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    final width = size.width * 0.6;
    final height = size.height * 0.3;
    
    path.addOval(Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    ));
    
    canvas.drawPath(path, paint);
    
    // Add some geographical features
    final featurePaint = Paint()
      ..color = Colors.green[300]!
      ..style = PaintingStyle.fill;
    
    // Add some dots to represent major cities
    final cities = [
      Offset(centerX * 0.8, centerY * 0.9), // Istanbul
      Offset(centerX, centerY), // Ankara
      Offset(centerX * 1.4, centerY * 1.2), // Antalya
    ];
    
    for (final city in cities) {
      canvas.drawCircle(city, 3, featurePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
