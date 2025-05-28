import 'package:flutter/material.dart';
import '../../../../data/models/image_item.dart'; // Updated import
import '../../../../data/sources/ingredient_data.dart'; // Import initial data
import '../../widgets/image_box_widget.dart'; // Updated import
import '../../widgets/selected_image_box_widget.dart'; // Updated import

class ImageBoxScreen extends StatefulWidget {
  const ImageBoxScreen({super.key});

  @override
  _ImageBoxScreenState createState() => _ImageBoxScreenState();
}

class _ImageBoxScreenState extends State<ImageBoxScreen> {
  List<ImageItem> availableItems = List.from(
    initialAvailableItems.map((item) => item.copyWith()),
  ); // Ensure deep copy for mutable lists
  List<ImageItem> selectedItems = [];

  void toggleItemSelection(ImageItem item) {
    setState(() {
      final isCurrentlySelected = selectedItems.any(
        (selected) => selected.id == item.id,
      );
      int availableItemIndex = availableItems.indexWhere(
        (availItem) => availItem.id == item.id,
      );

      if (isCurrentlySelected) {
        selectedItems.removeWhere((selected) => selected.id == item.id);
        // When deselecting an item, also clear its selected subtypes in the availableItems list.
        if (availableItemIndex != -1 &&
            availableItems[availableItemIndex]
                .selectedSubtypeNames
                .isNotEmpty) {
          var currentSubtypes = List<String>.from(
            availableItems[availableItemIndex].selectedSubtypeNames,
          );
          currentSubtypes.clear(); // Clear the list
          availableItems[availableItemIndex] =
              availableItems[availableItemIndex].copyWith(
                selectedSubtypeNames: currentSubtypes,
                // Pass the cleared list
              );
        }
      } else {
        if (availableItemIndex != -1) {
          // Ensure the item added to selectedItems is the one from availableItems
          // which holds the subtype selections.
          selectedItems.add(availableItems[availableItemIndex]);
        }
      }
    });
  }

  // Renamed and logic updated for toggling a single subtype name
  void toggleItemSubtype(int itemId, String subtypeNameToggled) {
    setState(() {
      int availableIndex = availableItems.indexWhere(
        (item) => item.id == itemId,
      );
      if (availableIndex != -1) {
        // Get the current list of selected subtypes for the item
        List<String> currentSelectedSubtypes = List.from(
          availableItems[availableIndex].selectedSubtypeNames,
        );

        // Toggle the presence of subtypeNameToggled
        if (currentSelectedSubtypes.contains(subtypeNameToggled)) {
          currentSelectedSubtypes.remove(subtypeNameToggled);
        } else {
          currentSelectedSubtypes.add(subtypeNameToggled);
        }

        // Update the item in availableItems with the new list of selected subtypes
        availableItems[availableIndex] = availableItems[availableIndex]
            .copyWith(selectedSubtypeNames: currentSelectedSubtypes);

        // If the item is also in selectedItems, update it there too to ensure consistency.
        int selectedIndex = selectedItems.indexWhere(
          (item) => item.id == itemId,
        );
        if (selectedIndex != -1) {
          selectedItems[selectedIndex] =
              availableItems[availableIndex]; // Keep them in sync
        }

        // If the item was not selected but now has subtypes, and is in availableItems,
        // it might need to be added to selectedItems if that's the desired behavior.
        // Current logic: item is added to selectedItems only by toggleItemSelection.
        // If subtypes are selected for an unselected item, it doesn't auto-select the main item.
        // This seems fine. The main item must be tapped first.
        bool isMainItemSelected = selectedItems.any(
          (item) => item.id == itemId,
        );
        if (!isMainItemSelected && currentSelectedSubtypes.isNotEmpty) {
          // If you want to auto-select the main item when a subtype is chosen for an unselected item:
          // selectedItems.add(availableItems[availableIndex]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.red[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'RecipAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[600]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: selectedItems.isEmpty
                ? Center(
                    child: Text(
                      'Tap items below to add them to your selection',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      // Ensure we're showing the item from selectedItems
                      final itemToDisplay = selectedItems[index];
                      return SelectedImageBox(
                        key: ValueKey(
                          itemToDisplay.id,
                        ), // Add key for better list management
                        item: itemToDisplay,
                        onRemove: () => toggleItemSelection(itemToDisplay),
                      );
                    },
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: availableItems.length,
                      itemBuilder: (context, index) {
                        final item = availableItems[index];
                        final isSelected = selectedItems.any(
                          (selected) => selected.id == item.id,
                        );
                        return ImageBoxWidget(
                          key: ValueKey(item.id),
                          item: item,
                          isSelected: isSelected,
                          onTap: () => toggleItemSelection(item),
                          onSubtypeToggled:
                              (
                                subtypeNameToggled,
                              ) => // Use the new callback name
                              toggleItemSubtype(
                                item.id,
                                subtypeNameToggled,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
