import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

class GetAllAreas {
  final RecipeRepository repository;

  GetAllAreas(this.repository);

  Future<List<AreaModel>> call() async {
    return await repository.getAllAreas();
  }
}
