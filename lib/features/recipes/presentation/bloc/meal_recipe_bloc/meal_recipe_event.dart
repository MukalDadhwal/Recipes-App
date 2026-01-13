part of 'meal_recipe_bloc.dart';

sealed class MealRecipeEvent extends Equatable {
  const MealRecipeEvent();
}

final class ApplyFiltersEvent extends MealRecipeEvent {
  final String? searchQuery;
  final String? category;
  final String? area;

  const ApplyFiltersEvent({this.searchQuery, this.category, this.area});

  @override
  List<Object?> get props => [searchQuery, category, area];
}

final class SearchMealsByNameEvent extends MealRecipeEvent {
  final String query;

  const SearchMealsByNameEvent(this.query);

  @override
  List<Object> get props => [query];
}

final class FilterMealsByCategoryEvent extends MealRecipeEvent {
  final String category;

  const FilterMealsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

final class FilterMealsByAreaEvent extends MealRecipeEvent {
  final String area;

  const FilterMealsByAreaEvent(this.area);

  @override
  List<Object> get props => [area];
}

final class GetMealByIdEvent extends MealRecipeEvent {
  final String id;

  const GetMealByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

final class LoadAllCategoriesEvent extends MealRecipeEvent {
  const LoadAllCategoriesEvent();

  @override
  List<Object> get props => [];
}

final class LoadAllAreasEvent extends MealRecipeEvent {
  const LoadAllAreasEvent();

  @override
  List<Object> get props => [];
}

final class ClearFiltersEvent extends MealRecipeEvent {
  const ClearFiltersEvent();

  @override
  List<Object> get props => [];
}

final class GetRandomMealEvent extends MealRecipeEvent {
  const GetRandomMealEvent();

  @override
  List<Object> get props => [];
}

final class LoadRecentMealsEvent extends MealRecipeEvent {
  const LoadRecentMealsEvent();

  @override
  List<Object> get props => [];
}

final class CacheMealEvent extends MealRecipeEvent {
  final MealModel meal;

  const CacheMealEvent(this.meal);

  @override
  List<Object> get props => [meal];
}
