import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/models/outfit.dart';
import '../../data/models/clothing_item.dart';
import '../../data/repositories/outfit_repository.dart';
import '../../data/repositories/clothing_repository.dart';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  final OutfitRepository _outfitRepo = OutfitRepository();
  final ClothingRepository _clothingRepo = ClothingRepository();

  List<Map<String, ClothingItem?>> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final savedOutfits = await _outfitRepo.getAllOutfits();

    List<Map<String, ClothingItem?>> loaded = [];

    for (Outfit outfit in savedOutfits) {
      final shirt =
          await _clothingRepo.getClothingById(outfit.shirtId);
      final pant =
          await _clothingRepo.getClothingById(outfit.pantId);
      final shoe =
          await _clothingRepo.getClothingById(outfit.shoesId);

      final jacket = outfit.jacketId != null
          ? await _clothingRepo.getClothingById(outfit.jacketId!)
          : null;

      final cap = outfit.capId != null
          ? await _clothingRepo.getClothingById(outfit.capId!)
          : null;

      if (shirt != null && pant != null && shoe != null) {
        loaded.add({
          'shirt': shirt,
          'pant': pant,
          'shoe': shoe,
          'jacket': jacket,
          'cap': cap,
        });
      }
    }

    setState(() {
      _outfits = loaded;
    });
  }

  Future<void> _deleteOutfit(int index) async {
    final savedOutfits = await _outfitRepo.getAllOutfits();
    await _outfitRepo.deleteOutfit(savedOutfits[index].id);
    _loadOutfits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Saved Outfits"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _outfits.isEmpty
          ? const Center(child: Text("No saved outfits yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _outfits.length,
              itemBuilder: (context, index) {
                final outfit = _outfits[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      // Images Row
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          if (outfit['cap'] != null)
                            _smallImage(outfit['cap']!),

                          if (outfit['jacket'] != null)
                            _smallImage(outfit['jacket']!),
                          _smallImage(outfit['shirt']!),
                          _smallImage(outfit['pant']!),
                          _smallImage(outfit['shoe']!),
                        ],
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () => _deleteOutfit(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _smallImage(ClothingItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(item.imagePath),
        height: 80,
        width: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}