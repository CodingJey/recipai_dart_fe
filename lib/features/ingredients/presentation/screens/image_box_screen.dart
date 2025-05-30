import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ingredient_bloc.dart';
import '../../widgets/image_box_widget.dart';
import '../../widgets/selected_list_box_widget.dart';
import 'package:go_router/go_router.dart'; // For navigation
import '../../../../app_router.dart';

class ImageBoxScreen extends StatelessWidget {
  final String? targetCategoryId; // Received from router
  final String? targetCategoryDisplayName; // Received from router

  const ImageBoxScreen({
    super.key,
    this.targetCategoryId,
    this.targetCategoryDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Use the target category name for the initial title if available,
    // otherwise fall back to BLoC state or a default.
    String initialScreenTitle =
        targetCategoryDisplayName ?? 'Select Ingredients';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: BlocBuilder<IngredientBloc, IngredientState>(
          builder: (context, state) {
            String screenTitle =
                initialScreenTitle; // Use initial/target name first
            if (state is IngredientLoaded) {
              // If BLoC has caught up and confirmed the category, use its display name
              if (state.currentCategoryId == targetCategoryId &&
                  state.currentCategoryDisplayName != null) {
                screenTitle = state.currentCategoryDisplayName!;
              } else if (targetCategoryId == null &&
                  state.currentCategoryDisplayName == null) {
                // If no target category was specified and BLoC also has no category, show "All"
                screenTitle = 'All Ingredients';
              }
            }
            return Text(
              screenTitle,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.categoriesPath);
            }
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[600]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: BlocConsumer<IngredientBloc, IngredientState>(
        listener: (context, state) {
          // ... (listener logic for save operations as before)
          if (state is SelectedItemsSaveSuccess) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Items saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.push(AppRouter.summaryPath);
          } else if (state is SelectedItemsSaveError) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving items: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SelectedItemsSaving) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saving items...'),
                duration: Duration(milliseconds: 800),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IngredientInitial ||
              (state is IngredientLoading && state is! IngredientLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IngredientError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is IngredientLoaded) {
            // Check if the BLoC's current category matches the target category for this screen instance
            // OR if no target category was specified (e.g. deep link directly to /ingredients)
            bool categoryDataReady =
                (targetCategoryId == null &&
                    state.currentCategoryId ==
                        null) || // Showing "All" by default
                (state.currentCategoryId == targetCategoryId);

            if (!categoryDataReady && targetCategoryId != null) {
              print(
                "[ImageBoxScreen] Waiting for BLoC state to match target category: $targetCategoryId. Current BLoC category: ${state.currentCategoryId}",
              );
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      "Loading ${targetCategoryDisplayName ?? 'ingredients'}...",
                    ),
                  ],
                ),
              );
            }

            final itemsToDisplayInGrid = state.displayedAvailableItems;
            final selectedItemsFromState = state.selectedItems;
            final currentCategoryDisplayNameFromState =
                state.currentCategoryDisplayName;

            // Use targetCategoryDisplayName for the section header if BLoC hasn't caught up, otherwise use BLoC's
            final String sectionTitleCategoryName =
                (state.currentCategoryId == targetCategoryId &&
                    currentCategoryDisplayNameFromState != null)
                ? currentCategoryDisplayNameFromState
                : (targetCategoryDisplayName ?? "All");

            return Column(
              children: [
                Container(
                  /* Selected items bar - as before */
                  height: 120,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ), // Added vertical padding
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: 1, // Reduced spread
                      ),
                    ],
                  ),
                  child: selectedItemsFromState.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'Tap items below to add them to your selection',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600], // Slightly darker grey
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: selectedItemsFromState.length,
                          itemBuilder: (context, index) {
                            final itemToDisplay = selectedItemsFromState[index];
                            return SelectedImageBox(
                              key: ValueKey(
                                "selected_${itemToDisplay.id}_${itemToDisplay.selectedSubtypeNames.join('_')}",
                              ),
                              item: itemToDisplay,
                              onRemove: () => context
                                  .read<IngredientBloc>()
                                  .add(ToggleItemSelectionEvent(itemToDisplay)),
                            );
                          },
                        ),
                ),
                // Available Ingredients Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Available in "$sectionTitleCategoryName"',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[850],
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              itemsToDisplayInGrid.isEmpty &&
                                  (targetCategoryId != null ||
                                      currentCategoryDisplayNameFromState !=
                                          null)
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      'No ingredients found for "$sectionTitleCategoryName".',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  /* ... as before, using itemsToDisplayInGrid ... */
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            MediaQuery.of(context).size.width >
                                                600
                                            ? 3
                                            : 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.92,
                                      ),
                                  itemCount: itemsToDisplayInGrid.length,
                                  itemBuilder: (context, index) {
                                    final item = itemsToDisplayInGrid[index];
                                    final isSelected = selectedItemsFromState
                                        .any(
                                          (selected) => selected.id == item.id,
                                        );
                                    return ImageBoxWidget(
                                      key: ValueKey(
                                        "available_${item.id}_${item.selectedSubtypeNames.join('_')}_$isSelected",
                                      ),
                                      item: item,
                                      isSelected: isSelected,
                                      onTap: () => context
                                          .read<IngredientBloc>()
                                          .add(ToggleItemSelectionEvent(item)),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Text('Loading or encountered an unknown state.'),
          );
        },
      ),
      floatingActionButton: BlocBuilder<IngredientBloc, IngredientState>(
        builder: (context, state) {
          // Show FAB only if in a loaded state, items are selected, and not currently saving
          if (state is IngredientLoaded &&
              state.selectedItems.isNotEmpty &&
              state is! SelectedItemsSaving) {
            // Ensure not in saving state specifically
            return FloatingActionButton(
              onPressed: () {
                context.read<IngredientBloc>().add(
                  SaveSelectedItemsAndProceed(),
                );
              },
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
              tooltip: 'Proceed with selected items',
              child: const Icon(Icons.arrow_forward_ios_rounded),
            );
          }
          return const SizedBox.shrink(); // Hide FAB otherwise
        },
      ),
    );
  }
}
