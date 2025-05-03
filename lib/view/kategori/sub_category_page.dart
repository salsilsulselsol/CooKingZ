import 'package:flutter/material.dart';
import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:masak2/models/food_model.dart'; // Import the Food model
import 'package:masak2/view/component/food_card_widget.dart'; // Import the FoodCard widget

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  // Define app colors
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color emeraldGreen = const Color(0xFF015551);

  // Lista navigasi tab (di bawah 'Sarapan')
  final List<String> _categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Vegan',
    'Halal',
  ];

  // Index tab yang aktif
  int _selectedCategoryIndex = 0;

  // Data makanan untuk kategori sarapan - converted to Food objects
  late List<Food> _breakfastFoods;

  @override
  void initState() {
    super.initState();
    // Initialize the breakfast foods list with Food objects
    _breakfastFoods = [
      Food(
        name: 'Eggs Benedict',
        description: 'Muffin dengan Bacon Kanada',
        image: 'images/eggs_benedict.png',
        duration: '45 menit',
        price: '30RB',
        likes: 12,
      ),
      Food(
        name: 'French Toast',
        description: 'Irisan roti yang lezat',
        image: 'images/french_toast.png',
        duration: '15 menit',
        price: '25RB',
        likes: 24,
      ),
      Food(
        name: 'Oatmeal & Kacang',
        description: 'Campuran sehat untuk sarapan',
        image: 'images/oatmeal_kacang.png',
        duration: '20 menit',
        price: '25RB',
        likes: 14,
      ),
      Food(
        name: 'Telur Dadar',
        description: 'bertekstur dan alami',
        image: 'images/telur_dadar.png',
        duration: '30 menit',
        price: '15RB',
        likes: 85,
      ),
      Food(
        name: 'Oatmeal Stroberi',
        description: 'Siap santap dengan stroberi dan blueberry',
        image: 'images/oatmeal_stroberi.png',
        duration: '15 menit',
        price: '25RB',
        likes: 23,
      ),
      Food(
        name: 'Bruschetta',
        description: 'Roti panggang dengan topping segar',
        image: 'images/bruschetta.png',
        duration: '30 menit',
        price: '35RB',
        likes: 42,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan BottomNavbar untuk konsistensi dengan CategoryPage
    return BottomNavbar(
      _buildMainContent(),
    );
  }

  // Widget yang berisi konten utama
  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Menggunakan CustomHeader yang sudah diupdate
            CustomHeader(
              title: 'Sarapan',
              titleColor: primaryColor,
            ),
            _buildTabBar(),
            Expanded(
              child: _buildFoodGridView(),
            ),
          ],
        ),
      ),
    );
  }

  // Tab bar untuk kategori makanan
  Widget _buildTabBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _selectedCategoryIndex == index
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
                  _categories[index],
                  style: TextStyle(
                    color: _selectedCategoryIndex == index
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

  // Grid view for food items - now using the FoodCard widget
  Widget _buildFoodGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0.50,
        mainAxisSpacing: 5,
        childAspectRatio: 3 / 3.5,
      ),
      itemCount: _breakfastFoods.length,
      itemBuilder: (context, index) {
        return FoodCard(
          food: _breakfastFoods[index],
          onFavoritePressed: () {
            // Add logic for favorite button here
            setState(() {
              // You could toggle a favorite status here
              // Example: _breakfastFoods[index].isFavorite = !_breakfastFoods[index].isFavorite;
            });
          },
          onCardTap: () {
            // Add navigation to detail page or other action when card is tapped
            // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailPage(food: _breakfastFoods[index])));
          },
        );
      },
    );
  }
}