import 'package:flutter/material.dart';

class CategoryTabBar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final Color primaryColor;

  const CategoryTabBar({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: primaryColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Colors.white
                        : primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}