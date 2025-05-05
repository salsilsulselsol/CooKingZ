import 'package:flutter/material.dart';
import 'package:masak2/view/home/popup_search.dart';
import 'package:masak2/view/component/trending_recipe_card.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/category_tab.dart';
import 'package:masak2/theme/theme.dart'; // Import the AppTheme

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  final List<String> mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Vegan',
    'Dessert',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(context),
              // Use the CategoryTabBar component
              CategoryTabBar(
                categories: mealTypes,
                selectedIndex: _selectedCategoryIndex,
                onCategorySelected: (index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                primaryColor: AppTheme.primaryColor,
              ),
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrendingRecipe(context),
                      _buildYourRecipes(
                        context,
                        'Resep Anda   >',
                        Colors.white,
                        AppTheme.primaryColor,
                      ),
                      _buildTopUsers(context),
                      _buildRecentlyAddedRecipe(
                        context,
                        'Baru Saja Ditambahkan',
                        AppTheme.primaryColor,
                        Colors.white,
                      ),
                      const SizedBox(height: 70), // Space for bottom navbar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top greeting and icons section
  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingXLarge,
        AppTheme.spacingXLarge,
        AppTheme.spacingXXLarge,
        AppTheme.spacingLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi! Siti',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              const Text(
                'Masak apa hari ini?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/notif');
                },
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/notif.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/penjadwalan');
                },
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/calendar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              GestureDetector(
                onTap: () {
                  showRecipeRecommendationsTopSheet(context);
                },
                child: Container(
                  width: AppTheme.favoriteButtonSize,
                  height: AppTheme.favoriteButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/search.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Trending Recipe section - Using the component
  Widget _buildTrendingRecipe(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingXLarge,
            right: AppTheme.spacingXXLarge,
            top: AppTheme.spacingMedium,
            bottom: AppTheme.spacingMedium,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/trending-resep');
            },
            child: Text(
              'Resep Trending   >',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        // Using the TrendingRecipeCard component
        TrendingRecipeCard(
          imagePath: 'images/croffle.png',
          title: 'Croffle Ice Cream',
          description: 'Berikut ringkasan bahan-bahannya...',
          favorites: '213',
          duration: '15menit',
          price: '20RB',
        ),
      ],
    );
  }

  // Your Recipes section
  Widget _buildYourRecipes(
      context,
      String recipesText,
      Color textColor,
      Color backgroundColor,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppTheme.spacingXLarge,
              right: AppTheme.spacingXXLarge,
              top: AppTheme.spacingXLarge,
              bottom: AppTheme.spacingXLarge,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/resep-anda');
              },
              child: Text(
                recipesText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          Container(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: AppTheme.spacingXLarge,
                right: AppTheme.spacingXLarge,
              ),
              children: [
                Center(
                  child: SizedBox(
                    width: 180,
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Gulai',
                        'image': 'images/gulai.jpg',
                        'likes': 15,
                        'duration': '50menit',
                        'price': '50RB',
                        'description': 'Gulai ayam dengan santan kental'
                      },
                      borderColor: Colors.white,
                      nameColor: Colors.white,
                      descriptionColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 180,
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Martabak Manis',
                        'image': 'images/martabak_manis.png',
                        'likes': 9,
                        'duration': '20menit',
                        'price': '30RB',
                        'description': 'Martabak dengan coklat dan keju'
                      },
                      borderColor: Colors.white,
                      nameColor: Colors.white,
                      descriptionColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacingXXLarge),
        ],
      ),
    );
  }

  Widget _buildRecentlyAddedRecipe(
      context,
      String recipesText,
      Color textColor,
      Color backgroundColor,
      ) {
    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppTheme.spacingXLarge,
              right: AppTheme.spacingXXLarge,
              top: AppTheme.spacingXLarge,
              bottom: AppTheme.spacingXLarge,
            ),
            child: Text(
              recipesText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Container(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: AppTheme.spacingXLarge,
                right: AppTheme.spacingXLarge,
              ),
              children: [
                Center(
                  child: SizedBox(
                    width: 180,
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Pasta',
                        'image': 'images/pasta.png',
                        'likes': 12,
                        'duration': '30menit',
                        'price': '40RB',
                        'description': 'Pasta dengan saus carbonara dan bacon'
                      },
                      borderColor: AppTheme.primaryColor,
                      nameColor: AppTheme.primaryColor,
                      descriptionColor: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 180,
                    child: _buildFoodCard(
                      context,
                      {
                        'name': 'Lemonade',
                        'image': 'images/lemon.png',
                        'likes': 7,
                        'duration': '10menit',
                        'price': '25RB',
                        'description': 'Minuman segar dengan lemon dan mint'
                      },
                      borderColor: AppTheme.primaryColor,
                      nameColor: AppTheme.primaryColor,
                      descriptionColor: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacingXXLarge),
        ],
      ),
    );
  }

  Widget _buildFoodCard(
      context,
      Map<String, dynamic> food, {
        Color borderColor = const Color(0xFF015551),
        Color nameColor = const Color(0xFF3E2823),
        Color descriptionColor = const Color(0xFF3E2823),
      }) {
    return IntrinsicHeight(
      child: Container(
        margin: AppTheme.marginFoodCard,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Food image with position settings
            Container(
              height: AppTheme.foodCardImageHeight,
              width: double.infinity,
              alignment: Alignment.topRight,
              child: Stack(
                children: [
                  // Food image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    child: Image.asset(
                      food['image'],
                      height: AppTheme.foodCardImageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite button (heart icon)
                  Positioned(
                    top: AppTheme.spacingMedium,
                    right: AppTheme.spacingMedium,
                    child: Container(
                      width: AppTheme.favoriteButtonSize,
                      height: AppTheme.favoriteButtonSize,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('images/love.png'),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide.none,
                    left: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                    right: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                    bottom: BorderSide(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
                    bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 0),
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name and Description
                    Container(
                      margin: EdgeInsets.only(
                        bottom: AppTheme.spacingSmall,
                        left: AppTheme.spacingLarge,
                        right: AppTheme.spacingLarge,
                        top: AppTheme.spacingSmall,
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'],
                            style: TextStyle(
                              color: nameColor,
                              fontSize: AppTheme.foodTitleStyle.fontSize,
                              fontWeight: AppTheme.foodTitleStyle.fontWeight,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            food['description'],
                            style: TextStyle(
                              color: descriptionColor,
                              fontSize: AppTheme.foodDescriptionStyle.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Likes, Duration, Price
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: 0,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Text(
                                food['likes'].toString(),
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontSize: AppTheme.foodInfoStyle.fontSize,
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              Icon(
                                Icons.star,
                                color: AppTheme.accentTeal,
                                size: AppTheme.iconSizeSmall,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppTheme.accentTeal,
                                size: AppTheme.iconSizeSmall,
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                food['duration'],
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontSize: AppTheme.foodInfoStyle.fontSize,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "RP",
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontSize: AppTheme.foodPriceStyle.fontSize,
                                  fontWeight: AppTheme.foodPriceStyle.fontWeight,
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                food['price'],
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontSize: AppTheme.foodInfoStyle.fontSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top Users section
  Widget _buildTopUsers(context) {
    final List<Map<String, String>> users = [
      {'name': 'Cecep', 'avatar': 'images/cecep.png'},
      {'name': 'Andre', 'avatar': 'images/andre.png'},
      {'name': 'Maya', 'avatar': 'images/miya.png'},
      {'name': 'Mila', 'avatar': 'images/mila.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacingXLarge,
            right: AppTheme.spacingXXLarge,
            top: AppTheme.spacingXLarge,
            bottom: AppTheme.spacingXLarge,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pengguna-terbaik');
            },
            child: Text(
              'Pengguna Terbaik   >',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: AppTheme.spacingXLarge,
              right: AppTheme.spacingXLarge,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: AppTheme.spacingXLarge),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE6F2F2),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage(users[index]['avatar']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      users[index]['name']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}