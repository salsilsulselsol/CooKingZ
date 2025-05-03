import 'package:flutter/material.dart';

class FilterPopup extends StatefulWidget {
  const FilterPopup({Key? key}) : super(key: key);

  @override
  State<FilterPopup> createState() => _FilterPopupDialogState();
}

class _FilterPopupDialogState extends State<FilterPopup> {
  // Selected allergens
  final List<String> _selectedAllergens = ['Kacang', 'Gandum'];

  // Difficulty level
  String _selectedDifficulty = 'Sedang';

  // Sliders
  double _priceValue = 5.0; // Default halfway
  double _timeValue = 90.0; // Default halfway (180/2)

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF035E53),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF035E53),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Handle bar - visual indicator of top sheet
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Allergen section
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF035E53),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tambah Alergen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Allergen tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._selectedAllergens.map((allergen) => _buildAllergenChip(allergen)),
              _buildAddAllergenButton(),
            ],
          ),
          const SizedBox(height: 20),

          // Difficulty section
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF035E53),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Kesulitan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Difficulty chips
          Row(
            children: [
              _buildDifficultyChip('Mudah'),
              const SizedBox(width: 8),
              _buildDifficultyChip('Sedang'),
              const SizedBox(width: 8),
              _buildDifficultyChip('Sulit'),
            ],
          ),
          const SizedBox(height: 20),

          // Price estimation section
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF035E53),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Estimasi Harga',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price slider
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                color: const Color(0xFF035E53),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFb0dcdc),
                    inactiveTrackColor: const Color(0xFFb0dcdc),
                    thumbColor: const Color(0xFF035E53),
                    overlayColor: const Color(0x29035E53),
                    trackHeight: 8.0,
                  ),
                  child: Slider(
                    value: _priceValue,
                    min: 0,
                    max: 10,
                    onChanged: (value) {
                      setState(() {
                        _priceValue = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '10jt',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time estimation section
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF035E53),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Estimasi Waktu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Time slider
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                color: const Color(0xFF035E53),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFb0dcdc),
                    inactiveTrackColor: const Color(0xFFb0dcdc),
                    thumbColor: const Color(0xFF035E53),
                    overlayColor: const Color(0x29035E53),
                    trackHeight: 8.0,
                  ),
                  child: Slider(
                    value: _timeValue,
                    min: 0,
                    max: 180,
                    onChanged: (value) {
                      setState(() {
                        _timeValue = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '180Menit',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply filter button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can return the filter values here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFb0dcdc),
                foregroundColor: const Color(0xFF035E53),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Tambahkan Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Add some bottom padding for better spacing
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Helper method to build allergen chips
  Widget _buildAllergenChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFb0dcdc),
      labelStyle: const TextStyle(color: Color(0xFF035E53)),
      deleteIconColor: const Color(0xFF035E53),
      onDeleted: () {
        setState(() {
          _selectedAllergens.remove(label);
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // Helper method to build add allergen button
  Widget _buildAddAllergenButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFb0dcdc),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add +',
            style: TextStyle(
              color: Color(0xFF035E53),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build difficulty choice chips
  Widget _buildDifficultyChip(String label) {
    final bool isSelected = _selectedDifficulty == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      backgroundColor: const Color(0xFFb0dcdc),
      selectedColor: const Color(0xFF035E53),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF035E53),
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedDifficulty = label;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// Function to show the filter as a top sheet
void showFilterDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'FilterTopSheet',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: const SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: FilterPopup(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // from top
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
  );
}