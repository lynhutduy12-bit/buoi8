import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class FileService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/todo.txt');
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final file = await _file;
    final String data = todos.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  Future<List<Todo>> loadTodos() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<Todo> result = [];
      for (final line in content.split("\n")) {
        if (line.trim().isEmpty) continue;
        try {
          result.add(Todo.fromString(line));
        } catch (_) {}
      }
      return result;
    } catch (e) {
      return [];
    }
  }
}
