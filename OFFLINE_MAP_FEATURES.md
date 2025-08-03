# Turkey Services Map - Offline Feature

## Overview
We have completely rebuilt the map feature from scratch to be:
- **Offline-first**: No internet required, all data stored locally
- **Turkey-focused**: Uses the Turkey JSON data files
- **Simple and efficient**: Lightweight implementation without complex dependencies

## Features Implemented

### 🗺️ Offline Map View
- Custom-drawn Turkey map outline using Flutter's CustomPainter
- Visual representation of Turkey's geographical boundaries
- Service markers positioned using latitude/longitude coordinates
- User location marker (blue dot) when location permission is granted

### 🏥 Service Categories
- **Hospitals** (🏥): From `turkey_hospitals.json`
- **Schools** (🏫): From `turkey_schools.json` 
- **Shelters** (🏠): From `turkey_shelters.json`

### 📍 Location Features
- **Automatic location detection**: Gets user's current location
- **Nearest service detection**: Automatically finds and shows the nearest service of selected type
- **Distance calculation**: Shows distance to services when location is available
- **Service sorting**: Services are sorted by distance when user location is known

### 🔍 Search & Filter
- **Real-time search**: Search services by name or address
- **Service type tabs**: Easy switching between hospitals, schools, and shelters
- **Interactive map markers**: Tap markers to see service details

### 📱 User Interface
- **Clean, modern design**: Uses app's green color scheme (#2E7D59)
- **Bottom sheet details**: Tap any service for detailed information
- **Floating action button**: Quick access to location services
- **Nearest service card**: Shows closest service at bottom of screen

## Technical Implementation

### Data Loading
- Uses existing Turkey JSON files in `data/Turkey/` folder
- Caches data for performance
- Handles large datasets efficiently (hospitals: 43k+, schools: 307k+, shelters: 96k+)

### Coordinate Mapping
- Converts lat/lng coordinates to screen positions
- Handles Turkey's geographical bounds (36°N-42°N, 26°E-45°E)
- Implements zoom and pan functionality
- Clamps coordinates to visible area

### Dependencies Removed
- `flutter_map`: Heavy mapping library
- `latlong2`: Coordinate utilities
- `url_launcher`: External navigation
- `routing_client_dart`: Complex routing

### Dependencies Kept
- `geolocator`: For user location detection
- Core Flutter widgets and materials

## Files Modified/Created

### New Files
- `lib/screens/services_map_screen.dart`: Main offline map implementation
- `lib/screens/service_list_screen.dart`: Alternative list view

### Modified Files
- `lib/services/location_service.dart`: Updated to use Turkey JSON files correctly
- `lib/screens/main_navigation_screen.dart`: Added new map and list views
- `pubspec.yaml`: Removed unnecessary map dependencies

### Removed Files
- `lib/screens/navigation_screen.dart`: Complex routing screen (no longer needed)

## Usage Instructions

1. **Launch the app** and navigate to "Map View" tab
2. **Grant location permission** when prompted for best experience
3. **Select service type** using the tabs (Hospitals, Schools, Shelters)
4. **Search services** using the search bar
5. **Tap markers** on the map to see service details
6. **View nearest service** in the card at bottom of screen
7. **Get directions** by tapping "Get Directions" in service details

## Data Structure
Each service includes:
- Name and type
- Full address (city, district, street)
- Exact coordinates (latitude, longitude)
- Distance from user (when location available)

## Performance
- Shows up to 20 services on map for performance
- Full list available in "List View" tab
- Efficient coordinate calculation and rendering
- Cached data loading for smooth experience

## Future Enhancements Possible
- Offline tile storage for more detailed maps
- Route calculation between user and services
- Favorites/bookmarks functionality
- Service ratings and reviews
- Multi-language support
