import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_location.dart';
import '../services/location_service.dart';
import 'navigation_screen.dart';

class ServicesMapScreen extends StatefulWidget {
  const ServicesMapScreen({super.key});

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late MapController _mapController;
  
  Country _selectedCountry = Country.turkey;
  ServiceType _selectedServiceType = ServiceType.hospital;
  Position? _userLocation;
  List<ServiceLocation> _currentServices = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ServiceType.values.length, vsync: this);
    _mapController = MapController();
    _loadInitialData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadServices();
    setState(() => _isLoading = false);
  }

  Future<void> _loadServices() async {
    try {
      print('🔍 Loading services for ${_selectedCountry.displayName} - ${_selectedServiceType.displayName}');
      
      List<ServiceLocation> services;
      if (_userLocation != null) {
        print('📍 User location available: ${_userLocation!.latitude}, ${_userLocation!.longitude}');
        // Get nearby services sorted by distance
        services = await LocationService.getNearbyServices(
          _selectedCountry,
          _selectedServiceType,
          _userLocation!.latitude,
          _userLocation!.longitude,
          radiusKm: 50.0, // 50km radius
        );
      } else {
        print('🌍 No user location, loading all services of type: ${_selectedServiceType.key}');
        // Get all services of selected type
        services = await LocationService.getServicesByType(_selectedCountry, _selectedServiceType);
      }
      
      print('✅ Loaded ${services.length} services of type: ${_selectedServiceType.key}');
      if (services.isNotEmpty) {
        print('📍 First service: ${services.first.name} (${services.first.type})');
      } else {
        print('❌ No services found for type: ${_selectedServiceType.key}');
      }
      
      setState(() {
        _currentServices = services;
      });
    } catch (e) {
      print('❌ Error loading services: $e');
      print('📍 Stack trace: ${StackTrace.current}');
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
      
      // Reload services with location
      await _loadServices();
      
      // Center map on user location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        12.0,
      );
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  void _onServiceTypeChanged(ServiceType serviceType) {
    print('🔄 Changing service type to: ${serviceType.key}');
    setState(() {
      _selectedServiceType = serviceType;
    });
    _loadServices();
  }

  void _onCountryChanged(Country country) {
    print('🔄 Changing country to: ${country.displayName}');
    setState(() {
      _selectedCountry = country;
    });
    _loadServices();
    
    // Center map on country
    final center = LocationService.getCountryCenter(country);
    _mapController.move(
      LatLng(center['lat']!, center['lng']!),
      6.0,
    );
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
                            _getServiceIcon(_getServiceTypeFromString(service.type)),
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
                                _getServiceTypeFromString(service.type).displayName,
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
                    
                    // Phone (if available)
                    if (service.raw['phone'] != null && service.raw['phone'].toString().isNotEmpty)
                      _buildDetailRow(Icons.phone, 'Phone', service.raw['phone'].toString()),
                    if (service.raw['phone'] != null && service.raw['phone'].toString().isNotEmpty) const SizedBox(height: 12),
                    
                    // Hours (if available)
                    if (service.raw['hours'] != null && service.raw['hours'].toString().isNotEmpty)
                      _buildDetailRow(Icons.access_time, 'Hours', service.raw['hours'].toString()),
                    if (service.raw['hours'] != null && service.raw['hours'].toString().isNotEmpty) const SizedBox(height: 12),
                    
                    // Distance (if user location available)
                    if (_userLocation != null)
                      _buildDetailRow(
                        Icons.straighten,
                        'Distance',
                        '${LocationService.calculateDistance(
                          _userLocation!.latitude,
                          _userLocation!.longitude,
                          service.latitude,
                          service.longitude,
                        ).toStringAsFixed(1)} km',
                      ),
                    if (_userLocation != null) const SizedBox(height: 20),
                    
                    // Action Buttons
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Center map on this service
                              _mapController.move(
                                LatLng(service.latitude, service.longitude),
                                15.0,
                              );
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
                            onPressed: () => _openDirections(service),
                            icon: const Icon(Icons.navigation),
                            label: const Text('Navigate'),
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

  void _openDirections(ServiceLocation service) {
    Navigator.pop(context); // Close bottom sheet
    
    if (_userLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            destination: service,
            userLocation: _userLocation,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission required for navigation'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  ServiceType _getServiceTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'hospital':
        return ServiceType.hospital;
      case 'school':
        return ServiceType.school;
      case 'shelter':
        return ServiceType.shelter;
      case 'food_bank':
      case 'food':
        return ServiceType.foodBank;
      default:
        return ServiceType.hospital;
    }
  }

  IconData _getServiceIcon(ServiceType type) {
    switch (type.key) {
      case 'hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'shelter':
        return Icons.home;
      case 'food_bank':
        return Icons.restaurant;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header with country selector and search
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D59),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Title and Country Selector
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nearby Services',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<Country>(
                        value: _selectedCountry,
                        onChanged: (Country? country) {
                          if (country != null) _onCountryChanged(country);
                        },
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFF2E7D59),
                        style: const TextStyle(color: Colors.white),
                        items: Country.values.map((Country country) {
                          return DropdownMenuItem<Country>(
                            value: country,
                            child: Text(
                              country.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
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
                      hintText: 'Search services...',
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
            child: TabBar(
              controller: _tabController,
              onTap: (index) => _onServiceTypeChanged(ServiceType.values[index]),
              indicatorColor: const Color(0xFF2E7D59),
              labelColor: const Color(0xFF2E7D59),
              unselectedLabelColor: Colors.grey[600],
              tabs: ServiceType.values.map((serviceType) {
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getServiceIcon(serviceType),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        serviceType.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      LocationService.getCountryCenter(_selectedCountry)['lat']!,
                      LocationService.getCountryCenter(_selectedCountry)['lng']!,
                    ),
                    initialZoom: 6.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    // Map Tiles
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.marhaba',
                    ),
                    
                    // Service Markers
                    MarkerLayer(
                      markers: _filteredServices.map((service) {
                        return Marker(
                          point: LatLng(service.latitude, service.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showServiceDetails(service),
                            child: Container(
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
                                _getServiceIcon(_getServiceTypeFromString(service.type)),
                                color: const Color(0xFF2E7D59),
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    // User Location Marker
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
                            width: 30,
                            height: 30,
                            child: Container(
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
                          ),
                        ],
                      ),
                  ],
                ),
                
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
                
                // Floating Action Button for User Location
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: const Color(0xFF2E7D59),
                    child: const Icon(Icons.my_location, color: Colors.white),
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
                      '${_filteredServices.length} ${_selectedServiceType.displayName.toLowerCase()}${_filteredServices.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D59),
                        fontSize: 12,
                      ),
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
