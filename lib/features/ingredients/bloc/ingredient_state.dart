part of 'ingredient_bloc.dart';

abstract class IngredientState extends Equatable {
  const IngredientState();
  @override
  List<Object> get props => [];
}

class IngredientInitial extends IngredientState {}

class IngredientLoading extends IngredientState {}

class IngredientLoaded extends IngredientState {
  final List<ImageItem> allMasterItems;
  final List<ImageItem> displayedAvailableItems;
  final List<ImageItem> selectedItems;
  final String? currentCategoryId; // <-- CHANGED from currentCategoryName
  final String? currentCategoryDisplayName; // To store the name for UI

  const IngredientLoaded({
    this.allMasterItems = const [],
    this.displayedAvailableItems = const [],
    this.selectedItems = const [],
    this.currentCategoryId,
    this.currentCategoryDisplayName,
  });

  @override
  List<Object> get props => [
    allMasterItems,
    displayedAvailableItems,
    selectedItems,
    currentCategoryId ?? '',
    currentCategoryDisplayName ?? '',
  ];

  IngredientLoaded copyWith({
    List<ImageItem>? allMasterItems,
    List<ImageItem>? displayedAvailableItems,
    List<ImageItem>? selectedItems,

    // For these nullable fields, we need a way to signal an explicit update to null
    // vs. no update intended. Using a wrapper like Value<T> or separate flags for each
    // is an option, or making the setter logic in copyWith more explicit.
    // Given we have `clearCurrentCategory`, let's ensure its precedence.
    String? currentCategoryId, // This is the NEW intended value if not clearing
    String?
    currentCategoryDisplayName, // This is the NEW intended value if not clearing
    bool clearCurrentCategory = false,
  }) {
    String? finalCategoryId;
    String? finalCategoryDisplayName;

    if (clearCurrentCategory) {
      finalCategoryId = null;
      finalCategoryDisplayName = null;
    } else {
      // If not clearing, use the provided value if it's there, else keep the current value.
      // This means if 'currentCategoryId' arg is null AND not clearing, it keeps 'this.currentCategoryId'.
      // If 'currentCategoryId' arg is a new ID, it uses that new ID.
      finalCategoryId = currentCategoryId ?? this.currentCategoryId;
      finalCategoryDisplayName =
          currentCategoryDisplayName ?? this.currentCategoryDisplayName;
    }

    return IngredientLoaded(
      allMasterItems: allMasterItems ?? this.allMasterItems,
      displayedAvailableItems:
          displayedAvailableItems ?? this.displayedAvailableItems,
      selectedItems: selectedItems ?? this.selectedItems,
      currentCategoryId: finalCategoryId,
      currentCategoryDisplayName: finalCategoryDisplayName,
    );
  }
}

class IngredientError extends IngredientState {
  /* ... as before ... */
  final String message;
  const IngredientError(this.message);
  @override
  List<Object> get props => [message];
}

// Update these to carry the new IngredientLoaded structure
class SelectedItemsSaving extends IngredientLoaded {
  const SelectedItemsSaving({
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryId,
    String? currentCategoryDisplayName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryId: currentCategoryId,
         currentCategoryDisplayName: currentCategoryDisplayName,
       );
}

class SelectedItemsSaveSuccess extends IngredientLoaded {
  const SelectedItemsSaveSuccess({
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryId,
    String? currentCategoryDisplayName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryId: currentCategoryId,
         currentCategoryDisplayName: currentCategoryDisplayName,
       );
}

class SelectedItemsSaveError extends IngredientLoaded {
  final String errorMessage;
  const SelectedItemsSaveError({
    required this.errorMessage,
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryId,
    String? currentCategoryDisplayName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryId: currentCategoryId,
         currentCategoryDisplayName: currentCategoryDisplayName,
       );

  @override
  List<Object> get props => [super.props, errorMessage];
}

class NavigateToRecipeResults extends IngredientLoaded {
  // The selectedItems from IngredientLoaded are implicitly the ones to use.
  const NavigateToRecipeResults({
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryId,
    String? currentCategoryDisplayName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryId: currentCategoryId,
         currentCategoryDisplayName: currentCategoryDisplayName,
       );
  // You can add a unique value to props if you need buildWhen to differentiate it
  // from a regular IngredientLoaded, e.g., final bool navigateSignal = true;
}
