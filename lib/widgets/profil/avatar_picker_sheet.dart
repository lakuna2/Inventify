import 'package:flutter/material.dart';
import 'package:inventify/theme.dart';

/// Sheet untuk memilih avatar dari 5 pilihan yang tersedia
class AvatarPickerSheet {
  static const List<String> avatars = [
    'butterfly.png',
    'deer.png',
    'jacutinga.png',
    'koi.png',
    'panda.png',
  ];

  static const Map<String, String> avatarNames = {
    'butterfly.png': 'Kupu-kupu',
    'deer.png': 'Rusa',
    'jacutinga.png': 'Burung',
    'koi.png': 'Ikan Koi',
    'panda.png': 'Panda',
  };

  static Future<String?> show(BuildContext context, {String? currentAvatar}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AvatarPickerContent(currentAvatar: currentAvatar),
    );
  }
}

class _AvatarPickerContent extends StatelessWidget {
  final String? currentAvatar;

  const _AvatarPickerContent({this.currentAvatar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Pilih Avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih karakter favorit Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // Avatar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: AvatarPickerSheet.avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = AvatarPickerSheet.avatars[index];
                    final isSelected = currentAvatar == avatar;
                    // ignore: unused_local_variable
                    final name = AvatarPickerSheet.avatarNames[avatar] ?? '';

                    return GestureDetector(
                      onTap: () => Navigator.pop(context, avatar),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGrey.withValues(alpha: 0.2),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/avatar/$avatar',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}