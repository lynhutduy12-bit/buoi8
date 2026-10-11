import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final NotificationService notificationService = NotificationService();
  List<PendingNotificationRequest> reminders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await notificationService.pendingReminders();
    if (!mounted) return;
    setState(() {
      reminders = data;
      loading = false;
    });
  }

  Future<void> cancelReminder(int id) async {
    await notificationService.cancel(id);
    await loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã huỷ lịch nhắc")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch nhắc")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? const Center(child: Text("Không có lịch nhắc nào"))
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (context, i) {
                      final r = reminders[i];
                      return ListTile(
                        leading: const Icon(Icons.alarm),
                        title: Text(r.title ?? ""),
                        subtitle: Text(r.body ?? ""),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => cancelReminder(r.id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
