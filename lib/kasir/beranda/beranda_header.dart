// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:inventify/services/user_service.dart';

////////////////////////////////////////////////////////////
/// HEADER BANNER
////////////////////////////////////////////////////////////
class HeaderBanner extends StatefulWidget {
  const HeaderBanner({super.key});

  @override
  State<HeaderBanner> createState() => _HeaderBannerState();
}

class _HeaderBannerState extends State<HeaderBanner> {
  final _userService = UserService();
  String _namaKasir = 'Kasir';
  String? _avatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final nama = await _userService.getNamaKasir();
    final avatar = await _userService.getCurrentAvatar();
    if (mounted) {
      setState(() {
        _namaKasir = nama;
        _avatar = avatar;
      });
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi,';
    if (h < 15) return 'Selamat Siang,';
    if (h < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: 210 + statusBarHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B5E), Color(0xFF1565C0), Color(0xFF00ACC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: _circle(160, Colors.white.withOpacity(0.07)),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: _circle(80, const Color(0xFF64FFDA).withOpacity(0.12)),
          ),
          Positioned(top: 30, left: 20, child: const _DotGrid()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 12,
              20,
              36,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatarIcon(),
                const SizedBox(width: 12),
                Expanded(child: _userInfo()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _avatarIcon() => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF64FFDA), width: 2),
      color: Colors.white.withOpacity(0.15),
    ),
    child: _avatar != null
        ? ClipOval(
            child: Image.asset(
              'assets/avatar/$_avatar',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          )
        : const Icon(Icons.person_rounded, color: Colors.white, size: 26),
  );

  Widget _userInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _greeting(),
        style: TextStyle(color: Colors.white.withOpacity(0.80), fontSize: 13),
      ),
      const SizedBox(height: 2),
      Text(
        _namaKasir,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 4),
      _roleBadge(),
    ],
  );

  Widget _roleBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF64FFDA).withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF64FFDA).withOpacity(0.5)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.storefront_rounded, size: 12, color: Color(0xFF64FFDA)),
        SizedBox(width: 4),
        Text(
          'Kasir',
          style: TextStyle(
            color: Color(0xFF64FFDA),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Row(
          children: List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.all(4),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}