import 'package:flutter/material.dart';

class PusatBantuan extends StatefulWidget {
  const PusatBantuan({super.key});

  @override
  State<PusatBantuan> createState() => _PusatBantuanState();
}

class _PusatBantuanState extends State<PusatBantuan> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  // Data dummy untuk aplikasi resep masakan
  final List<Map<String, dynamic>> _faqData = [
    {
      'question': 'Bagaimana cara mencari resep masakan?',
      'answer':
          'Anda bisa menggunakan fitur pencarian di halaman utama dan mengetik nama resep atau bahan yang ingin digunakan.'
    },
    {
      'question': 'Bagaimana cara menyimpan resep favorit?',
      'answer':
          'Tekan ikon hati di halaman resep untuk menyimpan resep ke daftar favorit Anda.'
    },
    {
      'question': 'Bagaimana cara membagikan resep ke teman?',
      'answer':
          'Di halaman resep, tekan ikon bagikan lalu pilih platform seperti WhatsApp, Instagram, atau lainnya.'
    },
    {
      'question': 'Apakah aplikasi bisa digunakan tanpa koneksi internet?',
      'answer':
          'Ya, Anda dapat mengakses resep yang telah disimpan ke favorit secara offline.'
    },
    {
      'question': 'Bagaimana cara melihat resep terbaru setiap hari?',
      'answer':
          'Buka tab "Resep Harian" di halaman utama untuk melihat rekomendasi resep terbaru setiap hari.'
    },
    {
      'question': 'Bisakah saya menyusun daftar belanja dari resep?',
      'answer':
          'Ya, di setiap resep terdapat tombol untuk menambahkan bahan-bahan ke daftar belanja.'
    },
    {
      'question': 'Apakah saya bisa menambahkan resep buatan sendiri?',
      'answer':
          'Tentu! Gunakan fitur "Tambah Resep" pada menu utama, lalu isi data resep dan unggah foto masakan.'
    },
    {
      'question': 'Apakah ada fitur untuk filter resep berdasarkan diet?',
      'answer':
          'Ya, Anda bisa menggunakan filter seperti "Vegetarian", "Bebas Gluten", atau "Rendah Kalori" di menu pencarian.'
    },
  ];

  final List<Map<String, dynamic>> _accountData = [
    {
      'question': 'Bagaimana cara membuat akun di aplikasi ini?',
      'answer':
          'Pilih tombol "Daftar" pada halaman awal dan isi informasi yang diminta seperti email dan kata sandi.'
    },
    {
      'question': 'Bagaimana cara mengganti nama pengguna?',
      'answer':
          'Masuk ke menu Profil, ketuk ikon edit di sebelah nama Anda, lalu masukkan nama baru.'
    },
    {
      'question': 'Bagaimana cara reset kata sandi?',
      'answer':
          'Pada halaman login, pilih "Lupa Kata Sandi", kemudian ikuti petunjuk untuk reset melalui email.'
    },
    {
      'question': 'Apakah akun bisa terhubung dengan Google?',
      'answer':
          'Ya, Anda dapat login atau mendaftar menggunakan akun Google untuk kemudahan akses.'
    },
  ];

  final List<Map<String, dynamic>> _serviceData = [
    {
      'question': 'Apa itu fitur "Resep Harian"?',
      'answer':
          'Fitur yang menampilkan resep rekomendasi setiap hari berdasarkan preferensi Anda.'
    },
    {
      'question': 'Bagaimana cara membuat daftar belanja otomatis?',
      'answer':
          'Pilih resep lalu tekan tombol "Tambahkan ke Daftar Belanja". Semua bahan akan otomatis tercatat.'
    },
    {
      'question': 'Bisakah saya memberi ulasan pada resep orang lain?',
      'answer':
          'Ya, setelah mencoba resep, Anda bisa memberi bintang dan komentar di bagian bawah halaman resep.'
    },
  ];

  final List<Map<String, dynamic>> _contactData = [
    {
      'type': 'Website',
      'link': 'www.cookingz.com',
      'icon': Icons.language,
    },
    {
      'type': 'Facebook',
      'link': 'facebook.com/cookingz',
      'icon': Icons.facebook,
    },
    {
      'type': 'Whatsapp',
      'link': '+62 812 3456 7890',
      'icon': Icons.message,
    },
    {
      'type': 'Instagram',
      'link': '@cookingz_app',
      'icon': Icons.camera_alt,
    },
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/home"),
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
                    'images/Tombol_kembali.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
            color: Color(0xFF015551),
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 80,
        flexibleSpace: Transform.translate(
          offset: const Offset(0, 15),
          child: Container(),
        ),
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('FAQ', 0),
                ),
                Expanded(
                  child: _buildTabButton('Hubungi Kami', 1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Akun', 2),
                ),
                Expanded(
                  child: _buildTabButton('Layanan', 3),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x8057B4BA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // FAQ Content
                _buildFaqList(_faqData),
                
                // Hubungi Kami Content
                _buildContactList(),
                
                // Akun Content
                _buildFaqList(_accountData),
                
                // Layanan Content
                _buildFaqList(_serviceData),
              ],
            ),
          ),
          // Bottom Navigation
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF015551),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            height: 5, // Menambahkan height minimal agar container terlihat
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF015551) : Color(0x8057B4BA),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList(List<Map<String, dynamic>> data) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return _buildFaqItem(item['question'], item['answer']);
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.white, // Mengatur background pertanyaan menjadi putih
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Menggunakan gambar sebagai trailing icon
          trailing: Image.asset(
            'images/Tombol_lanjut.png',
            width: 24,
            height: 24,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                answer,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _contactData.length,
      itemBuilder: (context, index) {
        final contact = _contactData[index];
        return _buildContactItem(
          title: contact['type'],
          subtitle: contact['link'],
          icon: contact['icon'],
        );
      },
    );
  }

  Widget _buildContactItem({required String title, required String subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.white, // Mengatur background pertanyaan menjadi putih
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF015551),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(subtitle),
          // Menggunakan gambar sebagai trailing icon
          trailing: Image.asset(
            'images/Tombol_lanjut.png',
            width: 24,
            height: 24,
          ),
          onTap: () {
            // Implementasi aksi buka link
          },
        ),
      ),
    );
  }
}