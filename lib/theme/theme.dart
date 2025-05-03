import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color textBrown = Color(0xFF3E2823);
  static const Color searchBarColor = Color(0xFF9FD5DB);
  static const Color backgroundColor = Colors.white;
  
  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
  
  static const TextStyle foodTitleStyle = TextStyle(
    color: textBrown,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle foodDescriptionStyle = TextStyle(
    color: textBrown,
    fontSize: 10,
  );
  
  static const TextStyle foodInfoStyle = TextStyle(
    color: accentTeal,
    fontSize: 10,
  );
  
  static const TextStyle foodPriceStyle = TextStyle(
    color: accentTeal,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle searchHintStyle = TextStyle(
    color: Colors.white,
  );
  
  // Sizes
  static const double iconSizeSmall = 10.0;
  static const double iconSizeMedium = 16.0;
  static const double iconSizeLarge = 24.0;
  
  static const double foodCardImageHeight = 160.0;
  static const double favoriteButtonSize = 30.0;
  static const double favoriteIconSize = 30.0;
  
  static const double searchBarHeight = 50.0;
  static const double filterButtonSize = 50.0;
  static const double backButtonSize = 30.0;
  
  // Spacing
  static const double spacingXSmall = 1.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 10.0;
  static const double spacingXLarge = 16.0;
  static const double spacingXXLarge = 20.0;
  
  // Border Radius
  static const double borderRadiusSmall = 10.0;
  static const double borderRadiusMedium = 14.0;
  static const double borderRadiusLarge = 15.0;
  static const double borderRadiusXLarge = 30.0;
  
  // Border Width
  static const double borderWidth = 1.0;
  
  // Shadow
  static BoxShadow boxShadowSmall = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    spreadRadius: 1,
    blurRadius: 3,
  );
  
  // Paddings
  static const EdgeInsets paddingHeader = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets paddingSearchBar = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets paddingFoodGrid = EdgeInsets.symmetric(horizontal: 2, vertical: 20);
  static const EdgeInsets paddingFoodCardContent = EdgeInsets.only(bottom: 8, left: 10, right: 10);
  static const EdgeInsets paddingFoodCardInfo = EdgeInsets.symmetric(horizontal: 4, vertical: 4);
  
  // Margins
  static const EdgeInsets marginFoodCard = EdgeInsets.only(right: 10, left: 10, bottom: 0);
  static const EdgeInsets marginSearchBar = EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10);
  static const EdgeInsets marginFilterButton = EdgeInsets.only(right: 16, top: 10, bottom: 10);
  
  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridCrossAxisSpacing = 0.50;
  static const double gridMainAxisSpacing = 5.0;
  static const double gridChildAspectRatio = 3 / 3.5;

  // Recipe Card
  static const double recipeCardBorderRadius = 12.0;

  // Resep Anda Page
  static const double mostViewedContainerPadding = 16.0;
}