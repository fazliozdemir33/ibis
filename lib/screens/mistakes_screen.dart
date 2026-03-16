import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word.dart';
import '../services/word_service.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class MistakesScreen extends StatefulWidget {
  const MistakesScreen({super.key});

  @override
  State<MistakesScreen> createState() => _MistakesScreenState();
}

class _MistakesScreenState extends State<MistakesScreen>
    with SingleTickerProviderStateMixin {
  final WordService _wordService = WordService();
  List<Word> _mistakeWords = [];
  bool _isLoading = true;

  // Quiz state
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  List<String> _currentOptions = [];
  int? _selectedOptionIndex;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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
    _initTts();
    _loadMistakes();
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
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMistakes() async {
    setState(() => _isLoading = true);

    List<Word> mistakes = await _wordService.getMistakes();

    if (mistakes.isNotEmpty) {
      mistakes.shuffle();
    }

    if (mounted) {
      setState(() {
        _mistakeWords = mistakes;
        _isLoading = false;
        if (_mistakeWords.isNotEmpty) {
          _generateOptions();
          _animationController.forward();
        }
      });
    }
  }

  Future<void> _generateOptions() async {
    String correctAnswer = _mistakeWords[_currentIndex].turkish;
    List<String> allAnswers = await _wordService.getAllTurkishWords();

    if (allAnswers.length < 4) {
      allAnswers = ["Elma", "Armut", "Okul", "Kitap", "Kalem", "Masa"];
    }

    allAnswers.remove(correctAnswer);
    allAnswers.shuffle();
    List<String> wrongOptions = allAnswers.take(3).toList();

    if (mounted) {
      setState(() {
        _currentOptions = [correctAnswer, ...wrongOptions];
        _currentOptions.shuffle();
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _handleAnswer(int index) async {
    if (_isAnswered) return;

    _isAnswered = true; // Tıklamayı hemen engelle

    Word currentWord = _mistakeWords[_currentIndex];
    bool isCorrect = _currentOptions[index] == currentWord.turkish;

    setState(() {
      _selectedOptionIndex = index;
    });

    if (isCorrect) {
      // Doğru bildi!
      bool removed = await _wordService.handleMistakeSuccess(currentWord);
      if (mounted && removed) {
        setState(() {
          _score++; // Sadece tamamen silinenleri say
        });
      }
    } else {
      // Yanlış bildi, sayaç sıfırlanabilir veya olduğu gibi kalır.
      // Şimdilik dokunmuyoruz, bir sonraki denemede yine sorulacak.
    }

    Timer(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex < _mistakeWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
      });
      _generateOptions();
      _animationController.reset();
      _animationController.forward();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Tamamlandı!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$_score hatanı temizledin.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog kapat
                  Navigator.pop(context); // Ekran kapat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientMid,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("Harika!",
                    style: TextStyle(color: Colors.white)),
              ),
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
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_mistakeWords.isEmpty) {
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
              const Icon(Icons.check_circle_outline,
                  size: 80, color: Colors.white70),
              const SizedBox(height: 24),
              const Text(
                "Harikasın! Hiç hatan yok.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Bol bol pratik yapmaya devam et.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    Word currentWord = _mistakeWords[_currentIndex];

    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Hatalarım",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Soru ${_currentIndex + 1}/${_mistakeWords.length}",
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Temizlenen: $_score",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Soru Kartı (QuizScreen ile aynı tasarım)
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
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Tekrar Dene",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWord.german,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
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
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Şıklar
            if (_currentOptions.length == 4)
              ...List.generate(4, (index) {
                String option = _currentOptions[index];
                bool isSelected = _selectedOptionIndex == index;
                bool isCorrectOption = option == currentWord.turkish;

                Color bgColor = AppColors.white.withValues(alpha: 0.1);
                Color textColor = Colors.white;
                Color borderColor = AppColors.white.withValues(alpha: 0.3);
                IconData? icon;

                if (_isAnswered) {
                  if (isCorrectOption) {
                    bgColor = AppColors.correct;
                    borderColor = AppColors.correct;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isCorrectOption) {
                    bgColor = AppColors.wrong;
                    borderColor = AppColors.wrong;
                    icon = Icons.cancel;
                  }
                }

                return Padding(
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
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                  alpha: _isAnswered &&
                                          (isCorrectOption || isSelected)
                                      ? 0.3
                                      : 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  color: Colors.white,
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
