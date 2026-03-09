import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/models/clothing_item.dart';
import '../../data/repositories/clothing_repository.dart';
import 'image_viewer_screen.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final ClothingRepository _repository = ClothingRepository();

  List<ClothingItem> _items = [];
  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getAllClothing();

    setState(() {
      _items = items;
    });
  }

  Future<void> _deleteItem(String id) async {
    await _repository.deleteClothing(id);
    _loadItems();
  }

  List<ClothingItem> get filteredItems {
    if (_selectedCategory == "all") {
      return _items;
    }

    return _items
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  Widget _categoryButton(String label, String category) {
    final selected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
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

          /// Category Filter
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              children: [
                _categoryButton("All", "all"),
                _categoryButton("Shirts", "shirts"),
                _categoryButton("Pants", "pants"),
                _categoryButton("Shoes", "shoes"),
                _categoryButton("Jackets", "jackets"),
                _categoryButton("Caps", "caps"),
              ],
            ),
          ),

          /// Closet Grid
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

                            /// Image
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

                            /// Clothing Info
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
                                    "${item.category} • ${item.color}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
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