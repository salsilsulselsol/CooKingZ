import 'package:flutter/material.dart';
import 'package:masak2/models/food_model.dart';
import '../../component/grid_2_builder.dart';

class MakananFavorit extends StatelessWidget {
  const MakananFavorit({super.key});

  @override
  Widget build(BuildContext context) {
    List<Food> recipes = [
      Food(
        name: 'French Toast',
        description: 'Rican ini yang klasik',
        image: 'images/french_toast.jpg',
        cookingTime: 25,
        price: '35.000',
        likes: 30,
      ),
      Food(
        name: 'Crepes Buah',
        description: 'Crepes cream isi buah',
        image: 'images/crepes.png',
        cookingTime: 15,
        price: '30.000',
        likes: 27,
      ),
      Food(
        name: 'Macarons',
        description: 'Klasik, berwarna-warni, dan lembut manis',
        image: 'images/macarons.jpg',
        cookingTime: 60,
        price: '40.000',
        likes: 38,
      ),
      Food(
        name: 'Spring Cupcake',
        description: 'Cupcake di spring, bertopping kurma mudah siap',
        image: 'images/springcake.png',
        cookingTime: 45,
        price: '28.000',
        likes: 25,
      ),
      Food(
        name: 'Cheesecake',
        description: 'Cheesecake dingin yang lemon dan lembut',
        image: 'images/chesscake.png',
        cookingTime: 50,
        price: '45.000',
        likes: 32,
      ),
      Food(
        name: 'Es Kopi',
        description: 'Kopi susu dingin dan segar',
        image: 'images/eskopi.png',
        cookingTime: 10,
        price: '25.000',
        likes: 29,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/"),
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
                    'images/arrow.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Manis',
          style: TextStyle(
            color: Color(0xFF006A4E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FoodGridWidget(
        foods: recipes,
        onFavoritePressed: (index) {
          final food = recipes[index];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Favorited ${food.name}')),
          );
        },
        onCardTap: (index) {
          final food = recipes[index];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${food.name}')),
          );
        },
      ),
    );
  }
}