import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app_router.dart'; // Your AppRouter for path constants
import '../../../../data/models/ingredient_category.dart';
import '../../../../data/sources/category_data.dart'; // Your static category data

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Category'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        automaticallyImplyLeading: false, // No back button to splash
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: ingredientCategories.length,
        itemBuilder: (context, index) {
          final category = ingredientCategories[index];
          return CategoryCard(category: category);
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IngredientCategory category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Ensures the image respects border radius
      child: InkWell(
        onTap: () {
          // For now, navigate to the general ingredients screen.
          // Later, you might pass category.name or an ID to filter.
          context.push(AppRouter.ingredientsPath);
        },
        splashColor: theme.primaryColor.withOpacity(0.3),
        child: Container(
          height: 150, // Decently sized horizontal bar
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(category.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(
                  0.45,
                ), // Darken image for text readability
                BlendMode.darken,
              ),
              onError: (exception, stackTrace) {
                // Optional: You can log the error or handle it
                // print('Error loading image for ${category.name}: $exception');
              },
            ),
          ),
          child: Center(
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
