import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task.dart';

class ApiService {
  static const String baseUrl = 'https://todoapp-api.apps.k8s.gu.se';
  static const String apiKey = '0041ffcc-460e-4fb3-9db0-e7ff970ee09e';

  ApiService();

  Future<List<Task>> getTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos?key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Misslyckades att ladda uppgifter');
    }
  }

  Future<void> addTodo(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Misslyckades att lägga till uppgift');
    }
  }

  Future<void> updateTodo(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/${task.id}?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Misslyckades att uppdatera uppgift');
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id?key=$apiKey'),
    );
    if (response.statusCode != 200) {
      throw Exception('Misslyckades att ta bort uppgift');
    }
  }
}
