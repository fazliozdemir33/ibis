import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Gizlilik Politikası',
          style:
              TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Giriş',
              'Bu Gizlilik Politikası, Ibis uygulamasını kullandığınızda kişisel verilerinizin nasıl toplandığını, kullanıldığını ve korunduğunu açıklar. Uygulamamızı kullanarak bu politikada belirtilen veri uygulamalarını kabul etmiş olursunuz.',
            ),
            _buildSection(
              'Toplanan Veriler',
              'Uygulamamız şu verileri toplayabilir:\n'
                  '• E-posta adresi (hesap oluşturma için)\n'
                  '• Kullanıcı adı ve profil bilgileri\n'
                  '• Eğitim ilerlemesi ve puan durumu\n'
                  '• Uygulama kullanım istatistikleri',
            ),
            _buildSection(
              'Verilerin Kullanım Amacı',
              'Toplanan veriler şu amaçlarla kullanılır:\n'
                  '• Kullanıcı hesabınızı yönetmek\n'
                  '• Eğitim ilerlemenizi kaydetmek ve skor tablosunu güncellemek\n'
                  '• Uygulama deneyiminizi iyileştirmek\n'
                  '• İletişim sağlamak ve destek sunmak',
            ),
            _buildSection(
              'Veri Güvenliği',
              'Verileriniz Firebase (Google Cloud) altyapısı üzerinde güvenle saklanmaktadır. Verilerinizin güvenliğini sağlamak için endüstri standardı şifreleme ve güvenlik önlemleri kullanıyoruz.',
            ),
            _buildSection(
              'Üçüncü Taraf Paylaşımı',
              'Kişisel verileriniz asla üçüncü taraflara satılmaz veya ticari amaçlarla paylaşılmaz. Verileriniz yalnızca uygulamanın temel fonksiyonlarını yerine getirmek amacıyla altyapı sağlayıcılarımızla paylaşılabilir.',
            ),
            _buildSection(
              'Haklarınız',
              'Kullanıcılar olarak verilerinize erişme, düzeltme veya silme hakkına sahipsiniz. Hesabınızı ve verilerinizi silmek için profil ayarlarını kullanabilir veya bizimle iletişime geçebilirsiniz.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Son Güncelleme: 26 Şubat 2026',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
