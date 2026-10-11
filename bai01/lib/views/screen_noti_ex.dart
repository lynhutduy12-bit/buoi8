import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  NotificationService get _service => NotificationService();

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen Noti Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _service.showSimpleNotification();
              },
              child: const Text("Gửi thông báo nhắc học Ngoại ngữ"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await _service.scheduleNotificationAfter(
                  const Duration(minutes: 2),
                  'drink_water_channel',
                  'Uống nước',
                  'Nhắc uống nước đúng giờ',
                  id: 1,
                );
                if (context.mounted) {
                  _showSnack(context, 'Đã hẹn nhắc uống nước sau 2 phút');
                }
              },
              child: const Text("Gửi thông báo nhắc uống nước sau 2 phút"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await _service.scheduleNotificationAfter(
                  const Duration(minutes: 10),
                  'learn_language_schedule_channel',
                  'Học Ngoại ngữ',
                  'Đã đến giờ học Ngoại ngữ rồi!',
                  id: 2,
                );
                if (context.mounted) {
                  _showSnack(context, 'Đã hẹn nhắc học Ngoại ngữ sau 10 phút');
                }
              },
              child: const Text(
                "Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
