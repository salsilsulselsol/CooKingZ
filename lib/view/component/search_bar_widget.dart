// File: lib/view/component/search_bar_widget.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onSearchSubmitted; // Callback saat pencarian disubmit
  final VoidCallback? onFilterTap; // Callback saat tombol filter ditekan

  const SearchBarWidget({
    Key? key,
    required this.controller,
    this.hintText = 'Cari',
    this.onSearchSubmitted,
    this.onFilterTap, // Menerima callback untuk filter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Input Field
        Expanded(
          child: Container(
            height: AppTheme.searchBarHeight,
            decoration: BoxDecoration(
              color: AppTheme.searchBarColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppTheme.primaryColor),
                    ),
                    onSubmitted: onSearchSubmitted, // Gunakan callback onSearchSubmitted
                  ),
                ),
                // Icon Search (bisa jadi tombol submit juga)
                GestureDetector(
                  onTap: () {
                    if (onSearchSubmitted != null) {
                      onSearchSubmitted!(controller.text); // Panggil callback submit
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                      'images/search.png',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.search, color: Colors.white);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        // Filter Button (hanya tampil jika callback diberikan)
        if (onFilterTap != null) // Tampilkan tombol filter hanya jika callbacknya diberikan
          GestureDetector(
            onTap: onFilterTap, // Memanggil callback onFilterTap
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.filterButtonSize / 2),
              ),
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Icon(
                Icons.filter_alt,
                color: AppTheme.backgroundColor,
                size: AppTheme.iconSizeMedium,
              ),
            ),
          ),
      ],
    );
  }
}