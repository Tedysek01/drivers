import 'dart:math';

import 'package:drivers/main.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:drivers/screens/home.dart';
import 'package:drivers/benzinkaclass.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  List<PetrolStation> stations = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Get User's Current Location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLat = position.latitude;
      double userLon = position.longitude;

      // Fetch petrol stations from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('stations').get();

      stations = snapshot.docs.map((doc) {
        final data = doc.data();
        return PetrolStation.fromJson(doc.id, data)
          ..distanceFromUser =
              _calculateDistance(userLat, userLon, data['lat'], data['lon']);
      }).toList();

      // Sort by nearest petrol station
      stations
          .sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));

      // Navigate to home screen with preloaded stations
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainApp(),
        ),
      );
    } catch (e) {
      print("Error loading initial data: $e");
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in km
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
      backgroundColor: colorScheme.surface,
      body: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
        ),
      ),
    );
  }
}
