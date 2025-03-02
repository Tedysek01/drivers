import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/okreskyclass.dart';
import 'package:drivers/screens/marketplace_detail.dart';
import 'package:drivers/screens/routes.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'event_details.dart';

import '../benzinkaclass.dart';
import '../data_provider.dart';
import 'cenyphm_detail.dart';
import 'cenyphm_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers/screens/cenyphm_detail.dart'; // Import PetrolStationDetailScreen
import 'package:drivers/benzinkaclass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  final List<PetrolStation> stations; // Accept stations as a parameter

  const MyHomePage({Key? key, required this.stations}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Aktuálně vybraný index
  List<FunRoute> _routes = [];

  @override
  void initState() {
    super.initState();
    fetchFunRoutes(); // ✅ Načtení okresek
  }

  Future<void> fetchFunRoutes() async {
    try {
      print("📡 Načítám okresky...");
      final snapshot =
          await FirebaseFirestore.instance.collection('routes').get();
      print("✅ Okresky načteny: ${snapshot.docs.length}");

      if (!mounted) return; // ✅ Ověření, zda widget stále existuje

      setState(() {
        _routes =
            snapshot.docs.map((doc) => FunRoute.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('❌ Chyba při načítání okresek: $e');
    }
  }

  Future<String> fetchEncodedPolyline(GeoPoint start, GeoPoint end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';

    print("🌍 Načítám polyline z URL: $url"); // ✅ Debug výpis

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final polyline = data['routes'][0]['overview_polyline']['points'];
          print("✅ Polyline načtena: $polyline"); // ✅ Výpis polyline
          return polyline;
        }
      }
    } catch (e) {
      print('❌ Chyba při načítání polyline: $e');
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
      print("⚠️ Upozornění: Trasa neobsahuje žádné body mezi startem a cílem.");
      return calculateDistance(
        startLocation.latitude,
        startLocation.longitude,
        endLocation.latitude,
        endLocation.longitude,
      );
    }

    double totalDistance = calculateDistance(
      startLocation.latitude,
      startLocation.longitude,
      path.first.latitude,
      path.first.longitude,
    );

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

    totalDistance += calculateDistance(
      path.last.latitude,
      path.last.longitude,
      endLocation.latitude,
      endLocation.longitude,
    );

    print("✅ Celková délka trasy: $totalDistance km");
    return totalDistance;
  }

  Future<String> buildStaticMapUrl(FunRoute route) async {
    final polyline =
        await fetchEncodedPolyline(route.startLocation, route.endLocation);

    List<GeoPoint> points = [
      route.startLocation,
      ...route.path,
      route.endLocation
    ];

    // Najdeme extrémní souřadnice (bounding box)
    double minLat =
        points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat =
        points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng =
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng =
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    // Přidáme malý padding (aby nebyla trasa nalepená na okraje)
    double latPadding = (maxLat - minLat) * 0.2;
    double lngPadding = (maxLng - minLng) * 0.2;

    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;

    // Výpočet středu bounding boxu
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;

    // Dynamický výpočet zoomu
    int zoom = calculateZoom(minLat, maxLat, minLng, maxLng);

    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=600x300'
        '&scale=2' // Lepší rozlišení
        '&path=color:blue|weight:5|enc:$polyline' // Trasa
        '&markers=color:blue%7C${route.startLocation.latitude},${route.startLocation.longitude}'
        '&markers=color:red%7C${route.endLocation.latitude},${route.endLocation.longitude}'
        '&visible=${minLat},${minLng}|${maxLat},${maxLng}' // 👈 Toto donutí mapu zobrazit celou trasu
        '&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
  }

  int calculateZoom(
      double minLat, double maxLat, double minLng, double maxLng) {
    const int MAP_WIDTH = 600; // Šířka v pixelech
    const int MAP_HEIGHT = 300; // Výška v pixelech

    // Přepočítáme rozsah na stupně zeměpisné šířky a délky
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;

    // Určíme, která osa je dominantní
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Výpočet zoomu – upravený vzorec
    double zoomLevel =
        (log(360 / maxDiff) / log(2)) - log(MAP_WIDTH / 256) / log(2);
    return zoomLevel.clamp(6, 15).floor(); // Omezíme zoom do rozumných mezí
  }

  Future<String> getCityFromGeoPoint(GeoPoint location) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
    print("🌍 Načítám město pro: ${location.latitude}, ${location.longitude}");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📜 API Response: $data"); // 🔥 Log the full response

        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var result in data['results']) {
            for (var component in result['address_components']) {
              print(
                  "🔍 Address Component: ${component}"); // Log all address components
              if (component['types'].contains('locality')) {
                print("✅ Nalezené město: ${component['long_name']}");
                return component['long_name'];
              }
            }
          }
        }
        print("❌ Město nenalezeno v odpovědi API");
      } else {
        print("❌ Chyba API: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Chyba při načítání města: $e');
    }

    return 'Neznáme město'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (!dataProvider.isLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
  backgroundColor: colorScheme.surface,
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(

                child: Image.asset(
                  'assets/logowide.png',
                  width: 140,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Natankuj si!',
                    style: TextStyle(
                      fontSize: 20,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PetrolPricesScreen()),
                      );
                    },
                    child: Text(
                      'Zobrazit vše...',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              // "Natankuj si!" Section
              SizedBox(height: 7),
              _FuelPriceCard(),

              SizedBox(height: 23),

              Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.start,
                children: [
                  _buildChoiceChip("Příspěvky", 0, useGradient: true),
                  _buildChoiceChip("Marketplace", 1, useGradient: true),
                  _buildChoiceChip("Okresky", 2, useGradient: true),
                  _buildChoiceChip("Srazy", 3,
                      useGradient: true), // Použije gradient
                ],
              ),

              SizedBox(height: 16),
              _selectedIndex == 0
                  ? _buildTopPost()
                  : _selectedIndex == 1
                      ? _buildMarketplace()
                      : _selectedIndex == 2
                          ? _buildFunRoutes()
                          : _buildEvents(), // ✅ Přidáno zobrazení srazů
            ],
          ),
        ),
      ),
    
  );
  }

  Widget _buildEvents() {
  // Mapování typů srazů na ikony
  final Map<String, String> eventIcons = {
    'Drifty': '/Users/mac/Development/drivers/assets/drifty.png',
    'Sraz': '/Users/mac/Development/drivers/assets/sraz.png',
    'Závody': 'assets/race.png',
    'Okresky': 'assets/road.png',
  };

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('events').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('Žádné akce nejsou dostupné.'));
      }

      var events = snapshot.data!.docs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PLÁNOVANÉ SRAZY 🚗💨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 14),
          Column(
            children: events.map((event) {
              var eventData = event.data() as Map<String, dynamic>;
              final eventType = eventData['type'] ?? 'road'; // Výchozí typ, pokud není zadán
              final iconPath = eventIcons[eventType] ?? 'assets/road.png'; // Výchozí ikona, pokud typ není v mapě

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(
                        title: eventData['name'] ?? 'Neznámá akce',
                        location: eventData['location'] ?? 'Neznámé místo',
                        date: eventData['date'] ?? 'Neznámé datum',
                        type: eventData['type'] ?? 'Neznámý typ',
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: colorScheme.secondary,
                  child: Row(
                    children: [
                      // Ikona srazu
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 10),
                        child: Image.asset(
                          iconPath,
                          width: 50, // Nastavte šířku ikony
                          height: 50, // Nastavte výšku ikony
                          fit: BoxFit.cover,
                          color: colorScheme.primary,
                        ),
                      ),
                      // Textové informace o srazu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                eventData['name'] ?? 'Neznámá akce',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${eventData['location'] ?? 'Neznámé místo'} • ${eventData['date'] ?? 'Neznámé datum'}',
                                style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(0.7)),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: colorScheme.onPrimary),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 12),
                              child: Text(
                                eventData['type'] ?? 'Neznámý typ',
                                style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(0.7)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}

  Widget _buildChoiceChip(String label, int index, {bool useGradient = false}) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 1, vertical: 2), // ✅ Přidá mezery mezi chipy
      child: Container(
        decoration: isSelected && useGradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.redAccent], // ✅ Gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              )
            : null, // ✅ Pouze aktivní chip má gradient

        padding: isSelected && useGradient
            ? EdgeInsets.all(1.5) // ✅ Přidá vnitřní padding pro gradient
            : EdgeInsets.zero, // Neaktivní chip nemá padding

        child: ChoiceChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : const Color.fromARGB(
                      255, 145, 145, 145), // ✅ Opravená barva textu
              fontWeight: FontWeight.w600,
            ),
          ),
          checkmarkColor: Colors.white,
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              _selectedIndex = index;
            });
          }, // ✅ Neaktivní chip průhledný
          backgroundColor: colorScheme.secondary,
          selectedColor: colorScheme.secondary, // ✅ Aby fungoval gradient
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : const Color.fromARGB(255, 145, 145, 145), // ✅ Lepší rámeček
              width: 2,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 11),
          elevation: 0, // ✅ Bez stínu pro čistší vzhled
        ),
      ),
    );
  }

  /// 🔄 Placeholder widget for loading state
  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.secondary,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// ❌ Placeholder widget for error state
  Widget _buildErrorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.secondary,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
            child: Text("❌ Chyba při načítání dat",
                style: TextStyle(color: Colors.white))),
      ),
    );
  }

  /// ❌ Placeholder widget for failed map loading
  Widget _buildErrorMap() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      color: Colors.grey[800], // Fallback background color
      child: Text("❌ Nelze načíst mapu", style: TextStyle(color: Colors.white)),
    );
  }

  /// 🔥 Widget pro zobrazení okresek
  Widget _buildFunRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "ZÁBAVNÉ OKRESKY 🏁",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              child: Text('Zobrazit vše',
                  style: TextStyle(color: colorScheme.primary)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FunRoutesScreen()),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 14),

        // ✅ Kontrola, zda jsou okresky načteny
        _routes.isEmpty
            ? Center(child: CircularProgressIndicator()) // ⏳ Načítání
            : Column(
                children: _routes.map((route) {
                  return _buildRouteCard(route);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildRouteCard(FunRoute route) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        getCityFromGeoPoint(route.startLocation), // Název start města
        getCityFromGeoPoint(route.endLocation), // Název cílového města
        buildStaticMapUrl(route), // URL statické mapy
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!snapshot.hasData || snapshot.data!.length < 3) {
          print("⚠️ Chyba: Data se nepodařilo načíst");
          return _buildErrorCard();
        }

        final startCity = snapshot.data![0];
        final endCity = snapshot.data![1];
        final mapUrl = snapshot.data![2];

        print("✅ Start: $startCity, End: $endCity, Length: ${route.length} km");

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: colorScheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🗺 Static Map
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  mapUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorMap();
                  },
                ),
              ),

              // ℹ️ Route Details
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 📍 Města + Název trasy
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.blue, size: 10),
                              SizedBox(width: 6),
                              Text(
                                startCity,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 10),
                              SizedBox(width: 6),
                              Text(
                                endCity,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ℹ️ Délka trasy + Hodnocení
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${route.length.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              Icons.star,
                              color: starIndex < route.rating.round()
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 16,
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
    );
  }

  Widget _buildTopPost() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TOP DNEŠNÍ PŘÍSPĚVEK 🔥",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 14,
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius:
                BorderRadius.circular(10), // Zaoblené rohy pro celý box
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Obrázek
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ), // Zaoblení pouze pro horní rohy
                child: Image.network(
                  "http://ddztmb1ahc6o7.cloudfront.net/policarobmw/wp-content/uploads/2021/02/05112228/2022-BMW-M5-CS-Driving1-1.jpg",
                  height: 200, // Nastavení výšky obrázku
                  width: double.infinity, // Obrázek vyplní celý prostor
                  fit: BoxFit.cover, // Obrázek se přizpůsobí prostoru
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0), // Vnitřní odsazení textu
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Uživatel
                    Text(
                      "tedysek04",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Popis příspěvku
                    Text(
                      "Dnešní poježdění po poušti ON TOP",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Interakce
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Vertikální zarovnání ikon
                      children: [
                        // Lajky
                        Icon(Icons.favorite_border,
                            color: colorScheme.onPrimary),
                        const SizedBox(width: 5),
                        Text(
                          "123",
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 20), // Mezera mezi ikonami
                        // Komentáře
                        Image.asset(
                          'assets/zpravy.png',
                          height: 27,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "45",
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 20), // Mezera mezi ikonami
                        // Sdílení
                        Icon(Icons.share_outlined,
                            color: colorScheme.onPrimary),
                        const Spacer(), // Oddělení pravé strany od levé
                        // Bookmark
                        Icon(Icons.bookmark_border,
                            color: colorScheme.onPrimary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget for "Marketplace" Section – načítá data z Firestore
  Widget _buildMarketplace() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('marketplace')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text("Chyba při načítání dat: ${snapshot.error}"));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Text(
            'Žádné nabídky na marketplace.',
            style: TextStyle(fontSize: 16, color: colorScheme.onPrimary),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NABÍDKY NA MARKETPLACE 🏎️",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14),
              TextFormField(
                style: TextStyle(color: colorScheme.onPrimary),
                decoration: InputDecoration(
                  hintText: 'Prohledat Marketplace...',
                  hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  suffixIcon: Icon(CupertinoIcons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 7),
            ],
          ),
          ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true, // ✅ Řeší problém s nekonečnou výškou
            physics: NeverScrollableScrollPhysics(), // ✅ Zabrání konfliktu se SingleChildScrollView
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return _buildListingCard(context, doc);
            },
          ),
        ],
      );
    },
  );
}



  Widget _buildListingCard(BuildContext context, QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    String docId = doc.id; // 📌 Získáme ID dokumentu

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.secondary,
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailScreen(docId: docId),
            ),
          );
        },
        child: Row(
          children: [
            // 🖼 Obrázek auta
            Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(12)),
                image: data['images'] != null && data['images'].isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(data['images'][0]),
                        fit: BoxFit.cover)
                    : DecorationImage(
                        image: AssetImage('assets/placeholder_car.png'),
                        fit: BoxFit.cover),
              ),
            ),

            // 📋 Textové info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['brand']} ${data['model']}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${data['year']}, ${data['mileage']} km, ${data['fuelType']}",
                      style: TextStyle(
                          fontSize: 14, color: colorScheme.onSecondary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${data['price']} Kč",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension GradientDecoration on Widget {
  Widget decorateWithGradient(bool apply) {
    if (!apply) return this;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.redAccent], // Lepší barvy
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.2), // Jemný stín pro vizuální oddělení
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: this,
    );
  }
}

