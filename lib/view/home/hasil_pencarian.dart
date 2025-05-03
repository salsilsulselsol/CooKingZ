import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../component/grid_2_builder.dart';
import '../component/header_back.dart';
import '../component/search_bar_widget.dart';
import '../../models/food_model.dart';

class HasilPencaharian extends StatefulWidget {
  const HasilPencaharian({super.key});

  @override
  State<HasilPencaharian> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<HasilPencaharian> {
  // Data makanan untuk hasil pencarian (contoh data)
  final List<Map<String, dynamic>> _searchResultsData = [
    {
      'name': 'Telur Gulung',
      'description': 'Telur dengan Roti Kanada',
      'image': 'images/telur_gulung.png',
      'cookingTime': 15, // Menggunakan cookingTime, bukan duration
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Roti Telur',
      'description': 'Irisan roti yang lezat',
      'image': 'images/roti_telur.png',
      'cookingTime': 15, // Menggunakan cookingTime, bukan duration
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Pudding Telur',
      'description': 'Campuran sehat untuk sarapan',
      'image': 'images/pudding_telur.png',
      'cookingTime': 15, // Menggunakan cookingTime, bukan duration
      'price': '20RB',
      'likes': 12,
    },
    {
      'name': 'Pizza Telur',
      'description': 'Pesona pedesaan yang bertekstur dan alami',
      'image': 'images/pizza_telur.png',
      'cookingTime': 15, // Menggunakan cookingTime, bukan duration
      'price': '20RB',
      'likes': 7,
    },
    {
      'name': 'Oatmeal Telur',
      'description': 'menggabungkan oatmeal dengan telur',
      'image': 'images/oatmeal_telur.png',
      'cookingTime': 34, // Menggunakan cookingTime, bukan duration
      'price': '20RB',
      'likes': 34,
    },
    {
      'name': 'Telur Roti Panggang',
      'description': 'Roti panggang dengan telur',
      'image': 'images/telur_roti_panggang.png',
      'cookingTime': 34, // Menggunakan cookingTime, bukan duration
      'price': '18RB',
      'likes': 32,
    },
  ];

  // Konversi data Map ke List<Food>
  late List<Food> _searchResults;

  @override
  void initState() {
    super.initState();
    // Konversi data Map ke objek Food saat widget diinisialisasi
    _searchResults = _searchResultsData.map((item) => Food.fromMap(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Using HeaderWidget component
            HeaderWidget(
              title: 'Hasil Pencarian',
              onBackPressed: () => Navigator.pop(context),
            ),

            // Using SearchBarWidget component
            SearchBarWidget(
              hintText: 'Telur',
              onSubmitted: _handleSearch,
              onFilterPressed: _handleFilterPress,
            ),

            // Using FoodGridWidget component
            Expanded(
              child: FoodGridWidget(
                foods: _searchResults,
                onFavoritePressed: _handleFavoritePress,
                onCardTap: _handleCardTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handler untuk pencarian
  void _handleSearch(String query) {
    // Implementasi pencarian
    print('Searching for: $query');
    // Contoh implementasi:
    // setState(() {
    //   _searchResults = _allFoodItems
    //       .where((food) =>
    //           food.name.toLowerCase().contains(query.toLowerCase()) ||
    //           food.description.toLowerCase().contains(query.toLowerCase()))
    //       .toList();
    // });
  }

  // Handler untuk filter button
  void _handleFilterPress() {
    print('Filter button pressed');
    // Implementasi filter
    // Contoh: Tampilkan bottom sheet untuk filter
  }

  // Handler untuk tombol favorit
  void _handleFavoritePress(int index) {
    print('Favorite pressed for ${_searchResults[index].name}');
    // Implementasi favorite
    // setState(() {
    //   // Toggle favorite state or add to favorites list
    // });
  }

  // Handler untuk tap pada card
  void _handleCardTap(int index) {
    print('Card pressed for ${_searchResults[index].name}');
    // Navigasi ke halaman detail
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => FoodDetailPage(food: _searchResults[index]),
    //   ),
    // );
  }
}