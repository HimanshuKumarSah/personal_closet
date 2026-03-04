import 'dart:io';
import 'package:ai_closet/presentation/screens/add_item_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/clothing_item.dart';
import '../../data/repositories/clothing_repository.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final ClothingRepository _repository = ClothingRepository();

  List<ClothingItem> _items = [];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getAllClothing();
    setState(() => _items = items);
  }

  Future<void> _deleteItem(String id) async {
    await _repository.deleteClothing(id);
    _loadItems();
  }

  List<ClothingItem> get _filteredItems {
    if (_selectedCategory == "All") return _items;

    return _items.where((item) {
      final category = item.category.toLowerCase();
      final selected = _selectedCategory.toLowerCase();
      return category.contains(selected.substring(0, selected.length - 1));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("My Closet"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterButton("All"),
                _filterButton("Shirts"),
                _filterButton("Pants"),
                _filterButton("Shoes"),
                _filterButton("Jackets"),
                _filterButton("Caps"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(item.imagePath),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.all(8),
                            child: Text(
                              item.name,
                              textAlign:
                                  TextAlign.center,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () =>
                              _deleteItem(item.id),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                Colors.red,
                            child: Icon(
                              Icons.delete,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddItemScreen(),
            ),
          );
          _loadItems();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _filterButton(String category) {
    final selected =
        _selectedCategory == category;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? Colors.black : Colors.grey[300],
          foregroundColor:
              selected ? Colors.white : Colors.black,
        ),
        onPressed: () =>
            setState(() => _selectedCategory = category),
        child: Text(category),
      ),
    );
  }
}