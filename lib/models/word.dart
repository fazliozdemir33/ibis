enum Level {
  a1,
  a2,
  b1,
  b2,
}

class Word {
  final String german;
  final String turkish;
  final Level level;
  final int
      correctCount; // Hataları tekrar ederken kaç kere doğru bilindiğini tutar

  Word({
    required this.german,
    required this.turkish,
    required this.level,
    this.correctCount = 0,
  });

  // Veri setinden kolayca nesne oluşturmak için factory metodu eklenebilir
  Map<String, dynamic> toMap() {
    return {
      'german': german,
      'turkish': turkish,
      'level': level.name.toUpperCase(),
      'correctCount': correctCount,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      german: map['german'] ?? '',
      turkish: map['turkish'] ?? '',
      level: _parseLevel(map['level'] ?? 'A1'),
      correctCount: map['correctCount'] ?? 0,
    );
  }

  static Level _parseLevel(String levelStr) {
    if (levelStr.isEmpty) return Level.a1;
    switch (levelStr.toUpperCase()) {
      case 'A1':
        return Level.a1;
      case 'A2':
        return Level.a2;
      case 'B1':
        return Level.b1;
      case 'B2':
        return Level.b2;
      default:
        return Level.a1;
    }
  }
}
