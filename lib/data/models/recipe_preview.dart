import 'package:equatable/equatable.dart';

class RecipePreview extends Equatable {
  final String id;
  final String title;
  final String imageUrl; // Placeholder for recipe image

  const RecipePreview({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, imageUrl];
}
