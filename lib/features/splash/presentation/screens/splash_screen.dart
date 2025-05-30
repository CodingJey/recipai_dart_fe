import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:go_router/go_router.dart';
import '../../../../app_router.dart';
import '../../../ingredients/bloc/ingredient_bloc.dart'; // Import your BLoC and states

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  StreamSubscription? _blocSubscription; // To listen to BLoC state changes

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();

    // Listen to IngredientBloc for initial load completion
    final ingredientBloc = context.read<IngredientBloc>();

    // Check current state first - useful for hot restarts
    if (ingredientBloc.state is IngredientLoaded) {
      print(
        "[SplashScreen] Ingredients already loaded, navigating immediately.",
      );
      _navigateToCategories();
    } else {
      print("[SplashScreen] Subscribing to IngredientBloc stream.");
      _blocSubscription = ingredientBloc.stream.listen((blocState) {
        print("[SplashScreen] Received BLoC state: ${blocState.runtimeType}");
        if (blocState is IngredientLoaded) {
          print(
            "[SplashScreen] IngredientLoaded state received, navigating to categories.",
          );
          _navigateToCategories();
        } else if (blocState is IngredientError) {
          print(
            "[SplashScreen] IngredientError state received: ${blocState.message}. Navigating anyway or to an error screen.",
          );
          // Decide how to handle initial load error, for now, navigate to categories
          _navigateToCategories(); // Or navigate to a dedicated error screen
        }
      });
      // Optional: Fallback timer in case something unexpected happens with the BLoC stream
      Timer(const Duration(seconds: 7), () {
        // A reasonable timeout
        if (mounted &&
            (_blocSubscription != null ||
                !(ingredientBloc.state is IngredientLoaded))) {
          // Check if not yet navigated
          print(
            "[SplashScreen] Fallback timer expired, attempting navigation to categories.",
          );
          _navigateToCategories();
        }
      });
    }
  }

  void _navigateToCategories() {
    _blocSubscription
        ?.cancel(); // Important to cancel to prevent multiple navigations
    _blocSubscription = null; // Nullify to avoid re-entry in timer
    if (mounted) {
      context.go(AppRouter.categoriesPath);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blocSubscription?.cancel(); // ALWAYS cancel subscriptions in dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method UI remains the same) ...
    return Scaffold(
      body: Container(
        // ... (gradient etc.)
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.red[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'RecipAI',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 4),
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI-Powered Recipe Discovery',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
