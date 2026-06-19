import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

import 'naqash/welcome_screen.dart';
import 'naqash/auth_screen.dart';

import 'zahin/admin_dashboard.dart';
import 'zahin/court_management.dart';

import 'yasmin/home_screen.dart';

import 'sharifah/mybooking_screen.dart';
import 'sharifah/user_dashboard.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlotIn',
      debugShowCheckedModeBanner: false,

      // ---- THEME ----
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6B3C), // SlotIn green
        ),
        useMaterial3: true,
      ),

      // ---- FIRST SCREEN ----
      initialRoute: '/',

      // ---- ALL ROUTES ----
      routes: {
        // Naqash - Auth
        '/': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthScreen(),

        // Zahin - Admin
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/manage-courts': (context) => const ManageCourtsScreen(),

        // Yasmin - Booking
        '/home': (context) => const HomeScreen(),

        // Sharifah - User
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
      },
    );
  }
}
