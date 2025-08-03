import 'package:flutter/material.dart';
import '../models/service_location.dart';
import '../services/location_service.dart';

class DataTestScreen extends StatefulWidget {
  const DataTestScreen({super.key});

  @override
  State<DataTestScreen> createState() => _DataTestScreenState();
}

class _DataTestScreenState extends State<DataTestScreen> {
  List<ServiceLocation> _services = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _testDataLoading();
  }

  Future<void> _testDataLoading() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      print('🔍 Testing data loading... v2'); // Force reload
      
      // Test loading Turkey hospital data
      final turkeyHospitals = await LocationService.loadCategoryData(Country.turkey, 'hospital');
      print('📊 Turkey hospitals loaded: ${turkeyHospitals.length} locations');
      
      if (turkeyHospitals.isNotEmpty) {
        print('✅ Success! Sample Turkey hospital data:');
        turkeyHospitals.take(3).forEach((loc) {
          print('  - ${loc.name} (${loc.type}) at ${loc.city}');
        });
        
        // Test loading different categories
        final schools = await LocationService.loadCategoryData(Country.turkey, 'school');
        final shelters = await LocationService.loadCategoryData(Country.turkey, 'shelter');
        
        print('🏥 Hospitals found: ${turkeyHospitals.length}');
        print('🏫 Schools found: ${schools.length}');
        print('🏠 Shelters found: ${shelters.length}');
        
        setState(() {
          _services = [...turkeyHospitals.take(5), ...schools.take(3), ...shelters.take(2)].toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No hospital data found in turkey_hospitals.json. The file might be empty or not properly formatted.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _error = 'Error loading data: $e\n\nPlease check:\n1. turkey_hospitals.json exists in data/Turkey/ folder\n2. File is properly formatted JSON\n3. Assets are declared in pubspec.yaml';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Test'),
        backgroundColor: const Color(0xFF2E7D59),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error:',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _testDataLoading,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.green[100],
                      child: Column(
                        children: [
                          Text(
                            '✅ Data Loading Successful!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Found ${_services.length} sample services',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2E7D59),
                              child: Icon(
                                _getServiceIcon(service.type),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(service.name),
                            subtitle: Text('${service.type} in ${service.city}'),
                            trailing: Text(
                              '${service.latitude.toStringAsFixed(3)}, ${service.longitude.toStringAsFixed(3)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  IconData _getServiceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'shelter':
        return Icons.home;
      default:
        return Icons.place;
    }
  }
}
