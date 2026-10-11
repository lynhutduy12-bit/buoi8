class Word {
  String word;
  String meaning;

  Word({required this.word, required this.meaning});

  String toFileString() {
    final w = word.replaceAll('|', '/').replaceAll('\n', ' ');
    final m = meaning.replaceAll('|', '/').replaceAll('\n', ' ');
    return "$w|$m";
  }

  static Word fromString(String line) {
    final index = line.indexOf('|');
    return Word(
      word: line.substring(0, index).trim(),
      meaning: line.substring(index + 1).trim(),
    );
  }
}
