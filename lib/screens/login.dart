import 'package:drivers/screens/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:drivers/screens/home.dart';
import 'package:drivers/screens/register.dart';
import 'package:drivers/style/barvy.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _loginUser() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Výpis dat po přihlášení
      print("✅ Přihlášený uživatel: ${userCredential.user?.email}");
      print("✅ User ID: ${userCredential.user?.uid}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Chyba při přihlášení';
      if (e.code == 'user-not-found') {
        errorMessage = 'Uživatel s tímto e-mailem nebyl nalezen.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Nesprávné heslo.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Příliš mnoho pokusů. Zkuste to později.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("❌ Neočekávaná chyba: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Neočekávaná chyba: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zadejte svůj e-mail pro reset hesla.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Odkaz na reset hesla byl odeslán na váš e-mail.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true, // ✅ Zajistí, že se obrazovka přizpůsobí klávesnici
      body: SingleChildScrollView( // ✅ Přidá možnost skrolování, když je klávesnice otevřená
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Header Image Section
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/welcome.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Content Section (Fills the remaining screen space)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Vítejte!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: colorScheme.onPrimary),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
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
                          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Zadejte platný e-mail';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: colorScheme.onPrimary),
                        decoration: InputDecoration(
                          hintText: 'Heslo',
                          hintStyle: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                          filled: true,
                          fillColor: colorScheme.secondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Zadejte heslo';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _resetPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Text(
                            'Zapomenuté heslo?',
                            style: TextStyle(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _isLoading ? null : _loginUser,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Přihlásit se',
                                  style: TextStyle(
                                      fontSize: 18, color: colorScheme.onPrimary),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Registration Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ještě nemáte účet?',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Zaregistrovat se',
                              style: TextStyle(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
