import 'package:flutter/material.dart';
import 'package:inventify/pages/masuk.dart';
import 'package:inventify/pages/registrasi.dart';
import 'package:inventify/theme.dart';

class AuthLink extends StatelessWidget {
  final bool isLogin;

  const AuthLink({
    super.key,
    required this.isLogin,
    });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'Sudah Punya Akun? ' : 'Belum Punya Akun? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            if(isLogin){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MasukPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            }
          },
          child: Text(
            isLogin ? 'Masuk' : 'Daftar',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget _buildLoginLink() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       const Text(
//         'Sudah Punya Akun? ',
//         style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//       ),
//       GestureDetector(
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const MasukPage()),
//           );
//         },
//         child: const Text(
//           'Masuk',
//           style: TextStyle(
//             color: AppColors.accent,
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             decoration: TextDecoration.underline,
//             decorationColor: AppColors.accent,
//           ),
//         ),
//       ),
//     ],
//   );
// }
