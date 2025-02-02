import 'dart:convert';
import 'dart:math';
import 'package:drivers/screens/routesdetail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../style/barvy.dart';
import '../okreskyclass.dart';

class FunRoutesScreen extends StatefulWidget {
  @override
  _FunRoutesScreenState createState() => _FunRoutesScreenState();
}

class _FunRoutesScreenState extends State<FunRoutesScreen> {
  List<FunRoute> routes = [];

  @override
  void initState() {
    super.initState();
    fetchFunRoutes();
  }

  Future<String> fetchEncodedPolyline(GeoPoint start, GeoPoint end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return data['routes'][0]['overview_polyline']['points'];
        }
      }
    } catch (e) {
      print('Error fetching polyline: $e');
    }
    return '';
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Poloměr Země v kilometrech
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  double calculateRouteLength(
      GeoPoint startLocation, List<GeoPoint> path, GeoPoint endLocation) {
    if (path.isEmpty) {
      // Pokud není žádný mezibod, vypočítáme pouze vzdálenost mezi start a end
      return calculateDistance(
        startLocation.latitude,
        startLocation.longitude,
        endLocation.latitude,
        endLocation.longitude,
      );
    }

    // Přidání vzdálenosti ze startLocation do prvního bodu path
    double totalDistance = calculateDistance(
      startLocation.latitude,
      startLocation.longitude,
      path.first.latitude,
      path.first.longitude,
    );

    // Přidání vzdálenosti mezi body v path
    for (int i = 0; i < path.length - 1; i++) {
      final start = path[i];
      final end = path[i + 1];
      totalDistance += calculateDistance(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

    // Přidání vzdálenosti z posledního bodu path do endLocation
    totalDistance += calculateDistance(
      path.last.latitude,
      path.last.longitude,
      endLocation.latitude,
      endLocation.longitude,
    );

    return totalDistance;
  }

  Future<void> fetchFunRoutes() async {
    try {
      // Získání aktuální polohy uživatele
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final snapshot =
          await FirebaseFirestore.instance.collection('routes').get();
      setState(() {
        routes = snapshot.docs.map((doc) {
          final data = doc.data();

          // Získání `path` jako mapa s indexy a GeoPointy
          final Map<String, dynamic> pathMap =
              data['path'] as Map<String, dynamic>;
          final List<GeoPoint> pathPoints =
              pathMap.values.whereType<GeoPoint>().toList();

          // Výpočet délky trasy včetně startLocation a endLocation
          final routeLength = calculateRouteLength(
            data['startLocation'] as GeoPoint,
            pathPoints,
            data['endLocation'] as GeoPoint,
          );

          // Vzdálenost od uživatele ke startLocation
          final startLocation = data['startLocation'] as GeoPoint;
          final distanceFromUser = calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            startLocation.latitude,
            startLocation.longitude,
          );

          return FunRoute(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            length: routeLength,
            rating: (data['rating'] ?? 0).toDouble(),
            startLocation: startLocation,
            endLocation: data['endLocation'] as GeoPoint,
            path: pathPoints,
            distanceFromUser:
                distanceFromUser, // Uložení vzdálenosti od uživatele
          );
        }).toList();

        // Třídění tras podle vzdálenosti od uživatele
        routes
            .sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));
      });
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  Future<String> buildStaticMapUrl(FunRoute route) async {
    final polyline =
        await fetchEncodedPolyline(route.startLocation, route.endLocation);

    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=600x300'
        '&path=color:blue|weight:5|enc:$polyline'
        '&markers=color:blue%7C${route.startLocation.latitude},${route.startLocation.longitude}'
        '&markers=color:red%7C${route.endLocation.latitude},${route.endLocation.longitude}'
        '&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
  }

  Future<String> getCityFromGeoPoint(GeoPoint location) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          // Extract city from the "address_components"
          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality')) {
              return component['long_name'];
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching city: $e');
    }
    return 'Nezname mesto'; // Fallback in case of errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Zábavné okresky'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: routes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: routes.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final route = routes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteDetailScreen(route: route),
                      ),
                    );
                  },
                  child: FutureBuilder(
                    future: Future.wait([
                      getCityFromGeoPoint(route.startLocation),
                      getCityFromGeoPoint(route.endLocation),
                      buildStaticMapUrl(route),
                    ]),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.length < 3) {
                        return SizedBox.shrink();
                      }
                      final startCity = snapshot.data![0];
                      final endCity = snapshot.data![1];
                      final mapUrl = snapshot.data![2];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: colorScheme.secondary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Static Map
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                mapUrl,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Route Details
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        route.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.circle,
                                              color: Colors.blue, size: 10),
                                          SizedBox(width: 8),
                                          Text(
                                            startCity,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.circle,
                                              color: Colors.red, size: 10),
                                          SizedBox(width: 8),
                                          Text(
                                            endCity,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Délka: ${route.length.toStringAsFixed(1)} km',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (starIndex) => Icon(
                                            Icons.star,
                                            color:
                                                starIndex < route.rating.round()
                                                    ? Colors.yellow
                                                    : Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
