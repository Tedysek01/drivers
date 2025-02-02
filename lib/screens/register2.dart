import 'dart:io';

import 'package:drivers/screens/home.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterStep3 extends StatefulWidget {
  const RegisterStep3({super.key});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final TextEditingController _usernameController = TextEditingController();
  String? _profilePhotoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Back Navigation
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Handle back navigation
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
                        'Home',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Username Field
            const Text(
              'Uživatelské jméno',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Uživatelské jméno',
                hintStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Profile Photo Upload
            const Text(
              'Profilová fotka',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);

                if (image != null) {
                  setState(() {
                    _profilePhotoPath = image.path; // Save the image path
                  });
                }
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                  image: _profilePhotoPath != null
                      ? DecorationImage(
                          image: FileImage(File(_profilePhotoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profilePhotoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: colorScheme.onPrimary,
                            size: 40,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Klikněte pro nahrání fotky',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Perform validation
                  if (_usernameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zadejte uživatelské jméno'),
                      ),
                    );
                    return;
                  }
                  if (_profilePhotoPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nahrajte profilovou fotku'),
                      ),
                    );
                    return;
                  }

                  // Navigate to Home Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(
                        stations: [],
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Pokračovat',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
