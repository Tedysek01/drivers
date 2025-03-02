import 'dart:io';
import 'dart:typed_data';
import 'package:drivers/screens/loading_screen.dart';
import 'package:drivers/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers/style/barvy.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _profilePhotoPath;
  bool _isLoading = false;
  int _currentPage = 0;

  /// ✅ Posunutí na další krok (kontrola validace)
  void _nextPage() {
    if (_currentPage == 0 && (_formKey.currentState == null || !_formKey.currentState!.validate())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vyplňte všechna pole"), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _currentPage++);
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// ✅ Posunutí na předchozí krok
  void _prevPage() {
    setState(() => _currentPage--);
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// ✅ Výběr fotky z galerie
  Future<void> _selectPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File selectedFile = File(image.path);
      int fileSize = selectedFile.lengthSync();
      double fileSizeMB = fileSize / (1024 * 1024);

      if (fileSizeMB > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profilová fotka nesmí být větší než 5 MB"), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _profilePhotoPath = image.path;
      });
    }
  }

  /// ✅ Nahrání fotky do Firebase Storage
  Future<String?> _uploadProfilePhoto(String uid) async {
    if (_profilePhotoPath == null) return null;
    try {
      File imageFile = File(_profilePhotoPath!);
      final ref = FirebaseStorage.instance.ref().child('users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');

      Uint8List fileBytes = await imageFile.readAsBytes();
      await ref.putData(fileBytes);

      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Chyba při nahrávání obrázku: $e");
      return null;
    }
  }

  /// ✅ Registrace uživatele a uložení do Firestore
  Future<void> _registerUser() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) return;

      String? profilePhotoUrl = await _uploadProfilePhoto(user.uid);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'profilePhoto': profilePhotoUrl ?? "",
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chyba při registraci: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildEmailPasswordStep(),
                    _buildUsernameStep(),
                    _buildProfilePhotoStep(),
                  ],
                ),
              ),
              if (_currentPage > 0)
                TextButton(
                  onPressed: _prevPage,
                  child: const Text("Zpět"),
                ),
              _buildMainButton(),
              const SizedBox(height: 10),
              if (_currentPage == 0)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text("Už máš účet? Přihlásit se"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Hlavní tlačítko pro pokračování / registraci
  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity, // 🔥 Zvětšená šířka tlačítka
      child: ElevatedButton(
        onPressed: _currentPage == 2 ? _registerUser : _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 🔥 Zaoblené tlačítko
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _currentPage == 2 ? "Registrovat" : "Pokračovat",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildEmailPasswordStep() {
    return _buildCard(
      Column(
        children: [
          SizedBox(height: 40,),
          _buildTextField("E-mail", _emailController, TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField("Heslo", _passwordController, TextInputType.visiblePassword, obscureText: true),
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return _buildCard(
      Column(
        children: [
          SizedBox(height: 40,),
          _buildTextField("Uživatelské jméno", _usernameController, TextInputType.text),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoStep() {
    return _buildCard(
      Column(
        children: [
          SizedBox(height: 40,),
          GestureDetector(
            onTap: _selectPhoto,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profilePhotoPath != null ? FileImage(File(_profilePhotoPath!)) : null,
              child: _profilePhotoPath == null ? const Icon(Icons.camera_alt, size: 50) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: colorScheme.onPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: colorScheme.secondary,
      ),
      validator: (value) => value == null || value.isEmpty ? "Toto pole je povinné" : null,
    );
  }
}
