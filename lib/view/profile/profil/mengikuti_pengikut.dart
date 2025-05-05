import 'package:flutter/material.dart';

import '../../component/back_button_widget.dart';

class MengikutiPengikut extends StatefulWidget {
  const MengikutiPengikut({super.key});

  @override
  State<MengikutiPengikut> createState() => _MengikutiPengikutState();
}

class _MengikutiPengikutState extends State<MengikutiPengikut> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _followingList = [
  {
    'username': '@bagus_pratama',
    'name': 'Bagus Pratama',
    'image': 'images/bagas.png',
    'isFollowing': true,
  },
  {
    'username': '@chef_maya',
    'name': 'Maya Cinta',
    'image': 'images/maya.png',
    'isFollowing': true,
  },
  {
    'username': '@danaos',
    'name': 'Danaos',
    'image': 'images/daniel.png',
    'isFollowing': true,
  },
  {
    'username': '@johuol',
    'name': 'Johuol',
    'image': 'images/joshua.png',
    'isFollowing': true,
  },
  {
    'username': '@yudapratama',
    'name': 'Yuda Pratama',
    'image': 'images/yuda.png',
    'isFollowing': true,
  },
  {
    'username': '@entin_cio',
    'name': 'Entin Cio',
    'image': 'images/entin_cio.png',
    'isFollowing': true,
  },
  {
    'username': '@ristarian',
    'name': 'Ristari Abrar',
    'image': 'images/rizki.png',
    'isFollowing': true,
  },
  {
    'username': '@daniel_santoso',
    'name': 'Daniel Santoso',
    'image': 'images/daniel.png',
    'isFollowing': true,
  },
  {
    'username': '@ridwansahra',
    'name': 'Riri Sahrini',
    'image': 'images/melisa.png',
    'isFollowing': true,
  },
  {
    'username': '@ayyu',
    'name': 'Ayu Lestari',
    'image': 'images/ayu.png',
    'isFollowing': true,
  },
];

