import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addRouteToFirestore() async {
  try {
    final routeData = {
      "category": "Klikaté",
      "description": "Krásná jízda mezi kopci s výhledy na hory.",
      "endLocation": {
        "latitude": 49.564,
        "longitude": 18.245,
      },
      "length": 45.3,
      "name": "Okruh kolem Beskyd",
      "path": [
        {
          "latitude": 49.654,
          "longitude": 18.345,
        },
        {
          "latitude": 49.645,
          "longitude": 18.3,
        },
        {
          "latitude": 49.64,
          "longitude": 18.27,
        },
      ],
      "rating": 4,
      "startLocation": {
        "latitude": 49.654,
        "longitude": 18.345,
      },
    };

    // Přidání dat do kolekce "routes"
    await FirebaseFirestore.instance.collection('routes').add(routeData);

    print("Trasa byla úspěšně přidána do Firestore.");
  } catch (e) {
    print("Chyba při přidávání trasy do Firestore: $e");
  }
}

void main() async {
  await addRouteToFirestore();
}
