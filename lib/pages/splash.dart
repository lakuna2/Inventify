import 'package:flutter/material.dart';
import 'package:inventify/pages/auth_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    
    // Skip video di web, langsung ke AuthWrapper
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      });
      return;
    }

    // Initialize video player untuk mobile
    _controller = VideoPlayerController.asset('assets/splash_screen.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      }).catchError((error) {
        // ignore: avoid_print
        print('Error loading video: $error');
        if (mounted) {
          setState(() => _videoError = true);
          // Jika video error, tunggu 2 detik lalu navigate
          Future.delayed(const Duration(seconds: 2), _navigateToAuth);
        }
      });

    // Listener untuk detect video selesai
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _navigateToAuth();
      }
    });
  }

  void _navigateToAuth() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Untuk web, tampilkan widget kosong (akan langsung navigate)
    if (kIsWeb) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Jika video error, tampilkan fallback splash
    if (_videoError) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 60,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Inventify',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D47A1),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan video jika sudah initialized
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FA),
      body: _controller.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
