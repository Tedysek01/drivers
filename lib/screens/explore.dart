import 'package:drivers/screens/event_list.dart';
import 'package:drivers/screens/marketplace_list.dart';
import 'package:flutter/material.dart';
import 'package:drivers/style/barvy.dart'; // Předpokládáme, že zde je definován colorScheme
import 'cenyphm_screen.dart'; // Ukázkově pro Benzínky
import 'routes.dart'; // Ukázkově pro Okresky (FunRoutesScreen)

class Explore extends StatelessWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definice položek Explore screenu s využitím asset ikon
    final List<_ExploreItem> items = [
      _ExploreItem(
        title: 'Marketplace',
        assetIconPath: 'assets/marketplace.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarketplaceScreen(),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Benzínky',
        assetIconPath: 'assets/gas-station.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetrolPricesScreen(),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Srazy',
        assetIconPath: 'assets/drifty.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventListScreen(),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Okresky',
        assetIconPath: 'assets/road.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FunRoutesScreen(),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Servisy',
        assetIconPath: 'assets/servis_ikona.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlaceholderScreen(title: 'Servisy'),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Fotografové a Videomakeři',
        assetIconPath: 'assets/photographer.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PlaceholderScreen(title: 'Fotografové a Videomakeři'),
            ),
          );
        },
      ),
      _ExploreItem(
        title: 'Detaileři',
        assetIconPath: 'assets/detailer.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PlaceholderScreen(title: 'Detaileři'),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objevovat'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar pro vyhledávání uživatelů
            TextField(
              style: TextStyle(color: colorScheme.onPrimary),
              decoration: InputDecoration(
                hintText: 'Hledat uživatele...',
                hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                
                fillColor: colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              
              onSubmitted: (query) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaceholderScreen(
                        title: 'Výsledky hledání: "$query"'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Mřížka s jednotlivými sekcemi
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // dva prvky na řádek
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: item.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Použití assetové ikony s přebarvením
                          Image.asset(
                            item.assetIconPath,
                            width: 48,
                            height: 48,
                            color: colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model pro položku Explore screenu s asset ikonou
class _ExploreItem {
  final String title;
  final String assetIconPath;
  final VoidCallback onTap;

  _ExploreItem({required this.title, required this.assetIconPath, required this.onTap});
}

// Placeholder screen – můžeš jej nahradit konkrétní implementací
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 24, color: colorScheme.onPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
