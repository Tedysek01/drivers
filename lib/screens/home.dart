import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../benzinkaclass.dart';
import 'cenyphm_detail.dart';
import 'cenyphm_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers/screens/cenyphm_detail.dart'; // Import PetrolStationDetailScreen
import 'package:drivers/benzinkaclass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatelessWidget {
  final List<PetrolStation> stations; // Accept stations as a parameter

  const MyHomePage({Key? key, required this.stations})
      : super(key: key); // Require stations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              const SizedBox(height: 20),
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
              const SizedBox(height: 7),
              _FuelPriceCard(),

              const SizedBox(height: 23),

              // "TOP dnešní příspěvek" Section
              Text(
                "TOP DNEŠNÍ PŘÍSPĚVEK 🔥",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildTopPost(),

              const SizedBox(height: 23),

              // "Marketplace" Section
              Text(
                "Marketplace",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              _buildMarketplace(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPost() {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(10), // Zaoblené rohy pro celý box
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
              "https://ddztmb1ahc6o7.cloudfront.net/policarobmw/wp-content/uploads/2021/02/05112228/2022-BMW-M5-CS-Driving1-1.jpg",
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
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Vertikální zarovnání ikon
                  children: [
                    // Lajky
                    Icon(Icons.favorite_border, color: colorScheme.onPrimary),
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
                    Icon(Icons.share_outlined, color: colorScheme.onPrimary),
                    const Spacer(), // Oddělení pravé strany od levé
                    // Bookmark
                    Icon(Icons.bookmark_border, color: colorScheme.onPrimary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for "Marketplace" Section
  Widget _buildMarketplace() {
    return CarouselSlider(
      items: [
        _buildMarketplaceCard(
          imageUrl:
              "https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/2010_Mercedes-Benz_C_200_CGI_%28W_204%29_Classic_sedan_%282010-09-23%29_01.jpg/1024px-2010_Mercedes-Benz_C_200_CGI_%28W_204%29_Classic_sedan_%282010-09-23%29_01.jpg",
          title: "Mercedes S class",
          mileage: 167000,
          year: 2010,
          price: 240000,
        ),
        _buildMarketplaceCard(
          imageUrl:
              "https://luxurypulse.com/img/pictures/5e47cd4632471-large.jpg",
          title: "McLaren P1",
          mileage: 50000,
          year: 2018,
          price: 2240000,
        ),
      ],
      options: CarouselOptions(
        height: 230, // Adjust height for the cards
        enlargeCenterPage: false, // Disable enlarging the center card
        enableInfiniteScroll: true, // Allow infinite scrolling
        autoPlay: true, // Enable auto-play
        viewportFraction:
            0.5, // Show two cards side-by-side (50% width for each card)
        padEnds: false, // Avoid extra padding at the edges
      ),
    );
  }

// Individual Marketplace Card
  Widget _buildMarketplaceCard({
    required String imageUrl,
    required String title,
    required int mileage,
    required int year,
    required int price,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$year",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "$mileage km",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      "${NumberFormat.currency(locale: "cs_CZ", symbol: "Kč", decimalDigits: 0).format(price)}",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.all(5.0),
              child: Icon(
                Icons.favorite_border,
                grade: 4,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelPriceCard extends StatefulWidget {
  @override
  _FuelPriceCardState createState() => _FuelPriceCardState();
}

class _FuelPriceCardState extends State<_FuelPriceCard> {
  PetrolStation? cheapestStation;
  double? distanceToUser; // Store distance for display

  @override
  void initState() {
    super.initState();
    fetchCheapestStation();
  }

  Future<void> fetchCheapestStation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

      // Filter stations within 20 km radius
      stations = stations.where((station) {
        double distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              station.lat,
              station.lon,
            ) /
            1000; // Convert meters to km
        return distance <= 20;
      }).toList();

      // Find the cheapest petrol price
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
                cheapestStation!.lon,
              ) /
              1000; // Convert meters to km
        });

        // Fetch formatted address if missing
        if (cheapestStation!.address == null ||
            cheapestStation!.address!.isEmpty) {
          await fetchAddress(cheapestStation!);
        }
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
          station.address = _formatAddress(data['results'][0]);
          setState(() {}); // Update UI with the formatted address
        }
      }
    } catch (e) {
      print("Chyba při načítání adresy: $e");
    }
  }

  // **Formats address to only street + city**
  String _formatAddress(Map<String, dynamic> result) {
    String street = "";
    String city = "";
    String houseNumber = "";

    for (var component in result['address_components']) {
      List types = component['types'];

      if (types.contains('route')) {
        street = component['long_name']; // Street name
      }
      if (types.contains('street_number')) {
        houseNumber = component['long_name']; // House number
      }
      if (types.contains('locality')) {
        city = component['long_name']; // City name
      }
      if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = component['long_name']; // District fallback
      }
    }

    // **Formatted output**: "Street Name 123, City" OR "City" if no street
    if (street.isNotEmpty && houseNumber.isNotEmpty) {
      return "$street $houseNumber, $city";
    } else if (street.isNotEmpty) {
      return "$street, $city";
    } else {
      return city;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cheapestStation == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PetrolStationDetailScreen(station: cheapestStation!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_gas_station,
              color: colorScheme.onSurface,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cheapestStation!.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cheapestStation!.address ?? "Načítání adresy...",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        'assets/navigation.png', // 🧭 Navigation Icon
                        height: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distanceToUser != null
                            ? "${distanceToUser!.toStringAsFixed(1)} km"
                            : "Načítání...",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Benzín:',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  cheapestStation!.petrolPrice != null
                      ? '${cheapestStation!.petrolPrice} Kč'
                      : '--',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nafta:',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  cheapestStation!.dieselPrice != null
                      ? '${cheapestStation!.dieselPrice} Kč'
                      : '--',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
