import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/clothing_item.dart';
import '../../data/repositories/clothing_repository.dart';
import '../../services/image_storage_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  File? _selectedImage;
  String _category = 'shirts';
  String _name = '';
  String _color = '';

  final _picker = ImagePicker();
  final _repository = ClothingRepository();
  final _storageService = ImageStorageService();

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (_selectedImage == null ||
        _color.isEmpty ||
        _name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final savedPath =
        await _storageService.saveImage(_selectedImage!, _category);

    final item = ClothingItem(
      id: const Uuid().v4(),
      name: _name,
      category: _category,
      color: _color,
      imagePath: savedPath,
      tags: '',
      createdAt: DateTime.now().toIso8601String(),
    );

    await _repository.insertClothing(item);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Add Clothing Item"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            const SizedBox(height: 24),

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

            const Text(
              "Category",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'shirts',
                    child: Text('Shirts')),
                DropdownMenuItem(
                    value: 'pants',
                    child: Text('Pants')),
                DropdownMenuItem(
                    value: 'shoes',
                    child: Text('Shoes')),
                DropdownMenuItem(
                    value: 'jackets',
                    child: Text('Jackets')),
                DropdownMenuItem(
                    value: 'caps',
                    child: Text('Caps / Hats')),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),

            const SizedBox(height: 20),

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