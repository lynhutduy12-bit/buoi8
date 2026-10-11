import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    await _requestPermission();
    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await androidImpl?.requestExactAlarmsPermission();
    }
  }

  static NotificationDetails _details(String channelId, String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
    );
  }

  int newId() => DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647;

  Future<void> showNow({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      _details('vocab_info_channel', 'Thông báo học từ'),
    );
  }

  Future<void> scheduleAfter({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      _details('vocab_reminder_channel', 'Nhắc ôn từ vựng'),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<List<PendingNotificationRequest>> pendingReminders() {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
