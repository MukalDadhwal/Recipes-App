import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class FilterMealsByCategory {
  final RecipeRepository repository;

  FilterMealsByCategory(this.repository);

  Future<List<MealSummaryModel>> call(String category) async {
    return await repository.filterMealsByCategory(category);
  }
}
