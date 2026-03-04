import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  final _uuid = const Uuid();

  Future<String> saveImage(File imageFile, String category) async {
    final directory = await getApplicationDocumentsDirectory();

    final categoryFolder =
        Directory('${directory.path}/$category');

    if (!await categoryFolder.exists()) {
      await categoryFolder.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.jpg';
    final savedImage =
        await imageFile.copy('${categoryFolder.path}/$fileName');

    return savedImage.path;
  }
}