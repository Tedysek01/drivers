import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class FunRoute {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double length;
  final GeoPoint startLocation;
  final GeoPoint endLocation;
  final List<GeoPoint> path;
  final double rating;
  double? distanceFromUser; // Volitelná vlastnost

  FunRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.length,
    required this.startLocation,
    required this.endLocation,
    required this.path,
    required this.rating,
    this.distanceFromUser,
  });

  // Factory metoda pro vytvoření objektu z Firestore
  factory FunRoute.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Převod `path` na seznam GeoPointů
    final List<GeoPoint> pathPoints = (data['path'] as List<dynamic>)
        .map((point) => point as GeoPoint)
        .toList();

    return FunRoute(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      length: (data['length'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      startLocation: data['startLocation'] as GeoPoint,
      endLocation: data['endLocation'] as GeoPoint,
      path: pathPoints,
    );
  }

  // Metoda pro převod objektu na Map (pro uložení do Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'length': length,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'path': path,
      'rating': rating,
    };
  }

  // Metoda pro výpočet celkové délky trasy
  double calculateTotalLength() {
    double totalLength = 0.0;

    // Vzdálenost mezi startLocation a prvním bodem v path
    if (path.isNotEmpty) {
      totalLength += calculateDistance(
        startLocation.latitude,
        startLocation.longitude,
        path.first.latitude,
        path.first.longitude,
      );
    }

    // Vzdálenosti mezi body v path
    for (int i = 0; i < path.length - 1; i++) {
      totalLength += calculateDistance(
        path[i].latitude,
        path[i].longitude,
        path[i + 1].latitude,
        path[i + 1].longitude,
      );
    }

    // Vzdálenost mezi posledním bodem v path a endLocation
    if (path.isNotEmpty) {
      totalLength += calculateDistance(
        path.last.latitude,
        path.last.longitude,
        endLocation.latitude,
        endLocation.longitude,
      );
    }

    return totalLength;
  }

  // Funkce pro výpočet vzdálenosti mezi dvěma body (Haversine formula)
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Poloměr Země v kilometrech
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}
