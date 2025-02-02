import 'package:cloud_firestore/cloud_firestore.dart';

class FunRoute {
  final String id; // ID dokumentu ve Firestore
  final String name;
  final String description;
  final GeoPoint location; // Použití GeoPoint pro uložení lokace
  final double? distance; // Nepovinný údaj o délce trasy

  FunRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.distance,
  });

  // Factory metoda pro vytvoření instance třídy z Firestore
  factory FunRoute.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FunRoute(
      id: doc.id,
      name: data['name'] ?? 'Neznámá trasa',
      description: data['description'] ?? '',
      location: data['location'], // GeoPoint
      distance: data['distance'] != null ? data['distance'].toDouble() : null,
    );
  }

  // Metoda pro převod instance na mapu pro ukládání do Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location, // GeoPoint
      if (distance != null) 'distance': distance,
    };
  }
}
