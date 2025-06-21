// File: lib/view/home/search_popup.dart

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'popup_filter.dart';
import '../component/search_bar_widget.dart';

class SearchPopup extends StatefulWidget {
  const SearchPopup({Key? key}) : super(key: key);

  @override
  _RecipeRecommendationsBottomSheetState createState() => _RecipeRecommendationsBottomSheetState();
}

class _RecipeRecommendationsBottomSheetState extends State<SearchPopup> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> selectedCategories = {};
  Map<String, dynamic> _filterParams = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilterAndGetParams() async {
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterPopup(initialParams: _filterParams),
    );

    if (result != null) {
      setState(() {
        _filterParams = result;
      });
      print('DEBUG: Filter params received: $_filterParams');
    }
  }

  void _performSearch([String? recommendationKeyword]) {
    final String keyword = recommendationKeyword ?? _searchController.text;

    final Map<String, dynamic> searchParams = {
      'keyword': keyword.isNotEmpty ? keyword : null,
      'categories': selectedCategories.isNotEmpty ? selectedCategories.toList() : null,
      ..._filterParams,
    };

    searchParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty));

    print('DEBUG: Performing search with params from SearchPopup: $searchParams');

    Navigator.of(context).pushNamed(
      '/hasil-pencarian',
      arguments: searchParams,
    );
  }

  Widget _buildFilterSummary() {
    if (_filterParams.isEmpty) return const SizedBox.shrink();

    List<Widget> chips = [];

    _filterParams.forEach((key, value) {
      if (value == null) return;
      String label = '';

      if (key == 'allergens' && value is List) {
        label = 'Alergen: ${(value as List).join(', ')}';
      } else if (key == 'difficulty') {
        label = 'Kesulitan: $value';
      } else if (key == 'min_rating') {
        label = 'Rating ≥ $value';
      } else if (key == 'max_price') {
        label = 'Harga ≤ $value';
      } else if (key == 'max_time') {
        label = 'Durasi ≤ $value menit';
      } else {
        label = '$key: $value';
      }

      chips.add(
        Chip(
          label: Text(label),
          backgroundColor: AppTheme.searchBarColor,
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Filter aktif:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: chips,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingXXLarge,
        AppTheme.spacingXLarge,
        AppTheme.spacingXXLarge,
        AppTheme.spacingXXLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 16),

          SearchBarWidget(
            controller: _searchController,
            hintText: 'Cari resep...',
            onSearchSubmitted: (_) => _performSearch(),
            onFilterTap: _showFilterAndGetParams,
          ),
          const SizedBox(height: 12),

          _buildFilterSummary(),
          const SizedBox(height: 20),

          Text('Rekomendasi Resep', style: AppTheme.headerStyle),
          const SizedBox(height: 12),

          Wrap(
            spacing: AppTheme.spacingMedium,
            runSpacing: AppTheme.spacingLarge,
            children: [
              for (var category in [
                'Soto', 'Hamburger', 'Egg Rolls', 'Wraps',
                'Cheesecake', 'Tomato Soup', 'Parfait', 'Vegan', 'Baked Salmon'
              ])
                _buildRecommendationChip(category),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _performSearch,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppTheme.searchBarColor,
      labelStyle: TextStyle(color: AppTheme.primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
    );
  }
}

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
                bottom: AppTheme.spacingXXLarge),
            child: const SafeArea(
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
          begin: const Offset(0, -1),
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