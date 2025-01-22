import 'dart:convert';
import 'package:drivers/benzinkaclass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PetrolPricesScreen extends StatefulWidget {
  @override
  _PetrolPricesScreenState createState() => _PetrolPricesScreenState();
}

class _PetrolPricesScreenState extends State<PetrolPricesScreen> {
  List<PetrolStation> stations = [];

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    try {
      print("Začínám načítat JSON...");
      final String response =
          await rootBundle.loadString('assets/stations_processed.json');
      print("JSON úspěšně načten!");

      final List<dynamic> data = json.decode(response);
      print("JSON dekódován, počet položek: ${data.length}");

      setState(() {
        stations =
            data.where((e) => e['lat'] != null && e['lon'] != null).map((e) {
          return PetrolStation(
            name: e['name'] ?? 'Neznámá benzínka',
            lat: e['lat'].toDouble(),
            lon: e['lon'].toDouble(),
          );
        }).toList();
        print("Benzínky načteny, počet: ${stations.length}");
      });
    } catch (error) {
      print("Chyba při načítání JSON: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ceny paliv'),
        backgroundColor: Colors.orange,
      ),
      body: stations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(station.name),
                    subtitle: Text(
                        'Lat: ${station.lat}, Lon: ${station.lon}\nAdresa: ${station.address ?? 'Není k dispozici'}'),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PetrolStationDetailScreen(station: station),
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

class PetrolStationDetailScreen extends StatelessWidget {
  final PetrolStation station;

  const PetrolStationDetailScreen({required this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lat: ${station.lat}, Lon: ${station.lon}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Adresa: ${station.address ?? 'Není k dispozici'}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Nafta: ${station.dieselPrice ?? 'Neuvedeno'} Kč',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Benzín: ${station.petrolPrice ?? 'Neuvedeno'} Kč',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
