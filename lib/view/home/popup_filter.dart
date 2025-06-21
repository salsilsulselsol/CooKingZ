import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class FilterPopup extends StatefulWidget {
  final Map<String, dynamic> initialParams;

  const FilterPopup({Key? key, this.initialParams = const {}}) : super(key: key);

  @override
  State<FilterPopup> createState() => _FilterPopupDialogState();
}

class _FilterPopupDialogState extends State<FilterPopup> {
  Set<String> _selectedAllergens = {};
  String _selectedDifficulty = 'Semua';
  double _minRating = 0.0;
  double _maxPrice = 100000.0;
  double _maxTime = 180.0;

  @override
  void initState() {
    super.initState();
    _selectedAllergens = Set<String>.from(widget.initialParams['allergens'] ?? []);
    _selectedDifficulty = widget.initialParams['difficulty'] ?? 'Semua';
    _minRating = widget.initialParams['min_rating'] ?? 0.0;
    _maxPrice = widget.initialParams['max_price'] ?? 100000.0;
    _maxTime = widget.initialParams['max_time'] ?? 180.0;
  }

  @override
  Widget build(BuildContext context) {
    return Material( // <- Tambahan penting di sini
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingXXLarge),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: SingleChildScrollView( // Antisipasi overflow di layar kecil
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter', style: AppTheme.headerStyle),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.primaryColor, size: AppTheme.iconSizeLarge),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingXLarge),
              Center(
                child: Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingXXLarge),

              _buildFilterSectionTitle(Icons.warning, 'Alergen'),
              SizedBox(height: AppTheme.spacingLarge),
              Wrap(
                spacing: AppTheme.spacingMedium,
                runSpacing: AppTheme.spacingMedium,
                children: [
                  _buildAllergenChip('Kacang'),
                  _buildAllergenChip('Gandum'),
                  _buildAllergenChip('Susu'),
                  _buildAllergenChip('Telur'),
                ],
              ),
              SizedBox(height: AppTheme.spacingXLarge),

              _buildFilterSectionTitle(Icons.star, 'Kesulitan'),
              SizedBox(height: AppTheme.spacingLarge),
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

              _buildFilterSectionTitle(Icons.star_half, 'Rating Minimal'),
              Slider(
                value: _minRating, min: 0, max: 5, divisions: 5,
                label: _minRating.toStringAsFixed(1),
                onChanged: (value) => setState(() => _minRating = value),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.searchBarColor,
                thumbColor: AppTheme.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0', style: TextStyle(fontSize: 12)),
                    Text('5', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingXLarge),

              _buildFilterSectionTitle(Icons.attach_money, 'Estimasi Harga Maksimal'),
              Slider(
                value: _maxPrice, min: 0, max: 100000.0, divisions: 20,
                label: _maxPrice.toStringAsFixed(0),
                onChanged: (value) => setState(() => _maxPrice = value),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.searchBarColor,
                thumbColor: AppTheme.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0', style: TextStyle(fontSize: 12)),
                    Text('100K+', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingXLarge),

              _buildFilterSectionTitle(Icons.access_time, 'Estimasi Waktu Memasak Maksimal (Menit)'),
              Slider(
                value: _maxTime, min: 0, max: 180.0, divisions: 18,
                label: _maxTime.toStringAsFixed(0),
                onChanged: (value) => setState(() => _maxTime = value),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.searchBarColor,
                thumbColor: AppTheme.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0 Menit', style: TextStyle(fontSize: 12)),
                    Text('180+ Menit', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingXXLarge),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final Map<String, dynamic> filteredParams = {
                      'allergens': _selectedAllergens.toList(),
                      'difficulty': _selectedDifficulty == 'Semua' ? null : _selectedDifficulty,
                      'min_rating': _minRating > 0 ? _minRating : null,
                      'max_price': _maxPrice < 100000.0 ? _maxPrice : null,
                      'max_time': _maxTime < 180.0 ? _maxTime : null,
                    };
                    filteredParams.removeWhere((key, value) => value == null || (value is List && value.isEmpty));
                    Navigator.of(context).pop(filteredParams);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
                    ),
                  ),
                  child: const Text(
                    'Terapkan Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: AppTheme.iconSizeMedium),
        SizedBox(width: AppTheme.spacingMedium),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildAllergenChip(String label) {
    final bool isSelected = _selectedAllergens.contains(label);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.searchBarColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.backgroundColor : AppTheme.primaryColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedAllergens.add(label);
          } else {
            _selectedAllergens.remove(label);
          }
        });
      },
    );
  }

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
      onSelected: (selected) {
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
