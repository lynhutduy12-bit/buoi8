// lib/services/file_services.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class FileService {
  // Lấy đường dẫn thư mục Documents của ứng dụng
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  // Tạo đối tượng File trỏ tới todo.txt
  Future<File> get _file async {
    final path = await _path;
    return File('$path/todo.txt');
  }

  // Ghi toàn bộ danh sách Todo vào file (mỗi Todo 1 dòng)
  Future<void> saveTodos(List<Todo> todos) async {
    final file = await _file;
    final String data = todos.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  // Đọc dữ liệu từ file và trả về danh sách Todo
  Future<List<Todo>> loadTodos() async {
    try {
      final file = await _file;
      // SỬA: lần chạy đầu file chưa tồn tại -> trả về rỗng, không ném lỗi
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<Todo> result = [];
      for (final line in content.split("\n")) {
        if (line.trim().isEmpty) continue;
        // SỬA: bỏ qua dòng hỏng thay vì làm mất toàn bộ danh sách
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
