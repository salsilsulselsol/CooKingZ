import 'package:flutter/material.dart';
import '../component/resep_card_widget.dart';
import '../../theme/theme.dart';
import '../component/header_back_PSN.dart';

class ResepAndaPage extends StatelessWidget {
  final EdgeInsets paddingGridView = const EdgeInsets.symmetric(
    horizontal: AppTheme.spacingXLarge,
    vertical: AppTheme.spacingXLarge,
  );

  const ResepAndaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: HeaderBackPSN(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppTheme.spacingXLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(AppTheme.mostViewedContainerPadding),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius:
                    BorderRadius.circular(AppTheme.recipeCardBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Most Viewed Today',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Row(
                    spacing: AppTheme.spacingXLarge,
                    children: [
                      Expanded(
                        child: RecipeCard(
                            title: 'Gulai',
                            rating: '15★',
                            time: '50menit',
                            price: 'RP 50RB',
                            imagePath: 'images/gulai.jpg',
                            showGlow: false),
                      ),
                      Expanded(
                        child: RecipeCard(
                            title: 'Pina Colada',
                            rating: '5★',
                            time: '5menit',
                            price: 'RP 20RB',
                            imagePath: 'images/pina_colada.jpg',
                            showGlow: false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: paddingGridView,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingMedium,
                mainAxisSpacing: AppTheme.spacingXLarge,
                childAspectRatio: 0.75,
                children: [
                  RecipeCard(
                    title: 'Pasta Bechamel',
                    description: 'Krim yang lembut dan memanjakan.',
                    rating: '5★',
                    time: '30menit',
                    price: 'RP 20RB',
                    imagePath: 'images/pasta.jpg',
                  ),
                  RecipeCard(
                    title: 'Grilled Skewers',
                    description: 'Potongan-potongan lezat.',
                    rating: '5★',
                    time: '30menit',
                    price: 'RP 20RB',
                    imagePath: 'images/skewers.png',
                  ),
                  RecipeCard(
                    title: 'kue brownies kacang',
                    description:
                        'Adalah hidangan penutup yang lezat dan nikmat…',
                    rating: '23★',
                    time: '87menit',
                    price: 'RP 47RB',
                    imagePath: 'images/brownies.png',
                  ),
                  RecipeCard(
                    title: 'Oatmeal pancakes',
                    description:
                        'Kelezatan yang bergizi ini menawarkan kepuasan…',
                    rating: '76★',
                    time: '58menit',
                    price: 'RP 88RB',
                    imagePath: 'images/pancakes.jpg',
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