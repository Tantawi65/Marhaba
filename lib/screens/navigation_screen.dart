import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_location.dart';
import '../services/offline_routing_service.dart';

class NavigationScreen extends StatefulWidget {
  final ServiceLocation destination;
  final Position? userLocation;

  const NavigationScreen({
    super.key,
    required this.destination,
    required this.userLocation,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late MapController _mapController;
  RouteResult? _currentRoute;
  int _currentInstructionIndex = 0;
  bool _isNavigating = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = widget.userLocation;
    _calculateRoute();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateRoute() {
    if (_currentPosition != null) {
      final start = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final end = LatLng(widget.destination.latitude, widget.destination.longitude);
      
      setState(() {
        _currentRoute = OfflineRoutingService.calculateRoute(start, end);
      });

      // Center map on route
      if (_currentRoute != null) {
        _centerMapOnRoute();
      }
    }
  }

  void _centerMapOnRoute() {
    if (_currentRoute != null && _currentRoute!.routePoints.isNotEmpty) {
      final bounds = _calculateBounds(_currentRoute!.routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
      _currentInstructionIndex = 0;
    });

    // In a real app, you'd start location tracking here
    _showNavigationDialog();
  }

  void _showNavigationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Started'),
        content: const Text(
          'In a real implementation, this would track your location and provide turn-by-turn voice guidance. For this demo, use the instruction list below.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Navigate to ${widget.destination.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D59),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Route Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D59),
            child: _buildRouteSummary(),
          ),

          // Map
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : LatLng(widget.destination.latitude, widget.destination.longitude),
                    initialZoom: 14.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    // Map Tiles
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.marhaba',
                    ),

                    // Route Line
                    if (_currentRoute != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _currentRoute!.routePoints,
                            color: const Color(0xFF2E7D59),
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),

                    // Start Marker (User Location)
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            width: 40,
                            height: 40,
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
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Destination Marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(widget.destination.latitude, widget.destination.longitude),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
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
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Map Controls
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        onPressed: _centerMapOnRoute,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.center_focus_strong, color: Color(0xFF2E7D59)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Instructions List
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Instructions Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: Color(0xFF2E7D59)),
                        const SizedBox(width: 8),
                        const Text(
                          'Turn-by-Turn Directions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D59),
                          ),
                        ),
                        const Spacer(),
                        if (!_isNavigating)
                          ElevatedButton.icon(
                            onPressed: _startNavigation,
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D59),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Instructions List
                  Expanded(
                    child: _currentRoute != null
                        ? ListView.builder(
                            itemCount: _currentRoute!.instructions.length,
                            itemBuilder: (context, index) {
                              final instruction = _currentRoute!.instructions[index];
                              final isActive = _isNavigating && index == _currentInstructionIndex;
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF2E7D59).withOpacity(0.1) : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isActive 
                                      ? Border.all(color: const Color(0xFF2E7D59), width: 2)
                                      : null,
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isActive 
                                          ? const Color(0xFF2E7D59) 
                                          : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getManeuverIcon(instruction.maneuver),
                                      color: isActive ? Colors.white : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    instruction.instruction,
                                    style: TextStyle(
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      color: isActive ? const Color(0xFF2E7D59) : null,
                                    ),
                                  ),
                                  subtitle: instruction.distance > 0
                                      ? Text('${instruction.distance.toStringAsFixed(1)} km')
                                      : null,
                                  trailing: isActive
                                      ? const Icon(Icons.navigation, color: Color(0xFF2E7D59))
                                      : null,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D59)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    if (_currentRoute == null) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destination.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.destination.shortAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, size: 16, color: Color(0xFF2E7D59)),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentRoute!.totalDistance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D59),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF2E7D59)),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentRoute!.estimatedDuration.inMinutes} min',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2E7D59),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getManeuverIcon(RouteManeuver maneuver) {
    switch (maneuver) {
      case RouteManeuver.straight:
        return Icons.arrow_upward;
      case RouteManeuver.left:
        return Icons.turn_left;
      case RouteManeuver.right:
        return Icons.turn_right;
      case RouteManeuver.arrive:
        return Icons.flag;
    }
  }
}
