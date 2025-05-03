import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/food_model.dart'; // Import model Food
import '../../models/scheduled_food_model.dart'; // Import model ScheduledFood
import '../component/food_card_jadwal.dart'; // Import widget FoodCardJadwal

class PenjadwalanPage extends StatefulWidget {
  const PenjadwalanPage({Key? key}) : super(key: key);

  @override
  State<PenjadwalanPage> createState() => _PenjadwalanPageState();
}

class _PenjadwalanPageState extends State<PenjadwalanPage> {
  // Sample data for scheduled foods using the new Food model
  final List<ScheduledFood> scheduledFoods = [
    ScheduledFood(
      date: DateTime(2025, 4, 1),
      food: Food(
        id: 1,
        name: 'Croffle Ice Cream',
        image: 'images/croffle.png',
        cookingTime: 15,
        rating: 4.2,
        likes: 213,
        price: '20RB',
        description: 'Croffle dengan es krim yang lezat.',
      ),
    ),
    ScheduledFood(
      date: DateTime(2025, 12, 11),
      food: Food(
        id: 2,
        name: 'Telur Dadar',
        image: 'images/telur_dadar.png',
        cookingTime: 30,
        rating: 4.5,
        likes: 89,
        price: '15RB',
        description: 'Telur dadar sederhana dan nikmat.',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('images/arrow.png', width: 24, height: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Penjadwalan',
                style: TextStyle(
                  color: Color(0xFF006666),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Image.asset('images/calendar.png', width: 28, height: 28),
                onPressed: _showDatePicker,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 16, top: 10),
          child: ListView.builder(
            itemCount: scheduledFoods.length,
            itemBuilder: (context, index) {
              final scheduledFood = scheduledFoods[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(scheduledFood.date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006666),
                    ),
                  ),
                  FoodCardJadwal(scheduledFood: scheduledFood), // Menggunakan FoodCardJadwal
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year'.toLowerCase();
  }

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006666),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF006666),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Handle the selected date
      // For example, add a new scheduled food for this date
    }
  }
}