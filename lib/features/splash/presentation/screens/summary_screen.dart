import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // To dispatch event to IngredientBloc
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../app_router.dart';
import '../../../../data/models/image_item.dart'; // Adjust path as needed
import '../../../ingredients/bloc/ingredient_bloc.dart'; // For IngredientBloc and events
import '../../../ingredients/widgets/summary_ingredient_card.dart'; // Your new display widget

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<ImageItem> _savedItems = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  Future<void> _loadSavedItems() async {
    // ... (load logic remains the same as before) ...
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemsJsonString = prefs.getString('selectedIngredients');
      if (itemsJsonString != null) {
        final List<dynamic> decodedJsonList =
            jsonDecode(itemsJsonString) as List<dynamic>;
        _savedItems = decodedJsonList
            .map(
              (itemJson) =>
                  ImageItem.fromJson(itemJson as Map<String, dynamic>),
            )
            .toList();
      } else {
        _savedItems = [];
      }
    } catch (e) {
      print("Error loading saved items for summary: $e");
      _savedItems = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading saved items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      // Check mounted before calling setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(ImageItem itemToRemove) async {
    // ... (remove logic remains the same as before, updates _savedItems, shared_prefs, BLoC, and calls setState) ...
    final originalItems = List<ImageItem>.from(
      _savedItems,
    ); // For potential rollback
    setState(() {
      _savedItems.removeWhere((item) => item.id == itemToRemove.id);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> updatedItemsJson = _savedItems
          .map((item) => item.toJson())
          .toList();
      await prefs.setString(
        'selectedIngredients',
        jsonEncode(updatedItemsJson),
      );

      if (mounted) {
        context.read<IngredientBloc>().add(
          SynchronizeSelectedItems(List.from(_savedItems)),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${itemToRemove.name} removed.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("Error saving items after removal: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating saved items: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Rollback UI change if saving failed
        setState(() {
          _savedItems = originalItems;
        });
      }
    }
  }

  void _showRemoveConfirmationDialog(ImageItem item) {
    // ... (confirmation dialog logic remains the same, calls _removeItem) ...
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Remove ${item.name}?'),
          content: const Text(
            'Are you sure you want to remove this ingredient from your selection?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Remove', style: TextStyle(color: Colors.red[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _removeItem(item);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmAndProceed() {
    if (_savedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one ingredient to proceed.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    print(
      "[SummaryScreen] Dispatching ConfirmSummaryAndProceedToResults event.",
    );
    // Dispatch event to BLoC instead of navigating directly
    context.read<IngredientBloc>().add(ConfirmSummaryAndProceedToResults());
  }

  @override
  Widget build(BuildContext context) {
    final screenBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final ThemeData theme = Theme.of(context);

    // Use BlocListener to handle navigation triggered by BLoC states
    return BlocListener<IngredientBloc, IngredientState>(
      listener: (context, state) {
        if (state is NavigateToRecipeResults) {
          print(
            "[SummaryScreen] BlocListener: NavigateToRecipeResults state received. Navigating...",
          );
          // Pass the confirmed ingredients from the state to the next screen
          context.push(
            AppRouter.recipeResultPath,
            extra: List<ImageItem>.from(state.selectedItems),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Your Ingredients'),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded),
              onPressed: _savedItems.isNotEmpty ? _confirmAndProceed : null,
              tooltip: 'Confirm and Proceed',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedItems.isEmpty
            ? Center(
                /* ... empty state text ... */
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No ingredients selected. Go back and add some ingredients to your list.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
              )
            : Stack(
                /* ... Stack with ListView and Gradient for fade ... */
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 80.0,
                    ), // Padding for FAB and fade
                    itemCount: _savedItems.length,
                    itemBuilder: (context, index) {
                      final item = _savedItems[index];
                      return SummaryIngredientCard(
                        item: item,
                        onRemoveTapped: () =>
                            _showRemoveConfirmationDialog(item),
                      );
                    },
                  ),
                  Positioned(
                    /* ... Gradient Fade-out ... */
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 70.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            screenBackgroundColor.withOpacity(0.0),
                            screenBackgroundColor.withOpacity(0.8),
                            screenBackgroundColor.withOpacity(1.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: _savedItems.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _confirmAndProceed,
                label: const Text('Confirm'),
                icon: const Icon(Icons.check_rounded),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              )
            : null,
      ),
    );
  }
}
