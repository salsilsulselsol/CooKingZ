import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:masak2/view/component/back_button_widget.dart';
import '../../../models/follower_user_model.dart'; 

class MengikutiPengikut extends StatefulWidget {
  const MengikutiPengikut({super.key});

  @override
  State<MengikutiPengikut> createState() => _MengikutiPengikutState();
}

class _MengikutiPengikutState extends State<MengikutiPengikut> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<FollowerUser> _followingList = [];
  List<FollowerUser> _followersList = [];
  bool _isLoadingFollowing = true;
  bool _isLoadingFollowers = true;
  
  // Asumsi profil yang dilihat adalah profil kita sendiri (ID 1)
  final int _profileUserId = 1; 
  String _profileUsername = 'memuat...';
  // Asumsi pengguna yang sedang login adalah ID 1
  final int _loggedInUserId = 1; 
  
  bool _hasMadeChanges = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi TabController dengan index awal dari argumen navigasi
    final int initialIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // Ambil semua data yang diperlukan saat halaman dibuka
    _fetchUsername();
    _fetchFollowingList();
    _fetchFollowersList();
  }

  Future<void> _fetchUsername() async {
    final baseUrl = dotenv.env['BASE_URL'];
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$_profileUserId'));
      if(mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
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
      final response = await http.get(Uri.parse('$baseUrl/users/$_profileUserId/following'));
       if(mounted && response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        setState(() {
          _followingList = body.map((data) => FollowerUser.fromJson(data)).toList();
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
      final response = await http.get(Uri.parse('$baseUrl/users/$_profileUserId/followers'));
       if(mounted && response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        setState(() {
          _followersList = body.map((data) => FollowerUser.fromJson(data)).toList();
        });
      }
    } catch(e) {
      print("Error fetching followers list: $e");
    } finally {
      if(mounted) setState(() => _isLoadingFollowers = false);
    }
  }

  Future<void> _toggleFollow(FollowerUser userToToggle) async {
    final originalStatus = userToToggle.isFollowing;
    
    // Optimistic UI update
    setState(() {
      userToToggle.isFollowing = !originalStatus;
    });

    final baseUrl = dotenv.env['BASE_URL'];
    final action = userToToggle.isFollowing ? 'follow' : 'unfollow';
    final url = Uri.parse('$baseUrl/users/${userToToggle.id}/$action');
    
    try {
      // Panggil API
      final response = await http.post(url);
      if (response.statusCode != 200) {
        throw Exception('Gagal follow/unfollow user');
      }
      // Jika berhasil, tandai bahwa ada perubahan
      _hasMadeChanges = true;
    } catch (e) {
       // Jika gagal, kembalikan state UI ke semula
       if(mounted) {
        setState(() {
          userToToggle.isFollowing = originalStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal, periksa koneksi Anda.'), backgroundColor: Colors.red),
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
                  _buildUserListView(list: _followingList, isLoading: _isLoadingFollowing),
                  _buildUserListView(list: _followersList, isLoading: _isLoadingFollowers),
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
    final imagePath = user.profilePicture?.startsWith('/') ?? false
        ? user.profilePicture
        : '/${user.profilePicture}';

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
            ? NetworkImage('$baseUrl$imagePath')
            : const AssetImage('images/default_avatar.png') as ImageProvider,
      ),
      title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('@${user.username}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: _buildFollowButton(user),
    );
  }
  
  Widget _buildFollowButton(FollowerUser user) {
    // Jangan tampilkan tombol untuk profil kita sendiri jika muncul di list
    if (user.id == _loggedInUserId) {
      return const SizedBox(width: 48); // Beri ruang kosong agar sejajar
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