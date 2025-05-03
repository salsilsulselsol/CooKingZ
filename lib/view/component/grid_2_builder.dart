import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../theme/theme.dart';
import 'food_card_widget.dart';

class FoodGridWidget extends StatelessWidget {
  final List<Food> foods;
  final Function(int) onFavoritePressed;
  final Function(int) onCardTap;

  const FoodGridWidget({
    Key? key,
    required this.foods,
    required this.onFavoritePressed,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppTheme.paddingFoodGrid,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppTheme.gridCrossAxisCount,
        crossAxisSpacing: AppTheme.gridCrossAxisSpacing,
        mainAxisSpacing: AppTheme.gridMainAxisSpacing,
        childAspectRatio: AppTheme.gridChildAspectRatio,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        return FoodCard(
          food: foods[index],
          onFavoritePressed: () => onFavoritePressed(index),
          onCardTap: () => onCardTap(index),
        );
      },
    );
  }
}