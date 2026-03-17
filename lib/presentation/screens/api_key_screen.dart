import 'package:flutter/material.dart';
import '../../services/api_key_service.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _saveKey() async {
    final key = _controller.text.trim();

    if (key.isEmpty) return;

    await ApiKeyService.saveApiKey(key);

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter API Key")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Enter your remove.bg API Key",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "API Key",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveKey,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}