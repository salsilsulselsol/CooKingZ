// File: lib/view/home/hasil_pencarian.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme.dart';
import '../../models/food_model.dart'; 
import '../../models/user_profile_model.dart'; 
import '../../models/category_model.dart'; 

import '../component/search_bar_widget.dart'; 
import '../component/food_card_widget.dart'; 
import '../component/bottom_navbar.dart'; 
import '../component/custom_appbar.dart'; 

import 'popup_filter.dart'; // Ini mengimpor showFilterDialog

class HasilPencaharian extends StatefulWidget { // NAMA KELAS YANG BENAR
  final Map<String, dynamic> initialSearchParams;

  const HasilPencaharian({Key? key, this.initialSearchParams = const {}}) : super(key: key);

  @override
  State<HasilPencaharian> createState() => _HasilPencaharianState(); // NAMA STATE YANG BENAR
}

class _HasilPencaharianState extends State<HasilPencaharian> { // NAMA STATE YANG BENAR
  final TextEditingController _searchController = TextEditingController();
  List<Food> _searchResults = [];
  bool _isLoading = false; 
  bool _hasError = false;
  String _errorMessage = '';

  Map<String, dynamic> _currentSearchParams = {};

  final String _baseUrl = 'http://192.168.100.44:3000'; 

  @override
  void initState() {
    super.initState();
    print('DEBUG HASIL_PENCARIAN: initState dipanggil.');
    _currentSearchParams = Map<String, dynamic>.from(widget.initialSearchParams);
    print('DEBUG HASIL_PENCARIAN: initialSearchParams: ${widget.initialSearchParams}');
    
    _searchController.text = _currentSearchParams['keyword'] ?? '';
    print('DEBUG HASIL_PENCARIAN: Search bar keyword: ${_searchController.text}');
    
    _fetchSearchResults(_currentSearchParams); // Lakukan pencarian awal
  }

  @override
  void dispose() {
    print('DEBUG HASIL_PENCARIAN: dispose dipanggil.');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSearchResults(Map<String, dynamic> params) async {
    print('DEBUG HASIL_PENCARIAN: _fetchSearchResults dipanggil dengan params: $params');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _searchResults = []; 
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final Map<String, String> queryParams = {};
      if (params['keyword'] != null && params['keyword'].isNotEmpty) {
        queryParams['keyword'] = params['keyword'];
      }
      if (params['categories'] != null && (params['categories'] as List).isNotEmpty) {
        queryParams['category_name'] = (params['categories'] as List<String>)[0]; 
      }

      if (params['difficulty'] != null && params['difficulty'] != 'Semua') {
        queryParams['difficulty'] = params['difficulty'];
      }
      if (params['min_rating'] != null && params['min_rating'] > 0) {
        queryParams['min_rating'] = params['min_rating'].toString();
      }
      if (params['max_price'] != null && params['max_price'] < 100000.0) { 
        queryParams['max_price'] = params['max_price'].toString();
      }
      if (params['max_time'] != null && params['max_time'] < 180.0) { 
        queryParams['max_time'] = params['max_time'].toString();
      }
      
      queryParams['limit'] = '20'; 
      queryParams['offset'] = '0'; 

      final uri = Uri.parse('$_baseUrl/home/search').replace(queryParameters: queryParams);
      print('DEBUG HASIL_PENCARIAN: Searching URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG HASIL_PENCARIAN: Search API Status Code: ${response.statusCode}');
      print('DEBUG HASIL_PENCARIAN: Search API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> recipeList = responseData['data']; 

        setState(() {
          _searchResults = recipeList.map((jsonItem) => Food.fromJson(jsonItem)).toList();
          _isLoading = false;
        });
        print('DEBUG HASIL_PENCARIAN: Search results parsed. Count: ${_searchResults.length}');
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal memuat hasil pencarian: ${response.statusCode} ${response.reasonPhrase}';
          _isLoading = false;
        });
        print('[ERROR] Search API failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan saat pencarian: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] Error during search: $e');
    }
  }

  Future<void> _onFilterButtonTapped() async {
    print('DEBUG HASIL_PENCARIAN: Filter button tapped. Current params: $_currentSearchParams');
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterPopup(initialParams: _currentSearchParams), 
    );

    if (result != null) {
      print('DEBUG HASIL_PENCARIAN: Filter result received: $result');
      setState(() {
        _currentSearchParams.addAll(result); 
        _currentSearchParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
      });
      _fetchSearchResults(_currentSearchParams); 
    } else {
      print('DEBUG HASIL_PENCARIAN: Filter dialog closed without result.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG HASIL_PENCARIAN: build method dipanggil. isLoading: $_isLoading, hasError: $_hasError, searchResults.length: ${_searchResults.length}');
    return BottomNavbar( 
      Scaffold(
        appBar: CustomAppBar(
          title: 'Hasil Pencarian', 
          onBackPressed: () {
            print('DEBUG HASIL_PENCARIAN: Back button pressed.');
            Navigator.pop(context); 
          }, 
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingXLarge),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Cari Resep...',
                onSearchSubmitted: (keyword) {
                  print('DEBUG HASIL_PENCARIAN: Search submitted: $keyword');
                  setState(() {
                    _currentSearchParams['keyword'] = keyword;
                    _currentSearchParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
                  });
                  _fetchSearchResults(_currentSearchParams); 
                },
                onFilterTap: _onFilterButtonTapped, 
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada resep ditemukan.', 
                                style: TextStyle(fontSize: 16, color: AppTheme.textBrown), 
                              )
                            )
                          : GridView.builder( 
                              padding: EdgeInsets.all(AppTheme.spacingXLarge),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppTheme.spacingMedium,
                                mainAxisSpacing: AppTheme.spacingMedium,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final recipe = _searchResults[index];
                                return FoodCard( 
                                  food: recipe,
                                  onCardTap: () {
                                    if (recipe.id != null) {
                                      print('DEBUG HASIL_PENCARIAN: Tapped recipe ID: ${recipe.id}');
                                      Navigator.pushNamed(context, '/detail-resep/${recipe.id}'); 
                                    } else {
                                      print('ERROR: Recipe ID is null for search result at index $index.');
                                    }
                                  },
                                  onFavoritePressed: () {
                                    print('Favorite pressed for ${recipe.name}');
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}