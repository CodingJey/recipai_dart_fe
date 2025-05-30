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
    String? currentCategoryId,
    String? currentCategoryDisplayName, // Add to copyWith
    bool clearCurrentCategory = false,
  }) {
    return IngredientLoaded(
      allMasterItems: allMasterItems ?? this.allMasterItems,
      displayedAvailableItems:
          displayedAvailableItems ?? this.displayedAvailableItems,
      selectedItems: selectedItems ?? this.selectedItems,
      currentCategoryId: clearCurrentCategory
          ? null
          : (currentCategoryId ?? this.currentCategoryId),
      currentCategoryDisplayName: clearCurrentCategory
          ? null
          : (currentCategoryDisplayName ?? this.currentCategoryDisplayName),
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
