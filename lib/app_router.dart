import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipai_app/features/splash/presentation/screens/category_selection_screen.dart';
import 'features/ingredients/presentation/screens/image_box_screen.dart';
// import 'features/summary/screens/summary_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart'; // Import SplashScreen

class AppRouter {
  static const String splashPath = '/splash';
  static const String categoriesPath = '/categories'; // New path for categories
  static const String ingredientsPath = '/ingredients';
  static const String summaryPath = '/summary';

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
          // Later, you might receive a categoryId or name here from the state
          // final String? categoryId = state.pathParameters['categoryId'];
          // final String? categoryName = state.extra as String?;
          return const ImageBoxScreen(); // For now, it shows all ingredients
        },
      ),
      // GoRoute(
      //   path: summaryPath,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const SummaryScreen();
      //   },
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Error: ${state.error?.message ?? 'Page not found'}'),
      ),
    ),
  );
}
