import 'package:recipes_app/features/recipes/data/datasources/mealdb_api_service.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final MealDbApiService apiService;
  final MealLocalDataSource localDataSource;

  RecipeRepositoryImpl(this.apiService, this.localDataSource);

  @override
  Future<List<MealModel>> searchMealsByName(String query) async {
    return await apiService.searchMealsByName(query);
  }

  @override
  Future<List<MealSummaryModel>> filterMealsByArea(String area) async {
    return await apiService.filterMealsByArea(area);
  }

  @override
  Future<List<MealSummaryModel>> filterMealsByCategory(String category) async {
    return await apiService.filterMealsByCategory(category);
  }

  @override
  Future<MealModel?> getMealById(String id) async {
    try {
      final cachedMeal = await localDataSource.getCachedMeal(id);
      if (cachedMeal != null) {
        print('Meal found in cache: $id');
        return cachedMeal;
      }

      print('Fetching meal from API: $id');
      final meal = await apiService.getMealById(id);
      return meal;
    } catch (e) {
      print('Error in getMealById: $e');
      rethrow;
    }
  }

  @override
  Future<MealModel?> getRandomMeal() async {
    return await apiService.getRandomMeal();
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return await apiService.getAllCategories();
  }

  @override
  Future<List<AreaModel>> getAllAreas() async {
    return await apiService.getAllAreas();
  }
}
