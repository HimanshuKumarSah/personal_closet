import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../data/models/clothing_item.dart';

import '../../data/repositories/category_repository.dart';
import '../../data/repositories/clothing_repository.dart';

import 'add_item_screen.dart';
import 'closet_screen.dart';
import 'generate_screen.dart';
import 'saved_outfits_screen.dart';
import 'category_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ClothingRepository _clothingRepo = ClothingRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  Map<String, int> _stats = {};
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // ================= LOAD STATS =================

  Future<void> _loadStats() async {

    final items = await _clothingRepo.getAllClothing();
    final categories = await _categoryRepo.getAllCategories();

    Map<String, int> counts = {};

    for (var category in categories) {
      counts[category.id] =
          items.where((e) => e.categoryId == category.id).length;
    }

    setState(() {
      _categories = categories;
      _stats = counts;
    });
  }

  // ================= NAVIGATION =================

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => _loadStats());
  }

  // ================= STAT CARD =================

  Widget _statCard(String title, int count, IconData icon) {

    return Container(
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
    );
  }

  // ================= ACTION BUTTON =================

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

  // ================= ICON SELECTOR =================

  IconData _getIconForCategory(String name) {

    switch (name.toLowerCase()) {
      case "shirts":
        return Icons.checkroom;
      case "pants":
        return Icons.straighten;
      case "shoes":
        return Icons.directions_walk;
      case "jackets":
        return Icons.ac_unit;
      case "caps":
        return Icons.sports_baseball;
      default:
        return Icons.category;
    }
  }

  // ================= UI =================

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

              // ================= STATS =================

              Wrap(
                children: _categories.map((category) {

                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 26,

                    child: _statCard(
                      category.name,
                      _stats[category.id] ?? 0,
                      _getIconForCategory(category.name),
                    ),
                  );

                }).toList(),
              ),

              const SizedBox(height: 30),

              // ================= GENERATE =================

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

              // ================= OTHER ACTIONS =================

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

              _actionButton(
                "Manage Categories",
                Icons.category,
                const CategoryManagerScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}