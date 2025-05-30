import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/sources/ingredient_data.dart';
// data models - ensure paths are correct relative to this BLoC file
import '../../../data/models/image_item.dart';
import '../../../data/models/subtype_detail.dart';

// Part directives to link event and state files
part 'ingredient_event.dart';
part 'ingredient_state.dart';

// Base definitions for ingredients - this could also be loaded from a JSON or other source
final List<Map<String, dynamic>> _baseIngredientDefinitions = baseIngredients;

class IngredientBloc extends Bloc<IngredientEvent, IngredientState> {
  Map<String, List<SubtypeDetail>> _staticSubtypeData = {};
  List<ImageItem> _masterIngredientList = []; // To store all loaded ingredients

  IngredientBloc() : super(IngredientInitial()) {
    on<LoadIngredients>(_onLoadIngredients);
    on<SetDisplayCategory>(_onSetDisplayCategory); // Register new event handler
    on<ToggleItemSelectionEvent>(_onToggleItemSelection);
    on<ToggleItemSubtypeEvent>(_onToggleItemSubtype);
    on<SaveSelectedItemsAndProceed>(_onSaveSelectedItemsAndProceed);
  }

  Future<void> _onLoadIngredients(
    LoadIngredients event,
    Emitter<IngredientState> emit,
  ) async {
    emit(IngredientLoading());
    try {
      final String subtypeJsonString = await rootBundle.loadString(
        'assets/data/ingredient_subtypes.json',
      );
      final Map<String, dynamic> subtypeJsonMap = jsonDecode(subtypeJsonString);
      _staticSubtypeData = subtypeJsonMap.map((itemName, subtypesDynamic) {
        final List<dynamic> subtypeListDynamic =
            subtypesDynamic as List<dynamic>;
        final List<SubtypeDetail> subtypeDetails = subtypeListDynamic
            .map(
              (subtypeMapDynamic) =>
                  SubtypeDetail(name: subtypeMapDynamic['name'] as String),
            )
            .toList();
        return MapEntry(itemName, subtypeDetails);
      });

      _masterIngredientList = _baseIngredientDefinitions.map((itemDef) {
        // Populate master list
        final String itemName = itemDef['name'] as String;
        final List<SubtypeDetail> subtypesForItem =
            _staticSubtypeData[itemName] ?? [];
        final String categoryName =
            itemDef['categoryName'] as String? ??
            'Uncategorized'; // Get categoryName

        return ImageItem(
          id: itemDef['id'] as int,
          name: itemName,
          imageUrl: itemDef['imageUrl'] as String,
          categoryName: categoryName, // Pass categoryName
          subtypes: subtypesForItem,
          selectedSubtypeNames: [],
        );
      }).toList();

      emit(
        IngredientLoaded(
          allMasterItems: _masterIngredientList,
          displayedAvailableItems:
              _masterIngredientList, // Initially display all
          selectedItems: [],
          currentCategoryName: null, // No category selected initially
        ),
      );
    } catch (e) {
      print("Error loading ingredients: $e");
      emit(IngredientError("Failed to load ingredients: ${e.toString()}"));
    }
  }

