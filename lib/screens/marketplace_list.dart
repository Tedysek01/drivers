import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/screens/marketplace_detail.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = "";
  String? selectedFuel;
  String? selectedBrand;
  int? minPrice, maxPrice, minYear, maxYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Marketplace"),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Vyhledávací pole
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Hledat značku nebo model...",
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 📋 Seznam inzerátů
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('marketplace').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Žádné inzeráty", style: TextStyle(fontSize: 18, color: colorScheme.onSurface)));
                }

                var listings = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((data) => _filterListings(data))
                    .toList();

                return ListView.builder(
  padding: EdgeInsets.all(10),
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    return _buildListingCard(context, snapshot.data!.docs[index]);
  },
);

                
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Filtrujeme inzeráty podle vybraných parametrů
  bool _filterListings(Map<String, dynamic> data) {
    if (searchQuery.isNotEmpty) {
      String fullTitle = "${data['brand']} ${data['model']}".toLowerCase();
      if (!fullTitle.contains(searchQuery)) return false;
    }
    if (selectedBrand != null && data['brand'] != selectedBrand) return false;
    if (selectedFuel != null && data['fuelType'] != selectedFuel) return false;
    if (minPrice != null && int.parse(data['price']) < minPrice!) return false;
    if (maxPrice != null && int.parse(data['price']) > maxPrice!) return false;
    if (minYear != null && int.parse(data['year']) < minYear!) return false;
    if (maxYear != null && int.parse(data['year']) > maxYear!) return false;
    return true;
  }

  // 🎛 Zobrazíme popup pro výběr filtrů
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filtry", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown("Palivo", selectedFuel, ["Benzín", "Diesel", "Elektro"], (val) => setState(() => selectedFuel = val)),
              _buildDropdown("Značka", selectedBrand, ["Škoda", "BMW", "Audi"], (val) => setState(() => selectedBrand = val)),
              _buildNumberField("Min. cena (Kč)", (val) => setState(() => minPrice = val)),
              _buildNumberField("Max. cena (Kč)", (val) => setState(() => maxPrice = val)),
              _buildNumberField("Min. rok", (val) => setState(() => minYear = val)),
              _buildNumberField("Max. rok", (val) => setState(() => maxYear = val)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Zrušit")),
            TextButton(onPressed: () => setState(() => Navigator.pop(context)), child: Text("Použít", style: TextStyle(color: colorScheme.primary))),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField(String label, ValueChanged<int?> onChanged) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(val.isNotEmpty ? int.parse(val) : null),
    );
  }
}


  Widget _buildListingCard(BuildContext context, QueryDocumentSnapshot doc) {
  var data = doc.data() as Map<String, dynamic>;
  String docId = doc.id; // 📌 Získáme ID dokumentu

  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: colorScheme.secondary,
    elevation: 3,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(docId: docId),
          ),
        );
      },

        child: Row(
          children: [
            // 🖼 Obrázek auta
            Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                image: data['images'] != null && data['images'].isNotEmpty
                    ? DecorationImage(image: NetworkImage(data['images'][0]), fit: BoxFit.cover)
                    : DecorationImage(image: AssetImage('assets/placeholder_car.png'), fit: BoxFit.cover),
              ),
            ),

            // 📋 Textové info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['brand']} ${data['model']}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${data['year']}, ${data['mileage']} km, ${data['fuelType']}",
                      style: TextStyle(fontSize: 14, color: colorScheme.onSecondary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "${data['price']} Kč",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
