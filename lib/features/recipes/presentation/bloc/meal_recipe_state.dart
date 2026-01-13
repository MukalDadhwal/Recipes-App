part of 'meal_recipe_bloc.dart';

sealed class MealRecipeState extends Equatable {
  const MealRecipeState();
}

final class MealRecipeInitial extends MealRecipeState {
  @override
  List<Object> get props => [];
}
