import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/word.dart';
import '../data/word_data.dart'; // Lokal veriyi yüklemek için

class WordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'words';

  // --- Hatalarım (Mistakes) Yönetimi ---

  // Hatayı ekle
  Future<void> addMistake(Word word) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mistakes')
          .doc(word.german) // Kelime bazlı unique ID
          .set(word.toMap());
    } catch (e) {
      print("Hata eklenirken sorun oluştu: $e");
    }
  }

  // Hataları getir
  Future<List<Word>> getMistakes() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mistakes')
          .get();

      return snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();
    } catch (e) {
      print("Hatalar getirilirken sorun oluştu: $e");
      return [];
    }
  }

  // Hatayı sil (doğru bilinirse)
  Future<void> removeMistake(Word word) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mistakes')
          .doc(word.german)
          .delete();
    } catch (e) {
      print("Hata silinirken sorun oluştu: $e");
    }
  }

  // Hatayı güncelle (Doğru bilindiğinde sayaç artır veya sil)
  Future<bool> handleMistakeSuccess(Word word) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      int newCount = word.correctCount + 1;

      if (newCount >= 3) {
        // 3 kez doğru bilindiyse sil
        await removeMistake(word);
        return true; // Silindi
      } else {
        // Sayacı güncelle
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mistakes')
            .doc(word.german)
            .update({'correctCount': newCount});
        return false; // Silinmedi, güncellendi
      }
    } catch (e) {
      print("Hata güncellenirken sorun oluştu: $e");
      return false;
    }
  }

  /// Firestore'dan belirli bir seviyedeki toplam kelime sayısını getirir
  Future<int> getWordCountForLevel(Level level) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('level', isEqualTo: level.name.toUpperCase())
          .get();
      return snapshot.size;
    } catch (e) {
      print("Kelime sayısı getirilirken hata oluştu: $e");
      return 0;
    }
  }

  /// Kelimeleri Firestore'dan seviyeye göre getirir
  Future<List<Word>> getWordsForLevel(Level level) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('level', isEqualTo: level.name.toUpperCase())
          .get();

      List<Word> words = snapshot.docs.map((doc) {
        return Word.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // İndeks hatasını önlemek için sıralamayı istemci tarafında yapıyoruz.
      // Bu sayede Firebase Console'da manuel indeks oluşturmaya gerek kalmaz.
      words.sort((a, b) => a.german.compareTo(b.german));

      return words;
    } catch (e) {
      print("Kelimeler getirilirken hata oluştu: $e");
      return [];
    }
  }

  /// Firestore'daki tüm kelimeleri getirir (Yanlış şıkları üretmek için)
  Future<List<String>> getAllTurkishWords() async {
    try {
      // Performans notu: Çok fazla kelime olduğunda sadece gerekli alanları çekmek daha iyidir
      // Ancak şimdilik basit tutuyoruz.
      QuerySnapshot snapshot =
          await _firestore.collection(_collectionPath).get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['turkish'] as String? ?? '';
          })
          .where((w) => w.isNotEmpty)
          .toList();
    } catch (e) {
      print("Tüm kelimeler çekilirken hata: $e");
      return [];
    }
  }

  // --- Seviye İlerlemesi (Level Progress) Yönetimi ---

  // Seviye ilerlemesini kaydet
  Future<void> saveLevelProgress(Level level, int index) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc(level.name.toUpperCase())
          .set({
        'currentIndex': index,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("İlerleme kaydedilirken hata oluştu: $e");
    }
  }

  // Seviye ilerlemesini getir
  Future<int> getLevelProgress(Level level) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc(level.name.toUpperCase())
          .get();

      if (doc.exists) {
        return doc.data()?['currentIndex'] ?? 0;
      }
      return 0;
    } catch (e) {
      print("İlerleme getirilirken hata oluştu: $e");
      return 0;
    }
  }

  /// ADMIN FONKSİYONU: Lokaldeki WordData verilerini tek seferlik Firestore'a yükler
  Future<void> uploadInitialData() async {
    final batch = _firestore.batch();

    // WordData içindeki özel _allWords listesine erişemediğimiz için
    // WordData sınıfına public bir getter eklememiz veya
    // WordData class'ını değiştirmemiz gerekebilir.
    // Şimdilik WordData'yı modifiye edeceğiz.

    // WordData._allWords private olduğu için şu an erişemeyiz.
    // Bu yüzden WordData.getWordsForLevel çağırarak tüm seviyeleri toplayacağız.
    List<Word> allWords = [];
    for (var level in Level.values) {
      allWords.addAll(WordData.getWordsForLevel(level));
    }

    if (allWords.isEmpty) {
      print("Yüklenecek kelime bulunamadı.");
      return;
    }

    for (var word in allWords) {
      // Benzersiz ID oluşturmak için almanca kelimeyi kullanabiliriz (boşluksuz, küçük harf)
      // veya random ID. Random ID daha güvenlidir.
      var docRef = _firestore.collection(_collectionPath).doc();
      batch.set(docRef, word.toMap());
    }

    await batch.commit();
    print("${allWords.length} kelime başarıyla yüklendi!");
  }
}
