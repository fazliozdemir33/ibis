import '../models/word.dart';

class WordData {
  static final List<Word> _allWords = [
    // A1 Seviyesi (Başlangıç) - 30 Kelime
    Word(german: 'Der Apfel', turkish: 'Elma', level: Level.a1),
    Word(german: 'Das Haus', turkish: 'Ev', level: Level.a1),
    Word(german: 'Die Katze', turkish: 'Kedi', level: Level.a1),
    Word(german: 'Der Hund', turkish: 'Köpek', level: Level.a1),
    Word(german: 'Das Buch', turkish: 'Kitap', level: Level.a1),
    Word(german: 'Die Schule', turkish: 'Okul', level: Level.a1),
    Word(german: 'Der Vater', turkish: 'Baba', level: Level.a1),
    Word(german: 'Die Mutter', turkish: 'Anne', level: Level.a1),
    Word(german: 'Das Wasser', turkish: 'Su', level: Level.a1),
    Word(german: 'Das Brot', turkish: 'Ekmek', level: Level.a1),
    Word(german: 'Der Tisch', turkish: 'Masa', level: Level.a1),
    Word(german: 'Der Stuhl', turkish: 'Sandalye', level: Level.a1),
    Word(german: 'Die Blume', turkish: 'Çiçek', level: Level.a1),
    Word(german: 'Das Fenster', turkish: 'Pencere', level: Level.a1),
    Word(german: 'Die Tür', turkish: 'Kapı', level: Level.a1),
    Word(german: 'Der Baum', turkish: 'Ağaç', level: Level.a1),
    Word(german: 'Das Auto', turkish: 'Araba', level: Level.a1),
    Word(german: 'Der Lehrer', turkish: 'Öğretmen', level: Level.a1),
    Word(german: 'Der Schüler', turkish: 'Öğrenci', level: Level.a1),
    Word(german: 'Die Sonne', turkish: 'Güneş', level: Level.a1),
    Word(german: 'Der Mond', turkish: 'Ay', level: Level.a1),
    Word(german: 'Der Stern', turkish: 'Yıldız', level: Level.a1),
    Word(german: 'Die Milch', turkish: 'Süt', level: Level.a1),
    Word(german: 'Der Zucker', turkish: 'Şeker', level: Level.a1),
    Word(german: 'Das Salz', turkish: 'Tuz', level: Level.a1),
    Word(german: 'Der Kaffee', turkish: 'Kahve', level: Level.a1),
    Word(german: 'Der Tee', turkish: 'Çay', level: Level.a1),
    Word(german: 'Die Farbe', turkish: 'Renk', level: Level.a1),
    Word(german: 'Das Geld', turkish: 'Para', level: Level.a1),
    Word(german: 'Der Name', turkish: 'İsim', level: Level.a1),

    // A2 Seviyesi (Temel) - 30 Kelime
    Word(german: 'Arbeiten', turkish: 'Çalışmak', level: Level.a2),
    Word(german: 'Lernen', turkish: 'Öğrenmek', level: Level.a2),
    Word(german: 'Essen', turkish: 'Yemek yemek', level: Level.a2),
    Word(german: 'Trinken', turkish: 'İçmek', level: Level.a2),
    Word(german: 'Gehen', turkish: 'Gitmek', level: Level.a2),
    Word(german: 'Kommen', turkish: 'Gelmek', level: Level.a2),
    Word(german: 'Schlafen', turkish: 'Uyumak', level: Level.a2),
    Word(german: 'Das Frühstück', turkish: 'Kahvaltı', level: Level.a2),
    Word(german: 'Das Mittagessen', turkish: 'Öğle yemeği', level: Level.a2),
    Word(german: 'Das Abendessen', turkish: 'Akşam yemeği', level: Level.a2),
    Word(german: 'Der Freund', turkish: 'Erkek Arkadaş', level: Level.a2),
    Word(german: 'Die Freundin', turkish: 'Kız Arkadaş', level: Level.a2),
    Word(german: 'Die Familie', turkish: 'Aile', level: Level.a2),
    Word(german: 'Der Bahnhof', turkish: 'Tren istasyonu', level: Level.a2),
    Word(german: 'Der Flughafen', turkish: 'Havalimanı', level: Level.a2),
    Word(german: 'Das Krankenhaus', turkish: 'Hastane', level: Level.a2),
    Word(german: 'Die Straße', turkish: 'Cadde', level: Level.a2),
    Word(german: 'Die Stadt', turkish: 'Şehir', level: Level.a2),
    Word(german: 'Das Dorf', turkish: 'Köy', level: Level.a2),
    Word(german: 'Besuchen', turkish: 'Ziyaret etmek', level: Level.a2),
    Word(german: 'Kaufen', turkish: 'Satın almak', level: Level.a2),
    Word(german: 'Verkaufen', turkish: 'Satmak', level: Level.a2),
    Word(german: 'Die Reise', turkish: 'Seyahat', level: Level.a2),
    Word(german: 'Der Urlaub', turkish: 'Tatil', level: Level.a2),
    Word(german: 'Die Karte', turkish: 'Harita/Kart', level: Level.a2),
    Word(german: 'Der Preis', turkish: 'Fiyat', level: Level.a2),
    Word(german: 'Die Rechnung', turkish: 'Fatura/Hesap', level: Level.a2),
    Word(german: 'Der Arzt', turkish: 'Doktor', level: Level.a2),
    Word(german: 'Die Medizin', turkish: 'İlaç', level: Level.a2),
    Word(german: 'Das Wetter', turkish: 'Hava Durumu', level: Level.a2),

    // B1 Seviyesi (Orta) - 15 Kelime
    Word(german: 'Die Erfahrung', turkish: 'Deneyim', level: Level.b1),
    Word(german: 'Entscheiden', turkish: 'Karar vermek', level: Level.b1),
    Word(german: 'Die Meinung', turkish: 'Fikir/Görüş', level: Level.b1),
    Word(german: 'Erklären', turkish: 'Açıklamak', level: Level.b1),
    Word(german: 'Die Zukunft', turkish: 'Gelecek', level: Level.b1),
    Word(german: 'Die Umwelt', turkish: 'Çevre', level: Level.b1),
    Word(german: 'Der Erfolg', turkish: 'Başarı', level: Level.b1),
    Word(german: 'Die Bildung', turkish: 'Eğitim', level: Level.b1),
    Word(german: 'Die Gesundheit', turkish: 'Sağlık', level: Level.b1),
    Word(german: 'Die Gesellschaft', turkish: 'Toplum', level: Level.b1),
    Word(german: 'Verstehen', turkish: 'Anlamak', level: Level.b1),
    Word(german: 'Planen', turkish: 'Planlamak', level: Level.b1),
    Word(german: 'Vergleichen', turkish: 'Karşılaştırmak', level: Level.b1),
    Word(german: 'Die Lösung', turkish: 'Çözüm', level: Level.b1),
    Word(german: 'Das Problem', turkish: 'Sorun', level: Level.b1),

    // B2 Seviyesi (İleri) - 15 Kelime
    Word(german: 'Die Verantwortung', turkish: 'Sorumluluk', level: Level.b2),
    Word(german: 'Überzeugen', turkish: 'İkna etmek', level: Level.b2),
    Word(german: 'Die Gelegenheit', turkish: 'Fırsat', level: Level.b2),
    Word(german: 'Notwendig', turkish: 'Gerekli', level: Level.b2),
    Word(
        german: 'Die Untersuchung',
        turkish: 'Araştırma/İnceleme',
        level: Level.b2),
    Word(
        german: 'Die Herausforderung',
        turkish: 'Meydan Okuma',
        level: Level.b2),
    Word(german: 'Die Entwicklung', turkish: 'Gelişim', level: Level.b2),
    Word(german: 'Die Wirtschaft', turkish: 'Ekonomi', level: Level.b2),
    Word(german: 'Die Wissenschaft', turkish: 'Bilim', level: Level.b2),
    Word(german: 'Abhängig', turkish: 'Bağımlı', level: Level.b2),
    Word(german: 'Unabhängig', turkish: 'Bağımsız', level: Level.b2),
    Word(german: 'Die Maßnahme', turkish: 'Önlem/Tedbir', level: Level.b2),
    Word(german: 'Der Vorteil', turkish: 'Avantaj', level: Level.b2),
    Word(german: 'Der Nachteil', turkish: 'Dezavantaj', level: Level.b2),
    Word(german: 'Die Bedingung', turkish: 'Koşul/Şart', level: Level.b2),
  ];

  /// Belirli bir seviyeye ait kelimeleri getirir.
  static List<Word> getWordsForLevel(Level level) {
    return _allWords.where((word) => word.level == level).toList();
  }

  /// Tüm kelimelerin Türkçe karşılıklarını (yanlış şık üretmek için) getirir.
  static List<String> getAllTurkishWords() {
    return _allWords.map((word) => word.turkish).toList();
  }
}
