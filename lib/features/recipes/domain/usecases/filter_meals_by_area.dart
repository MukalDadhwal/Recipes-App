import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class FilterMealsByArea {
  final RecipeRepository repository;

  FilterMealsByArea(this.repository);

  Future<List<MealSummaryModel>> call(String area) async {
    return await repository.filterMealsByArea(area);
  }
}
