import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final Function(String) onSubmitted;
  final Function()? onFilterPressed;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Search...',
    required this.onSubmitted,
    this.onFilterPressed,
    this.controller,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Field
        Expanded(
          flex: 5,
          child: Container(
            margin: AppTheme.marginSearchBar,
            decoration: BoxDecoration(
              color: AppTheme.searchBarColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
              boxShadow: [AppTheme.boxShadowSmall],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTheme.searchHintStyle,
                suffixIcon: Image.asset(
                  'images/search.png',
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.search, color: Colors.white, size: 20);
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppTheme.paddingSearchBar.vertical / 2,
                  horizontal: AppTheme.paddingSearchBar.horizontal + 10,
                ),
                border: InputBorder.none,
              ),
              autofocus: autofocus,
              onSubmitted: onSubmitted,
            ),
          ),
        ),
        // Filter Button
        GestureDetector(
          onTap: onFilterPressed,
          child: Container(
            margin: AppTheme.marginFilterButton,
            width: AppTheme.filterButtonSize,
            height: AppTheme.filterButtonSize,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Center(
              child: Image.asset(
                'images/filter.png',
                width: AppTheme.iconSizeLarge,
                height: AppTheme.iconSizeLarge,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.filter_list, color: Colors.white, size: 24);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}