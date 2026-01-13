import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';

abstract class RecipeRepository {
  Future<List<MealModel>> searchMealsByName(String query);
  Future<List<MealSummaryModel>> filterMealsByArea(String area);
  Future<List<MealSummaryModel>> filterMealsByCategory(String category);
  Future<MealModel?> getMealById(String id);
  Future<MealModel?> getRandomMeal();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<AreaModel>> getAllAreas();
}
