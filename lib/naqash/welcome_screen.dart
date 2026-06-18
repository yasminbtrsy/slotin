// ============================================================
// lib/naqash/welcome_screen.dart
// ============================================================

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              //APP NAME
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6B3C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'SmartQ', // change app name
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A6B3C),
                ),
              ),

              const SizedBox(height: 5),

              // ---- TAGLINE ----     change the TAGLINE
              const Text(
                'Tap for the Wash\nDone in a Flash',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(206, 0, 0, 0),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // ---- LOGIN BUTTON ----
              //change button color from navy(smartq color) to green for slotin
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6B), // dark navy
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to Login screen
                    Navigator.pushNamed(context, '/auth');
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---- SIGN UP LINK ----
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/auth');
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'New here? ',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---- ADMIN LOGIN LINK ----   change to admin in Auth Screen
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/auth'),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'admin ',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color(0xFFE74C3C),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
