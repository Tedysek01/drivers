class PetrolStation {
  final String name;
  final double lat;
  final double lon;
  String? address; // Volitelná vlastnost
  String? dieselPrice; // Volitelná vlastnost
  String? petrolPrice; // Volitelná vlastnost

  PetrolStation({
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    this.dieselPrice,
    this.petrolPrice,
  });

  factory PetrolStation.fromJson(Map<String, dynamic> json) {
    return PetrolStation(
      name: json['name'] ?? 'Neznámá benzínka',
      lat: json['lat'],
      lon: json['lon'],
      address: json['address'], // Může být null
      dieselPrice: json['diesel_price'], // Může být null
      petrolPrice: json['petrol_price'], // Může být null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      if (address != null) 'address': address,
      if (dieselPrice != null) 'diesel_price': dieselPrice,
      if (petrolPrice != null) 'petrol_price': petrolPrice,
    };
  }
}
