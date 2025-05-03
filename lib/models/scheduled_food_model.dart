import '../models/food_model.dart';

class ScheduledFood {
  final DateTime date;
  final Food food;

  ScheduledFood({
    required this.date,
    required this.food,
  });
}