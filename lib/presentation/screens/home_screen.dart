import 'package:flutter/material.dart';
import '../../data/models/clothing_item.dart';
import '../../data/repositories/clothing_repository.dart';

import 'add_item_screen.dart';
import 'closet_screen.dart';
import 'generate_screen.dart';
import 'saved_outfits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClothingRepository _repo = ClothingRepository();

  int shirts = 0;
  int pants = 0;
  int shoes = 0;
  int jackets = 0;
  int caps = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final items = await _repo.getAllClothing();

    setState(() {
      shirts = items.where((e) => e.category == "shirts").length;
      pants = items.where((e) => e.category == "pants").length;
      shoes = items.where((e) => e.category == "shoes").length;
      jackets = items.where((e) => e.category == "jackets").length;
      caps = items.where((e) => e.category == "caps").length;
    });
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => _loadStats());
  }

  Widget _statCard(String title, int count, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 5),
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(
              "$count",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigate(context, page),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 5),
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Personal Closet",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
          children: [

            const SizedBox(height: 20),

            /// STATS SECTION
            Row(
              children: [
                _statCard("Shirts", shirts, Icons.checkroom),
                _statCard("Pants", pants, Icons.straighten),
              ],
            ),

            Row(
              children: [
                _statCard("Shoes", shoes, Icons.directions_walk),
                _statCard("Jackets", jackets, Icons.ac_unit),
              ],
            ),

            Row(
              children: [
                _statCard("Caps", caps, Icons.sports_baseball),
              ],
            ),

            const SizedBox(height: 30),

            /// MAIN ACTION
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                "Generate Outfit",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () =>
                  _navigate(context, const GenerateScreen()),
            ),

            const SizedBox(height: 20),

            /// OTHER ACTIONS
            _actionButton(
              "Add Clothing Item",
              Icons.add,
              const AddItemScreen(),
            ),

            _actionButton(
              "View Closet",
              Icons.checkroom_outlined,
              const ClosetScreen(),
            ),

            _actionButton(
              "Saved Outfits",
              Icons.bookmark_border,
              const SavedOutfitsScreen(),
            ),
          ],
        ),
        )      
      ),
    );
  }
}