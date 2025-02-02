import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetrolStation {
  final String id; // ID dokumentu z Firestore
  final String name;
  final double lat;
  final double lon;
  String? address; // Adresa benzínky
  String? dieselPrice; // Cena nafty
  String? petrolPrice; // Cena benzínu
  double? distanceFromUser; // Vzdálenost od uživatele
  String? updatedBy; // Uživatelské jméno nebo ID uživatele, který cenu aktualizoval
  DateTime? updatedAt; // Čas poslední aktualizace

  PetrolStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    this.dieselPrice,
    this.petrolPrice,
    this.distanceFromUser,
    this.updatedBy,
    this.updatedAt,
  });

  /// Vytvoření instance z JSON (např. z Firestore)
  factory PetrolStation.fromJson(String id, Map<String, dynamic> json) {
    return PetrolStation(
      id: id,
      name: json['name'] ?? 'Neznámá benzínka',
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      address: json['address'],
      dieselPrice: json['diesel_price'],
      petrolPrice: json['petrol_price'],
      distanceFromUser: json['distance_from_user']?.toDouble(),
      updatedBy: json['updated_by'],
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Převod instance na JSON (např. pro ukládání do Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon,
      if (address != null) 'address': address,
      if (dieselPrice != null) 'diesel_price': dieselPrice,
      if (petrolPrice != null) 'petrol_price': petrolPrice,
      if (distanceFromUser != null) 'distance_from_user': distanceFromUser,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Načtení adresy pomocí Geocoding API
  Future<void> fetchAddress(String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          address = data['results'][0]['formatted_address'];
        } else {
          address = 'Adresa nenalezena';
        }
      } else {
        address = 'Chyba při načítání adresy: ${response.statusCode}';
      }
    } catch (error) {
      address = 'Chyba: $error';
    }
  }
}
