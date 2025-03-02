import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = '';
  String _email = '';
  String _profilePhoto = '';
  String _uid = '';
  bool _isUserLoaded = false;

  String get username => _username;
  String get email => _email;
  String get profilePhoto => _profilePhoto;
  String get uid => _uid;
  bool get isUserLoaded => _isUserLoaded;

  /// ✅ Načtení uživatele (pouze pokud není načten)
  Future<void> loadUserData() async {
    if (_isUserLoaded) {
      print("✅ Uživatelská data jsou již načtena, nebudeme znovu načítat.");
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("🚨 Uživatel není přihlášen, resetuji data.");
      _resetUserData();
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      _username = userDoc.data()?['username'] ?? 'Neznámý uživatel';
      _email = userDoc.data()?['email'] ?? '';
      _profilePhoto = userDoc.data()?['profilePhoto'] ?? '';
      _uid = user.uid;
      _isUserLoaded = true;

      Future.delayed(Duration.zero, () {
      notifyListeners();
    });

    }
  }

  /// ✅ Reset dat po odhlášení
  void _resetUserData() {
    _username = '';
    _email = '';
    _profilePhoto = '';
    _uid = '';
    _isUserLoaded = false;
    notifyListeners();
  }

  /// ✅ Odhlášení uživatele
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _resetUserData();
  }
}
