import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:recipes_app/features/recipes/data/datasources/mealdb_api_service.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/favourites_bloc/favorites_bloc.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/meal_recipe_bloc/meal_recipe_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<MealDbApiService>(
    () => MealDbApiServiceImpl(getIt()),
  );

  getIt.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(getIt(), getIt()),
  );

  getIt.registerFactory<MealRecipeBloc>(() => MealRecipeBloc(getIt(), getIt()));

  getIt.registerFactory<FavoritesBloc>(() => FavoritesBloc(getIt()));
}
