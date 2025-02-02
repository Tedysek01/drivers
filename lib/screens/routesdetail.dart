import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:drivers/okreskyclass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteDetailScreen extends StatelessWidget {
  final FunRoute route;

  const RouteDetailScreen({required this.route});

  Future<String> fetchEncodedPolyline() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${route.startLocation.latitude},${route.startLocation.longitude}&destination=${route.endLocation.latitude},${route.endLocation.longitude}&key=YOUR_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return data['routes'][0]['overview_polyline']['points'];
        }
      }
    } catch (e) {
      print('Error fetching polyline: $e');
    }
    return '';
  }

  Future<String> buildStaticMapUrl() async {
    final polyline = await fetchEncodedPolyline();

    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=600x300'
        '&path=color:blue|weight:5|enc:$polyline'
        '&markers=color:blue%7C${route.startLocation.latitude},${route.startLocation.longitude}'
        '&markers=color:red%7C${route.endLocation.latitude},${route.endLocation.longitude}'
        '&key=AIzaSyCk9B0oOilVXflt7ZyI2iOAW-dgWsdG0rY';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static Map
            Column(
              children: [
                SizedBox(height: 40,),
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
                FutureBuilder<String>(
                  future: buildStaticMapUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Text('Mapa není k dispozici')),
                      );
                    }
                    final mapUrl = snapshot.data!;
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(mapUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              route.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(route.description, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kategorie: ${route.category}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Délka: ${route.length.toStringAsFixed(1)} km",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      Icons.star,
                      color: index < route.rating.round()
                          ? Colors.orange
                          : Colors.grey,
                    ),
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
