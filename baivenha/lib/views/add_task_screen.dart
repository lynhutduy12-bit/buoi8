import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TaskService taskService = TaskService();
  final NotificationService notificationService = NotificationService();
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      selectedTime = time;
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      timeController.text = '$h:$m';
    });
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhiệm vụ và giờ nhắc')),
      );
      return;
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647,
      title: title,
      remindTime: selectedTime!,
    );

    await taskService.addTask(task);
    await notificationService.scheduleDaily(
      id: task.id,
      title: task.title,
      time: task.remindTime,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhiệm vụ mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên nhiệm vụ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: pickTime,
              decoration: const InputDecoration(
                labelText: 'Giờ nhắc',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveTask,
              child: const Text('Lưu nhiệm vụ'),
            ),
          ],
        ),
      ),
    );
  }
}
