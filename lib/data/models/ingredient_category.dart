import 'package:equatable/equatable.dart';

class IngredientCategory extends Equatable {
  final String name;
  final String imagePath; // Background image for the category bar

  const IngredientCategory({required this.name, required this.imagePath});

  @override
  List<Object?> get props => [name, imagePath];
}
