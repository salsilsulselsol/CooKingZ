import 'package:flutter/material.dart';
import '../../theme/theme.dart'; // Import your theme

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
              Text(
                'Filter',
                style: AppTheme.headerStyle,
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppTheme.primaryColor,
                  size: AppTheme.iconSizeLarge,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingXLarge),

          // Handle bar - visual indicator of top sheet
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingXXLarge),

          // Allergen section
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: AppTheme.iconSizeMedium,
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                'Tambah Alergen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLarge),

          // Allergen tags
          Wrap(
            spacing: AppTheme.spacingMedium,
            runSpacing: AppTheme.spacingMedium,
            children: [
              ..._selectedAllergens.map((allergen) => _buildAllergenChip(allergen)),
              _buildAddAllergenButton(),
            ],
          ),
          SizedBox(height: AppTheme.spacingXLarge),

          // Difficulty section
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: AppTheme.iconSizeMedium,
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                'Kesulitan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLarge),

          // Difficulty chips
          Row(
            children: [
              _buildDifficultyChip('Mudah'),
              SizedBox(width: AppTheme.spacingMedium),
              _buildDifficultyChip('Sedang'),
              SizedBox(width: AppTheme.spacingMedium),
              _buildDifficultyChip('Sulit'),
            ],
          ),
          SizedBox(height: AppTheme.spacingXLarge),

          // Price estimation section
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: AppTheme.iconSizeMedium,
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                'Estimasi Harga',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLarge),

          // Price slider
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                color: AppTheme.primaryColor,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.searchBarColor,
                    inactiveTrackColor: AppTheme.searchBarColor,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
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
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                '10jt',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingXLarge),

          // Time estimation section
          Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: AppTheme.iconSizeMedium,
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                'Estimasi Waktu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLarge),

          // Time slider
          Row(
            children: [
              Container(
                width: 5,
                height: 24,
                color: AppTheme.primaryColor,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.searchBarColor,
                    inactiveTrackColor: AppTheme.searchBarColor,
                    thumbColor: AppTheme.primaryColor,
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
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
              SizedBox(width: AppTheme.spacingMedium),
              Text(
                '180Menit',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingXXLarge),

          // Apply filter button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can return the filter values here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.searchBarColor,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
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
          SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }

  // Helper method to build allergen chips
  Widget _buildAllergenChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.searchBarColor,
      labelStyle: TextStyle(color: AppTheme.primaryColor),
      deleteIconColor: AppTheme.primaryColor,
      onDeleted: () {
        setState(() {
          _selectedAllergens.remove(label);
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // Helper method to build add allergen button
  Widget _buildAddAllergenButton() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge,
          vertical: AppTheme.spacingMedium
      ),
      decoration: BoxDecoration(
        color: AppTheme.searchBarColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add +',
            style: TextStyle(
              color: AppTheme.primaryColor,
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
      backgroundColor: AppTheme.searchBarColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.primaryColor,
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedDifficulty = label;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
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
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
                bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingXXLarge,
              left: AppTheme.spacingXXLarge,
              right: AppTheme.spacingXXLarge,
              bottom: AppTheme.spacingXXLarge,
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