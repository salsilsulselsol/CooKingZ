import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'back_button_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: BackButtonWidget(onPressed: onBackPressed),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF006A4E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}