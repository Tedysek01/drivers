import 'package:drivers/screens/create_event.dart';
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
      statusBarIconBrightness: Brightness.light, // Ikony a text status baru budou tmavé
    ),
  );
  
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< Updated upstream
            const SizedBox(height: 50),
=======
            SizedBox(height: 50,),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Akce v okoli',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: colorScheme.onPrimary),
                      ),
                      Text(
                        'Zobrazit vse...',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colorScheme.onPrimary),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, left: 10, right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Liberecka srazova sraz u globusu',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          color:colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          )),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined, size: 20,),
                                      SizedBox(width: 5,),
                                      Text('Globus Liberec, Liberec',style: TextStyle(
                                        color: colorScheme.onPrimary,

                                      ),)
                                    ],
                                  ),
                                  SizedBox(height: 2,),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range, size: 20,),
                                      SizedBox(width: 5,),
                                      Text('13.3.2025 18:30',style: TextStyle(
                                        color: colorScheme.onPrimary,)),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 215, 147, 247),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.drive_eta_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(122, 28, 172,1),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, left: 10, right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drifty Jablonec',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color:Color.fromRGBO(235, 211, 248,1),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined),
                                      Text('Jablonec nad Nisou')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range),
                                      Text('13.4.2025 20:00')
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 174, 213, 245),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.cloudy_snowing,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                     
                     SizedBox(height: 10,),
                     ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add),
                          label: Text('Vytvorit akci'),
                          style: ElevatedButton.styleFrom(
                            
                            foregroundColor:Color.fromRGBO(235, 211, 248,1),
                            backgroundColor: Colors.blue,
                            iconColor: Colors.white,
                            iconSize: 20,
                            textStyle: TextStyle(fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Set the radius here
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/servis.png'), opacity: 0.7, ),
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Servis',style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/fotogtaf.png'), opacity: 0.7),
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Fotografování',style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/detailing.png'), opacity: 0.7),
                  color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Detailing', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment(-1, 1),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/okresky.png'),fit: BoxFit.cover, opacity: 0.7),
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: 115,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Okresky', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
              ),
            ),
            
            SizedBox(height: 10,),
>>>>>>> Stashed changes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Akce v okolí',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return  Center(child: Text('Žádné akce k dispozici.', style: TextStyle(color: colorScheme.onPrimary),));
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
                    height: 200,
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
                      builder: (context) => const CreateEventPage(),
                    ),
                  );
                },
                icon:  Icon(Icons.add,color: colorScheme.onPrimary,),
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
                  _buildServiceCard('Benzín a nafta', 'assets/benzinky.png', () {}),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 5),
                Text(location),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16),
                const SizedBox(width: 5),
                Text(date),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 5),
                Text(type),
              ],
            ),
          ],
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
            opacity: 0.3,
          ),
          color: Colors.purple,
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
