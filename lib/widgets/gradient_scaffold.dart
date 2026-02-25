import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // AppBar'ın arkasına gradientin devam etmesi için
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientMid,
              AppColors.gradientDark,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        // Işık efekti için üzerine ikinci bir gradient katmanı (Radial)
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center:
                  const Alignment(-0.8, -0.2), // Sol üst taraftan vuran ışık
              radius: 1.5,
              colors: [
                AppColors.gradientLight.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: body,
          ),
        ),
      ),
    );
  }
}
