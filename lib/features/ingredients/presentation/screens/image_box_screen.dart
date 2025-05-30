import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ingredient_bloc.dart';
import '../../widgets/image_box_widget.dart';
import '../../widgets/selected_list_box_widget.dart';

class ImageBoxScreen extends StatelessWidget {
  const ImageBoxScreen({super.key});

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
      body: BlocBuilder<IngredientBloc, IngredientState>(
        builder: (context, state) {
          if (state is IngredientInitial || state is IngredientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IngredientError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is IngredientLoaded) {
            final availableItems = state.displayedAvailableItems;
            final selectedItems = state.selectedItems;

            return Column(
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
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
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
                            final itemToDisplay = selectedItems[index];
                            return SelectedImageBox(
                              key: ValueKey(
                                "selected_${itemToDisplay.id}_${itemToDisplay.selectedSubtypeNames.join()}",
                              ),
                              item: itemToDisplay,
                              onRemove: () => context
                                  .read<IngredientBloc>()
                                  .add(ToggleItemSelectionEvent(itemToDisplay)),
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 600
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
                                key: ValueKey(
                                  "available_${item.id}_${item.selectedSubtypeNames.join()}_$isSelected",
                                ),
                                item: item,
                                isSelected: isSelected,
                                onTap: () => context.read<IngredientBloc>().add(
                                  ToggleItemSelectionEvent(item),
                                ),
                                // onSubtypeToggled is handled within ImageBoxWidget now
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
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
