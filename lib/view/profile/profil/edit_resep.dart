import 'package:flutter/material.dart';
import '../../component/header_back.dart';
import '../../component/bottom_navbar.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF005A4D);
  static const Color accentTeal = Color(0xFF57B4BA);
  static const Color emeraldGreen = Color(0xFF015551);
  static const Color lightTeal = Color(0xFF9FD5DB);
  static const Color bgColor = Color(0xFFF9F9F9);
}

class EditResep extends StatelessWidget {
  const EditResep({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header yang tetap fix
              HeaderWidget(
                title: 'Edit Resep',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),

              // Konten yang bisa di-scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightTeal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Unggah',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightTeal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sisanya dari konten Anda...
                      // Video upload area
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('../images/pina_colada.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.emeraldGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recipe Info Fields
                      _buildInfoField('Judul', 'Pina colada'),
                      _buildInfoField('Deskripsi', 'Minuman segar khas resep', lighter: true),
                      _buildInfoField('Estimasi Waktu', '30 menit'),
                      _buildInfoField('Harga', 'Rp 20.000'),

                      // Difficulty Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                            child: Text(
                              'Tingkat Kesulitan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.lightTeal,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Mudah',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Tools Section (Alat-Alat)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 24.0, bottom: 8.0),
                        child: Text(
                          'Alat-Alat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _buildToolItem('Blender'),
                      _buildToolItem('Juicer (opsional)'),
                      _buildToolItem('Pisau'),
                      _buildToolItem('Gelas'),
                      _buildToolItem('Sendok'),

                      // Add Tool Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                '+ Tambahkan Alat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Ingredients Section (Bahan-Bahan)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          'Bahan-Bahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _buildIngredientItem('60 ml', 'Es susu (non panas)'),
                      _buildIngredientItem('15 ml', 'Jus pepaya yang sudah disaring'),
                      _buildIngredientItem('30 ml', 'Sirup santan kelapa atau krim kelapa'),
                      _buildIngredientItem('1-2', 'Es batu secukupnya'),
                      _buildIngredientItem('1 sdm', 'Hiasan nanas & ceri untuk garnish (opsional)'),

                      // Add Ingredient Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                '+ Tambahkan Bahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Instructions Section (Instruksi)
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          'Instruksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _buildInstructionItem('Siapkan blender. Masukkan rum putih, jus nanas, sirup/krim kelapa, dan campurkan es batu ke dalam blender.'),
                      _buildInstructionItem('Campurkan semua bahan hingga halus dan tercampur rata.'),
                      _buildInstructionItem('Tuangkan campuran ke dalam gelas saji.'),
                      _buildInstructionItem('Tambahkan hiasan nanas dan ceri di atasnya jika diinginkan.'),
                      _buildInstructionItem('Minuman siap disajikan. Nikmati selagi dingin!'),
                      _buildInstructionItem('Kocok minuman hingga halus.'),

                      // Add Instruction Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: Text(
                                '+ Tambahkan Instruksi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Add extra padding at the bottom to account for the navbar
                      const SizedBox(height: 80),
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

  // Method-method builder lainnya tetap sama...
  Widget _buildInfoField(String label, String placeholder, {bool lighter = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 16.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightTeal,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            placeholder,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Row(
        children: [
          // More button
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Tool name
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightTeal,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String amount, String item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Row(
        children: [
          // More button
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Amount field
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Item field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 4, 0, 0)),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: Row(
        children: [
          // More button
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Instruction text
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightTeal,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {},
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}