import 'package:flutter/material.dart';
import 'package:recipai_app/data/models/image_item.dart'; // Main ingredient model
import '../../../../../data/models/recipe_preview.dart'; // Your new recipe preview model
import '../../../ingredients/widgets/recipe_card_widget.dart'; // Your new recipe card widget

class RecipeResultScreen extends StatefulWidget {
  final List<ImageItem> selectedIngredients;

  const RecipeResultScreen({super.key, required this.selectedIngredients});

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  bool _isGeneratingRecipes = true;
  List<RecipePreview> _generatedRecipes = []; // To store placeholder recipes

  @override
  void initState() {
    super.initState();
    _generateMockRecipes();
  }

  void _generateMockRecipes() {
    // Simulate recipe generation delay and create placeholder data
    setState(() {
      _isGeneratingRecipes = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Create some mock recipes based on the number of ingredients or just static ones
        // For now, let's create a few static placeholders.
        // Ensure you have these images in your assets folder.
        final List<RecipePreview> mockRecipes = [
          RecipePreview(
            id: '1',
            title: 'Spicy Chicken Stir-fry',
            imageUrl: 'assets/images/recipes/stir_fry.png',
          ),
          RecipePreview(
            id: '2',
            title: 'Creamy Tomato Pasta with Chicken',
            imageUrl: 'assets/images/recipes/pasta.png',
          ),
          RecipePreview(
            id: '3',
            title: 'Hearty Vegetable Soup',
            imageUrl: 'assets/images/recipes/soup.png',
          ),
          RecipePreview(
            id: '4',
            title: 'Quick Omelette with Herbs',
            imageUrl: 'assets/images/recipes/omelette.png',
          ),
        ];

        // If you want to vary based on selected ingredients (example)
        if (widget.selectedIngredients.any(
          (item) => item.name.toLowerCase().contains('egg'),
        )) {
          // mockRecipes.add(RecipePreview(id: '4', title: 'Quick Omelette with Herbs', imageUrl: 'assets/images/recipes/omelette.png'));
        }
        if (widget.selectedIngredients.length > 2) {
          // mockRecipes.add(RecipePreview(id: '5', title: 'Gourmet Multi-Ingredient Dish', imageUrl: 'assets/images/recipes/gourmet.png'));
        }

        setState(() {
          _generatedRecipes = mockRecipes
              .take(3)
              .toList(); // Take first 3 or so
          _isGeneratingRecipes = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Ideas'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        // If you want a back button explicitly to SummaryScreen, though go_router handles stack.
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     if (context.canPop()) context.pop();
        //     else context.go(AppRouter.summaryPath); // Fallback
        //   },
        // ),
      ),
      body: _isGeneratingRecipes
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Finding amazing recipes for you based on ${widget.selectedIngredients.length} ingredients...',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : _generatedRecipes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not find recipes for the selected ingredients. Try changing your selection.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _generatedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _generatedRecipes[index];
                return RecipeCardWidget(
                  recipe: recipe,
                  onTap: () {
                    // Placeholder for navigating to recipe details screen
                    print('Tapped on recipe: ${recipe.title}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${recipe.title}')),
                    );
                    // Example: context.push('/recipe-details/${recipe.id}');
                  },
                );
              },
            ),
    );
  }
}
