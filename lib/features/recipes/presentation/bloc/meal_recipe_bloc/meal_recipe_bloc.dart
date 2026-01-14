import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recipes_app/core/constants/app_strings.dart';
import 'package:recipes_app/core/error/exceptions.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

part 'meal_recipe_event.dart';
part 'meal_recipe_state.dart';

class MealRecipeBloc extends Bloc<MealRecipeEvent, MealRecipeState> {
  final RecipeRepository repository;
  final MealLocalDataSource localDataSource;

  MealRecipeBloc(this.repository, this.localDataSource)
    : super(MealRecipeInitial()) {
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<SearchMealsByNameEvent>(_onSearchMealsByName);
    on<FilterMealsByCategoryEvent>(_onFilterMealsByCategory);
    on<FilterMealsByAreaEvent>(_onFilterMealsByArea);
    on<GetMealByIdEvent>(_onGetMealById);
    on<LoadAllCategoriesEvent>(_onLoadAllCategories);
    on<LoadAllAreasEvent>(_onLoadAllAreas);
    on<ClearFiltersEvent>(_onClearFilters);
    on<GetRandomMealEvent>(_onGetRandomMeal);
    on<LoadRecentMealsEvent>(_onLoadRecentMeals);
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    final hasSearch =
        event.searchQuery != null && event.searchQuery!.trim().isNotEmpty;
    final hasCategory = event.category != null;
    final hasArea = event.area != null;

    if (!hasSearch && !hasCategory && !hasArea) {
      final recentMeals = await _getRecentMealsFromCache();
      if (recentMeals.isEmpty) {
        emit(MealRecipeInitial());
      } else {
        emit(RecentMealsLoadedState(recentMeals));
      }
      return;
    }

    emit(MealRecipeLoadingState());

    try {
      if (hasSearch) {
        await _handleSearchWithFilters(event, emit, hasCategory, hasArea);
      } else {
        await _handleCategoryAreaFilters(event, emit, hasCategory, hasArea);
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _handleSearchWithFilters(
    ApplyFiltersEvent event,
    Emitter<MealRecipeState> emit,
    bool hasCategory,
    bool hasArea,
  ) async {
    final meals = await repository.searchMealsByName(event.searchQuery!);

    if (meals.isEmpty) {
      emit(const MealRecipeEmptyState(AppStrings.noDataFound));
      return;
    }

    List<MealModel> filteredMeals = meals;

    if (hasCategory) {
      filteredMeals = filteredMeals.where((meal) {
        return meal.category?.toLowerCase() == event.category!.toLowerCase();
      }).toList();
    }

    if (hasArea) {
      filteredMeals = filteredMeals.where((meal) {
        return meal.area?.toLowerCase() == event.area!.toLowerCase();
      }).toList();
    }

    if (filteredMeals.isEmpty) {
      emit(const MealRecipeEmptyState('No recipes found matching all filters'));
      return;
    }

    emit(
      MealsLoadedState(
        meals: filteredMeals,
        appliedCategory: event.category,
        appliedArea: event.area,
      ),
    );
  }

  Future<void> _handleCategoryAreaFilters(
    ApplyFiltersEvent event,
    Emitter<MealRecipeState> emit,
    bool hasCategory,
    bool hasArea,
  ) async {
    if (hasCategory && !hasArea) {
      final meals = await repository.filterMealsByCategory(event.category!);
      if (meals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
        return;
      }
      emit(
        MealsSummaryLoadedState(meals: meals, appliedCategory: event.category),
      );
    } else if (hasArea && !hasCategory) {
      final meals = await repository.filterMealsByArea(event.area!);
      if (meals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
        return;
      }
      emit(MealsSummaryLoadedState(meals: meals, appliedArea: event.area));
    } else if (hasCategory && hasArea) {
      final summaryMeals = await repository.filterMealsByCategory(
        event.category!,
      );

      if (summaryMeals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
        return;
      }

      final fullMeals = await _fetchFullMealDetails(summaryMeals);

      if (fullMeals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
        return;
      }

      final filteredMeals = fullMeals.where((meal) {
        return meal.area?.toLowerCase() == event.area!.toLowerCase();
      }).toList();

      if (filteredMeals.isEmpty) {
        emit(
          const MealRecipeEmptyState('No recipes found matching all filters'),
        );
        return;
      }

      emit(
        MealsLoadedState(
          meals: filteredMeals,
          appliedCategory: event.category,
          appliedArea: event.area,
        ),
      );
    }
  }

  Future<List<MealModel>> _fetchFullMealDetails(
    List<MealSummaryModel> summaryMeals,
  ) async {
    final List<MealModel> fullMeals = [];

    for (final summary in summaryMeals) {
      try {
        final meal = await repository.getMealById(summary.id);
        if (meal != null) {
          fullMeals.add(meal);
        }
      } catch (e) {
        continue;
      }
    }

    return fullMeals;
  }

  Future<void> _onSearchMealsByName(
    SearchMealsByNameEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const MealRecipeEmptyState('Please enter a search query'));
      return;
    }

    emit(MealRecipeLoadingState());

    try {
      final meals = await repository.searchMealsByName(event.query);

      if (meals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
      } else {
        emit(MealsLoadedState(meals: meals));
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _onFilterMealsByCategory(
    FilterMealsByCategoryEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    emit(MealRecipeLoadingState());

    try {
      final meals = await repository.filterMealsByCategory(event.category);

      if (meals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
      } else {
        emit(
          MealsSummaryLoadedState(
            meals: meals,
            appliedCategory: event.category,
          ),
        );
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _onFilterMealsByArea(
    FilterMealsByAreaEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    emit(MealRecipeLoadingState());

    try {
      final meals = await repository.filterMealsByArea(event.area);

      if (meals.isEmpty) {
        emit(const MealRecipeEmptyState(AppStrings.noDataFound));
      } else {
        emit(MealsSummaryLoadedState(meals: meals, appliedArea: event.area));
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _onGetMealById(
    GetMealByIdEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    emit(MealRecipeLoadingState());

    try {
      final meal = await repository.getMealById(event.id);

      if (meal == null) {
        emit(const MealRecipeEmptyState('Meal not found'));
      } else {
        await localDataSource.cacheMeal(meal);
        emit(MealDetailLoadedState(meal));
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _onLoadAllCategories(
    LoadAllCategoriesEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    try {
      final categories = await repository.getAllCategories();

      if (categories.isNotEmpty) {
        emit(CategoriesLoadedState(categories));
      }
    } catch (e) {
      // Silently fail for categories loading
    }
  }

  Future<void> _onLoadAllAreas(
    LoadAllAreasEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    try {
      final areas = await repository.getAllAreas();

      if (areas.isNotEmpty) {
        emit(AreasLoadedState(areas));
      }
    } catch (e) {
      // Silently fail for areas loading
    }
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    final recentMeals = await _getRecentMealsFromCache();
    if (recentMeals.isEmpty) {
      emit(MealRecipeInitial());
    } else {
      emit(RecentMealsLoadedState(recentMeals));
    }
  }

  Future<void> _onGetRandomMeal(
    GetRandomMealEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    emit(MealRecipeLoadingState());
    try {
      final meal = await repository.getRandomMeal();
      if (meal != null) {
        emit(RandomMealLoadedState(meal));
      } else {
        emit(const MealRecipeEmptyState('No random meal found'));
      }
    } on NetworkException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } on ServerException catch (e) {
      emit(MealRecipeErrorState(e.message));
    } catch (e) {
      emit(const MealRecipeErrorState(AppStrings.unknownError));
    }
  }

  Future<void> _onLoadRecentMeals(
    LoadRecentMealsEvent event,
    Emitter<MealRecipeState> emit,
  ) async {
    emit(MealRecipeLoadingState());
    try {
      final recentMeals = await _getRecentMealsFromCache();
      print("fetched ${recentMeals.length} recent meals from cache");
      if (recentMeals.isEmpty) {
        emit(MealRecipeInitial());
      } else {
        emit(RecentMealsLoadedState(recentMeals));
      }
    } catch (e) {
      emit(MealRecipeInitial());
    }
  }

  Future<List<MealModel>> _getRecentMealsFromCache() async {
    try {
      final allCached = await localDataSource.getAllCachedMeals();
      final uniqueMeals = <String, MealModel>{};
      for (final meal in allCached.reversed) {
        uniqueMeals[meal.id] = meal;
      }
      return uniqueMeals.values.toList();
    } catch (e) {
      return [];
    }
  }
}
