part of 'ingredient_bloc.dart';

abstract class IngredientState extends Equatable {
  const IngredientState();
  @override
  List<Object> get props => [];
}

class IngredientInitial extends IngredientState {}

class IngredientLoading extends IngredientState {}

class IngredientLoaded extends IngredientState {
  final List<ImageItem> allMasterItems; // All ingredients loaded
  final List<ImageItem>
  displayedAvailableItems; // Filtered ingredients for display
  final List<ImageItem> selectedItems;
  final String? currentCategoryName; // Name of the currently selected category

  const IngredientLoaded({
    this.allMasterItems = const [],
    this.displayedAvailableItems = const [],
    this.selectedItems = const [],
    this.currentCategoryName,
  });

  @override
  List<Object> get props => [
    allMasterItems,
    displayedAvailableItems,
    selectedItems,
    currentCategoryName ?? '',
  ];

  IngredientLoaded copyWith({
    List<ImageItem>? allMasterItems,
    List<ImageItem>? displayedAvailableItems,
    List<ImageItem>? selectedItems,
    String? currentCategoryName, // Use String? for nullable currentCategoryName
    bool clearCurrentCategory = false, // Flag to explicitly clear category
  }) {
    return IngredientLoaded(
      allMasterItems: allMasterItems ?? this.allMasterItems,
      displayedAvailableItems:
          displayedAvailableItems ?? this.displayedAvailableItems,
      selectedItems: selectedItems ?? this.selectedItems,
      currentCategoryName: clearCurrentCategory
          ? null
          : (currentCategoryName ?? this.currentCategoryName),
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

// Update these to carry the new IngredientLoaded structure if needed,
// or ensure they correctly reflect the data they operate on.
// For simplicity, let's make them extend a simple IngredientLoaded for now.

class SelectedItemsSaving extends IngredientLoaded {
  const SelectedItemsSaving({
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryName: currentCategoryName,
       );
}

class SelectedItemsSaveSuccess extends IngredientLoaded {
  const SelectedItemsSaveSuccess({
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryName: currentCategoryName,
       );
}

class SelectedItemsSaveError extends IngredientLoaded {
  final String errorMessage;
  const SelectedItemsSaveError({
    required this.errorMessage,
    required List<ImageItem> allMasterItems,
    required List<ImageItem> displayedAvailableItems,
    required List<ImageItem> selectedItems,
    String? currentCategoryName,
  }) : super(
         allMasterItems: allMasterItems,
         displayedAvailableItems: displayedAvailableItems,
         selectedItems: selectedItems,
         currentCategoryName: currentCategoryName,
       );

  @override
  List<Object> get props => [super.props, errorMessage];
}
