import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class GetAllCategories {
  final RecipeRepository repository;

  GetAllCategories(this.repository);

  Future<List<CategoryModel>> call() async {
    return await repository.getAllCategories();
  }
}
