import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drivers/screens/register2.dart';
import 'package:drivers/style/barvy.dart';

class RegisterStep2 extends StatefulWidget {
  const RegisterStep2({super.key});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _registerUser() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase registrace
      final UserCredential userCredential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
);


      print('Uživatel vytvořen: ${userCredential.user?.uid}');

      // Přechod na další krok registrace
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterStep3()),
      ).then((_) {
        setState(() {
          _isLoading = false; // Reset stavu při návratu
        });
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Chyba při registraci';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Tento e-mail je již zaregistrován.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Heslo je příliš slabé.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print('Neočekávaná chyba: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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

              // Email Field
              const Text(
                'E-mail',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Zadejte e-mail';
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Zadejte platný e-mail';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Field
              const Text(
                'Heslo',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Heslo',
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Zadejte heslo';
                  }
                  if (value.length < 6) {
                    return 'Heslo musí mít alespoň 6 znaků';
                  }
                  return null;
                },
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
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Pokračovat',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
