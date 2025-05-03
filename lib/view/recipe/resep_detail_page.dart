import 'package:flutter/material.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key});

  @override
  State<RecipeDetailPage> createState() => DetailRecipe();
}

class DetailRecipe extends State<RecipeDetailPage> {
  // Define app colors
  final Color primaryColor = const Color(0xFF005A4D);
  final Color accentTeal = const Color(0xFF57B4BA);
  final Color lightTeal = const Color(0xFFB3E0DB);
  final Color emeraldGreen = const Color(0xFF015551);
  final Color backgroundColor = const Color(0xFFF5FFFD);
  final Color textDarkColor = const Color(0xFF333333);

  // Sample recipe data
  final Map<String, dynamic> recipe = {
    'name': 'Croffle Ice Cream',
    'likes': 48,
    'comments': 41,
    'author': '@xylefbrian',
    'authorName': 'William Smith',
    'description': 'Croffle Ice Cream adalah kombinasi croffle (croissant + '
        'Croffle) dengan es krim dingin, disajikan dengan saus '
        'cokelat atau sirup maple, serta taburan gula halus. '
        'Sempurna untuk camilan manis yang menggugah selera!',
    'points': 'RP 20 RB',
    'difficulty': null, // Setting to null as per requirement
    'tools': [
      'Wajan',
      'Spatula',
      'Pisau',
      'Piring',
    ],
    'ingredients': [
      '2 lembar croissant',
      '1 butir telur',
      '1 sdm susu cair',
      '1 sdt gula pasir',
      '1/4 sdt vanila bubuk',
      'Minyak goreng untuk menggoreng',
    ],
    'steps': [
      'Potong croissant jadi dua, celupkan ke campuran telur, susu, gula, dan vanila. Goreng hingga kecokelatan, lalu tiriskan.',
      'Letakkan croffle di piring saji, susun saling bersilangan agar terlihat menarik.',
      'Campurkan bahan kering: Ayak bubuk kako, tepung terigu, dan garam dalam wadah terpisah, lalu tambahkan ke campuran mentega dan aduk hingga rata.',
      'Siram dengan saus cokelat atau sirup maple, lalu taburi gula halus. Tambahkan kacang panggang jika suka.',
      'Sajikan segera selagi hangat, nikmati perpaduan renyah dan dingin!',
    ],
  };

  bool isFollowing = false;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecipeImage(),
                    _buildAuthorSection(),
                    _buildDivider(),
                    _buildDescriptionSection(),
                    _buildScheduleButton(), // Memastikan tombol jadwalkan menu muncul
                    _buildToolsSection(),
                    _buildIngredientsSection(),
                    _buildStepsSection(),
                    _buildDivider(),
                    _buildRatingSection(),
                    _buildCommentInput(),
                    _buildDivider(),
                    _buildViewAllCommentsButton(),
                    const SizedBox(height: 60), // Space for bottom navbar
                  ],
                ),
              ),
            ),
            // _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Menambahkan tombol Jadwalkan Menu
  Widget _buildScheduleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: InkWell(
        onTap: () {
          _showCalendarDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Jadwalkan Menu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog kalender
  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Jadwalkan Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('April 2025'),
                const SizedBox(height: 16),
                _buildCalendar(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text(
                'Tambahkan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget untuk membangun kalender
  Widget _buildCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 35, // 5 weeks
      itemBuilder: (context, index) {
        // Header for days of week
        if (index < 7) {
          final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
          return Center(
            child: Text(
              days[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          );
        }

        // Calculate the day number
        int day = index - 7 + 1;

        // Handle March days at the beginning (30, 31)
        if (day <= 0) {
          day = 30 + day; // March has 31 days
          return Center(
            child: Text(
              day.toString(),
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        // Handle May days at the end
        if (day > 30) {
          day = day - 30;
          return Center(
            child: Text(
              day.toString(),
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        bool isSelected = day == 1;

        return InkWell(
          onTap: () {
            setState(() {
              selectedDate = DateTime(2025, 4, day);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? accentTeal : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog sukses setelah menu berhasil dijadwalkan
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Penjadwalan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Menu Berhasil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (updated to use arrow.png)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'images/arrow.png',
                color: primaryColor,
                width: 24,
                height: 24,
              ),
            ),
          ),

          // Recipe title
          Text(
            recipe['name'],
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          // Action buttons
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Image.asset(
                    'images/love_hijau_tua.png',
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                ),
              ),
              Container(
                width: 30,
                height: 30,
                
                child: IconButton(
                  icon: Image.asset(
                    'images/share_button.png',
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image part
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              'images/croffle.png',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Text info part
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recipe['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe['likes'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe['comments'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('images/xyfebrian.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['author'],
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    recipe['authorName'],
                    style: TextStyle(
                      color: textDarkColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Tombol Mengikuti/Ikuti dengan lebar berbeda
              SizedBox(
                width: isFollowing ? 120 : 100, // Lebar lebih besar untuk kedua status
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? lightTeal : primaryColor,
                    foregroundColor: isFollowing ? primaryColor : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isFollowing ? 'Mengikuti' : 'Ikuti',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Icon titik tiga (more options)
              IconButton(
                icon: Icon(Icons.more_vert, color: primaryColor),
                onPressed: () {
                  // Tambahkan aksi ketika titik tiga diklik
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Divider(
        thickness: 2,
        color: primaryColor,
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deskripsi',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  // Points - RP 20RB
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe['points'],
                          style: const TextStyle(
                            color: Color(0xFF005A4D),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time - 15 menit with alarm icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/alarm_hitam.png',
                          color: primaryColor,
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '15 menit',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Difficulty - Mudah
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Mudah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipe['description'],
            style: TextStyle(
              color: textDarkColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alat-Alat',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (recipe['tools'] as List<String>)
                .map<Widget>((tool) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tool,
                    style: TextStyle(
                      color: textDarkColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahan-Bahan',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (recipe['ingredients'] as List<String>)
                .map<Widget>((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ingredient,
                    style: TextStyle(
                      color: textDarkColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${recipe['steps'].length} Langkah Mudah',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(
              recipe['steps'].length,
                  (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? primaryColor : lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index % 2 == 0 ? lightTeal : primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index % 2 == 0 ? primaryColor : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recipe['steps'][index],
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.white : primaryColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ulasan',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              5,
                  (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  'images/star.png',
                  color: primaryColor,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: lightTeal.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: primaryColor,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tuliskan ulasan anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'images/send_button.png',
                color: primaryColor,
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCommentsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lihat Semua Ulasan & Diskusi Resep',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}