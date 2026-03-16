import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word.dart';
import '../services/word_service.dart';
import '../services/auth_service.dart'; // Added import
import '../services/ad_service.dart'; // Added import
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Added import
import '../constants/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class QuizScreen extends StatefulWidget {
  final Level level;

  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final WordService _wordService = WordService();
  List<Word> _words = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isOptionsUpdating = false;

  List<String> _currentOptions = [];
  int? _selectedOptionIndex;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;

  Timer? _timer;
  int _timeLeft = 20;
  final FlutterTts flutterTts = FlutterTts();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initTts();
    _loadWords();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdReady = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    );
    _bannerAd?.load();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("de-DE");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5); // Biraz yavaş okusun, anlaşılır olsun
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    flutterTts.stop();
    _timer?.cancel();
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);

    // Kelimeleri Firestore'dan çek
    List<Word> fetchedWords = await _wordService.getWordsForLevel(widget.level);

    // Kayıtlı ilerlemeyi getir
    int savedIndex = await _wordService.getLevelProgress(widget.level);

    if (fetchedWords.isNotEmpty) {
      // Eğer önceden bitirdiyse (son soruya ulaştıysa) baştan başlasın
      if (savedIndex >= fetchedWords.length) {
        savedIndex = 0;
      }
    }

    if (mounted) {
      setState(() {
        _words = fetchedWords;
        _currentIndex = savedIndex; // Kayıtlı indeksten başla
        _isLoading = false;
        if (_words.isNotEmpty) {
          _generateOptions();
        }
      });
      if (_words.isNotEmpty) {
        _animationController.forward();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _shakeController.reset();
    setState(() => _timeLeft = 20);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _shakeController.forward();
        }
      });
    });
  }

  Future<void> _generateOptions() async {
    String correctAnswer = _words[_currentIndex].turkish;

    // Tüm kelimeleri çekmek biraz maliyetli olabilir,
    // ama şık üretmek için başka kelimelere ihtiyacımız var.
    // İdealde WordService içinde rastgele 3 yanlış cevap getiren bir metod olmalı.
    // Şimdilik tüm kelimeleri çekip client tarafında eliyoruz.
    List<String> allAnswers = await _wordService.getAllTurkishWords();

    if (allAnswers.length < 4) {
      // Yeterli kelime yoksa dummy data kullan
      allAnswers = ["Elma", "Armut", "Okul", "Kitap", "Kalem", "Masa"];
    }

    allAnswers.remove(correctAnswer);
    allAnswers.shuffle();
    List<String> wrongOptions = allAnswers.take(3).toList();

    if (mounted) {
      setState(() {
        _currentOptions = [correctAnswer, ...wrongOptions];
        _currentOptions.shuffle();
        _isOptionsUpdating = false;
        if (!_isAnswered) _startTimer();
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _handleAnswer(int index) {
    if (_isAnswered || _isOptionsUpdating) return;
    _timer?.cancel();

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = index;
      if (_currentOptions[index] == _words[_currentIndex].turkish) {
        _score++;
        // Puanı veritabanına işle (Her doğru cevap 10 puan)
        AuthService().addScore(10);
        // Doğru bilindiyse, eğer hatalar listesindeyse silebiliriz.
        // İsteğe bağlı, şimdilik sadece eklemeye odaklanalım.
        // _wordService.removeMistake(_words[_currentIndex]);
      } else {
        // Yanlış cevaplandı, hatalara ekle
        _wordService.addMistake(_words[_currentIndex]);
      }
    });

    Timer(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _isOptionsUpdating = true;
        _currentIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
        // İlerlemeyi kaydet
        _wordService.saveLevelProgress(widget.level, _currentIndex);
      });
      _generateOptions();
      _animationController.reset();
      _animationController.forward();
    } else {
      // Test bittiğinde ilerlemeyi "bitmiş" olarak işaretle (indeksi kelime sayısına eşitle)
      _wordService.saveLevelProgress(widget.level, _currentIndex + 1);
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final percentage = (_score / _words.length * 100).round();
    final isPerfect = _score == _words.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : [AppColors.gradientLight, AppColors.gradientMid],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPerfect
                              ? const Color(0xFFFFD700)
                              : AppColors.gradientLight)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isPerfect ? Icons.emoji_events : Icons.check_circle,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Başlık
              Text(
                isPerfect ? "Mükemmel! 🎉" : "Tebrikler!",
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPerfect ? "Tüm soruları doğru bildin!" : "Testi tamamladın",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              // Skor kartı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientLight.withValues(alpha: 0.1),
                      AppColors.gradientMid.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gradientLight.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$_score",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gradientMid,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 4),
                          child: Text(
                            "/ ${_words.length}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: percentage >= 80
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                            : percentage >= 50
                                ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                                : const Color(0xFFE91E63)
                                    .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "%$percentage Başarı",
                        style: TextStyle(
                          color: percentage >= 80
                              ? const Color(0xFF2E7D32)
                              : percentage >= 50
                                  ? const Color(0xFFEF6C00)
                                  : const Color(0xFFC2185B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Ana Menü",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentIndex = 0;
                          _score = 0;
                          _words.shuffle();
                          _isAnswered = false;
                          // İlerlemeyi sıfırla
                          _wordService.saveLevelProgress(widget.level, 0);
                        });
                        _generateOptions();
                        _animationController.reset();
                        _animationController.forward();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientMid,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Tekrarla",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const GradientScaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_words.isEmpty) {
      return GradientScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                "Bu seviyede henüz kelime yok.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await _wordService.uploadInitialData();
                  _loadWords();
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Varsayılan Kelimeleri Yükle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.gradientDark,
                ),
              )
            ],
          ),
        ),
      );
    }

    Word currentWord = _words[_currentIndex];
    final progress = (_currentIndex + 1) / _words.length;

    return GradientScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.level.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Soru ${_currentIndex + 1}/${_words.length}",
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Timer Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _timeLeft <= 3
                                ? AppColors.wrong.withOpacity(0.2)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _timeLeft <= 3
                                  ? AppColors.wrong.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.2),
                            )),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16,
                                color: _timeLeft <= 3
                                    ? AppColors.wrong
                                    : Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              "$_timeLeft sn",
                              style: TextStyle(
                                color: _timeLeft <= 3
                                    ? AppColors.wrong
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "$_score",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gradientLight),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Soru Kartı
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gradientLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "🇩🇪 Almanca",
                          style: TextStyle(
                            color: AppColors.gradientMid,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              currentWord.german,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 32, // Biraz küçülttük
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.visible, // Taşarsa aşağı kaysın
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _speak(currentWord.german),
                            icon: const Icon(Icons.volume_up_rounded,
                                color: AppColors.gradientMid, size: 32),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.translate,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              "Türkçe karşılığı nedir?",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Şıklar
              if (_currentOptions.length == 4)
                ...List.generate(4, (index) {
                  String option = _currentOptions[index];
                  bool isSelected = _selectedOptionIndex == index;
                  bool isCorrectOption = option == currentWord.turkish;

                  // Varsayılan: Beyaz Arka Plan (Soru kartı gibi)
                  Color bgColor = Colors.white;
                  Color textColor = AppColors.textDark;
                  Color borderColor = Colors.transparent;
                  Color circleColor =
                      AppColors.gradientMid.withValues(alpha: 0.1);
                  Color circleTextColor = AppColors.gradientMid;
                  IconData? icon;

                  if (_isAnswered) {
                    if (isSelected || isCorrectOption) {
                      // Seçilen veya doğru olan şıklar beyaz kalsın (arkaplandan ayrışsın)
                      bgColor = Colors.white;

                      if (isCorrectOption) {
                        borderColor = AppColors.correct; // Yeşil çerçeve
                        textColor = AppColors.correct; // Yeşil yazı
                        circleColor = AppColors.correct.withValues(alpha: 0.1);
                        circleTextColor = AppColors.correct;
                        icon = Icons.check_circle;
                      } else if (isSelected && !isCorrectOption) {
                        borderColor = AppColors.wrong; // Kırmızı çerçeve
                        textColor = AppColors.wrong; // Kırmızı yazı
                        circleColor = AppColors.wrong.withValues(alpha: 0.1);
                        circleTextColor = AppColors.wrong;
                        icon = Icons.cancel;
                      }
                    } else {
                      // Seçilmeyen diğer şıklar sönükleşsin
                      bgColor = Colors.white.withValues(alpha: 0.3);
                      textColor = AppColors.textDark.withValues(alpha: 0.3);
                      circleColor = Colors.transparent;
                      circleTextColor =
                          AppColors.textDark.withValues(alpha: 0.3);
                    }
                  } else if (_timeLeft == 0 && isCorrectOption) {
                    borderColor = Colors.amber;
                    bgColor = Colors.white;
                  }

                  Widget optionWidget = Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => _handleAnswer(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: borderColor,
                              width: (_isAnswered &&
                                      (isCorrectOption || isSelected))
                                  ? 3.0
                                  : 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: circleColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: circleTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (icon != null) ...[
                              const SizedBox(width: 8),
                              Icon(icon, color: Colors.white, size: 22),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );

                  if (isCorrectOption) {
                    return AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final double offset =
                            sin(_shakeController.value * pi * 4) * 8;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: optionWidget,
                    );
                  }
                  return optionWidget;
                }),

              if (_isBannerAdReady)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),

              const SizedBox(height: 80), // Reklam alanı için boşluk
            ],
          ),
        ),
      ),
    );
  }
}
