import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// First Page - Cooking Level Selection Page
class CookingLevelPage extends StatelessWidget {
  const CookingLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            const SizedBox(height: 20), // Added space from top
            // Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'images/arrow.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'images/slide_kiri.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: 12,
              ),
            ),
            const SizedBox(height: 24),
            // Title & Description
            const Padding(
              padding: EdgeInsets.only(left: 40, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level Memasak Kamu Apa?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih level memasakmu untuk rekomendasi yang lebih tepat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
            // Spacing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildOptionCards(),
                  ),
                ),
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CookingPreferences()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB3E0DA),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildOptionCards() {
    final levels = [
      {
        'title': 'Pemula',
        'desc':
            'Baru mulai belajar memasak dan masih mencoba resep-resep dasar. Butuh panduan yang mudah dan langkah-langkah yang jelas.',
      },
      {
        'title': 'Menengah',
        'desc':
            'Sudah terbiasa memasak dan ingin mencoba resep yang sedikit lebih menantang dengan variasi bahan dan teknik baru.',
      },
      {
        'title': 'Lanjutan',
        'desc':
            'Memiliki pengalaman memasak yang cukup dan bisa mengikuti resep yang lebih kompleks tanpa banyak kesulitan.',
      },
      {
        'title': 'Professional',
        'desc':
            'Sudah ahli dalam memasak, terbiasa dengan teknik lanjutan dan suka bereksperimen sendiri dengan berbagai bahan.',
      },
    ];

    return levels
        .map((level) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF206153)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level['desc']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}

// Second Page - Cooking Preferences Page
class CookingPreferences extends StatefulWidget {
  const CookingPreferences({super.key});

  @override
  State<CookingPreferences> createState() => _CookingPreferencesState();
}

class _CookingPreferencesState extends State<CookingPreferences> {
  // Set for storing selected preferences
  final Set<String> selectedPreferences = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Back Button - Using the same style as CookingLevelPage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'images/arrow.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar - Using slide_tengah.png for the middle step
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'images/slide_tengah.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: 12,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Padding(
              padding: EdgeInsets.only(left: 40, right: 24), // Consistent with CookingLevelPage
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Preferensi Masakan Anda',
                    style: TextStyle(
                      fontSize: 20, // Consistent font size with CookingLevelPage
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih preferensi masakanmu untuk rekomendasi yang lebih personal (bisa dilewati)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Food Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 16,
                  children: _buildFoodItems(),
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Lewati Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllergyQuestionnairePage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF206153)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF206153),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Selanjutnya Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllergyQuestionnairePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3E0DA),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFoodItems() {
    final foodItems = [
      {'name': 'Pecel', 'image': 'images/pecel.png'},
      {'name': 'Sop Jagung', 'image': 'images/sop_jagung.png'},
      {'name': 'Telur Balado', 'image': 'images/telur_balado.png'},
      {'name': 'Seafood', 'image': 'images/seafood.png'},
      {'name': 'Pasta', 'image': 'images/pasta.png'},
      {'name': 'Daging', 'image': 'images/daging.png'},
      {'name': 'Burger', 'image': 'images/burger.png'},
      {'name': 'Pizza', 'image': 'images/pizza.png'},
      {'name': 'Sushi', 'image': 'images/sushi.png'},
      {'name': 'Nasi Goreng', 'image': 'images/nasi_goreng.png'},
      {'name': 'Brownies', 'image': 'images/brownies.png'},
      {'name': 'Roti', 'image': 'images/roti.png'},
    ];

    return foodItems.map((food) {
      final isSelected = selectedPreferences.contains(food['name']);
      
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedPreferences.remove(food['name']);
            } else {
              selectedPreferences.add(food['name']!);
            }
          });
        },
        child: Column(
          children: [
            Container(
              width: 111.63,
              height: 111.63,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFF206153), width: 3)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  food['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              food['name']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Third Page - Allergy Questionnaire Page
class AllergyQuestionnairePage extends StatefulWidget {
  const AllergyQuestionnairePage({super.key});

  @override
  State<AllergyQuestionnairePage> createState() => _AllergyQuestionnairePageState();
}

class _AllergyQuestionnairePageState extends State<AllergyQuestionnairePage> {
  final List<String> selectedItems = [];

  final List<Map<String, String>> allergies = [
    {'label': 'Pisang', 'image': 'images/pisang.png'},
    {'label': 'Daging', 'image': 'images/daging.png'},
    {'label': 'Kiwi', 'image': 'images/kiwi.png'},
    {'label': 'Kacang', 'image': 'images/kacang.png'},
    {'label': 'Susu', 'image': 'images/susu.png'},
    {'label': 'Telur', 'image': 'images/telur.png'},
    {'label': 'Gula', 'image': 'images/gula.png'},
    {'label': 'Gandum', 'image': 'images/gandum.png'},
    {'label': 'Udang', 'image': 'images/udang.png'},
    {'label': 'Kacang Pohon', 'image': 'images/kacang.png'},
    {'label': 'Tepung', 'image': 'images/tepung.png'},
    {'label': 'Ikan', 'image': 'images/ikan.png'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            const SizedBox(height: 20), // Consistent spacing from top
            // Back Button - Updated to match other pages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'images/arrow.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar - Using image for consistency with other pages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                'images/slide_kanan.png', // Assuming this is the name for the third step
                fit: BoxFit.contain,
                width: double.infinity,
                height: 12,
              ),
            ),
            const SizedBox(height: 24),
            // Title & Subtitle
            const Padding(
              padding: EdgeInsets.only(left: 40, right: 24), // Consistent with other pages
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada Alergi Makanan Tertentu?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lorem ipsum dolor sit amet consectetur. Leo ornare ullamcorper viverra ultrices in.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Grid Pilihan Alergi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: allergies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = allergies[index];
                    final isSelected = selectedItems.contains(item['label']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedItems.remove(item['label']);
                          } else {
                            selectedItems.add(item['label']!);
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 111.63,
                            height: 111.63,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: const Color(0xFF206153), width: 3)
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Tombol navigasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to next page
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF206153)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF206153),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                      Navigator.pushNamed(context, '/beranda');
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB3E0DA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      ),
                      child: const Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F1F1F),
                        fontWeight: FontWeight.w600,
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
