import 'package:drivers/screens/create_event.dart';
import 'package:drivers/screens/event_details.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Průhledné pozadí
        statusBarIconBrightness:
            Brightness.light, // Ikony a text status baru budou tmavé
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logocarmio.png', width: 120,),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Akce v okolí',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: colorScheme.onPrimary,
                  ),
                ),
                Text(
                  'Zobrazit vše...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    'Žádné akce k dispozici.',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ));
                }

                final events = snapshot.data!.docs;

                return CarouselSlider(
                  items: events.map((event) {
                    return _buildEventCard(
                      title: event['name'] ?? 'Neznámý název',
                      location: event['location'] ?? 'Neznámé místo',
                      date: event['date'] ?? 'Neznámé datum',
                      type: event['type'] ?? 'Neznámý typ',
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 168,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateEventPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: colorScheme.onPrimary,
                ),
                label: const Text('Vytvořit akci'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary,
                  backgroundColor: colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  minimumSize: const Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Služby',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildServiceCard('Servis', 'assets/servis.png', () {}),
                  _buildServiceCard('Fotograf', 'assets/fotogtaf.png', () {}),
                  _buildServiceCard('Detailing', 'assets/detailing.png', () {}),
                  _buildServiceCard('Okresky', 'assets/okresky.png', () {}),
                  _buildServiceCard(
                      'Ceny benzínu', 'assets/benzinky.png', () {}),
                  _buildServiceCard('Marketplace', 'assets/oko.png', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
  required String title,
  required String location,
  required String date,
  required String type,
}) {
  final Map<String, String> typeIcons = {
    'Sraz': 'assets/carmeet.png',
    'Závody': 'assets/race.png',
    'Drifty': 'assets/drifting.png',
    'Okresky': 'assets/road.png',
    'Neznámý typ': 'assets/question.png', // Default icon
  };

  // Select the icon based on type
  String selectedIcon = typeIcons[type] ?? 'assets/question.png';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetails(
            title: title,
            location: location,
            date: date,
            type: type,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 0),
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 16, color: colorScheme.onPrimary),
                      const SizedBox(width: 5),
                      Text(location,
                          style: TextStyle(color: colorScheme.onPrimary)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          size: 16, color: colorScheme.onPrimary),
                      const SizedBox(width: 5),
                      Text(date,
                          style: TextStyle(color: colorScheme.onPrimary)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.category,
                          size: 16, color: colorScheme.onPrimary),
                      const SizedBox(width: 5),
                      Text(type,
                          style: TextStyle(color: colorScheme.onPrimary)),
                    ],
                  ),
                ],
              ),
              // Use the PNG asset icon
              Image.asset(
                selectedIcon,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                color: colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildServiceCard(String title, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
          color: colorScheme.primary,

          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
