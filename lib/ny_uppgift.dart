import 'package:flutter/material.dart';

class AddTaskPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lägg till ny uppgift'),
        backgroundColor: const Color.fromARGB(255, 246, 255, 0),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 241, 200), // Bakgrundsfärg
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Uppgiftsbeskrivning',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      Navigator.pop(context, _controller.text);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
