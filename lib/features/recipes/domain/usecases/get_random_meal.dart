import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class GetRandomMeal {
  final RecipeRepository repository;

  GetRandomMeal(this.repository);

  Future<MealModel?> call() async {
    return await repository.getRandomMeal();
  }
}
