import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PenggunaTerbaik extends StatelessWidget {
  const PenggunaTerbaik({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/beranda"),
          child: Transform.translate(
            offset: const Offset(15, 0),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'images/arrow.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Pengguna Terbaik',
          style: TextStyle(
            color: Color(0xFF005A4D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Color(0xFF005A4D),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SizedBox(
              height: 30,
              width: 30,
              child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'images/notif.png',
                fit: BoxFit.contain,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Color(0xFF005A4D),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SizedBox(
              height: 30,
              width: 30,
              child: IconButton(
              padding: EdgeInsets.zero,
              icon: Image.asset(
                'images/search.png',
                fit: BoxFit.contain,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/personal');
              },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
              height: 310,
              decoration: const BoxDecoration(
                color: Color(0xFF005A4D),
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildSectionTitle("Pengguna Populer"),
                _buildUsersGrid('Pengguna Populer', [
                  {
                  'name': 'Ayu Lestari',
                  'username': '@ayu_lestari',
                  'likes': '925',
                  'followw': true,
                  'image': 'images/ayulestari.png',
                  },
                  {
                  'name': 'Bagas Pratama',
                  'username': '@bagaspratama',
                  'likes': '880',
                  'followw': true,
                  'image': 'images/bagas_pt.png',
                  },
                ]),
                ],
              ),
              ),
             
              Container(
              height: 310,
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildSectionTitle("Pengguna Disukai Terbaru"),
                _BuildUmum('Pengguna Disukai Terbaru', [
                  {
                  'name': 'Doni Candra',
                  'username': '@donicandra',
                  'likes': '800',
                  'followw': true,
                  'image': 'images/doni.png',
                  },
                
                  {
                  'name': 'Ayu Dewi' ,
                  'username': '@ayudewi',
                  'likes': '750',
                  'followw': true,
                  'image': 'images/ayu_23.png',
                  },
                
                ]),
               
                ],
              ),
              ),
       
              Container(
              height: 310,
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildSectionTitle("Pengguna Terbaru"),
                _BuildUmum('Pengguna Terbaru', [
                  {
                  'name': 'Lulu Rahma',
                  'username': '@lulu_rahma',
                  'likes': '700',
                  'followw': true,
                  'image': 'images/lulu.png',
                  },
                
                  {   
                  'name': 'Edward Jones',
                  'username': '@edwardjones',
                  'likes': '650',
                  'followw': true,
                  'image': 'images/edwar.png',
                  },
                
                ]),
        
                ],
              ),
              ),
            ],
            ),
          ),
        ),
      
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, top: 10.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: title == "Pengguna Populer" ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildUsersGrid(String title, List<Map<String, dynamic>> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:
                users.map((user) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildUserCard(
                        name: user['name'],
                        username: user['username'],
                        likes: user['likes'],
                        isFollowing: user['followw'] ?? false,
                        image: user['image'],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String username,
    required String likes,
    required bool isFollowing,
    required String image,
  }) {
    return Container(
      // Kartu utama pembungkus user card
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 254, 253, 253).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================
          // BAGIAN FOTO PROFIL USER
          // ========================
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
                
              ),
            ),
          ),
          // ================================
          // BAGIAN INFORMASI USER (NAMA DLL)
          // ================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              0,
              12,
              0,
            ), // Jarak atas dikurangi
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Color(0xFF005A4D),
                border: const Border(
                  left: BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 2,
                  ),
                  right: BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255),
                    width: 2,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Username
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  // Baris Like dan Tombol Follow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ikon dan jumlah like
                      Row(
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            Icons.favorite,
                            color: const Color(0xFF57B4BA),
                            size: 12,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            likes,
                            style: const TextStyle(
                              color: Color(0xFF57B4BA),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 30),
                          // Tombol "Mengikuti" atau "Pengikut"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF57B4BA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isFollowing ? 'Mengikuti' : 'Pengikut',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Tombol Share
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF57B4BA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

////////////////////////////////
Widget _BuildUmum(String title, List<Map<String, dynamic>> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:
                users.map((user) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _BuildUmumCard(
                        name: user['name'],
                        username: user['username'],
                        likes: user['likes'],
                        isFollowing: user['followw'] ?? false,
                        image: user['image'],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _BuildUmumCard({
    required String name,
    required String username,
    required String likes,
    required bool isFollowing,
    required String image,
  }) {
    return Container(
      // Kartu utama pembungkus user card
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 254, 253, 253).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================
          // BAGIAN FOTO PROFIL USER
          // ========================
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
                
              ),
            ),
          ),
          // ================================
          // BAGIAN INFORMASI USER (NAMA DLL)
          // ================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              0,
              12,
              0,
            ), // Jarak atas dikurangi
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 251, 254, 253),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFF005A4D),
                    width: 2,
                  ),
                  right: BorderSide(
                    color: Color(0xFF005A4D),
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: Color(0xFF005A4D),
                    width: 2,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Username
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  // Baris Like dan Tombol Follow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ikon dan jumlah like
                      Row(
                        children: [
                          const SizedBox(width: 5),
                          Icon(
                            Icons.favorite,
                            color: const Color(0xFF57B4BA),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likes,
                            style: const TextStyle(
                              color: Color(0xFF57B4BA),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 25),
                          // Tombol "Mengikuti" atau "Pengikut"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF57B4BA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isFollowing ? 'Mengikuti' : 'Pengikut',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Tombol Share
                          Container(
                            height: 20,
                            width: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF57B4BA),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
