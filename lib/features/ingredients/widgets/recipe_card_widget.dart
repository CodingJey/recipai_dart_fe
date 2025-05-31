import 'package:flutter/material.dart';
import '../../../data/models/recipe_preview.dart'; // Adjust path if necessary

class RecipeCardWidget extends StatelessWidget {
  final RecipePreview recipe;
  final VoidCallback onTap;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior:
          Clip.antiAlias, // Ensures InkWell splash respects border radius
      child: InkWell(
        onTap: onTap,
        splashColor: theme.primaryColor.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // You could add more details here later, like cooking time, difficulty etc.
                    const SizedBox(height: 8),
                    Text(
                      "Tap to see details", // Placeholder subtitle
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  // Assuming placeholder images are in assets
                  recipe.imageUrl,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 80,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: Colors.grey[500],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
