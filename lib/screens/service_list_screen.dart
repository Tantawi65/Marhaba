import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_location.dart';
import '../services/location_service.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  ServiceType _selectedServiceType = ServiceType.hospital;
  Position? _userLocation;
  List<ServiceLocation> _currentServices = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
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
      
      // If user location is available, sort by distance
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
      }
      
      print('✅ Loaded ${services.length} ${_selectedServiceType.displayName} services');
      
      setState(() {
        _currentServices = services;
      });
    } catch (e) {
      print('❌ Error loading services: $e');
      setState(() {
        _currentServices = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D59),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text(
                  'Turkey Services',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
          
          // Services List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D59)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredServices.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      final distance = _userLocation != null
                          ? LocationService.calculateDistance(
                              _userLocation!.latitude,
                              _userLocation!.longitude,
                              service.latitude,
                              service.longitude,
                            )
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D59).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getServiceIcon(_selectedServiceType),
                              color: const Color(0xFF2E7D59),
                            ),
                          ),
                          title: Text(
                            service.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.fullAddress),
                              if (distance != null)
                                Text(
                                  '${distance.toStringAsFixed(1)} km away',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Show details
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(service.name),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${_selectedServiceType.displayName}'),
                                    const SizedBox(height: 8),
                                    Text('Address: ${service.fullAddress}'),
                                    if (distance != null) ...[
                                      const SizedBox(height: 8),
                                      Text('Distance: ${distance.toStringAsFixed(1)} km'),
                                    ],
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
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
