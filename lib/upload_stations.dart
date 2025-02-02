import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addRouteToFirestore() async {
  try {
    // Původní data trasy
    final routeData = {
      "category": "Klikaté",
      "description": "Krásná jízda mezi kopci s výhledy na hory.",
      "endLocation": GeoPoint(49.564, 18.245),
      "length": 45.3,
      "name": "Okruh kolem Beskyd",
      "rating": 4,
      "startLocation": GeoPoint(49.654, 18.345),
    };

    // Pole GeoPointů
    final List<GeoPoint> pathPoints = [
      GeoPoint(49.654, 18.345),
      GeoPoint(49.645, 18.3),
      GeoPoint(49.64, 18.27),
    ];

    // Převod pole na mapu s indexy
    final Map<String, GeoPoint> pathAsMap = {
      for (int i = 0; i < pathPoints.length; i++) i.toString(): pathPoints[i],
    };

    // Přidání `path` do dat trasy
    routeData['path'] = pathAsMap;

    // Uložení do Firestore
    await FirebaseFirestore.instance.collection('routes').add(routeData);
    print("Trasa byla úspěšně přidána do Firestore.");
  } catch (e) {
    print("Chyba při přidávání trasy do Firestore: $e");
  }
}
