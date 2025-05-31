import 'package:flutter/material.dart';
import '../../../data/models/image_item.dart'; // Adjust path as needed

class SummaryIngredientCard extends StatelessWidget {
  final ImageItem item;
  final VoidCallback onRemoveTapped; // Changed from onLongPress for clarity

  const SummaryIngredientCard({
    super.key,
    required this.item,
    required this.onRemoveTapped, // For the 'X' icon tap
  });

  @override
  Widget build(BuildContext context) {
    // Only create subtype text if there are actually selected subtypes
    final String? selectedSubtypesText = item.selectedSubtypeNames.isNotEmpty
        ? item.selectedSubtypeNames.join(', ')
        : null;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ), // Adjusted margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        // Removed InkWell to make 'X' the primary removal target
        padding: const EdgeInsets.only(
          left: 12.0,
          top: 12.0,
          bottom: 12.0,
          right: 4.0,
        ), // Adjust right padding for IconButton
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                item.imageUrl,
                width: 65, // Slightly adjusted size
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 65,
                  height: 65,
                  color: Colors.grey[300],
                  child: Icon(Icons.fastfood, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 17, // Slightly adjusted size
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedSubtypesText !=
                      null) // Conditionally display subtype text
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Ingredients: $selectedSubtypesText",
                        style: TextStyle(
                          fontSize: 13, // Slightly adjusted size
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red[600],
                size: 24,
              ), // 'X' icon
              onPressed: onRemoveTapped, // Trigger removal
              tooltip: 'Remove ${item.name}',
              padding: EdgeInsets.zero, // Reduce padding for a tighter fit
              constraints: const BoxConstraints(), // Reduce constraints
            ),
          ],
        ),
      ),
    );
  }
}
