import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
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

  void _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Hesabı Sil',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz. Tüm verileriniz ve ilerlemeniz kalıcı olarak silinir.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Vazgeç',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => _isLoading = true);
                try {
                  await _authService.deleteAccount();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hesabınız başarıyla silindi.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Evet, Sil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String initial =
        user?.displayName != null && user!.displayName!.isNotEmpty
            ? user.displayName![0].toUpperCase()
            : "?";

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          "Profilim",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profil Resmi / Baş harf
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.5),
                          width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gradientMid,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // İsim ve E-posta
                Text(
                  user?.displayName ?? "Misafir Kullanıcı",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.email ?? "email@yok.com",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Menü Öğeleri
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.edit,
                        text: "Profili Düzenle",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileScreen()),
                          );
                        },
                        showDivider: true,
                      ),
                      _buildProfileItem(
                        icon: Icons.lock_outline,
                        text: "Şifre Değiştir",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen()),
                          );
                        },
                        showDivider: true,
                      ),
                      _buildProfileItem(
                        icon: Icons.notifications_none,
                        text: "Bildirimler",
                        onTap: () {},
                        showDivider: true,
                      ),
                      _buildProfileItem(
                        icon: Icons.help_outline,
                        text: "Yardım ve Destek",
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Çıkış Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: const Color(0xFFFF5252),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black45,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Çıkış Yap",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hesabı Sil Butonu
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _showDeleteAccountDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete_forever_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Hesabı Sil",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_isBannerAdReady)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gradientLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gradientMid, size: 22),
          ),
          title: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          trailing:
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68, right: 20),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
      ],
    );
  }
}