final List<Map<String, dynamic>> _followersList = [
  {
    'username': '@sitisanti_',
    'name': 'Siti Santi',
    'image': 'images/siti.png',
    'isFollowing': true,
  },
  {
    'username': '@melisa_ayu',
    'name': 'Melisa Ayu',
    'image': 'images/melisa.png',
    'isFollowing': true,
  },
  {
    'username': '@alexitiari',
    'name': 'Alexa Tiari',
    'image': 'images/anisa.png',
    'isFollowing': true,
  },
  {
    'username': '@katiyanahmi',
    'name': 'Katiya Rahma',
    'image': 'images/kafiya.png',
    'isFollowing': true,
  },
  {
    'username': '@indrani',
    'name': 'Indrani Shaukat',
    'image': 'images/indiana.png',
    'isFollowing': true,
  },
  {
    'username': '@mega_oki',
    'name': 'Mega Oktaviani',
    'image': 'images/megan.png',
    'isFollowing': true,
  },
  {
    'username': '@ratuninsa',
    'name': 'Ratu Annisa',
    'image': 'images/ratuanisa.png',
    'isFollowing': true,
  },
  {
    'username': '@lovexp',
    'name': 'Yunni Aprilia',
    'image': 'images/viarel.png',
    'isFollowing': true,
  },
  {
    'username': '@alfahartono',
    'name': 'Alif Hartono',
    'image': 'images/rudi.png',
    'isFollowing': true,
  },
  {
    'username': '@nolyena_',
    'name': 'Nadia Riyani',
    'image': 'images/nadya.png',
    'isFollowing': true,
  },
];


   @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil index tab dari arguments (default 0 = Mengikuti)
    final int initialIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Toggle follow status
  void _toggleFollow(int index, bool isFollower) {
    setState(() {
      if (isFollower) {
        _followersList[index]['isFollowing'] = !_followersList[index]['isFollowing'];
      } else {
        _followingList[index]['isFollowing'] = !_followingList[index]['isFollowing'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButtonWidget(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '@siti_r',
          style: TextStyle(
            color: Color(0xFF015551),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: [
            Tab(text: '120 Mengikuti'),
            Tab(text: '250 Pengikut'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlue[50],
                hintText: 'Cari',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Following Tab
                _buildFollowingList(),

                // Followers Tab
                _buildFollowersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _followingList.length,
          itemBuilder: (context, index) {
            final user = _followingList[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(user['image']),
                  ),
                  const SizedBox(width: 12),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user['name'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Following Button
                  ElevatedButton(
                    onPressed: () => _toggleFollow(index, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006257),
                      minimumSize: Size(100, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Mengikuti',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  // More Options
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) {
                          return Stack(
                            children: [
                              // Blurred Background
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                              // Bottom Sheet Content
                                Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                    children: [
                                      CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(user['image']),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                      user['username'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                    ),
                                    Divider(),
                                    _buildSettingsOption(
                                    'Atur notifikasi',
                                    Icons.notifications_none,
                                    onTap: () {},
                                    ),
                                    _buildSettingsOption(
                                    'Notifikasi',
                                    Icons.notifications,
                                    hasSwitch: true,
                                    value: true,
                                    onChanged: (value) {},
                                    ),
                                    
                                    _buildSettingsOption(
                                    'Bisukan notifikasi',
                                    Icons.volume_off,
                                    hasSwitch: true,
                                    value: true,
                                    onChanged: (value) {},
                                    ),
                                    _buildSettingsOption(
                                    'Publikasi',
                                    Icons.public,
                                    hasSwitch: true,
                                    value: true,
                                    onChanged: (value) {},
                                    ),
                                    _buildSettingsOption(
                                    'Blokir Akun',
                                    Icons.block,
                                    hasSwitch: true,
                                    value: false,
                
                                    ),
                                    _buildSettingsOption(
                                    'Laporkan',
                                    Icons.flag_outlined,
                                    onTap: () {},
                                    ),
                                  ],
                                  ),
                                ),
                                ),
                              ],
                              );
                            },
                            );
                          },
                          ),
                        ],
                        ),
                      );
                      },
                    ),
                    ],
                  );
                  }

  Widget _buildFollowersList() {
    return ListView.builder(
      itemCount: _followersList.length,
      itemBuilder: (context, index) {
        final follower = _followersList[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(follower['image']),
              ),
              const SizedBox(width: 12),
              
              // User Info
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  follower['username'],
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  ),
                ),
                Text(
                  follower['name'],
                  style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  ),
                ),
                ],
              ),
              ),
              
              // Follow/Unfollow Button
              ElevatedButton(
              onPressed: () => _toggleFollow(index, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: follower['isFollowing'] 
                ? const Color(0xFF006257) 
                : Colors.white,
                side: BorderSide(
                color: const Color(0xFF006257),
                width: 1,
                ),
                minimumSize: Size(80, 36),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                follower['isFollowing'] ? 'Mengikuti' : 'Ikuti',
                style: TextStyle(
                color: follower['isFollowing'] ? Colors.white : const Color(0xFF006257),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                ),
              ),
              ),
              const SizedBox(width: 8),
              
              // Remove Button
              ElevatedButton(
              onPressed: () {
                setState(() {
                _followersList.removeAt(index);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(80, 36),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Hapus',
                style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                ),
              ),
              ),
            ],
            
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption(String title, IconData icon, {
    bool hasSwitch = false, 
    bool value = false,
    Function()? onTap,
    Function(bool)? onChanged,
  }) {
    return InkWell(
      onTap: hasSwitch ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14),
              ),
            ),
            if (hasSwitch)
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF006257),
                activeTrackColor: const Color(0xFF006257).withOpacity(0.4),
              ),
          ],
        ),
      ),
    );
  }
}
