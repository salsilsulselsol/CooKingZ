import 'package:flutter/material.dart';
import '../../theme/theme.dart'; // Import your theme
import 'popup_filter.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({Key? key}) : super(key: key);

  @override
  _RecipeRecommendationsBottomSheetState createState() =>
      _RecipeRecommendationsBottomSheetState();
}

class _RecipeRecommendationsBottomSheetState
    extends State<SearchPopup> {
  Set<String> selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
          bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          AppTheme.spacingXXLarge,
          AppTheme.spacingXLarge,
          AppTheme.spacingXXLarge,
          AppTheme.spacingXXLarge
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingXXLarge),

          // Search bar and filter button
          Row(
            children: [
              // Search bar
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.searchBarColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXLarge),
                  height: AppTheme.searchBarHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Image.asset(
                          'images/search.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingMedium),

              // Filter button
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
          ),
          SizedBox(height: AppTheme.spacingXXLarge),

          // Title
          Text(
            'Rekomendasi Resep',
            style: AppTheme.headerStyle,
          ),
          SizedBox(height: AppTheme.spacingXLarge),

          // Category chips
          Wrap(
            spacing: AppTheme.spacingMedium,
            runSpacing: AppTheme.spacingLarge,
            children: [
              for (var category in [
                'Soto',
                'Hamburger',
                'Egg Rolls',
                'Wraps',
                'Cheesecake',
                'Tomato Soup',
                'Parfait',
                'Vegan',
                'Baked Salmon'
              ])
                _buildCategoryChip(category),
            ],
          ),
          SizedBox(height: AppTheme.spacingXXLarge),

          // Search button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/hasil-pencarian');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.searchBarColor,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Cari',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = selectedCategories.contains(label);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.searchBarColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.backgroundColor : AppTheme.primaryColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedCategories.add(label);
          } else {
            selectedCategories.remove(label);
          }
        });
      },
    );
  }
}

// Function to show the popup
void showRecipeRecommendationsTopSheet(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'TopSheet',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
                bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.spacingXXLarge,
                left: AppTheme.spacingXXLarge,
                right: AppTheme.spacingXXLarge,
                bottom: AppTheme.spacingXXLarge
            ),
            child: SafeArea(
              bottom: false,
              child: SearchPopup(),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // from top
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
  );
}