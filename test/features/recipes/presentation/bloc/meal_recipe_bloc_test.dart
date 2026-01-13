import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/features/recipes/data/datasources/mealdb_api_service.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/meal_recipe_bloc/meal_recipe_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return './test/fixtures';
  }
}

void main() {
  late MealRecipeBloc bloc;
  late RecipeRepositoryImpl repository;
  late MealDbApiService apiService;
  late MealLocalDataSource localDataSource;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProvider();
    await Hive.initFlutter();
  });

  setUp(() {
    final dio = Dio();
    apiService = MealDbApiServiceImpl(dio);
    localDataSource = MealLocalDataSourceImpl();
    repository = RecipeRepositoryImpl(apiService, localDataSource);
    bloc = MealRecipeBloc(repository, localDataSource);
  });

  tearDown(() {
    bloc.close();
  });

  group('MealRecipeBloc', () {
    test('initial state is MealRecipeInitial', () {
      expect(bloc.state, isA<MealRecipeInitial>());
    });

    blocTest<MealRecipeBloc, MealRecipeState>(
      'emits MealRecipeLoadingState when SearchMealsByNameEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchMealsByNameEvent('chicken')),
      expect: () => [isA<MealRecipeLoadingState>()],
    );

    blocTest<MealRecipeBloc, MealRecipeState>(
      'emits MealRecipeLoadingState when GetMealByIdEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const GetMealByIdEvent('52772')),
      expect: () => [isA<MealRecipeLoadingState>()],
    );
  });
}
