import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class GetMealById {
  final RecipeRepository repository;

  GetMealById(this.repository);

  Future<MealModel?> call(String id) async {
    return await repository.getMealById(id);
  }
}
