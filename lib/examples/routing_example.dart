// Example usage of the fixed OfflineRoutingService

import '../services/offline_routing_service.dart';

void exampleUsage() {
  // Create coordinates for start and end points
  final start = Coordinate(39.9334, 32.8597); // Ankara
  final end = Coordinate(41.0082, 28.9784);   // Istanbul
  
  // Calculate route
  final route = OfflineRoutingService.calculateRoute(start, end);
  
  print('Route calculated:');
  print('Distance: ${route.totalDistance.toStringAsFixed(1)} km');
  print('Duration: ${route.estimatedDuration.inHours}h ${route.estimatedDuration.inMinutes % 60}m');
  print('Route points: ${route.routePoints.length}');
  print('Instructions: ${route.instructions.length}');
  
  // Print instructions
  for (int i = 0; i < route.instructions.length; i++) {
    final instruction = route.instructions[i];
    print('${i + 1}. ${instruction.instruction} (${instruction.distance.toStringAsFixed(1)} km)');
  }
}
