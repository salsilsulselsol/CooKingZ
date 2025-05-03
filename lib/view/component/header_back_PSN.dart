import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HeaderBackPSN extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBackPSN({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Image.asset(
          'images/arrow.png',
          height: AppTheme.iconSizeLarge,
          width: AppTheme.iconSizeLarge,
        ),
      ),
      title: Text(
        'Resep Anda',
        style: AppTheme.headerStyle.copyWith(color: AppTheme.emeraldGreen),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              const SizedBox(width: AppTheme.spacingMedium),
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    radius: 14,
                  ),
                  Image.asset(
                    'images/tambah.png',
                    height: AppTheme.iconSizeLarge + 4,
                    width: AppTheme.iconSizeLarge + 4,
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    radius: 14,
                  ),
                  Image.asset(
                    'images/search.png',
                    height: AppTheme.iconSizeLarge + 4,
                    width: AppTheme.iconSizeLarge + 4,
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    radius: 14,
                  ),
                  Image.asset(
                    'images/notif.png',
                    height: AppTheme.iconSizeLarge + 4,
                    width: AppTheme.iconSizeLarge + 4,
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingXLarge),
            ],
          ),
        ),
      ],
    );
  }
}