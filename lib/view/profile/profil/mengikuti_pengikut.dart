// lib/view/profile/profil/mengikuti_pengikut.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert';
import 'package:masak2/view/component/back_button_widget.dart';
import '../../../models/follower_user_model.dart'; 

class MengikutiPengikut extends StatefulWidget {
  // 1. Terima userId dari halaman profil
  final int userId; 
  const MengikutiPengikut({super.key, required this.userId});

  @override
  State<MengikutiPengikut> createState() => _MengikutiPengikutState();
}

class _MengikutiPengikutState extends State<MengikutiPengikut> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<FollowerUser> _followingList = [];
  List<FollowerUser> _followersList = [];
  List<FollowerUser> _filteredFollowingList = [];
  List<FollowerUser> _filteredFollowersList = [];

  bool _isLoadingFollowing = true;
  bool _isLoadingFollowers = true;
  
  String _profileUsername = 'memuat...';
  int? _loggedInUserId; 
  
  bool _hasMadeChanges = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterLists);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int initialIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _initializeAndFetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_filterLists);
    _searchController.dispose();
    super.dispose();
  }

  // 2. Tambahkan helper untuk mendapatkan header otentikasi
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<void> _initializeAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _loggedInUserId = prefs.getInt('user_id');
      });
    }
    // Ambil semua data yang diperlukan
    _fetchUsername();
    _fetchFollowingList();
    _fetchFollowersList();
  }

  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollowingList = _followingList.where((user) {
        return user.fullName.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);
      }).toList();
      _filteredFollowersList = _followersList.where((user) {
        return user.fullName.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchUsername() async {
    final baseUrl = dotenv.env['BASE_URL'];
    try {
      final headers = await _getAuthHeaders(); // <-- Gunakan token
      final response = await http.get(Uri.parse('$baseUrl/users/${widget.userId}'), headers: headers); // <-- Gunakan widget.userId
      if(mounted && response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() { _profileUsername = data['username'] ?? 'Tidak Ditemukan'; });
      }
    } catch(e) {
      print("Error fetching username: $e");
    }
  }

  Future<void> _fetchFollowingList() async {
    if (!mounted) return;
    setState(() => _isLoadingFollowing = true);
    final baseUrl = dotenv.env['BASE_URL'];
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/users/${widget.userId}/following'), headers: headers);
      
      if(mounted && response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        
        // ==== LOG DEBUG ====
        print('[DEBUG] RAW JSON from /following: $responseBody');
        
        final List<dynamic> body = responseBody['data'];
        setState(() {
          _followingList = body.map((data) => FollowerUser.fromJson(data)).toList();
          _filteredFollowingList = _followingList;
        });
      }
    } catch(e) {
      print("Error fetching following list: $e");
    } finally {
      if(mounted) setState(() => _isLoadingFollowing = false);
    }
  }

  Future<void> _fetchFollowersList() async {
    if (!mounted) return;
    setState(() => _isLoadingFollowers = true);
    final baseUrl = dotenv.env['BASE_URL'];
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/users/${widget.userId}/followers'), headers: headers);

      if(mounted && response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // ==== LOG DEBUG ====
        print('[DEBUG] RAW JSON from /followers: $responseBody');
        
        final List<dynamic> body = responseBody['data'];
        setState(() {
          _followersList = body.map((data) => FollowerUser.fromJson(data)).toList();
          _filteredFollowersList = _followersList;
        });
      }
    } catch(e) {
      print("Error fetching followers list: $e");
    } finally {
      if(mounted) setState(() => _isLoadingFollowers = false);
    }
  }

  Future<void> _toggleFollow(FollowerUser userToToggle) async {
    if (_loggedInUserId == null) return; // Jangan lakukan apa-apa jika tidak login

    final originalStatus = userToToggle.isFollowing;
    
    // Optimistic UI update
    setState(() {
      userToToggle.isFollowing = !originalStatus;
    });

    final baseUrl = dotenv.env['BASE_URL'];
    final action = userToToggle.isFollowing ? 'follow' : 'unfollow';
    final url = Uri.parse('$baseUrl/users/${userToToggle.id}/$action');
    
    try {
      final headers = await _getAuthHeaders(); // <-- Gunakan token
      final response = await http.post(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Gagal follow/unfollow user: ${response.body}');
      }
      _hasMadeChanges = true;
      // Refresh list yang relevan setelah berhasil
      if (widget.userId == _loggedInUserId && action == 'unfollow') {
         _fetchFollowingList();
      }
    } catch (e) {
       if(mounted) {
        setState(() {
          userToToggle.isFollowing = originalStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButtonWidget(
          onPressed: () => Navigator.of(context).pop(_hasMadeChanges),
        ),
        title: Text(
          '@$_profileUsername',
          style: const TextStyle(color: Color(0xFF015551), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF006257),
          indicatorWeight: 3,
          tabs: [
            Tab(text: '${_followingList.length} Mengikuti'),
            Tab(text: '${_followersList.length} Pengikut'),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(_hasMadeChanges);
          return true;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserListView(list: _filteredFollowingList, isLoading: _isLoadingFollowing),
                  _buildUserListView(list: _filteredFollowersList, isLoading: _isLoadingFollowers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListView({required List<FollowerUser> list, required bool isLoading}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return const Center(child: Text('Daftar kosong.'));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(FollowerUser user) {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final imagePath = (user.profilePicture != null && user.profilePicture!.isNotEmpty)
      ? (user.profilePicture!.startsWith('/') ? user.profilePicture : '/${user.profilePicture}')
      : null;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: (imagePath != null)
            ? NetworkImage('$baseUrl$imagePath')
            : const AssetImage('images/default_avatar.png') as ImageProvider,
      ),
      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('@${user.username}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: _buildFollowButton(user),
    );
  }
  
  Widget _buildFollowButton(FollowerUser user) {
    if (user.id == _loggedInUserId) {
      return const SizedBox(width: 90); // Beri ruang kosong agar sejajar
    }
    return ElevatedButton(
      onPressed: () => _toggleFollow(user),
      style: ElevatedButton.styleFrom(
        foregroundColor: user.isFollowing ? Colors.black : Colors.white,
        backgroundColor: user.isFollowing ? Colors.grey[200] : const Color(0xFF006257),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: user.isFollowing 
              ? BorderSide(color: Colors.grey[400]!)
              : BorderSide.none,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
      ),
      child: Text(user.isFollowing ? 'Mengikuti' : 'Ikuti'),
    );
  }
}