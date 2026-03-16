import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/word.dart';
import '../widgets/gradient_scaffold.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../services/word_service.dart';
import 'mistakes_screen.dart';
import 'leaderboard_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          // Özel Header Alanı
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8, // 20 -> 8
              bottom: 12, // 24 -> 12
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Builder(
              builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Uygulama İkonu
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'app-icon',
                              child: SizedBox(
                                width: 115,
                                height: 115,
                                child: Image.asset(
                                  'assets/images/ibis_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4), // 16 -> 4 (Yaklaştırıldı)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "IBIS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.gradientMid,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing:
                                            -0.5, // Daha sıkı ve modern
                                        fontFamily: 'Outfit',
                                      ),
                                ),
                                Text(
                                  "Almanca Öğren",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall // Biraz daha küçültüldü
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stats Badge - Yeniden Tasarlandı (Daha Premium Ödül Görünümü)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4), // Dış çerçeve
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 6),
                              StreamBuilder<int>(
                                stream: AuthService().getUserScoreStream(),
                                builder: (context, snapshot) {
                                  return Text(
                                    "${snapshot.data ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),

          // Ana İçerik (Liste)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF8A80)
                            .withValues(alpha: 0.9), // Pastel Kırmızı
                        const Color(0xFFFF80AB)
                            .withValues(alpha: 0.9), // Pembemsi Ton
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF80AB).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MistakesScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.refresh_rounded,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Hatalarım",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20, // 18 -> 20
                                      fontWeight: FontWeight.w900, // Daha kalın
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Yanlış yaptığın kelimeleri tekrar et",
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Seviye Başlığı - Daha belirgin
                // Seviye Başlığı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white, // Tam beyaz yaptık
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Seviyeler",
                        style: TextStyle(
                          color: Colors.white, // Tam beyaz
                          fontSize: 22, // Biraz büyüttük
                          fontWeight: FontWeight.w800, // Daha kalın font
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Seviye Kartları
                _buildLevelCard(context, "Başlangıç", Level.a1, "A1",
                    const Color(0xFF4CAF50)),
                const SizedBox(height: 16),
                _buildLevelCard(
                    context, "Temel", Level.a2, "A2", const Color(0xFF2196F3)),
                const SizedBox(height: 16),
                _buildLevelCard(
                    context, "Orta", Level.b1, "B1", const Color(0xFFFF9800)),
                const SizedBox(height: 16),
                _buildLevelCard(
                    context, "İleri", Level.b2, "B2", const Color(0xFFE91E63)),
              ],
            ),
          ),
          if (_isBannerAdReady)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.only(bottom: 12),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, String title, Level level,
      String badgeText, Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(level: level),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.white.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekoratif arka plan deseni
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    // Sol Taraf: İkon ve Badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Orta: Başlık ve Alt Başlık
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Dinamik Kelime Sayısı
                          FutureBuilder<int>(
                            future: WordService().getWordCountForLevel(level),
                            builder: (context, snapshot) {
                              String countText = "Yükleniyor...";
                              if (snapshot.hasData) {
                                countText = "${snapshot.data} kelime";
                              } else if (snapshot.hasError) {
                                countText = "Hata!";
                              }
                              return Text(
                                countText,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Sağ: Ok ikonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
