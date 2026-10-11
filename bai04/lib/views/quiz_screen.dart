import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/word_service.dart';

class QuizQuestion {
  final Word word;
  final String shownMeaning;

  QuizQuestion(this.word, this.shownMeaning);

  bool get isTrue =>
      shownMeaning.trim().toLowerCase() == word.meaning.trim().toLowerCase();
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int maxQuestions = 10;

  final WordService wordService = WordService();
  final Random random = Random();

  List<Word> words = [];
  List<QuizQuestion> questions = [];
  int index = 0;
  int correct = 0;
  int wrong = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await wordService.loadWords();
    if (!mounted) return;
    setState(() {
      words = data;
      loading = false;
      startQuiz();
    });
  }

  void startQuiz() {
    final shuffled = List<Word>.from(words)..shuffle(random);
    final total = min(maxQuestions, shuffled.length);

    questions = List.generate(total, (i) {
      final w = shuffled[i];
      final others = words.where((e) => e.meaning != w.meaning).toList();
      final showTrue = others.isEmpty || random.nextBool();
      final meaning =
          showTrue ? w.meaning : others[random.nextInt(others.length)].meaning;
      return QuizQuestion(w, meaning);
    });

    index = 0;
    correct = 0;
    wrong = 0;
  }

  void answer(bool userSaysTrue) {
    if (index >= questions.length) return;

    setState(() {
      if (userSaysTrue == questions[index].isTrue) {
        correct++;
      } else {
        wrong++;
      }
      index++;
    });

    if (index >= questions.length) {
      showResult();
    }
  }

  void showResult() {
    final total = questions.length;
    final rate = total == 0 ? 0 : correct * 100 / total;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Kết thúc bài kiểm tra"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tổng số câu: $total"),
            Text("✔️ Đúng: $correct"),
            Text("❌ Sai: $wrong"),
            Text("Tỷ lệ chính xác: ${rate.toStringAsFixed(1)}%"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(startQuiz);
            },
            child: const Text("Làm lại"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text("Thoát"),
          ),
        ],
      ),
    );
  }

  Widget scoreChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            text,
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
    if (questions.isEmpty) {
      return const Center(
        child: Text("Chưa có từ nào. Hãy thêm từ ở Trang chính."),
      );
    }

    final q = questions[min(index, questions.length - 1)];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              scoreChip("Đúng: $correct", Colors.green, Icons.check),
              scoreChip("Sai: $wrong", Colors.orange, Icons.close),
            ],
          ),
          const SizedBox(height: 8),
          Text("Câu ${min(index + 1, questions.length)}/${questions.length}"),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    q.word.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.shownMeaning,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => answer(true),
                icon: const Icon(Icons.check),
                label: const Text("Đúng"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => answer(false),
                icon: const Icon(Icons.close),
                label: const Text("Sai"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trắc nghiệm Đúng / Sai")),
      body: buildBody(),
    );
  }
}
