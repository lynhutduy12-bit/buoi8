import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/word.dart';

class WordService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/words.txt');
  }

  Future<void> saveWords(List<Word> words) async {
    final file = await _file;
    final data = words.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  Future<List<Word>> loadWords() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<Word> result = [];
      for (final line in content.split("\n")) {
        if (line.trim().isEmpty || !line.contains('|')) continue;
        result.add(Word.fromString(line));
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<void> addWord(Word word) async {
    final words = await loadWords();
    words.add(word);
    await saveWords(words);
  }
}
