// lib/models/todo.dart
class Todo {
  String title;
  DateTime time;

  // khởi tạo
  Todo({required this.title, required this.time});

  // convert -> string (mỗi Todo là 1 dòng: "tieu de|2026-10-11T17:00:00.000")
  // SỬA: thay ký tự '|' và xuống dòng trong tiêu đề, nếu không khi đọc lại
  // split("|") / split("\n") sẽ bị tách sai và app bị lỗi.
  String toFileString() {
    final safeTitle = title.replaceAll('|', '/').replaceAll('\n', ' ');
    return "$safeTitle|${time.toIso8601String()}";
  }

  // parse <- string
  static Todo fromString(String line) {
    // SỬA: lấy dấu '|' CUỐI CÙNG để tách thời gian, an toàn hơn split
    final index = line.lastIndexOf('|');
    return Todo(
      title: line.substring(0, index),
      time: DateTime.parse(line.substring(index + 1).trim()),
    );
  }
}
