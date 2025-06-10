import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../component/grid_2_builder.dart';
import '../component/header_back.dart';
import '../component/search_bar_widget.dart';
import '../home/popup_filter.dart'; // Import filter dialog
import '../../models/food_model.dart';

class HasilPencaharian extends StatefulWidget {
  const HasilPencaharian({super.key});

  @override
  State<HasilPencaharian> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<HasilPencaharian> {
  final TextEditingController _searchController = TextEditingController();

  // Data makanan untuk hasil pencarian (contoh data)
  final List<Map<String, dynamic>> _searchResultsData = [
    {
      'name': 'Telur Gulung',
      'description': 'Telur dengan Roti Kanada',
      'image': 'images/telur_gulung.png',
      'cookingTime': 15,
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Roti Telur',
      'description': 'Irisan roti yang lezat',
      'image': 'images/roti_telur.png',
      'cookingTime': 15,
      'price': '20RB',
      'likes': 5,
    },
    {
      'name': 'Pudding Telur',
      'description': 'Campuran sehat untuk sarapan',
      'image': 'images/pudding_telur.png',
      'cookingTime': 15,
      'price': '20RB',
      'likes': 12,
    },
    {
      'name': 'Pizza Telur',
      'description': 'Pesona pedesaan yang bertekstur dan alami',
      'image': 'images/pizza_telur.png',
      'cookingTime': 15,
      'price': '20RB',
      'likes': 7,
    },
    {
      'name': 'Oatmeal Telur',
      'description': 'Menggabungkan oatmeal dengan telur',
      'image': 'images/oatmeal_telur.png',
      'cookingTime': 34,
      'price': '20RB',
      'likes': 34,
    },
    {
      'name': 'Telur Roti Panggang',
      'description': 'Roti panggang dengan telur',
      'image': 'images/telur_roti_panggang.png',
      'cookingTime': 34,
      'price': '18RB',
      'likes': 32,
    },
  ];

  // Konversi ke List<Food>
  late List<Food> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = _searchResultsData.map((item) => Food.fromMap(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            HeaderWidget(
              title: 'Hasil Pencarian',
              onBackPressed: () => Navigator.pop(context),
            ),

            // Search Bar + Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBarWidget(
                hintText: 'Telur',
                controller: _searchController,
                onSubmitted: _handleSearch,
                onFilterPressed: _handleFilterPress,
              ),
            ),

            // Grid hasil pencarian
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

  // Fungsi pencarian
  void _handleSearch(String query) {
    print('Searching for: $query');
    setState(() {
      _searchResults = _searchResultsData
          .map((item) => Food.fromMap(item))
          .where((food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              (food.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    });
  }

  // Fungsi filter
  void _handleFilterPress() {
    print('Filter button pressed');
    showFilterDialog(context);
  }

  // Fungsi favorit
  void _handleFavoritePress(int index) {
    print('Favorite pressed for ${_searchResults[index].name}');
  }

  // Fungsi detail resep
  void _handleCardTap(int index) {
    print('Card pressed for ${_searchResults[index].name}');
    Navigator.pushNamed(
      context,
      '/detail-resep',
      arguments: _searchResults[index],
    );
  }
}
