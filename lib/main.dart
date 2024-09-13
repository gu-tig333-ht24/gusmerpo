import 'package:flutter/material.dart';
import 'ny_uppgift.dart'; // Importera den nya sidan

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => Homepagestate();
}

class Homepagestate extends State<Homepage> {
  final List<Map<String, dynamic>> tasks = [];

  void _addTask(String taskText) {
    if (taskText.isNotEmpty) {
      setState(() {
        tasks.add({'text': taskText, 'completed': false});
      });
    }
  }

  void _markAsCompleted(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _navigateToAddTaskPage() async {
    final String? newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskPage()),
    );

    if (newTask != null) {
      _addTask(newTask);
    }
  }

  void _clearTasks() {
    setState(() {
      tasks.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 255, 0),
        title: const Center(
          child: Text(
            'Att göra lista',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: _clearTasks,
          tooltip: 'Rensa lista',
        ),
        // Ta bort knappen till höger
        /*
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddTaskPage,
            tooltip: 'Lägg till uppgift',
          ),
        ],
        */
      ),
      body: Container(
        color: const Color.fromARGB(
            255, 255, 241, 200), // Bakgrundsfärg för hela body
        child: tasks.isEmpty
            ? Center(
                child: Text(
                  'Ingen uppgift att visa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: tasks.length,
                separatorBuilder: (context, index) =>
                    const Divider(), // Divider
                itemBuilder: (context, index) {
                  // Bestäm bakgrundsfärg baserat på om uppgiften är klar eller inte
                  Color tileColor =
                      tasks[index]['completed'] ? Colors.green : Colors.red;

                  return Container(
                    color: tileColor, // Bakgrundsfärg för varje ListTile
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      leading: Checkbox(
                        value: tasks[index]['completed'],
                        onChanged: (bool? value) {
                          _markAsCompleted(index);
                        },
                      ),
                      title: Text(
                        tasks[index]['text'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Ändra textfärg så den syns bra mot bakgrunden
                          decoration: tasks[index]['completed']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTask(index),
                        tooltip: 'Ta bort uppgift',
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskPage,
        child: const Icon(Icons.add),
        tooltip: 'Lägg till uppgift',
      ),
    );
  }
}
