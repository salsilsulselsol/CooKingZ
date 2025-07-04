import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masak2/view/profile/profil/profil_utama.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:masak2/view/component/bottom_navbar.dart';
import 'package:masak2/view/component/header_b_n_s.dart';
import 'package:masak2/view/component/grid_pengguna.dart';
import '../../theme/theme.dart';
import '../../models/user_profile_model.dart';

class PenggunaTerbaik extends StatefulWidget {
  const PenggunaTerbaik({super.key});

  @override
  State<PenggunaTerbaik> createState() => _PenggunaTerbaikState();
}

class _PenggunaTerbaikState extends State<PenggunaTerbaik> {
  List<UserProfile> _popularUsers = [];
  List<UserProfile> _latestUsers = [];
  int? _currentUserId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final String _baseUrl = 'http://localhost:3000'; // Replace with your backend URL

  @override
  void initState() {
    super.initState();
    _fetchAllUsersData();
  }

  Future<void> _fetchAllUsersData() async {
    print('DEBUG PTERBAIK: Starting to fetch all user data...');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Get current user ID
      setState(() {
        _currentUserId = prefs.getInt('id');
      });

      // --- Fetch Best Users (from /users/best endpoint) ---
      final uriBestUsers = Uri.parse('$_baseUrl/users/best');
      final responseBestUsers = await http.get(
        uriBestUsers,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (responseBestUsers.statusCode == 200) {
        final Map<String, dynamic> responseDataBestUsers = json.decode(responseBestUsers.body);
        _popularUsers = (responseDataBestUsers['data'] as List)
            .map((jsonItem) => UserProfile.fromJson(jsonItem))
            .toList();
        print('DEBUG PTERBAIK: Best users parsed successfully. Count: ${_popularUsers.length}');
      } else {
        print('[ERROR] PTERBAIK: Failed to load best users: ${responseBestUsers.statusCode} ${responseBestUsers.body}');
        _hasError = true;
        _errorMessage = 'Failed to load best users.';
      }

      // --- Fetch Latest Users (from /users/latest endpoint) ---
      final uriLatestUsers = Uri.parse('$_baseUrl/users/latest');
      final responseLatestUsers = await http.get(
        uriLatestUsers,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (responseLatestUsers.statusCode == 200) {
        final Map<String, dynamic> responseDataLatestUsers = json.decode(responseLatestUsers.body);
        _latestUsers = (responseDataLatestUsers['data'] as List)
            .map((jsonItem) => UserProfile.fromJson(jsonItem))
            .toList();
        print('DEBUG PTERBAIK: Latest users parsed successfully. Count: ${_latestUsers.length}');
      } else {
        print('[ERROR] PTERBAIK: Failed to load latest users: ${responseLatestUsers.statusCode} ${responseLatestUsers.body}');
        _hasError = true;
        _errorMessage = 'Failed to load latest users.';
      }

      setState(() {
        _isLoading = false;
        if (_hasError) {
          _errorMessage = _errorMessage.isEmpty ? 'Failed to load user data.' : _errorMessage;
        }
      });
      print('DEBUG PTERBAIK: Finished fetching all user data.');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error occurred while loading user data: $e';
        _isLoading = false;
      });
      print('[EXCEPTION] PTERBAIK: Error fetching all users: $e');
    }
  }

  Future<void> _toggleFollow(int userId) async {
    print('DEBUG PTERBAIK: Toggle follow for user ID: $userId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Follow/Unfollow user ID $userId (not implemented yet)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG PTERBAIK: build method called. isLoading: $_isLoading, hasError: $_hasError');
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomHeader(
                title: 'Pengguna Terbaik',
                titleColor: AppTheme.primaryColor,
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
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 320,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Pengguna Populer", isGreenBackground: true),
                            _buildHorizontalUserList(_popularUsers, useGreenBackground: true),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: AppTheme.spacingXXLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Pengguna Terbaru", isGreenBackground: false),
                            _buildVerticalUsersGrid(_latestUsers, useGreenBackground: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 90),
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

  Widget _buildSectionTitle(String title, {bool isGreenBackground = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingXXLarge + 10,
        top: AppTheme.spacingLarge,
        bottom: AppTheme.spacingMedium,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isGreenBackground ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildHorizontalUserList(List<UserProfile> users, {required bool useGreenBackground}) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Text(
            'No users found.',
            style: TextStyle(color: useGreenBackground ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge + 10),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userProfile = users[index];
          return ChefCard(
            user: userProfile,
            isFollowing: false,
            onFollowToggle: () => _toggleFollow(userProfile.id),
            useGreenBackground: useGreenBackground,
            onTap: () {
              if (userProfile.id == _currentUserId) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ProfilUtama(),
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfilUtama(userId: userProfile.id),
                ));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildVerticalUsersGrid(List<UserProfile> users, {required bool useGreenBackground}) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Text(
            'No users found.',
            style: TextStyle(color: useGreenBackground ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingMedium,
          mainAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 0.75,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userProfile = users[index];
          return ChefCard(
            user: userProfile,
            isFollowing: userProfile.isFollowedByMe,
            onFollowToggle: () => _toggleFollow(userProfile.id),
            useGreenBackground: useGreenBackground,
            onTap: () {
              if (userProfile.id == _currentUserId) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ProfilUtama(),
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfilUtama(userId: userProfile.id),
                ));
              }
            },
          );
        },
      ),
    );
  }
}