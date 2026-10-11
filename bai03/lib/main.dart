// lib/main.dart  (Bước 5 - sinh viên tự viết)
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'views/screen_todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // BÀI 3: khởi tạo notification + xin quyền
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ScreenTodo(),
    );
  }
}
