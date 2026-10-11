import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/notification_service.dart';
import '../services/word_service.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final WordService wordService = WordService();
  final NotificationService notificationService = NotificationService();

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> saveAndRemind() async {
    final word = wordController.text.trim();
    final meaning = meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      showMessage("Vui lòng nhập từ và nghĩa của từ");
      return;
    }

    await wordService.addWord(Word(word: word, meaning: meaning));

    await notificationService.showNow(
      title: "Đã lưu từ mới",
      body: "Đã lưu \"$word\". Hãy ôn tập sau 10 phút nhé!",
    );

    await notificationService.scheduleAfter(
      id: notificationService.newId(),
      title: "Ôn từ vựng mới!",
      body: "$word - $meaning",
      delay: const Duration(minutes: 10),
    );

    wordController.clear();
    meaningController.clear();

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    showMessage("Đã lưu và nhắc học sau 10 phút");
  }

  void openScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu_book, size: 32, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  "Trợ lý học từ vựng",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Trang chính"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Học từ"),
            onTap: () => openScreen(const LearnScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text("Kiểm tra từ"),
            onTap: () => openScreen(const QuizScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Lịch nhắc"),
            onTap: () => openScreen(const ReminderScreen()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ứng dụng học từ vựng")),
      drawer: buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(labelText: "Từ"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: meaningController,
              decoration: const InputDecoration(labelText: "Nghĩa"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveAndRemind,
              child: const Text("Lưu & Nhắc học sau 10 phút"),
            ),
          ],
        ),
      ),
    );
  }
}
