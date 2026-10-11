import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService taskService = TaskService();
  final NotificationService notificationService = NotificationService();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await taskService.loadTasks();
    if (!mounted) return;
    setState(() => tasks = data);
  }

  int get doneCount => tasks.where((t) => t.isDone).length;

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> onCheck(Task task) async {
    if (task.isDone) {
      setState(() => task.doneDate = '');
      await taskService.saveTasks(tasks);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Nhiệm vụ "${task.title}" đã hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => task.doneDate = Task.todayKey());
    await taskService.saveTasks(tasks);
    await notificationService.showCompleted(doneCount);
  }

  Future<void> changeRemindTime(Task task) async {
    final time = await showTimePicker(
      context: context,
      initialTime: task.remindTime,
    );
    if (time == null) return;

    setState(() => task.remindTime = time);
    await taskService.saveTasks(tasks);
    await notificationService.scheduleDaily(
      id: task.id,
      title: task.title,
      time: time,
    );
    if (!mounted) return;
    showMessage('Đã đặt nhắc "${task.title}" lúc ${task.timeText} mỗi ngày');
  }

  Future<void> deleteTask(Task task) async {
    setState(() => tasks.remove(task));
    await taskService.saveTasks(tasks);
    await notificationService.cancel(task.id);
    if (!mounted) return;
    showMessage('Đã xoá "${task.title}"');
  }

  void showToday() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
        content: Text('Đã hoàn thành $doneCount/${tasks.length} nhiệm vụ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> openAddScreen() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (added == true) {
      await loadData();
      if (!mounted) return;
      showMessage('Đã lưu nhiệm vụ');
    }
  }

  Widget buildItem(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => deleteTask(task),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => onCheck(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? Colors.grey : null,
            ),
          ),
          subtitle: Text('Nhắc lúc ${task.timeText}'),
          trailing: IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => changeRemindTime(task),
          ),
          onTap: () => onCheck(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ mỗi ngày'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: showToday,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Chưa có nhiệm vụ nào. Bấm + để thêm.'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: tasks.map(buildItem).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
