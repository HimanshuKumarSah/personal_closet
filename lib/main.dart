import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'data/database/db_helper.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 THIS FIXES WINDOWS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DBHelper.database;

  runApp(const AIClosetApp());
}

class AIClosetApp extends StatelessWidget {
  const AIClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Closet',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}