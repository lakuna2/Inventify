import 'package:flutter/material.dart';
import 'package:inventify/login.dart';
// import 'package:inventify/main.dart';
import 'package:inventify/login.dart';
import 'package:splash_master/splash_master.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: SplashMaster.video(
          source: AssetSource('assets/splash_screen.mp4'),
          videoConfig: const VideoConfig(
        videoVisibilityEnum: VisibilityEnum.useAspectRatio,
      ),
          backGroundColor: Colors.white,
          nextScreen: const Login(),
        ),
      ),
    );
  }
}