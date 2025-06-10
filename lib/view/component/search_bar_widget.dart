import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../home/popup_filter.dart'; // pastikan path ini sesuai struktur folder kamu

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Cari',
    this.onSubmitted,
    this.controller,
    this.autofocus = false, required void Function() onFilterPressed,
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
                    onSubmitted: onSubmitted,
                    autofocus: autofocus,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'images/search.png',
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.search, color: Colors.white);
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        // Filter Button
        GestureDetector(
          onTap: () {
            showFilterDialog(context);
          },
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
