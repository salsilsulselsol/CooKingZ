import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/food_model.dart'; // Import model Food
import '../../models/scheduled_food_model.dart'; // Import model ScheduledFood

class FoodCardJadwal extends StatelessWidget {
  final ScheduledFood scheduledFood;

  const FoodCardJadwal({Key? key, required this.scheduledFood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final food = scheduledFood.food;
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'RP',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF006666),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InkWell(
                onTap: () {
                  // Navigate to food detail page using the food object
                  Navigator.pushNamed(
                    context,
                    '/detail-resep',
                    arguments: food,
                  );
                },
              child: Container(
                height: 265,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // Food image with favorite button
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.asset(
                            food.image,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              // Handle favorite button press
                              //print('Favorite button pressed');
                            },
                            child: Image.asset(
                              'images/love.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Food info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  food.description?.replaceAll('\n', ' ') ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${food.likes ?? 0}',
                                    style: const TextStyle(
                                      color: Color(0xFF65B0B0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFF65B0B0),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF65B0B0),
                                    size: 16,
                                  ),
                                  Text(
                                    ' ${food.cookingTime != null ? '${food.cookingTime} menit' : ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF65B0B0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ' ${food.price ?? ''} RB',
                                style: const TextStyle(
                                  color: Color(0xFF65B0B0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: 210,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF65B0B0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}