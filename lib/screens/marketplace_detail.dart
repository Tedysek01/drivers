import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:drivers/style/barvy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListingDetailScreen extends StatefulWidget {
  final String docId;

  const ListingDetailScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _ListingDetailScreenState createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentImageIndex = 0; // Index aktuální fotky
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Detail inzerátu"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('marketplace').doc(widget.docId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return Center(child: Text("Inzerát neexistuje."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          return _buildDetailContent(data);
        },
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> data) {
    List<dynamic> images = data['images'] ?? [];
    Map<String, dynamic>? equipment =
        data['equipment'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fotky
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 250,
                child: PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index; // Aktualizace indexu
                    });
                  },
                  itemBuilder: (context, index) {
                    String imageUrl = images[index];
                    return Image.network(imageUrl, fit: BoxFit.cover);
                  },
                ),
              ),

              // Číslování (např. 1/5, 2/5)

              // Tečkový indikátor
              Positioned(
                bottom: 10,
                child: Row(
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                right: 30, // Umístění nad tečkovým indikátorem
                top: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),),
                    child: Text(
                      "${_currentImageIndex + 1}/${images.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Značka + Model
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${data['brand']} ${data['model']}",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary),
                    ),
                    IconButton(
  icon: Icon(Icons.share, color: colorScheme.primary),
  onPressed: () async {
    final Uri shareUri = Uri.parse('https://vase-aplikace.cz/inzerat/${widget.docId}');
    await Share.share('Podívej se na tento inzerát: $shareUri');
  },
),
                  ],
                ),
                SizedBox(height: 5),

                // Cena
                Text(
                  "${data['price']} Kč",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary),
                ),
                SizedBox(height: 12),

                // Základní informace
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTwoColumnRow(
                      'Karoserie',
                      data['bodyType'],
                      'assets/car.png',
                      'Objem motoru',
                      '${data['engineCapacity']} cm³',
                      'assets/engine.png',
                    ),
                    SizedBox(height: 10),
                    _buildTwoColumnRow(
                      'Palivo',
                      data['fuelType'],
                      'assets/gas-station.png',
                      'Převodovka',
                      data['transmission'],
                      'assets/gearbox.png',
                    ),
                    SizedBox(height: 10),
                    _buildTwoColumnRow(
                      'Výkon',
                      '${data['power']} kW',
                      'assets/power.png',
                      'Najezd',
                      '${data['mileage']} km',
                      'assets/races.png',
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Další parametry
                Text(
                  "Informace o vozu",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary),
                ),
                SizedBox(height: 8),
  
                _buildParamRow('Stav', data['condition']),
                _buildParamRow('Najeto', '${data['mileage']} km'),
                _buildParamRow('Vyrobeno', data['year']),
                _buildParamRow('VIN', data['vin'] ?? 'Neuvedeno'),

                SizedBox(height: 16),

                // Specifikace vozidla
                Text(
                  "Specifikace vozu",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary),
                ),
                SizedBox(height: 8),

                _buildParamRow('Karosérie', data['bodyType']),
                _buildParamRow('Barva', data['color']),
                _buildParamRow('Úpravy ZTP', data['ztpModifications'] ?? 'Ne'),
                _buildParamRow('Tuning', data['tuning'] ?? 'Ne'),

                SizedBox(height: 16),

                Text(
                  "Pohon",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary),
                ),
                SizedBox(height: 8),

                _buildParamRow('Palivo', data['fuelType']),
                _buildParamRow(
                  'Objem',
                  '${data['engineCapacity']} cm³',
                ),
                _buildParamRow('Výkon', '${data['power']} kW'),
                _buildParamRow('Převodovka', data['transmission']),
                _buildParamRow('Pohon', data['drivetrain']),

                // Výbava
                if (equipment != null && equipment.isNotEmpty) ...[
                  Text(
                    "Výbava",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                  ),
                  SizedBox(height: 8),
                  ...equipment.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary),
                        ),
                        ...entry.value.map((item) {
                          return Text(
                            "- $item",
                            style: TextStyle(color: colorScheme.onPrimary),
                          );
                        }).toList(),
                        SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ],

                SizedBox(height: 16),

                // Popis
                if (data['description'] != null &&
                    data['description'].toString().isNotEmpty) ...[
                  Text(
                    "Popis",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                  ),
                  SizedBox(height: 4),
                  Text(data['description'],
                      style: TextStyle(color: colorScheme.onPrimary)),
                ],

                SizedBox(height: 16),

                // Tlačítka pro kontaktování
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _callSeller(data['phone']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Zavolat"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _createChat(data['userId']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Poslat zprávu"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child:
                Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow(String label1, String value1, String icon1,
      String label2, String value2, String icon2) {
    return Row(
      children: [
        Expanded(child: _buildDetailColumn(label1, value1, icon1)),
        Expanded(child: _buildDetailColumn(label2, value2, icon2)),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value, String icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(icon, width: 30, height: 30, color: colorScheme.primary),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
            SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary)),
          ],
        ),
      ],
    );
  }

  void _callSeller(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Telefonní číslo není k dispozici.")),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nelze provést volání.")),
      );
    }
  }

  void _createChat(String? sellerId) async {
    if (sellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nelze vytvořit chat - prodejce není k dispozici.")),
      );
      return;
    }

    try {
      // Vytvoření nebo získání existujícího chatu
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pro poslání zprávy se musíte přihlásit.")),
        );
        return;
      }

      final chatDoc = await _firestore.collection('chats').where(
        'participants', 
        whereIn: [
          [currentUser.uid, sellerId],
          [sellerId, currentUser.uid]
        ]
      ).get();

      String chatId;
      if (chatDoc.docs.isEmpty) {
        // Vytvoření nového chatu
        final newChat = await _firestore.collection('chats').add({
          'participants': [currentUser.uid, sellerId],
          'lastMessage': null,
          'lastMessageTimestamp': null,
          'createdAt': FieldValue.serverTimestamp(),
          'listingId': widget.docId,
        });
        chatId = newChat.id;
      } else {
        chatId = chatDoc.docs.first.id;
      }

      // Přesměrování do chatu
      Navigator.pushNamed(
        context, 
        '/chat',
        arguments: {'chatId': chatId}
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nepodařilo se vytvořit chat. Zkuste to prosím později.")),
      );
    }
  }
}
