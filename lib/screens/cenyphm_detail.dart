import 'package:drivers/screens/updatefuelprice.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivers/benzinkaclass.dart';

class PetrolStationDetailScreen extends StatelessWidget {
  final PetrolStation station;

  const PetrolStationDetailScreen({required this.station});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zpětná navigace
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Návrat zpět
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Zpět',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Název a adresa
              Text(
                station.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adresa: ${station.address ?? 'Načítání...'}',
                style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
              ),
              const Divider(height: 30, thickness: 1, color: Colors.grey),

              // Informace o cenách
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ceny paliv:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nafta: ${station.dieselPrice ?? 'Neuvedeno'} Kč',
                        style: TextStyle(
                            fontSize: 18, color: colorScheme.onSurface),
                      ),
                      Text(
                        'Benzín: ${station.petrolPrice ?? 'Neuvedeno'} Kč',
                        style: TextStyle(
                            fontSize: 18, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        builder: (_) => UpdateFuelPriceScreen(station: station),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      'Upravit',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1, color: Colors.grey),

              // Mapa
              Text(
                'Poloha na mapě:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(station.lat, station.lon),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(station.name),
                        position: LatLng(station.lat, station.lon),
                        infoWindow: InfoWindow(
                          title: station.name,
                          snippet: station.address,
                        ),
                      ),
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tlačítko navigace
              ElevatedButton(
                onPressed: () {
                  print('Navigace spuštěna!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, color: colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Navigovat',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
