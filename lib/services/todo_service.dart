import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class TodoService {
  static const String _baseUrl = 'http://jsonplaceholder.typicode.com';

  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/todos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }

  Future<List<Todo>> fetchTodosByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/todos?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
