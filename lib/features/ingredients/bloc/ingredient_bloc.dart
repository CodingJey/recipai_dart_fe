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
    on<SynchronizeSelectedItems>(_onSynchronizeSelectedItems);
    on<ConfirmSummaryAndProceedToResults>(_onConfirmSummaryAndProceedToResults);
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
    print(
      "[Bloc._onShowAllIngredients] Received event. Current state BEFORE processing: $state",
    );
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      // When clearing, we don't need to pass currentCategoryId/DisplayName arguments to copyWith
      final newState = currentState.copyWith(
        displayedAvailableItems: currentState.allMasterItems,
        clearCurrentCategory:
            true, // This will set categoryId and displayName to null
        // allMasterItems and selectedItems will be preserved from currentState by copyWith
      );
      emit(newState);
      print(
        "[Bloc._onShowAllIngredients] EMITTED new state: currentCategoryId='${newState.currentCategoryId}', currentCategoryDisplayName='${newState.currentCategoryDisplayName}', displayedItemsCount=${newState.displayedAvailableItems.length}",
      );
    } else {
      print(
        "[Bloc._onShowAllIngredients] Current state is NOT IngredientLoaded. State: $state. Cannot clear category.",
      );
    }
  }

  void _onSetDisplayCategory(
    SetDisplayCategory event,
    Emitter<IngredientState> emit,
  ) {
    print(
      "[Bloc._onSetDisplayCategory] Received event with categoryId: '${event.categoryId}'",
    );
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      final newTargetCategoryId = event.categoryId;
      // ... (filtering logic for filteredItems and newCategoryDisplayName) ...
      final filteredItems = _masterIngredientList
          .where((item) => item.categoryId == newTargetCategoryId)
          .toList();

      String? newCategoryDisplayName;
      if (_allCategories.isNotEmpty) {
        try {
          newCategoryDisplayName = _allCategories
              .firstWhere((cat) => cat.id == newTargetCategoryId)
              .name;
        } catch (e) {
          newCategoryDisplayName = "Category (ID: $newTargetCategoryId)";
        }
      } else {
        newCategoryDisplayName = "Category (ID: $newTargetCategoryId)";
      }

      final newState = currentState.copyWith(
        displayedAvailableItems: filteredItems,
        currentCategoryId: newTargetCategoryId, // Explicitly pass the new ID
        currentCategoryDisplayName:
            newCategoryDisplayName, // Explicitly pass the new name
        // clearCurrentCategory will be false by default, so these values will be used.
      );
      emit(newState);
      print(
        "[Bloc._onSetDisplayCategory] EMITTED new state with currentCategoryId: ${newState.currentCategoryId}, currentCategoryDisplayName: ${newState.currentCategoryDisplayName}, displayedAvailableItems count: ${newState.displayedAvailableItems.length}",
      );
    } else {
      print(
        "[Bloc._onSetDisplayCategory] State is not IngredientLoaded. Current state is $state",
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

  void _onSynchronizeSelectedItems(
    SynchronizeSelectedItems event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      // These items from summary have correct IDs, selectedSubtypeNames, and categoryId,
      // BUT their 'subtypes' list is empty because they came from ImageItem.fromJson().
      final List<ImageItem> selectedItemsFromSummary =
          event.updatedSelectedItems;

      print(
        "[Bloc._onSynchronizeSelectedItems] Received ${selectedItemsFromSummary.length} items from summary.",
      );

      // Create a new master list. For each original master item:
      // - If it's still selected (present in selectedItemsFromSummary), update its selectedSubtypeNames.
      // - If it's NO LONGER selected, clear its selectedSubtypeNames.
      // - Crucially, ALWAYS keep the original 'subtypes' list from the masterItem.
      List<ImageItem> newMasterItems = currentState.allMasterItems.map((
        masterItem,
      ) {
        ImageItem? summaryVersion;
        try {
          summaryVersion = selectedItemsFromSummary.firstWhere(
            (si) => si.id == masterItem.id,
          );
        } catch (e) {
          // Item from master list is not in the new selected list from summary
          summaryVersion = null;
        }

        if (summaryVersion != null) {
          // Item IS in the new selected list from summary.
          // Update its selectedSubtypeNames from the summary version,
          // but keep ALL other properties (especially 'subtypes') from the original masterItem.
          return masterItem.copyWith(
            selectedSubtypeNames: summaryVersion.selectedSubtypeNames,
            // categoryId should be inherent to masterItem, but ensure consistency if summary could change it
            // For now, assuming categoryId from masterItem is authoritative.
          );
        } else {
          // Item from master list is NOT in the new selected list from summary.
          // This means it was deselected. Clear its selectedSubtypeNames.
          if (masterItem.selectedSubtypeNames.isNotEmpty) {
            return masterItem.copyWith(selectedSubtypeNames: []);
          }
          // If already empty, no change needed to this masterItem.
          return masterItem;
        }
      }).toList();

      // Create the new 'selectedItems' list for the BLoC state.
      // These should be instances from 'newMasterItems' to ensure they have the full 'subtypes' list.
      List<ImageItem> newBlocSelectedItems = [];
      for (var summaryItemShell in selectedItemsFromSummary) {
        try {
          // Find the corresponding (and now updated) item in newMasterItems
          final fullyHydratedItem = newMasterItems.firstWhere(
            (mi) => mi.id == summaryItemShell.id,
          );
          newBlocSelectedItems.add(fullyHydratedItem);
        } catch (e) {
          // This should ideally not happen if IDs are consistent and item was processed in newMasterItems.
          print(
            "[Bloc._onSynchronizeSelectedItems] Error: Could not find master item for summary item ID: ${summaryItemShell.id}. This indicates a logic flaw.",
          );
        }
      }

      // Re-filter displayed items based on current category, using the updated master list
      final String? currentCatId = currentState.currentCategoryId;
      final List<ImageItem> newDisplayedItems = currentCatId != null
          ? newMasterItems
                .where((item) => item.categoryId == currentCatId)
                .toList()
          : newMasterItems; // If no category, show all from the updated master list

      emit(
        currentState.copyWith(
          allMasterItems: newMasterItems, // Updated master list
          selectedItems: newBlocSelectedItems, // Hydrated selected items
          displayedAvailableItems:
              newDisplayedItems, // Correctly filtered display list
          // currentCategoryId and currentCategoryDisplayName are preserved by copyWith
        ),
      );
      print(
        "[Bloc._onSynchronizeSelectedItems] State updated. Master items: ${newMasterItems.length}, BLoC Selected items: ${newBlocSelectedItems.length}, Displayed: ${newDisplayedItems.length}",
      );
    } else {
      print(
        "[Bloc._onSynchronizeSelectedItems] Current state is NOT IngredientLoaded. State: $state.",
      );
    }
  }

  void _onConfirmSummaryAndProceedToResults(
    ConfirmSummaryAndProceedToResults event,
    Emitter<IngredientState> emit,
  ) {
    if (state is IngredientLoaded) {
      final currentState = state as IngredientLoaded;
      if (currentState.selectedItems.isNotEmpty) {
        print(
          "[Bloc] ConfirmSummaryAndProceedToResults: Requesting navigation with ${currentState.selectedItems.length} items.",
        );
        // Emit the specific state to trigger navigation in the UI
        emit(
          NavigateToRecipeResults(
            allMasterItems: currentState.allMasterItems,
            displayedAvailableItems: currentState.displayedAvailableItems,
            selectedItems:
                currentState.selectedItems, // These are the confirmed items
            currentCategoryId: currentState.currentCategoryId,
            currentCategoryDisplayName: currentState.currentCategoryDisplayName,
          ),
        );
      } else {
        print(
          "[Bloc] ConfirmSummaryAndProceedToResults: No items selected, navigation not requested.",
        );
        // Optionally, emit a state to show a message, though UI can also handle this.
      }
    } else {
      print(
        "[Bloc] ConfirmSummaryAndProceedToResults: Current state is not IngredientLoaded ($state).",
      );
    }
  }
}
