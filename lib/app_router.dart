import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipai_app/data/models/image_item.dart';
import 'package:recipai_app/features/splash/presentation/screens/category_selection_screen.dart';
import 'package:recipai_app/features/splash/presentation/screens/recipe_result_screen.dart';
import 'features/ingredients/presentation/screens/image_box_screen.dart';
import 'features/splash/presentation/screens/summary_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'data/models/ingredient_category.dart';

class AppRouter {
  static const String splashPath = '/splash';
  static const String categoriesPath = '/categories';
  static const String ingredientsPath = '/ingredients';
  static const String summaryPath = '/summary';
  static const String recipeResultPath = '/recipe-result';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    routes: <RouteBase>[
      GoRoute(
        path: splashPath,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: categoriesPath, // Define route for Category Selection Screen
        builder: (BuildContext context, GoRouterState state) {
          return const CategorySelectionScreen();
        },
      ),
      GoRoute(
        path: ingredientsPath,
        builder: (BuildContext context, GoRouterState state) {
          // Expect a map with 'id' and 'name' for the category
          final Map<String, String>? categoryInfo =
              state.extra as Map<String, String>?;
          return ImageBoxScreen(
            targetCategoryId: categoryInfo?['id'],
            targetCategoryDisplayName: categoryInfo?['name'],
          );
        },
      ),
      GoRoute(
        path: summaryPath,
        builder: (BuildContext context, GoRouterState state) {
          return const SummaryScreen();
        },
      ),
      GoRoute(
        path: recipeResultPath,
        builder: (BuildContext context, GoRouterState state) {
          // Receive the list of ImageItem passed as 'extra'
          final List<ImageItem>? selectedIngredients =
              state.extra as List<ImageItem>?;
          return RecipeResultScreen(
            selectedIngredients:
                selectedIngredients ?? [], // Pass to the screen
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Error: ${state.error?.message ?? 'Page not found'}'),
      ),
    ),
  );
}
