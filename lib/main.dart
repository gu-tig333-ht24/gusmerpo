import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'ny_uppgift.dart';
import 'task.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homepage(),
    );
  }
}

enum FilterOption { all, completed, notCompleted }

class TaskProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Task> _tasks = [];
  FilterOption _filterOption = FilterOption.all;

  List<Task> get tasks => _tasks;

  FilterOption get filterOption => _filterOption;

  void setFilterOption(FilterOption option) {
    _filterOption = option;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    switch (_filterOption) {
      case FilterOption.completed:
        return _tasks.where((task) => task.done).toList();
      case FilterOption.notCompleted:
        return _tasks.where((task) => !task.done).toList();
      case FilterOption.all:
      default:
        return _tasks;
    }
  }

  Future<void> fetchTasks() async {
    try {
      _tasks = await apiService.getTodos();
      notifyListeners();
    } catch (e) {
      throw Exception('Misslyckades att ladda uppgifter: $e');
    }
  }

  Future<void> addTask(String taskText) async {
    try {
      final newTask = Task(title: taskText, done: false);
      await apiService.addTodo(newTask);
      await fetchTasks();
    } catch (e) {
      throw Exception('Misslyckades att lägga till uppgift: $e');
    }
  }

  Future<void> markAsCompleted(int index) async {
    final task = _tasks[index];
    task.done = !task.done;

    try {
      await apiService.updateTodo(task);
      notifyListeners();
    } catch (e) {
      throw Exception('Misslyckades att uppdatera uppgift: $e');
    }
  }

  Future<void> removeTask(int index) async {
    final task = _tasks[index];

    try {
      await apiService.deleteTodo(task.id!);
      await fetchTasks();
    } catch (e) {
      throw Exception('Misslyckades att ta bort uppgift: $e');
    }
  }

  Future<void> clearTasks() async {
    try {
      for (var task in _tasks) {
        await apiService.deleteTodo(task.id!);
      }
      _tasks.clear();
      notifyListeners();
    } catch (e) {
      throw Exception('Misslyckades att rensa uppgifter: $e');
    }
  }
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();

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
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false).clearTasks();
          },
          tooltip: 'Rensa lista',
        ),
        actions: [
          PopupMenuButton<FilterOption>(
            onSelected: (FilterOption option) {
              Provider.of<TaskProvider>(context, listen: false)
                  .setFilterOption(option);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<FilterOption>>[
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.all,
                  child: Text('Visa alla'),
                ),
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.completed,
                  child: Text('Visa klara uppgifter'),
                ),
                const PopupMenuItem<FilterOption>(
                  value: FilterOption.notCompleted,
                  child: Text('Visa icke klara uppgifter'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 241, 200),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final tasks = taskProvider.filteredTasks;
            return tasks.isEmpty
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
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      Color tileColor =
                          tasks[index].done ? Colors.green : Colors.red;

                      return Container(
                        color: tileColor,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          leading: Checkbox(
                            value: tasks[index].done,
                            onChanged: (bool? value) {
                              Provider.of<TaskProvider>(context, listen: false)
                                  .markAsCompleted(index);
                            },
                          ),
                          title: Text(
                            tasks[index].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: tasks[index].done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              Provider.of<TaskProvider>(context, listen: false)
                                  .removeTask(index);
                            },
                            tooltip: 'Ta bort uppgift',
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );

          if (newTask != null) {
            Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Lägg till uppgift',
      ),
    );
  }
}
