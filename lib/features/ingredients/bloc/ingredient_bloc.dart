import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:recipai_app/data/models/ingredient_category.dart';
import 'package:recipai_app/data/sources/category_data.dart';
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
  List<IngredientCategory> _allCategories = []; // Declared here

  IngredientBloc() : super(IngredientInitial()) {
    on<LoadIngredients>(_onLoadIngredients);
    on<SetDisplayCategory>(_onSetDisplayCategory);
    on<ShowAllIngredients>(_onShowAllIngredients);
    on<ToggleItemSelectionEvent>(_onToggleItemSelection);
    on<ToggleItemSubtypeEvent>(_onToggleItemSubtype);
    on<SaveSelectedItemsAndProceed>(_onSaveSelectedItemsAndProceed);
  }

  Future<void> _onLoadIngredients(
    LoadIngredients event,
    Emitter<IngredientState> emit,
  ) async {
    emit(IngredientLoading());
    _allCategories = List.from(
      ingredientCategories,
    ); // Assuming ingredientCategories is your global list
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
        final String categoryId =
            itemDef['categoryId'] as String? ?? 'uncategorized';

        return ImageItem(
          id: itemDef['id'] as int,
          name: itemName,
          imageUrl: itemDef['imageUrl'] as String,
          categoryId: categoryId,
          subtypes: subtypesForItem,
          selectedSubtypeNames: [],
        );
      }).toList();

      emit(
        IngredientLoaded(
          allMasterItems: _masterIngredientList,
          displayedAvailableItems: _masterIngredientList,
          selectedItems: [],
          currentCategoryId: null,
          currentCategoryDisplayName: null,
        ),
      );
    } catch (e) {
      print("Error loading ingredients: $e");
      emit(IngredientError("Failed to load ingredients: ${e.toString()}"));
    }
  }

  void _onShowAllIngredients(
    ShowAllIngredients event,
    Emitter<IngredientState> emit,
  ) {
    print("[Bloc._onShowAllIngredients] Received event.");
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      emit(
        currentState.copyWith(
          displayedAvailableItems:
              currentState.allMasterItems, // Show all items
          currentCategoryId: null, // Clear category ID
          currentCategoryDisplayName: null, // Clear category display name
          // Ensure allMasterItems and selectedItems are preserved by copyWith
          allMasterItems: currentState.allMasterItems,
          selectedItems: currentState.selectedItems,
        ),
      );
      print(
        "[Bloc._onShowAllIngredients] Emitted state to display all items. Displayed: ${currentState.allMasterItems.length}",
      );
    } else {
      print(
        "[Bloc._onShowAllIngredients] Current state is NOT IngredientLoaded. State: $state.",
      );
      // If not loaded yet, LoadIngredients should handle showing all by default.
      // This event primarily makes sense if ingredients are already loaded.
    }
  }

  void _onSetDisplayCategory(
    SetDisplayCategory event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      final newTargetCategoryId = event.categoryId;

      print(
        "[Bloc._onSetDisplayCategory] Current BLoC state before update: currentCategoryId='${currentState.currentCategoryId}', displayedItemsCount=${currentState.displayedAvailableItems.length}",
      );
      print(
        "[Bloc._onSetDisplayCategory] _allCategories count: ${_allCategories.length}",
      ); // Check if _allCategories is populated

      final filteredItems =
          _masterIngredientList // Filter from the BLoC's master list
              .where((item) => item.categoryId == newTargetCategoryId)
              .toList();

      String? newCategoryDisplayName;
      if (_allCategories.isNotEmpty) {
        // Ensure _allCategories is not empty before using firstWhere
        try {
          newCategoryDisplayName = _allCategories
              .firstWhere((cat) => cat.id == newTargetCategoryId)
              .name;
        } catch (e) {
          newCategoryDisplayName = "Category (ID: $newTargetCategoryId)";
          print(
            "[Bloc._onSetDisplayCategory] Warning: Could not find display name for category ID '$newTargetCategoryId' in _allCategories. Error: $e",
          );
        }
      } else {
        newCategoryDisplayName = "Category (ID: $newTargetCategoryId)";
        print(
          "[Bloc._onSetDisplayCategory] Warning: _allCategories list is empty. Cannot find display name.",
        );
      }

      print(
        "[Bloc._onSetDisplayCategory] Filtering complete. For categoryId='${newTargetCategoryId}', found ${filteredItems.length} items. DisplayName='${newCategoryDisplayName}'",
      );

      final newState = currentState.copyWith(
        displayedAvailableItems: filteredItems,
        currentCategoryId: newTargetCategoryId,
        currentCategoryDisplayName: newCategoryDisplayName,
        allMasterItems:
            currentState.allMasterItems, // Ensure these are carried over
        selectedItems: currentState.selectedItems,
      );

      emit(newState);

      print(
        "[Bloc._onSetDisplayCategory] EMITTED new state: currentCategoryId='${newState.currentCategoryId}', currentCategoryDisplayName='${newState.currentCategoryDisplayName}', displayedItemsCount=${newState.displayedAvailableItems.length}",
      );
    } else {
      print(
        "[Bloc._onSetDisplayCategory] Current state is NOT IngredientLoaded. State: $state. Event for '${event.categoryId}' will not be fully processed.",
      );
    }
  }

  // ... rest of _onToggleItemSelection, _onToggleItemSubtype, _onSaveSelectedItemsAndProceed
  // These should remain as in the previous fully corrected version, ensuring they use
  // currentState.currentCategoryId and currentState.currentCategoryDisplayName when emitting new states via copyWith,
  // and re-filter displayedAvailableItems from the updated _masterIngredientList.
  // For brevity, I'm not repeating them here but ensure they are complete from the prior correct version.
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
          newMasterItems[masterItemIndex] = newMasterItems[masterItemIndex]
              .copyWith(selectedSubtypeNames: []);
        }
      } else {
        if (masterItemIndex != -1) {
          // Add the version from the master list (which reflects current subtype selections)
          newSelectedItems.add(newMasterItems[masterItemIndex]);
        } else {
          newSelectedItems.add(itemToToggle.copyWith());
        }
      }

      final String? currentCatId = currentState.currentCategoryId;
      final List<ImageItem> newDisplayedItems = currentCatId != null
          ? newMasterItems
                .where((item) => item.categoryId == currentCatId)
                .toList()
          : newMasterItems;

      emit(
        currentState.copyWith(
          allMasterItems:
              newMasterItems, // Persist changes to master list (e.g. cleared subtypes)
          displayedAvailableItems: newDisplayedItems,
          selectedItems: newSelectedItems,
          // currentCategoryId and currentCategoryDisplayName are preserved by copyWith by default
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
          List<String> currentSelectedSubtypeNames = List.from(
            item.selectedSubtypeNames,
          );
          if (currentSelectedSubtypeNames.contains(event.subtypeNameToggled)) {
            currentSelectedSubtypeNames.remove(event.subtypeNameToggled);
          } else {
            currentSelectedSubtypeNames.add(event.subtypeNameToggled);
          }
          return item.copyWith(
            selectedSubtypeNames: currentSelectedSubtypeNames,
          );
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

      final String? currentCatId = currentState.currentCategoryId;
      final List<ImageItem> newDisplayedItems = currentCatId != null
          ? newMasterItems
                .where((item) => item.categoryId == currentCatId)
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
    SaveSelectedItemsAndProceed event,
    Emitter<IngredientState> emit,
  ) async {
    if (state is IngredientLoaded) {
      final currentLoadedState = state as IngredientLoaded;
      emit(
        SelectedItemsSaving(
          // Pass all relevant fields from currentLoadedState
          allMasterItems: currentLoadedState.allMasterItems,
          displayedAvailableItems: currentLoadedState.displayedAvailableItems,
          selectedItems: currentLoadedState.selectedItems,
          currentCategoryId: currentLoadedState.currentCategoryId,
          currentCategoryDisplayName:
              currentLoadedState.currentCategoryDisplayName,
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
            currentCategoryId: currentLoadedState.currentCategoryId,
            currentCategoryDisplayName:
                currentLoadedState.currentCategoryDisplayName,
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
            currentCategoryId: currentLoadedState.currentCategoryId,
            currentCategoryDisplayName:
                currentLoadedState.currentCategoryDisplayName,
          ),
        );
      }
    }
  }
}
