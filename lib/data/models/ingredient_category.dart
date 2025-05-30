import 'package:equatable/equatable.dart';

class IngredientCategory extends Equatable {
  final String id;
  final String name;
  final String imagePath; // Background image for the category bar

  const IngredientCategory({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [id, name, imagePath];
}
