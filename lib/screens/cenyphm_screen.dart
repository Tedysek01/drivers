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
    final String response = await rootBundle.loadString('assets/benzinky.json');
    final data = json.decode(response) as List;
    setState(() {
      stations = data.map((e) => PetrolStation.fromJson(e)).toList();
    });
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
                        '${station.address}\nNafta: ${station.dieselPrice} Kč | Benzín: ${station.petrolPrice} Kč'),
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
            Text('Adresa: ${station.address}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Nafta: ${station.dieselPrice} Kč',
                style: TextStyle(fontSize: 18)),
            Text('Benzín: ${station.petrolPrice} Kč',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Detaily:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(station.details, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
