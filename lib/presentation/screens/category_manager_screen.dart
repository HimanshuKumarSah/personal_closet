import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() =>
      _CategoryManagerScreenState();
}

class _CategoryManagerScreenState
    extends State<CategoryManagerScreen> {

  final CategoryRepository _repo = CategoryRepository();

  List<Category> _categories = [];

  final TextEditingController _controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ================= LOAD =================

  Future<void> _loadCategories() async {

    final categories = await _repo.getAllCategories();

    setState(() {
      _categories = categories;
    });
  }

  // ================= ADD =================

  Future<void> _addCategory() async {

    final name = _controller.text.trim();

    if (name.isEmpty) return;

    await _repo.insertCategory(name);

    _controller.clear();

    _loadCategories();
  }

  // ================= DELETE =================

  Future<void> _deleteCategory(String id) async {

    await _repo.deleteCategory(id);

    _loadCategories();
  }

  // ================= TOGGLE ENABLED =================

  Future<void> _toggleEnabled(Category category) async {

    await _repo.toggleEnabled(category);

    _loadCategories();
  }

  // ================= TOGGLE REQUIRED =================

  Future<void> _toggleRequired(Category category) async {

    await _repo.toggleRequired(category);

    _loadCategories();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Category Manager"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ================= ADD CATEGORY =================

          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,

                    decoration: const InputDecoration(
                      hintText: "New Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text("Add"),
                ),

              ],
            ),
          ),

          const Divider(),

          // ================= CATEGORY LIST =================

          Expanded(
            child: ListView.builder(

              itemCount: _categories.length,

              itemBuilder: (context, index) {

                final category = _categories[index];

                return Card(

                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [

                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),

                              onPressed: () =>
                                  _deleteCategory(category.id),
                            ),

                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [

                            const Text("Required"),

                            Switch(
                              value: category.required,

                              onChanged: (_) =>
                                  _toggleRequired(category),
                            ),

                            const SizedBox(width: 20),

                            const Text("Enabled"),

                            Switch(
                              value: category.enabled,

                              onChanged: (_) =>
                                  _toggleEnabled(category),
                            ),

                          ],
                        ),

                      ],
                    ),
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