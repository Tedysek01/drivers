import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'benzinkaclass.dart';

class DataProvider extends ChangeNotifier {
  List<PetrolStation>? _stations;
  PetrolStation? _cheapestStation;
  double? _distanceToUser;

  List<PetrolStation>? get stations => _stations;
  PetrolStation? get cheapestStation => _cheapestStation;
  double? get distanceToUser => _distanceToUser;

  bool get isLoaded => _stations != null;

  
  Future<void> _loadStationsFromCache() async {
  final prefs = await SharedPreferences.getInstance();
  final cachedStations = prefs.getStringList('stations_cache');

  if (cachedStations != null) {
    _stations = cachedStations.map((stationString) {
      final data = jsonDecode(stationString);
      return PetrolStation(
        id: data['id'],
        name: data['name'],
        lat: data['lat'],
        lon: data['lon'],
        address: data['address'],
      );
    }).toList();

    print("✅ Načteno ${_stations!.length} benzínek z cache.");
  }
}

  
  
  /// 🔹 Načtení dat o benzínkách
  Future<void> loadData() async {
  if (_stations == null) {
    await _loadStationsFromCache();
  }

  try {
    print("🔄 Načítám aktuální ceny a vzdálenost...");

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final snapshot = await FirebaseFirestore.instance.collection('stations').get();
    List<PetrolStation> updatedStations = snapshot.docs.map((doc) {
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

    print("📌 Načteno ${updatedStations.length} benzínek z Firebase.");

    // Vypočítej vzdálenosti
    for (var station in updatedStations) {
      double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude, station.lat, station.lon,
      ) / 1000; // Převod na km
      station.distanceFromUser = distance;
      //print("📍 ${station.name} - $distance km");
    }

    _stations = updatedStations;

    // 🔥 Najdi nejlevnější benzínku do 10 km


    
    List<PetrolStation> nearbyStations = _stations!.where((station) {
      return station.distanceFromUser != null && station.distanceFromUser! <= 10;
    }).toList();

    print("🔍 Počet benzínek do 10 km: ${nearbyStations.length}");

    // Seřadit podle ceny benzínu
    nearbyStations.sort((a, b) {
      double priceA = a.petrolPrice != null ? double.tryParse(a.petrolPrice!) ?? double.infinity : double.infinity;
      double priceB = b.petrolPrice != null ? double.tryParse(b.petrolPrice!) ?? double.infinity : double.infinity;
      return priceA.compareTo(priceB);
    });

    if (nearbyStations.isNotEmpty) {
      _cheapestStation = nearbyStations.first;
      _distanceToUser = _cheapestStation!.distanceFromUser;

      print("⛽ Nejlevnější benzínka: ${_cheapestStation!.name} - ${_cheapestStation!.petrolPrice} Kč");

      if (_cheapestStation!.address == null || _cheapestStation!.address!.isEmpty) {
        await fetchAddress(_cheapestStation!);
      }
    } else {
      print("🚨 Žádná benzínka nesplňuje podmínky (vzdálenost ≤ 10 km).");
    }

    notifyListeners();
  } catch (e) {
    print("❌ Chyba při načítání dat: $e");
  }
}


  /// 🔹 Načtení adresy z Google Geocoding API
  Future<void> fetchAddress(PetrolStation station) async {

    if (station.address != null && station.address!.isNotEmpty && station.address != "Adresa nenalezena") {
      print("✅ Adresa již existuje: ${station.address}, nebudeme znovu načítat.");
      return; // Pokud je adresa už nastavena, ukončíme funkci
    }

    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${station.lat},${station.lon}&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';

      try {
        print("🌍 Získávám adresu pro: ${station.lat}, ${station.lon}");
        final response = await http.get(Uri.parse(url));

        print("🌍 API Response Status: ${response.statusCode}");
        print("🌍 API Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            station.address = _formatAddress(data['results'][0]);
            print("📍 Adresa načtena a nastavena na: ${station.address}");
            notifyListeners(); // 🔹 Aktualizuj UI
          } else {
            print("⚠️ API vrátilo prázdné výsledky.");
            station.address = 'Adresa nenalezena';
            notifyListeners();
          }
        } else {
          print("❌ Chyba při volání API: ${response.statusCode}");
          station.address = 'Chyba při načítání adresy';
          notifyListeners();
        }
      } catch (e) {
        print("❌ Výjimka při načítání adresy: $e");
        station.address = 'Chyba při načítání adresy';
        notifyListeners();
      }
    }


    /// 🔹 Formátování adresy
  String _formatAddress(Map<String, dynamic> result) {
    String street = "";
    String city = "";
    String houseNumber = "";

    for (var component in result['address_components']) {
      List types = component['types'];

      if (types.contains('route')) {
        street = component['long_name']; // Název ulice
      }
      if (types.contains('street_number')) {
        houseNumber = component['long_name']; // Číslo popisné
      }
      if (types.contains('locality')) {
        city = component['long_name']; // Název města
      }
      if (types.contains('administrative_area_level_2') && city.isEmpty) {
        city = component['long_name']; // Náhradní město
      }
    }

    // Výstup formátované adresy
    final formattedAddress = street.isNotEmpty && houseNumber.isNotEmpty
        ? "$street $houseNumber, $city"
        : street.isNotEmpty
        ? "$street, $city"
        : city;

    print("📍 Formátovaná adresa: $formattedAddress");
    return formattedAddress;
  }

}
