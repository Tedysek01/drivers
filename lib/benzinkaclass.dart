class PetrolStation {
  final String name;
  final String address;
  final String dieselPrice;
  final String petrolPrice;
  final String details;

  PetrolStation({
    required this.name,
    required this.address,
    required this.dieselPrice,
    required this.petrolPrice,
    required this.details,
  });

  factory PetrolStation.fromJson(Map<String, dynamic> json) {
    return PetrolStation(
      name: json['name'],
      address: json['address'],
      dieselPrice: json['diesel_price'],
      petrolPrice: json['petrol_price'],
      details: json['details'],
    );
  }
}
