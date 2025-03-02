import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/screens/login.dart';
import 'package:drivers/style/barvy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Můj profil'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Profilová fotka + Jméno
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userProvider.profilePhoto.isNotEmpty
                        ? NetworkImage(userProvider.profilePhoto)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProvider.username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('Moje auta'),
            _buildUserCars(userProvider),

            _buildSectionTitle('Moje příspěvky'),
            _buildUserPosts(userProvider),

            const SizedBox(height: 30),

            // 🔹 Tlačítko Odhlásit se
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Odhlásit se", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 🔹 Nadpis sekce
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  /// 🔹 Moje auta
  Widget _buildUserCars(UserProvider userProvider) {
    if (userProvider.uid.isEmpty) return Container();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userProvider.uid).collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Nemáš žádná auta přidána.',
              style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
            ),
          );
        }

        final cars = snapshot.data!.docs;

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index].data() as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car['brand'] ?? 'Neznámá značka',
                        style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                    Text(car['model'] ?? 'Neznámý model',
                        style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7))),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 🔹 Moje příspěvky
  Widget _buildUserPosts(UserProvider userProvider) {
    if (userProvider.uid.isEmpty) return Container();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: userProvider.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Nemáš žádné příspěvky.',
              style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: post['imageUrl'] != null
                    ? DecorationImage(image: NetworkImage(post['imageUrl']), fit: BoxFit.cover)
                    : null,
                color: colorScheme.secondary,
              ),
            );
          },
        );
      },
    );
  }
}
