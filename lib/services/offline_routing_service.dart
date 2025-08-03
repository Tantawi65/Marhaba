import 'dart:math';
import 'package:latlong2/latlong.dart';

class OfflineRoutingService {
  /// Calculate a simple offline route between two points
  static RouteResult calculateRoute(LatLng start, LatLng end) {
    final distance = _calculateDistance(start, end);
    final bearing = _calculateBearing(start, end);
    final duration = _estimateDuration(distance);
    
    // Generate simple route points (for demonstration - in a real app you'd use road data)
    final routePoints = _generateRoutePoints(start, end);
    final instructions = _generateInstructions(start, end, distance, bearing);
    
    return RouteResult(
      routePoints: routePoints,
      instructions: instructions,
      totalDistance: distance,
      estimatedDuration: duration,
    );
  }
  
  static double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }
  
  static double _calculateBearing(LatLng start, LatLng end) {
    final lat1Rad = start.latitude * (pi / 180);
    final lat2Rad = end.latitude * (pi / 180);
    final deltaLonRad = (end.longitude - start.longitude) * (pi / 180);
    
    final y = sin(deltaLonRad) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - 
              sin(lat1Rad) * cos(lat2Rad) * cos(deltaLonRad);
    
    final bearingRad = atan2(y, x);
    return (bearingRad * (180 / pi) + 360) % 360;
  }
  
  static Duration _estimateDuration(double distanceKm) {
    // Estimate based on average city driving speed (30 km/h)
    final hours = distanceKm / 30;
    return Duration(minutes: (hours * 60).round());
  }
  
  static List<LatLng> _generateRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[];
    points.add(start);
    
    // Generate intermediate points for a smoother route visualization
    const numPoints = 10;
    for (int i = 1; i < numPoints; i++) {
      final ratio = i / numPoints;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      points.add(LatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }
  
  static List<RouteInstruction> _generateInstructions(
    LatLng start, 
    LatLng end, 
    double distance, 
    double bearing
  ) {
    final instructions = <RouteInstruction>[];
    
    // Start instruction
    instructions.add(RouteInstruction(
      instruction: "Head ${_bearingToDirection(bearing)}",
      distance: distance * 0.1, // 10% of total distance for first segment
      maneuver: RouteManeuver.straight,
      position: start,
    ));
    
    // Middle instruction (if distance > 1km)
    if (distance > 1.0) {
      final midPoint = LatLng(
        (start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2,
      );
      instructions.add(RouteInstruction(
        instruction: "Continue ${_bearingToDirection(bearing)}",
        distance: distance * 0.8, // 80% of distance for main segment
        maneuver: RouteManeuver.straight,
        position: midPoint,
      ));
    }
    
    // Arrival instruction
    instructions.add(RouteInstruction(
      instruction: "You have arrived at your destination",
      distance: 0,
      maneuver: RouteManeuver.arrive,
      position: end,
    ));
    
    return instructions;
  }
  
  static String _bearingToDirection(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return "north";
    if (bearing >= 22.5 && bearing < 67.5) return "northeast";
    if (bearing >= 67.5 && bearing < 112.5) return "east";
    if (bearing >= 112.5 && bearing < 157.5) return "southeast";
    if (bearing >= 157.5 && bearing < 202.5) return "south";
    if (bearing >= 202.5 && bearing < 247.5) return "southwest";
    if (bearing >= 247.5 && bearing < 292.5) return "west";
    if (bearing >= 292.5 && bearing < 337.5) return "northwest";
    return "north";
  }
}

class RouteResult {
  final List<LatLng> routePoints;
  final List<RouteInstruction> instructions;
  final double totalDistance; // in kilometers
  final Duration estimatedDuration;
  
  RouteResult({
    required this.routePoints,
    required this.instructions,
    required this.totalDistance,
    required this.estimatedDuration,
  });
}

class RouteInstruction {
  final String instruction;
  final double distance; // in kilometers
  final RouteManeuver maneuver;
  final LatLng position;
  
  RouteInstruction({
    required this.instruction,
    required this.distance,
    required this.maneuver,
    required this.position,
  });
}

enum RouteManeuver {
  straight,
  left,
  right,
  arrive,
}
