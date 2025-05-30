import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart'; // Your GoRouter configuration
import 'features/ingredients/bloc/ingredient_bloc.dart'; // Your IngredientBloc

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IngredientBloc()..add(LoadIngredients()),
      child: MaterialApp.router(
        title: 'RecipAI Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: Colors.deepPurple[600],
          primaryColorDark: Colors.deepPurple[800],
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.orangeAccent, // Or your preferred accent
          ).copyWith(onPrimary: Colors.white),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto', // Example font
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
