import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/clothing_item.dart';
import '../../data/models/category.dart';
import '../../data/repositories/clothing_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../services/image_storage_service.dart';
import '../../services/bg_removal_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  File? _selectedImage;

  String _name = '';
  String _color = '';

  String? _selectedCategoryId;

  List<Category> _categories = [];

  final _picker = ImagePicker();
  final _repository = ClothingRepository();
  final _categoryRepo = CategoryRepository();
  final _storageService = ImageStorageService();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ===============================
  // LOAD CATEGORIES
  // ===============================

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();

    setState(() {
      _categories = categories;

      if (categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      }
    });
  }

  // ===============================
  // PICK IMAGE + REMOVE BG
  // ===============================

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => _isProcessing = true);

    final originalFile = File(picked.path);

    try {
      // 🔥 Remove background
      final Uint8List? processedBytes =
          await BgRemovalService.removeBackground(originalFile);

      if (processedBytes == null) {
        throw Exception("Background removal failed");
      }

      // 🔥 Convert to file
      final dir = await getApplicationDocumentsDirectory();
      final processedFile = File(
        '${dir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await processedFile.writeAsBytes(processedBytes);

      // 🔥 Update UI
      setState(() {
        _selectedImage = processedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isProcessing = false);
  }

  // ===============================
  // SAVE ITEM
  // ===============================

  Future<void> _saveItem() async {
    if (_selectedImage == null ||
        _color.isEmpty ||
        _name.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final selectedCategory = _categories
        .firstWhere((c) => c.id == _selectedCategoryId);

    final savedPath = await _storageService.saveImage(
      _selectedImage!,
      selectedCategory.name,
    );

    final item = ClothingItem(
      id: const Uuid().v4(),
      name: _name,
      categoryId: _selectedCategoryId!,
      color: _color,
      imagePath: savedPath,
      tags: '',
      createdAt: DateTime.now().toIso8601String(),
    );

    await _repository.insertClothing(item);

    Navigator.pop(context);
  }

  // ===============================
  // UI
  // ===============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Add Clothing Item"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // IMAGE PICKER
            // ===============================

            Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Text("Tap to select image"),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ===============================
            // NAME
            // ===============================

            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _name = value;
              },
            ),

            const SizedBox(height: 20),

            // ===============================
            // CATEGORY
            // ===============================

            const Text(
              "Category",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // ===============================
            // COLOR
            // ===============================

            TextField(
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _color = value;
              },
            ),

            const SizedBox(height: 30),

            // ===============================
            // SAVE BUTTON
            // ===============================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveItem,
                child: const Text("Save Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}