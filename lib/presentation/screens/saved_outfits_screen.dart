import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/models/outfit.dart';
import '../../data/models/outfit_item.dart';
import '../../data/models/clothing_item.dart';

import '../../data/repositories/outfit_repository.dart';
import '../../data/repositories/clothing_repository.dart';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() =>
      _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {

  final OutfitRepository _outfitRepo = OutfitRepository();
  final ClothingRepository _clothingRepo = ClothingRepository();

  List<List<ClothingItem>> _outfits = [];
  List<Outfit> _outfitContainers = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  // ================= LOAD OUTFITS =================

  Future<void> _loadOutfits() async {

    final savedOutfits = await _outfitRepo.getAllOutfits();

    List<List<ClothingItem>> loaded = [];

    for (Outfit outfit in savedOutfits) {

      final outfitItems =
          await _outfitRepo.getOutfitItems(outfit.id);

      List<ClothingItem> clothing = [];

      for (OutfitItem item in outfitItems) {

        final clothingItem =
            await _clothingRepo.getClothingById(
                item.clothingId);

        if (clothingItem != null) {
          clothing.add(clothingItem);
        }
      }

      if (clothing.isNotEmpty) {
        loaded.add(clothing);
      }
    }

    setState(() {
      _outfits = loaded;
      _outfitContainers = savedOutfits;
    });
  }

  // ================= DELETE =================

  Future<void> _deleteOutfit(int index) async {

    await _outfitRepo.deleteOutfit(
        _outfitContainers[index].id);

    _loadOutfits();
  }

  // ================= UI =================

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
          ? const Center(
              child: Text("No saved outfits yet"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _outfits.length,

              itemBuilder: (context, index) {

                final outfitItems = _outfits[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color:
                            Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // ================= IMAGES =================

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,

                        children: outfitItems.map((item) {
                          return _smallImage(item);
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      // ================= DELETE BUTTON =================

                      ElevatedButton(
                        onPressed: () =>
                            _deleteOutfit(index),

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

  // ================= IMAGE =================

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