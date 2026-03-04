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
import '../../data/repositories/outfit_repository.dart';

enum LayoutStyle { symmetrical, editorial }

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final OutfitGeneratorService _generator =
      OutfitGeneratorService();
  final OutfitRepository _outfitRepo = OutfitRepository();
  final GlobalKey _repaintKey = GlobalKey();

  ClothingItem? _shirt;
  ClothingItem? _pant;
  ClothingItem? _shoe;
  ClothingItem? _jacket;
  ClothingItem? _cap;

  LayoutStyle _selectedLayout = LayoutStyle.editorial;

  // ================= GENERATE =================
  Future<void> _generate() async {
    final result = await _generator.generateOutfit();

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Add at least Shirt, Pants and Shoes"),
        ),
      );
      return;
    }

    setState(() {
      _shirt = result['shirt'];
      _pant = result['pant'];
      _shoe = result['shoe'];
      _jacket = result['jacket'];
      _cap = result['cap'];
    });
  }

  // ================= SAVE =================
  Future<void> _saveOutfit() async {
    if (_shirt == null ||
        _pant == null ||
        _shoe == null) return;

    final outfit = Outfit(
      id: const Uuid().v4(),
      shirtId: _shirt!.id,
      pantId: _pant!.id,
      shoesId: _shoe!.id,
      jacketId: _jacket?.id,
      capId: _cap?.id,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _outfitRepo.insertOutfit(outfit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Outfit Saved")),
    );
  }

  // ================= SHARE =================
  Future<void> _shareOutfitImage() async {
    final boundary =
        _repaintKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final image =
        await boundary.toImage(pixelRatio: 3);

    final byteData =
        await image.toByteData(
            format: ui.ImageByteFormat.png);

    final pngBytes =
        byteData!.buffer.asUint8List();

    final directory =
        await getApplicationDocumentsDirectory();

    final filePath =
        '${directory.path}/outfit_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(filePath)]);
  }

  // ================= REMOVE =================
  void _removeItem(ClothingItem item) {
    setState(() {
      if (_shirt?.id == item.id) _shirt = null;
      if (_pant?.id == item.id) _pant = null;
      if (_shoe?.id == item.id) _shoe = null;
      if (_jacket?.id == item.id) _jacket = null;
      if (_cap?.id == item.id) _cap = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool complete =
        _shirt != null &&
            _pant != null &&
            _shoe != null;

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

            if (_shirt != null)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  _layoutButton(
                      "Symmetrical",
                      LayoutStyle.symmetrical),
                  const SizedBox(width: 12),
                  _layoutButton(
                      "Editorial",
                      LayoutStyle.editorial),
                ],
              ),

            const SizedBox(height: 20),

            if (_shirt != null)
              RepaintBoundary(
                key: _repaintKey,
                child: _buildLayout(),
              ),

            const SizedBox(height: 24),

            if (complete) ...[
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
            ],
          ],
        ),
      ),
    );
  }

  // ================= LAYOUT =================
  Widget _buildLayout() {
    return _selectedLayout ==
            LayoutStyle.symmetrical
        ? _buildSymmetricalLayout()
        : _buildEditorialLayout();
  }

  // -------- Symmetrical (simple stack)
  Widget _buildSymmetricalLayout() {
    return Container(
      width:
          MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (_cap != null)
            _collageItem(_cap!, 80),
          if (_jacket != null)
            _collageItem(_jacket!, 120),
          if (_shirt != null)
            _collageItem(_shirt!, 120),
          if (_pant != null)
            _collageItem(_pant!, 160),
          if (_shoe != null)
            _collageItem(_shoe!, 100),
        ],
      ),
    );
  }

  // -------- Clean Editorial Layout
  Widget _buildEditorialLayout() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ---------------- TOP ROW ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Cap (left column)
              if (_cap != null)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.file(
                      File(_cap!.imagePath),
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // Shirt + Jacket (right column)
              Expanded(
                flex: 2,
                child: Column(
                  children: [

                    if (_shirt != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.file(
                          File(_shirt!.imagePath),
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),

                    if (_jacket != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.file(
                          File(_jacket!.imagePath),
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ---------------- PANTS ----------------
          if (_pant != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Image.file(
                File(_pant!.imagePath),
                height: 180,
                fit: BoxFit.contain,
              ),
            ),

          const SizedBox(height: 20),

          // ---------------- SHOES ----------------
          if (_shoe != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.file(
                File(_shoe!.imagePath),
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _layoutButton(
      String label,
      LayoutStyle style) {
    final selected =
        _selectedLayout == style;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected
            ? Colors.black
            : Colors.grey[300],
        foregroundColor: selected
            ? Colors.white
            : Colors.black,
      ),
      onPressed: () =>
          setState(() =>
              _selectedLayout = style),
      child: Text(label),
    );
  }

  // ================= ITEM =================
  Widget _collageItem(
      ClothingItem item, double size) {
    return Image.file(
      File(item.imagePath),
      height: size,
      fit: BoxFit.contain,
    );
  }
}