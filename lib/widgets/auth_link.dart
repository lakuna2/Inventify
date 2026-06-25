import 'package:flutter/material.dart';
import 'package:inventify/pages/masuk.dart';
import 'package:inventify/pages/registrasi.dart';
import 'package:inventify/theme.dart';

enum AuthMode { login, register }

class AuthLink extends StatelessWidget {
  final AuthMode mode;

  const AuthLink({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == AuthMode.login;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin
              ? 'Belum Punya Akun? '
              : 'Sudah Punya Akun? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    isLogin ? const RegisterPage() : const MasukPage(),
              ),
            );
          },
          child: Text(
            isLogin ? 'Daftar' : 'Masuk',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}