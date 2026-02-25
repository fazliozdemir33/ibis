import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Şu anki kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Stream ile kullanıcı durumunu dinle (giriş/çıkış)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Giriş Yap
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Kayıt Ol
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Auth ile kullanıcı oluştur
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Firestore'a kullanıcı verilerini kaydet
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email.trim(),
          'name': name.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'level': 'A1', // Varsayılan seviye
          'score': 0,
        });

        // Kullanıcı adını güncelle
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Kullanıcı Adını Güncelle
  Future<void> updateDisplayName(String newName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});
      await user.reload(); // Kullanıcı bilgisini yenile
    }
  }

  // Şifre Güncelle
  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw 'Güvenlik nedeniyle şifre değiştirmek için lütfen çıkış yapıp tekrar giriş yapın.';
        }
        throw _handleAuthException(e);
      }
    }
  }

  // --- Skor / Liderlik Tablosu ---

  // Puan ekle (Atomic increment)
  Future<void> addScore(int points) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'score': FieldValue.increment(points),
        });
      } catch (e) {
        print("Puan eklenirken hata: $e");
      }
    }
  }

  // Liderlik tablosunu getir (En yüksek puanlı 20 kişi)
  Future<List<Map<String, dynamic>>> getTopUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'İsimsiz',
          'score': data['score'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("Liderlik tablosu çekilirken hata: $e");
      return [];
    }
  }

  // Kullanıcının anlık skorunu getir (Stream)
  Stream<int> getUserScoreStream() {
    User? user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return (data?['score'] as int?) ?? 0;
    });
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Hata yönetimi
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
