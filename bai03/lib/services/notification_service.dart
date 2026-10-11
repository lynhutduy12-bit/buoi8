import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // SỬA: code mẫu thiếu import này
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

    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;
    if (!canExact) {
      await androidImpl?.requestExactAlarmsPermission();
    }
  }

  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails androidDetails,
  }) async {
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode:
          canExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showAddedNotification(String title, String timeText) async {
    final details = _createAndroidDetails(
      channelId: 'todo_added_channel',
      channelName: 'Thêm công việc',
      channelDescription: 'Thông báo khi thêm lịch cho công việc',
    );
    await _plugin.show(
      0,
      'Đã thêm lịch công việc',
      '$title - lúc $timeText',
      NotificationDetails(android: details),
    );
  }

  Future<bool> scheduleTodoAt({
    required int id,
    required String title,
    required DateTime time,
  }) async {
    final scheduled = tz.TZDateTime.from(time, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return false;

    final details = _createAndroidDetails(
      channelId: 'todo_reminder_channel',
      channelName: 'Nhắc việc',
      channelDescription: 'Nhắc công việc đúng giờ đã hẹn',
    );
    await _scheduleNotification(
      id: id,
      title: 'Đến giờ làm việc',
      body: title,
      scheduledTime: scheduled,
      androidDetails: details,
    );
    return true;
  }

  Future<void> scheduleNotificationAfter(
    Duration delay,
    String channelId,
    String channelName,
    String channelDescription, {
    int id = 1,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _scheduleNotification(
      id: id,
      title: channelName,
      body: channelDescription,
      scheduledTime: scheduledTime,
      androidDetails: details,
    );
  }
}
