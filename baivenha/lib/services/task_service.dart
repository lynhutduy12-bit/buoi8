import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class TaskService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.txt');
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final file = await _file;
    await file.writeAsString(tasks.map((e) => e.toFileString()).join('\n'));
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<Task> result = [];
      for (final line in content.split('\n')) {
        if (line.trim().isEmpty) continue;
        try {
          result.add(Task.fromString(line));
        } catch (_) {}
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<void> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }
}
