import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_key_service.dart';

class BgRemovalService {
  static Future<Uint8List?> removeBackground(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );

    final apiKey = await ApiKeyService.getApiKey();

    if (apiKey == null) return null;

    request.headers['X-Api-Key'] = apiKey;

    request.files.add(
      await http.MultipartFile.fromPath('image_file', imageFile.path),
    );

    request.fields['size'] = 'auto';

    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      print("Error: ${response.statusCode}");
      return null;
    }
  }
}