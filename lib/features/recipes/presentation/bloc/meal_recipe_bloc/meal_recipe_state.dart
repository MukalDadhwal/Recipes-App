part of 'meal_recipe_bloc.dart';

sealed class MealRecipeState extends Equatable {
  const MealRecipeState();
}

final class MealRecipeInitial extends MealRecipeState {
  @override
  List<Object> get props => [];
}

final class MealRecipeLoadingState extends MealRecipeState {
  @override
  List<Object> get props => [];
}

final class MealsLoadedState extends MealRecipeState {
  final List<MealModel> meals;
  final String? appliedCategory;
  final String? appliedArea;

  const MealsLoadedState({
    required this.meals,
    this.appliedCategory,
    this.appliedArea,
  });

  @override
  List<Object?> get props => [meals, appliedCategory, appliedArea];
}

final class MealsSummaryLoadedState extends MealRecipeState {
  final List<MealSummaryModel> meals;
  final String? appliedCategory;
  final String? appliedArea;

  const MealsSummaryLoadedState({
    required this.meals,
    this.appliedCategory,
    this.appliedArea,
  });

  @override
  List<Object?> get props => [meals, appliedCategory, appliedArea];
}

final class MealDetailLoadedState extends MealRecipeState {
  final MealModel meal;

  const MealDetailLoadedState(this.meal);

  @override
  List<Object> get props => [meal];
}

final class CategoriesLoadedState extends MealRecipeState {
  final List<CategoryModel> categories;

  const CategoriesLoadedState(this.categories);

  @override
  List<Object> get props => [categories];
}

final class AreasLoadedState extends MealRecipeState {
  final List<AreaModel> areas;

  const AreasLoadedState(this.areas);

  @override
  List<Object> get props => [areas];
}

final class MealRecipeErrorState extends MealRecipeState {
  final String message;

  const MealRecipeErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class MealRecipeEmptyState extends MealRecipeState {
  final String message;

  const MealRecipeEmptyState(this.message);

  @override
  List<Object> get props => [message];
}

final class RandomMealLoadedState extends MealRecipeState {
  final MealModel meal;

  const RandomMealLoadedState(this.meal);

  @override
  List<Object> get props => [meal];
}

final class RecentMealsLoadedState extends MealRecipeState {
  final List<MealModel> meals;

  const RecentMealsLoadedState(this.meals);

  @override
  List<Object> get props => [meals];
}
