import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class SearchMealsByName {
  final RecipeRepository repository;

  SearchMealsByName(this.repository);

  Future<List<MealModel>> call(String query) async {
    return await repository.searchMealsByName(query);
  }
}
