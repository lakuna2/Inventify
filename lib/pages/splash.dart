import 'package:flutter/material.dart';
import 'package:inventify/main.dart';
import 'package:splash_master/splash_master.dart';
import 'package:flutter/foundation.dart';

// ============================================================
// THEME COLORS (Inventify)
// ============================================================
class AppColors {
  static const Color myBackground = Color(0xFFFAF7FA);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Di web, langsung ke AuthWrapper
    if (kIsWeb) {
      return const AuthWrapper();
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SplashMaster.video(
          source: AssetSource('splash_screen.mp4'),
          videoConfig: const VideoConfig(
            videoVisibilityEnum: VisibilityEnum.useAspectRatio,
          ),
          backGroundColor: const Color(0xFFFAF7FA),
          nextScreen: const AuthWrapper(),
        ),
      ),
    );
  }
}