class Todo {
  String title;
  DateTime time;

  Todo({required this.title, required this.time});

  String toFileString() {
    final safeTitle = title.replaceAll('|', '/').replaceAll('\n', ' ');
    return "$safeTitle|${time.toIso8601String()}";
  }

  static Todo fromString(String line) {
    final index = line.lastIndexOf('|');
    return Todo(
      title: line.substring(0, index),
      time: DateTime.parse(line.substring(index + 1).trim()),
    );
  }
}
