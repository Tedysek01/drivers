import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/benzinkaclass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../style/barvy.dart';
import 'cenyphm_detail.dart';

String formatAddress(String? fullAddress) {
  if (fullAddress == null || fullAddress.isEmpty) return 'Načítání adresy...';

  final parts = fullAddress.split(',');

  if (parts.length >= 2) {
    final streetAndNumber = parts[0].trim();
    final city = parts[1].trim();
    return '$city, $streetAndNumber';
  }

  return fullAddress;
}

class PetrolPricesScreen extends StatefulWidget {
  @override
  _PetrolPricesScreenState createState() => _PetrolPricesScreenState();
}

class _PetrolPricesScreenState extends State<PetrolPricesScreen> {
  List<PetrolStation> stations = [];
  List<PetrolStation> filteredStations = [];
  final String apiKey = 'AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStations();
    fetchNearestStations();
  }

  Future<void> loadStations() async {
    try {
      // Načtení dat z Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('stations').get();

      // Převod dokumentů na seznam objektů PetrolStation
      setState(() {
        stations = snapshot.docs
            .map((doc) {
              final data = doc.data();
              try {
                return PetrolStation(
                  name: data['name'],
                  lat: data['lat'] is double
                      ? data['lat']
                      : double.parse(data['lat']),
                  lon: data['lon'] is double
                      ? data['lon']
                      : double.parse(data['lon']),
                  dieselPrice: data['dieselPrice'],
                  petrolPrice: data['petrolPrice'],
                  address: data['address'],
                  updatedBy: data['updatedBy'],
                  updatedAt: data['updatedAt'] != null
                      ? (data['updatedAt'] as Timestamp).toDate()
                      : null,
                  id: doc.id,
                );
              } catch (e) {
                print('Chyba při zpracování dokumentu: ${doc.id}, chyba: $e');
                return null; // Vrátí null pro problémové dokumenty
              }
            })
            .whereType<PetrolStation>()
            .toList();

        filteredStations = List.from(stations); // Inicializace filtrování
      });
    } catch (error) {
      print('Chyba při načítání benzínek z Firestore: $error');
    }
  }

  Future<void> fetchNearestStations() async {
    // Získání aktuální polohy uživatele
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Uživatel zamítl přístup k poloze.");
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final double currentLat = position.latitude;
      final double currentLon = position.longitude;

      print("Aktuální souřadnice: lat=$currentLat, lon=$currentLon");

      // Seřadíme benzínky podle vzdálenosti
      final List<PetrolStation> sortedStations = List.from(stations);
      sortedStations.sort((a, b) {
        final distanceA =
            calculateDistance(currentLat, currentLon!, a.lat, a.lon);
        final distanceB =
            calculateDistance(currentLat!, currentLon!, b.lat, b.lon);
        a.distanceFromUser = distanceA; // Uložíme vzdálenost pro zobrazení
        b.distanceFromUser = distanceB;
        return distanceA.compareTo(distanceB);
      });

      // Zobrazíme 5 nejbližších benzínek
      setState(() {
        filteredStations = sortedStations.take(15).toList();
      });

      // Načteme adresy pro zobrazené benzínky
      await fetchAddressForVisibleStations(0, filteredStations.length);
    } catch (error) {
      print("Chyba při získávání aktuální polohy: $error");
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      // Pokud je vyhledávací pole prázdné, zobrazíme všechny benzínky
      setState(() {
        filteredStations = List.from(stations);
      });
      return;
    }

    try {
      print("Vyhledávám lokaci: $query");
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey';
      print("Odesílám dotaz na URL: $url");

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final double lat = location['lat'];
        final double lon = location['lng'];
        print("Souřadnice nalezeny: lat=$lat, lon=$lon");

        // Seřadíme benzínky podle vzdálenosti od zadané lokace
        final List<PetrolStation> sortedStations = List.from(stations);
        sortedStations.sort((a, b) {
          final distanceA = calculateDistance(lat, lon, a.lat, a.lon);
          final distanceB = calculateDistance(lat, lon, b.lat, b.lon);
          return distanceA.compareTo(distanceB);
        });

        setState(() {
          filteredStations =
              sortedStations.take(15).toList(); // Omezíme na 15 nejbližších
        });

        print(
            "Aktualizovaný seznam benzínek: ${filteredStations.map((e) => e.name).toList()}");

        // Načteme adresy pro zobrazené benzínky
        await fetchAddressForVisibleStations(0, filteredStations.length);
      } else {
        print("Lokalita nenalezena: ${data['status']}");
      }
    } catch (error) {
      print("Chyba při vyhledávání lokality: $error");
    }
  }

  Future<void> fetchAddressForVisibleStations(
      int startIndex, int endIndex) async {
    final visibleStations = filteredStations
        .sublist(startIndex, endIndex)
        .where((station) => station.address == null)
        .toList();

    if (visibleStations.isNotEmpty) {
      await Future.wait(visibleStations.map((station) async {
        await station.fetchAddress(apiKey);
        setState(() {}); // Aktualizace UI pro nové adresy
      }));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vyhledávání benzínek'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Vyhledat lokalitu',
                  hintStyle: TextStyle(color: colorScheme.onSecondary),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: colorScheme.onPrimary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                style: TextStyle(color: colorScheme.onPrimary),
                onFieldSubmitted: (value) {
                  searchLocation(value);
                },
              ),
            ),
          ),
          Expanded(
              child: filteredStations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredStations.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final station = filteredStations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetrolStationDetailScreen(station: station),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ikona benzínky
                                Icon(
                                  Icons.local_gas_station,
                                  color: colorScheme.onSurface,
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                // Informace o benzínce
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        station.name,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatAddress(station.address),
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: colorScheme.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            station.distanceFromUser != null
                                                ? (station.distanceFromUser! >=
                                                        1
                                                    ? '${station.distanceFromUser!.toStringAsFixed(1)} km'
                                                    : '${(station.distanceFromUser! * 1000).toInt()} m')
                                                : 'Načítání vzdálenosti...',
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Ceny paliv
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Benzín:',
                                      style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      station.petrolPrice != null
                                          ? '${station.petrolPrice} Kč'
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
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      station.dieselPrice != null
                                          ? '${station.dieselPrice} Kč'
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
                      },
                    )),
        ],
      ),
    );
    ;
  }
}
