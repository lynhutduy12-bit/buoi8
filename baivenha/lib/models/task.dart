import 'package:flutter/material.dart';

class Task {
  int id;
  String title;
  TimeOfDay remindTime;
  String doneDate;

  Task({
    required this.id,
    required this.title,
    required this.remindTime,
    this.doneDate = '',
  });

  static String todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  bool get isDone => doneDate == todayKey();

  String get timeText {
    final h = remindTime.hour.toString().padLeft(2, '0');
    final m = remindTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String toFileString() {
    final safeTitle = title.replaceAll('|', '/').replaceAll('\n', ' ');
    return '$id|$timeText|$doneDate|$safeTitle';
  }

  static Task fromString(String line) {
    final parts = line.split('|');
    final time = parts[1].split(':');
    return Task(
      id: int.parse(parts[0]),
      remindTime: TimeOfDay(
        hour: int.parse(time[0]),
        minute: int.parse(time[1]),
      ),
      doneDate: parts[2],
      title: parts.sublist(3).join('|'),
    );
  }
}