class _FuelPriceCard extends StatefulWidget {
  @override
  _FuelPriceCardState createState() => _FuelPriceCardState();
}

class _FuelPriceCardState extends State<_FuelPriceCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 🔥 Uchová widget v paměti

  PetrolStation? cheapestStation;
  double? distanceToUser;
  String? formattedAddress; // Uložená adresa benzínky

  @override
  void initState() {
    super.initState();
    fetchCheapestStation(); // Načíst benzinku při prvním vykreslení
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🔥 Důležité pro AutomaticKeepAliveClientMixin
    final dataProvider = Provider.of<DataProvider>(context);

    if (!dataProvider.isLoaded) {
      return Center(child: CircularProgressIndicator());
    }

    if (cheapestStation == null) {
      return Center(child: Text("Žádná dostupná benzínka v okolí."));
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PetrolStationDetailScreen(station: cheapestStation!)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(8), // 🔥 Mírně menší zaoblení
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10), // 🔥 Kompaktnější padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment
              .center, // 🔥 Zarovnání na střed pro lepší vzhled
          children: [
            // ⛽ Ikona benzínky
            Icon(Icons.local_gas_station,
                color: colorScheme.onSurface, size: 26),
            const SizedBox(width: 12),

            // 📍 Informace o benzínce
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 Název benzínky (max šířka + "..." pro dlouhé názvy)
                  Text(
                    cheapestStation!.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // ⏳ Pokud je název dlouhý, zobrazí "..."
                  ),
                  const SizedBox(height: 2),

                  // 🏠 Adresa benzínky (zkrácená pokud je dlouhá)
                  Text(
                    formattedAddress ?? "Načítání adresy...",
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // ⏳ Stejně jako u názvu, zabraňuje rozbití vzhledu
                  ),
                  const SizedBox(height: 2),

                  // 📍 Vzdálenost od uživatele
                  Row(
                    children: [
                      Image.asset('assets/navigation.png',
                          height: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        distanceToUser != null
                            ? "${distanceToUser!.toStringAsFixed(1)} km"
                            : "Načítání...",
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ⛽ Ceny paliva (zarovnané doprava)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPriceRow('Benzín:', cheapestStation!.petrolPrice),
                const SizedBox(height: 4),
                _buildPriceRow('Nafta:', cheapestStation!.dieselPrice),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Pomocná funkce pro zobrazení ceny (zmenšená, zarovnaná)
  Widget _buildPriceRow(String label, String? price) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          price != null ? '$price Kč' : '--',
          style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Future<void> fetchCheapestStation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final snapshot =
          await FirebaseFirestore.instance.collection('stations').get();

      List<PetrolStation> stations = snapshot.docs.map((doc) {
        final data = doc.data();
        return PetrolStation(
          id: doc.id,
          name: data['name'] ?? 'Neznámá benzínka',
          lat: data['lat'],
          lon: data['lon'],
          address: data['address'],
          dieselPrice: data['dieselPrice'],
          petrolPrice: data['petrolPrice'],
        );
      }).toList();

      // Najít nejlevnější benzinku v okruhu 10 km
      stations = stations.where((station) {
        double distance = Geolocator.distanceBetween(position.latitude,
                position.longitude, station.lat, station.lon) /
            1000;
        return distance <= 10;
      }).toList();

      // Seřadit podle ceny
      stations.sort((a, b) {
        double priceA = a.petrolPrice != null
            ? double.parse(a.petrolPrice!)
            : double.infinity;
        double priceB = b.petrolPrice != null
            ? double.parse(b.petrolPrice!)
            : double.infinity;
        return priceA.compareTo(priceB);
      });

      if (stations.isNotEmpty) {
        setState(() {
          cheapestStation = stations.first;
          distanceToUser = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  cheapestStation!.lat,
                  cheapestStation!.lon) /
              1000;
        });

        // 🔥 Adresu načteme jen jednou a uložíme do proměnné
        fetchAddress(cheapestStation!);
      }
    } catch (e) {
      print("Chyba při získávání nejlevnější benzínky: $e");
    }
  }

  Future<void> fetchAddress(PetrolStation station) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${station.lat},${station.lon}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            formattedAddress = _formatAddress(
                data['results'][0]); // 🔥 Uloží adresu pro další použití
          });
        }
      }
    } catch (e) {
      print("Chyba při načítání adresy: $e");
    }
  }

  String _formatAddress(Map<String, dynamic> result) {
    String street = "";
    String city = "";
    String houseNumber = "";

    for (var component in result['address_components']) {
      List types = component['types'];

      if (types.contains('route')) {
        street = component['long_name'];
      }
      if (types.contains('street_number')) {
        houseNumber = component['long_name'];
      }
      if (types.contains('locality')) {
        city = component['long_name'];
      }
      if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = component['long_name'];
      }
    }

    return street.isNotEmpty && houseNumber.isNotEmpty
        ? "$street $houseNumber, $city"
        : street.isNotEmpty
            ? "$street, $city"
            : city;
  }
}
