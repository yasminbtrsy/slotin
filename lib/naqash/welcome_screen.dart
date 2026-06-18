// ============================================================
// lib/naqash/welcome_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'auth_screen.dart';

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

              // APP LOGO
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

              // TODO: change 'SmartQ' to 'SlotIn'
              const Text(
                'SmartQ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A6B3C),
                ),
              ),

              const SizedBox(height: 5),

              // TODO: change tagline to SlotIn's tagline
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

              // GET STARTED BUTTON
              // TODO: change button color from navy (0xFF1A3A6B) to SlotIn green (0xFF1A6B3C)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A6B), // wrong color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
