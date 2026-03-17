import 'package:flutter/material.dart';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'presentation/screens/home_screen.dart';
import 'presentation/screens/api_key_screen.dart';
import 'data/database/db_helper.dart';
import 'services/api_key_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 WINDOWS / DESKTOP FIX
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize DB
  await DBHelper.database;

  runApp(const AIClosetApp());
}

class AIClosetApp extends StatelessWidget {
  const AIClosetApp({super.key});

  Future<Widget> _getStartScreen() async {
    final hasKey = await ApiKeyService.hasApiKey();

    if (hasKey) {
      return const HomeScreen();
    } else {
      return const ApiKeyScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Closet',
      theme: ThemeData(
        useMaterial3: true,
      ),

      // 🔥 Dynamic Start Screen
      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          // Loading screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Error fallback
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Something went wrong")),
            );
          }

          // Final screen
          return snapshot.data!;
        },
      ),

      // Optional routes
      routes: {
        '/home': (context) => const HomeScreen(),
        '/api-key': (context) => const ApiKeyScreen(),
      },
    );
  }
}