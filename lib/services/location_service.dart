import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_location.dart';

class LocationService {
  static Map<Country, Map<String, List<ServiceLocation>>> _cachedData = {};
  
  /// Load service data for a specific country
  static Future<List<ServiceLocation>> loadCountryData(Country country) async {
    if (_cachedData.containsKey(country) && _cachedData[country]!.isEmpty == false) {
      print('📚 Using cached data for ${country.displayName}');
      return _cachedData[country]!.values.expand((i) => i).toList();
    }

    try {
      print('📁 Loading data file: ${country.dataFile}');
      final String jsonString = await rootBundle.loadString(country.dataFile);
      print('📄 File loaded, size: ${jsonString.length} characters');
      
      if (jsonString.isEmpty) {
        print('❌ JSON file is empty');
        return [];
      }
      
      print('🔍 Parsing JSON...');
      final dynamic jsonData = json.decode(jsonString);
      
      if (jsonData is! List) {
        print('❌ JSON root is not a list, it is: ${jsonData.runtimeType}');
        return [];
      }
      
      final List<dynamic> jsonList = jsonData;
      print('📊 JSON parsed successfully, ${jsonList.length} items found');
      
      if (jsonList.isEmpty) {
        print('❌ JSON list is empty');
        return [];
      }
      
      print('🏗️ Converting to ServiceLocation objects...');
      final List<ServiceLocation> locations = [];
      
      for (int i = 0; i < jsonList.length; i++) {
        try {
          final item = jsonList[i];
          if (item is Map<String, dynamic>) {
            final location = ServiceLocation.fromJson(item);
            
            // Validate essential fields
            if (location.name.isNotEmpty && 
                location.latitude != 0.0 && 
                location.longitude != 0.0) {
              locations.add(location);
            } else {
              print('⚠️ Skipping item $i: missing essential data');
            }
          } else {
            print('⚠️ Skipping item $i: not a map');
          }
        } catch (e) {
          print('⚠️ Error parsing item $i: $e');
        }
      }
      
      print('✅ Successfully loaded ${locations.length} valid locations');
      if (locations.isNotEmpty) {
        final sampleLocation = locations.first;
        print('📍 Sample location: ${sampleLocation.name} (${sampleLocation.type}) at ${sampleLocation.city}');
        
        final types = locations.map((l) => l.type).toSet();
        print('🏷️ Available types: $types');
      }
      
      _cachedData[country] = {'': locations};
      return locations;
    } catch (e) {
      print('❌ Error loading country data for ${country.displayName}: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Load service data for a specific country and category
  static Future<List<ServiceLocation>> loadCategoryData(Country country, String category) async {
    _cachedData[country] ??= {};
    if (_cachedData[country]!.containsKey(category)) {
      print('📚 Using cached data for ${country.displayName} - $category');
      return _cachedData[country]![category]!;
    }

    try {
      final String dataFile = 'data/${country.displayName}/${country.displayName.toLowerCase()}_${category.toLowerCase()}.json';
      print('📁 Loading data file: $dataFile');
      final String jsonString = await rootBundle.loadString(dataFile);
      print('📄 File loaded, size: ${jsonString.length} characters');

      if (jsonString.isEmpty) {
        print('❌ JSON file is empty');
        return [];
      }

      print('🔍 Parsing JSON...');
      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is! List) {
        print('❌ JSON root is not a list, it is: ${jsonData.runtimeType}');
        return [];
      }

      final List<ServiceLocation> locations = jsonData.map((item) {
        if (item is Map<String, dynamic>) {
          return ServiceLocation.fromJson(item);
        }
        return null;
      }).whereType<ServiceLocation>().toList();

      print('✅ Successfully loaded ${locations.length} $category locations');
      _cachedData[country]![category] = locations;
      return locations;
    } catch (e) {
      print('❌ Error loading $category data for ${country.displayName}: $e');
      return [];
    }
  }

  /// Get services filtered by type and country
  static Future<List<ServiceLocation>> getServicesByType(
    Country country, 
    ServiceType serviceType
  ) async {
    final filteredServices = await loadCategoryData(country, serviceType.key);
    print('🎯 Loaded services for type ${serviceType.key}: ${filteredServices.length}');
    
    return filteredServices;
  }

  /// Get nearby services within a radius (in kilometers)
  static Future<List<ServiceLocation>> getNearbyServices(
    Country country,
    ServiceType serviceType,
    double userLat,
    double userLon,
    {double radiusKm = 10.0}
  ) async {
    final services = await getServicesByType(country, serviceType);
    
    return services.where((service) {
      final distance = calculateDistance(
        userLat, 
        userLon, 
        service.latitude, 
        service.longitude
      );
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final distanceA = calculateDistance(userLat, userLon, a.latitude, a.longitude);
        final distanceB = calculateDistance(userLat, userLon, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Get user's current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      // Get current position with timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get default center coordinates for a country
  static Map<String, double> getCountryCenter(Country country) {
    switch (country) {
      case Country.turkey:
        return {'lat': 39.9334, 'lng': 32.8597}; // Ankara
      case Country.germany:
        return {'lat': 52.5200, 'lng': 13.4050}; // Berlin
    }
  }

  /// Search services by name
  static Future<List<ServiceLocation>> searchServices(
    Country country,
    String query,
    {ServiceType? filterByType}
  ) async {
    List<ServiceLocation> allLocations = [];
    
    // If filterByType is specified, load only that category
    if (filterByType != null) {
      allLocations = await loadCategoryData(country, filterByType.key);
    } else {
      // Load all categories (hospitals, schools, shelters)
      final hospitals = await loadCategoryData(country, 'hospital');
      final schools = await loadCategoryData(country, 'school');
      final shelters = await loadCategoryData(country, 'shelter');
      allLocations = [...hospitals, ...schools, ...shelters];
    }
    
    final lowerQuery = query.toLowerCase();
    
    return allLocations.where((location) {
      final matchesQuery = location.name.toLowerCase().contains(lowerQuery) ||
                          location.city.toLowerCase().contains(lowerQuery) ||
                          location.district.toLowerCase().contains(lowerQuery);
      
      final matchesType = filterByType == null || location.type == filterByType.key;
      
      return matchesQuery && matchesType;
    }).toList();
  }

  /// Find the nearest facility of a specific category
  static Future<ServiceLocation?> findNearestFacility(
    Country country,
    String category,
    double userLat,
    double userLon
  ) async {
    final locations = await loadCategoryData(country, category);

    if (locations.isEmpty) {
      print('❌ No locations found for category: $category');
      return null;
    }

    ServiceLocation? nearest;
    double minDistance = double.infinity;

    for (final location in locations) {
      final distance = calculateDistance(userLat, userLon, location.latitude, location.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }

    print('📍 Nearest $category: ${nearest?.name} at ${minDistance.toStringAsFixed(2)} km');
    return nearest;
  }
}