  void _onSetDisplayCategory(
    SetDisplayCategory event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      final categoryName = event.categoryName;
      final filteredItems = _masterIngredientList
          .where((item) => item.categoryName == categoryName)
          .toList();

      emit(
        currentState.copyWith(
          displayedAvailableItems: filteredItems,
          currentCategoryName: categoryName,
          // Potentially reset selectedItems if category changes, or handle selections across categories
          // For now, selectedItems are preserved.
        ),
      );
    }
  }

  void _onToggleItemSelection(
    ToggleItemSelectionEvent event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      // Operate on currentState.allMasterItems for available items if needed for consistency
      // or directly on displayedAvailableItems if that's the source for toggling.
      // The logic here might need to ensure that toggling an item updates it correctly in both
      // allMasterItems (if it's mutable there for subtype selections) and selectedItems.

      List<ImageItem> newMasterItems = List.from(currentState.allMasterItems);
      List<ImageItem> newSelectedItems = List.from(currentState.selectedItems);
      final itemToToggle = event.item;

      final isCurrentlySelected = newSelectedItems.any(
        (selected) => selected.id == itemToToggle.id,
      );
      int masterItemIndex = newMasterItems.indexWhere(
        (avail) => avail.id == itemToToggle.id,
      );

      if (isCurrentlySelected) {
        newSelectedItems.removeWhere(
          (selected) => selected.id == itemToToggle.id,
        );
        if (masterItemIndex != -1) {
          // Clear subtypes of the item in the master list when fully deselected from the top
          newMasterItems[masterItemIndex] = newMasterItems[masterItemIndex]
              .copyWith(selectedSubtypeNames: []);
        }
      } else {
        if (masterItemIndex != -1) {
          // Add the version from the master list (which reflects current subtype selections)
          newSelectedItems.add(newMasterItems[masterItemIndex]);
        } else {
          // Should not happen if item came from UI displaying master/displayed items
          newSelectedItems.add(
            itemToToggle.copyWith(categoryName: itemToToggle.categoryName),
          );
        }
      }

      // Re-filter displayed items based on the current category if master items were modified
      final String? currentCategory = currentState.currentCategoryName;
      final List<ImageItem> newDisplayedItems = currentCategory != null
          ? newMasterItems
                .where((item) => item.categoryName == currentCategory)
                .toList()
          : newMasterItems;

      emit(
        currentState.copyWith(
          allMasterItems:
              newMasterItems, // Persist changes to master list (e.g. cleared subtypes)
          displayedAvailableItems: newDisplayedItems,
          selectedItems: newSelectedItems,
        ),
      );
    }
  }

  void _onToggleItemSubtype(
    ToggleItemSubtypeEvent event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;

      // Update in the master list
      List<ImageItem> newMasterItems = currentState.allMasterItems.map((item) {
        if (item.id == event.itemId) {
          List<String> currentSelectedSubtypes = List.from(
            item.selectedSubtypeNames,
          );
          if (currentSelectedSubtypes.contains(event.subtypeNameToggled)) {
            currentSelectedSubtypes.remove(event.subtypeNameToggled);
          } else {
            currentSelectedSubtypes.add(event.subtypeNameToggled);
          }
          return item.copyWith(selectedSubtypeNames: currentSelectedSubtypes);
        }
        return item;
      }).toList();

      // Update in selectedItems if present, ensuring it's the same instance from newMasterItems
      List<ImageItem> newSelectedItems = currentState.selectedItems.map((item) {
        if (item.id == event.itemId) {
          return newMasterItems.firstWhere(
            (masterItem) => masterItem.id == event.itemId,
          );
        }
        return item;
      }).toList();

      // Re-filter displayed items based on the current category
      final String? currentCategory = currentState.currentCategoryName;
      final List<ImageItem> newDisplayedItems = currentCategory != null
          ? newMasterItems
                .where((item) => item.categoryName == currentCategory)
                .toList()
          : newMasterItems;

      emit(
        currentState.copyWith(
          allMasterItems: newMasterItems,
          displayedAvailableItems: newDisplayedItems,
          selectedItems: newSelectedItems,
        ),
      );
    }
  }

  Future<void> _onSaveSelectedItemsAndProceed(
    /* ... as before ... */
    SaveSelectedItemsAndProceed event,
    Emitter<IngredientState> emit,
  ) async {
    if (state is IngredientLoaded) {
      final currentLoadedState =
          state as IngredientLoaded; // Cast to access all fields
      emit(
        SelectedItemsSaving(
          // Pass all relevant fields from currentLoadedState
          allMasterItems: currentLoadedState.allMasterItems,
          displayedAvailableItems: currentLoadedState.displayedAvailableItems,
          selectedItems: currentLoadedState.selectedItems,
          currentCategoryName: currentLoadedState.currentCategoryName,
        ),
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        final List<Map<String, dynamic>> itemsToSaveJson = currentLoadedState
            .selectedItems
            .map((item) => item.toJson())
            .toList();
        await prefs.setString(
          'selectedIngredients',
          jsonEncode(itemsToSaveJson),
        );

        emit(
          SelectedItemsSaveSuccess(
            // Pass all relevant fields
            allMasterItems: currentLoadedState.allMasterItems,
            displayedAvailableItems: currentLoadedState.displayedAvailableItems,
            selectedItems: currentLoadedState.selectedItems,
            currentCategoryName: currentLoadedState.currentCategoryName,
          ),
        );
      } catch (e) {
        emit(
          SelectedItemsSaveError(
            // Pass all relevant fields
            errorMessage: "Failed to save items: ${e.toString()}",
            allMasterItems: currentLoadedState.allMasterItems,
            displayedAvailableItems: currentLoadedState.displayedAvailableItems,
            selectedItems: currentLoadedState.selectedItems,
            currentCategoryName: currentLoadedState.currentCategoryName,
          ),
        );
      }
    }
  }
}
