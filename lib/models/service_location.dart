class ServiceLocation {
  final String id;
  final String name;
  final String type;
  final String city;
  final String district;
  final String street;
  final String number;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> raw;

  ServiceLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.district,
    required this.street,
    required this.number,
    required this.latitude,
    required this.longitude,
    required this.raw,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      raw: json['raw'] ?? {},
    );
  }

  String get fullAddress {
    List<String> addressParts = [];
    if (street.isNotEmpty) addressParts.add(street);
    if (number.isNotEmpty) addressParts.add(number);
    if (district.isNotEmpty) addressParts.add(district);
    if (city.isNotEmpty) addressParts.add(city);
    return addressParts.join(', ');
  }

  String get shortAddress {
    if (city.isNotEmpty) return city;
    if (district.isNotEmpty) return district;
    return 'Unknown Location';
  }
}

enum ServiceType {
  hospital('hospital', '🏥', 'Hospitals'),
  school('school', '🏫', 'Schools'),
  shelter('shelter', '🏠', 'Shelters'),
  foodBank('food_bank', '🍽️', 'Food Banks');

  const ServiceType(this.key, this.icon, this.displayName);

  final String key;
  final String icon;
  final String displayName;
}

enum Country {
  turkey('Turkey', 'data/Turkey_data.json'),
  germany('Germany', 'data/Germany_data.json');

  const Country(this.displayName, this.dataFile);

  final String displayName;
  final String dataFile;
}
