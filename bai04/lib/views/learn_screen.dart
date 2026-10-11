import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/notification_service.dart';
import '../services/word_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController answerController = TextEditingController();
  final WordService wordService = WordService();
  final NotificationService notificationService = NotificationService();
  final Random random = Random();

  List<Word> words = [];
  Word? current;
  int correct = 0;
  int wrong = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await wordService.loadWords();
    if (!mounted) return;
    setState(() {
      words = data;
      loading = false;
      nextWord();
    });
  }

  void nextWord() {
    if (words.isEmpty) {
      current = null;
      return;
    }
    if (words.length == 1) {
      current = words.first;
      return;
    }
    Word next;
    do {
      next = words[random.nextInt(words.length)];
    } while (identical(next, current));
    current = next;
  }

  String normalize(String s) => s.trim().toLowerCase();

  Future<void> check() async {
    if (current == null) return;
    final answer = answerController.text;
    if (answer.trim().isEmpty) return;

    final isCorrect = normalize(answer) == normalize(current!.meaning);
    final rightAnswer = current!.meaning;

    setState(() {
      if (isCorrect) {
        correct++;
      } else {
        wrong++;
      }
      answerController.clear();
      nextWord();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          content: Text(
            isCorrect ? "Chính xác!" : "Sai rồi! Đáp án: $rightAnswer",
          ),
        ),
      );

    if (!isCorrect && wrong % 3 == 0) {
      await notificationService.showNow(
        title: "Cần ôn tập thêm!",
        body: "Bạn đã trả lời sai $wrong từ. Hãy ôn lại từ vựng nhé!",
      );
    }
  }

  Widget scoreBox(IconData icon, Color color, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            "$value từ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (current == null) {
      return const Center(
        child: Text("Chưa có từ nào. Hãy thêm từ ở Trang chính."),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              scoreBox(Icons.check, Colors.green, correct),
              const SizedBox(width: 30),
              scoreBox(Icons.close, Colors.orange, wrong),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  current!.word,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: answerController,
                  onSubmitted: (_) => check(),
                  decoration: const InputDecoration(
                    hintText: "Nhập nghĩa tiếng Việt",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: check,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Check"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ôn tập từ mới")),
      body: buildBody(),
    );
  }
}
