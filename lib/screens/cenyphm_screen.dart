import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/benzinkaclass.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../data_provider.dart';
import 'cenyphm_detail.dart';
import '../style/barvy.dart';

class PetrolPricesScreen extends StatefulWidget {
  @override
  _PetrolPricesScreenState createState() => _PetrolPricesScreenState();
}

class _PetrolPricesScreenState extends State<PetrolPricesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PetrolStation> filteredStations = [];

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.loadData();

      List<PetrolStation> sortedStations = List.from(dataProvider.stations!);

      // Seřadíme benzínky podle vzdálenosti
      sortedStations
          .sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));

      // Vybereme 20 nejbližších
      List<PetrolStation> nearestStations = sortedStations.take(20).toList();

      // Seřadíme je podle ceny benzínu
      nearestStations.sort((a, b) {
        double priceA = a.petrolPrice != null
            ? double.parse(a.petrolPrice!)
            : double.infinity;
        double priceB = b.petrolPrice != null
            ? double.parse(b.petrolPrice!)
            : double.infinity;
        return priceA.compareTo(priceB);
      });

      setState(() {
        filteredStations = nearestStations;
      });

      await fetchAddressForVisibleStations();
    } catch (error) {
      print('Chyba při načítání benzínek: $error');
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredStations = List.from(
            Provider.of<DataProvider>(context, listen: false)
                .stations!
                .take(20));
      });
      return;
    }

    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final double lat = location['lat'];
        final double lon = location['lng'];

        List<PetrolStation> sortedStations = List.from(
            Provider.of<DataProvider>(context, listen: false).stations!);

        sortedStations.sort((a, b) {
          final distanceA = Geolocator.distanceBetween(lat, lon, a.lat, a.lon);
          final distanceB = Geolocator.distanceBetween(lat, lon, b.lat, b.lon);
          return distanceA.compareTo(distanceB);
        });

        setState(() {
          filteredStations = sortedStations.take(20).toList();
        });

        await fetchAddressForVisibleStations();
      } else {
        print("Lokalita nenalezena: ${data['status']}");
      }
    } catch (error) {
      print("Chyba při vyhledávání lokality: $error");
    }
  }

  Future<void> fetchAddressForVisibleStations() async {
    for (var station in filteredStations) {
      if (station.address == null || station.address!.isEmpty) {
        await Provider.of<DataProvider>(context, listen: false)
            .fetchAddress(station);
      }
    }
    setState(() {}); // Aktualizace UI
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

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
                                      station.name,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      station.address ?? 'Načítání adresy...',
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
                                              ? (station.distanceFromUser! >= 1
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
                  ),
          ),
        ],
      ),
    );
  }
}
