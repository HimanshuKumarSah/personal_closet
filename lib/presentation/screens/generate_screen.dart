import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/outfit_generator_service.dart';
import '../../data/models/clothing_item.dart';
import '../../data/models/outfit.dart';
import '../../data/models/outfit_item.dart';
import '../../data/models/category.dart';
import '../../data/repositories/outfit_repository.dart';
import '../../data/repositories/category_repository.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {

  final OutfitGeneratorService _generator = OutfitGeneratorService();
  final OutfitRepository _outfitRepo = OutfitRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final GlobalKey _repaintKey = GlobalKey();

  List<ClothingItem> _outfitItems = [];
  Map<String, String> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();

    setState(() {
      _categoryMap = {
        for (var c in categories) c.id: c.name.toLowerCase()
      };
    });
  }

  // ================= GENERATE =================

  Future<void> _generate() async {

    final result = await _generator.generateOutfit();

    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not enough clothing items to generate outfit"),
        ),
      );
      return;
    }

    setState(() {
      _outfitItems = result;
    });
  }

  // ================= SAVE =================

  Future<void> _saveOutfit() async {

    if (_outfitItems.isEmpty) return;

    final outfitId = const Uuid().v4();

    final outfit = Outfit(
      id: outfitId,
      createdAt: DateTime.now().toIso8601String(),
    );

    final outfitItems = _outfitItems.map((item) {
      return OutfitItem(
        id: const Uuid().v4(),
        outfitId: outfitId,
        clothingId: item.id,
        categoryId: item.categoryId,
      );
    }).toList();

    await _outfitRepo.insertOutfit(outfit, outfitItems);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Outfit Saved")),
    );
  }

  // ================= SHARE =================

  Future<void> _shareOutfitImage() async {

    final boundary =
        _repaintKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();

    final filePath =
        '${directory.path}/outfit_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(filePath)]);
  }

  // ================= REMOVE =================

  void _removeItem(ClothingItem item) {
    setState(() {
      _outfitItems.removeWhere((i) => i.id == item.id);
    });
  }

  // ================= LAYOUT =================

  Widget _buildOutfitLayout() {

    ClothingItem? shirt;
    ClothingItem? jacket;
    ClothingItem? pants;
    ClothingItem? shoes;
    ClothingItem? cap;

    for (var item in _outfitItems) {

      final category =
          _categoryMap[item.categoryId] ?? "";

      if (category.contains("shirt")) {
        shirt = item;
      }
      else if (category.contains("jacket") ||
          category.contains("coat") ||
          category.contains("overshirt")) {
        jacket = item;
      }
      else if (category.contains("pant") ||
          category.contains("trouser")) {
        pants = item;
      }
      else if (category.contains("shoe")) {
        shoes = item;
      }
      else if (category.contains("cap") ||
          category.contains("hat")) {
        cap = item;
      }
    }

    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if (cap != null)
            _itemWithRemove(cap, 60),

          if (shirt != null || jacket != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (jacket != null)
                  _itemWithRemove(jacket, 120),
                if (shirt != null)
                  _itemWithRemove(shirt, 120),
              ],
            ),

          if (pants != null)
            _itemWithRemove(pants, 140),

          if (shoes != null)
            _itemWithRemove(shoes, 100),
        ],
      ),
    );
  }

  // ================= ITEM =================

  Widget _itemWithRemove(ClothingItem item, double size) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Stack(
        children: [

          SizedBox(
            height: size,
            child: Image.file(
              File(item.imagePath),
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => _removeItem(item),
              child: const CircleAvatar(
                radius: 6,
                backgroundColor: ui.Color.fromARGB(0, 82, 82, 82),
                child: Icon(
                  Icons.close,
                  size: 7,
                  color: ui.Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Outfit Generator"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generate,
                child: const Text("Generate Outfit"),
              ),
            ),

            const SizedBox(height: 20),

            if (_outfitItems.isNotEmpty && _categoryMap.isNotEmpty)
              RepaintBoundary(
                key: _repaintKey,
                child: _buildOutfitLayout(),
              ),

            const SizedBox(height: 24),

            if (_outfitItems.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveOutfit,
                  child: const Text("Save Outfit"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _shareOutfitImage,
                  child: const Text("Share Outfit"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
