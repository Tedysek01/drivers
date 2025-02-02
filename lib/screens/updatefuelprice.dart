import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../benzinkaclass.dart';
import '../style/barvy.dart';

class UpdateFuelPriceScreen extends StatelessWidget {
  final PetrolStation station;

  const UpdateFuelPriceScreen({required this.station});

  @override
  Widget build(BuildContext context) {
    final TextEditingController dieselController =
    TextEditingController(text: station.dieselPrice);
    final TextEditingController petrolController =
    TextEditingController(text: station.petrolPrice);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upravit ceny paliv',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dieselController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cena nafty (Kč)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: petrolController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cena benzínu (Kč)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Aktualizace cen ve Firestore
              final updatedData = <String, dynamic>{};
              final now = DateTime.now(); // Aktuální čas
              final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown'; // Zde nahraďte aktuálním ID uživatele (např. z FirebaseAuth)

              if (dieselController.text.isNotEmpty) {
                updatedData['dieselPrice'] = dieselController.text;
              }
              if (petrolController.text.isNotEmpty) {
                updatedData['petrolPrice'] = petrolController.text;
              }

              // Přidání informací o aktualizaci
              updatedData['updatedBy'] = userId;
              updatedData['updatedAt'] = now;

              if (updatedData.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('stations')
                      .doc(station.id) // Použijeme `id` dokumentu
                      .update(updatedData);
                  print('Ceny byly úspěšně aktualizovány.');
                } catch (e) {
                  print('Chyba při aktualizaci cen: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Center(
              child: Text(
                'Uložit změny',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
