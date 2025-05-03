import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final Widget? rightWidget;

  const HeaderWidget({
    Key? key,
    required this.title,
    required this.onBackPressed,
    this.rightWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.paddingHeader,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol kembali dengan image asset
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: AppTheme.backButtonSize,
              height: AppTheme.backButtonSize,
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'images/arrow.png',
                width: AppTheme.iconSizeLarge,
                height: AppTheme.iconSizeLarge,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.arrow_back, color: AppTheme.primaryColor);
                },
              ),
            ),
          ),

          // Judul halaman
          Text(
            title,
            style: AppTheme.headerStyle,
          ),

          // Widget kanan opsional atau space kosong
          rightWidget ?? const SizedBox(width: AppTheme.backButtonSize),
        ],
      ),
    );
  }
}