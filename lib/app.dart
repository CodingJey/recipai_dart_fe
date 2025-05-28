import 'package:flutter/material.dart';
import 'features/splash/presentation/screens/splash_screen.dart'; // Updated import

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipAI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        // Example: Define a custom primary color and accent color for more control
        // primaryColor: Colors.indigo,
        // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(secondary: Colors.pinkAccent),
      ),
      home: const SplashScreen(), // Ensure SplashScreen is imported correctly
      debugShowCheckedModeBanner: false,
    );
  }
}
