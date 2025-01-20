import 'package:drivers/screens/home.dart';
import 'package:drivers/screens/register.dart';
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration:  BoxDecoration(
                color: colorScheme.surface,
              ),
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

                  // Form Fields
                  Form(
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: colorScheme.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Heslo',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: colorScheme.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
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
                              backgroundColor:
                                  colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: (){Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ),
                  );},
                            child:  Text(
                              'Přihlásit se',
                              style:
                                  TextStyle(fontSize: 18, color: colorScheme.onPrimary),
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
                              onPressed: (){Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterStep2(),
                    ),
                  );},
                              child:  Text(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
