import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/models/clothing_item.dart';
import '../../data/models/category.dart';
import '../../data/repositories/clothing_repository.dart';
import '../../data/repositories/category_repository.dart';
import 'image_viewer_screen.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {

  final ClothingRepository _clothingRepo = ClothingRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  List<ClothingItem> _items = [];
  List<Category> _categories = [];

  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ===============================
  // LOAD DATA
  // ===============================

  Future<void> _loadData() async {

    final items = await _clothingRepo.getAllClothing();
    final categories = await _categoryRepo.getAllCategories();

    setState(() {
      _items = items;
      _categories = categories;
    });
  }

  // ===============================
  // DELETE ITEM
  // ===============================

  Future<void> _deleteItem(String id) async {
    await _clothingRepo.deleteClothing(id);
    _loadData();
  }

  // ===============================
  // FILTERED ITEMS
  // ===============================

  List<ClothingItem> get filteredItems {

    if (_selectedCategory == "all") {
      return _items;
    }

    return _items
        .where((item) => item.categoryId == _selectedCategory)
        .toList();
  }

  // ===============================
  // CATEGORY BUTTON
  // ===============================

  Widget _categoryButton(String label, String categoryId) {

    final selected = _selectedCategory == categoryId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryId;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ===============================
  // GET CATEGORY NAME
  // ===============================

  String getCategoryName(String categoryId) {

    final category = _categories
        .where((c) => c.id == categoryId)
        .toList();

    if (category.isEmpty) return "Unknown";

    return category.first.name;
  }

  // ===============================
  // UI
  // ===============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        title: const Text("My Closet"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ===============================
          // CATEGORY FILTER
          // ===============================

          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              children: [

                _categoryButton("All", "all"),

                ..._categories.map((category) {
                  return _categoryButton(
                    category.name,
                    category.id,
                  );
                }).toList(),

              ],
            ),
          ),

          // ===============================
          // CLOSET GRID
          // ===============================

          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "No clothing items yet",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {

                      final item = filteredItems[index];

                      final categoryName =
                          getCategoryName(item.categoryId);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(0.08),
                            )
                          ],
                        ),
                        child: Column(
                          children: [

                            // ===============================
                            // IMAGE
                            // ===============================

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ImageViewerScreen(
                                        imagePath: item.imagePath,
                                        name: item.name,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // ===============================
                            // INFO
                            // ===============================

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                              child: Column(
                                children: [

                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    "$categoryName • ${item.color}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            // ===============================
                            // DELETE BUTTON
                            // ===============================

                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _deleteItem(item.id);
                              },
                            ),

                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}