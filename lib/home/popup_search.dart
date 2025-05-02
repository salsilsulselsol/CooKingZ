import 'package:flutter/material.dart';
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFb0dcdc),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xFF035E53)),
                          ),
                        ),
                      ),
                      Container(
                        child: Image.asset(
                          'images/search.png',
                          width: 35,
                          height: 35,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showFilterDialog(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF035E53),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Rekomendasi Resep',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF035E53),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
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
          const SizedBox(height: 24),
            ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/hasil-pencarian');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF035E53),
              backgroundColor: const Color(0xFFb0dcdc),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
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
      selectedColor: const Color(0xFF035E53),
      backgroundColor: const Color(0xFFb0dcdc),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF035E53),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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


// Function to show the bottom sheet
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
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