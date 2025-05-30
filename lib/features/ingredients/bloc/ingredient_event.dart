part of 'ingredient_bloc.dart';

abstract class IngredientEvent extends Equatable {
  const IngredientEvent();
  @override
  List<Object> get props => [];
}

class LoadIngredients extends IngredientEvent {}

class ToggleItemSelectionEvent extends IngredientEvent {
  final ImageItem item;
  const ToggleItemSelectionEvent(this.item);
  @override
  List<Object> get props => [item];
}

class ToggleItemSubtypeEvent extends IngredientEvent {
  final int itemId;
  final String subtypeNameToggled;
  const ToggleItemSubtypeEvent(this.itemId, this.subtypeNameToggled);
  @override
  List<Object> get props => [itemId, subtypeNameToggled];
}

class SaveSelectedItemsAndProceed extends IngredientEvent {}

// NEW EVENT
class SetDisplayCategory extends IngredientEvent {
  final String categoryName;

  const SetDisplayCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}
