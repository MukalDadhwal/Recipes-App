import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/favourites_bloc/favorites_bloc.dart';
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
  late FavoritesBloc bloc;
  late MealLocalDataSource localDataSource;

  setUpAll(() async {
    PathProviderPlatform.instance = FakePathProvider();
    await Hive.initFlutter();
  });

  setUp(() {
    localDataSource = MealLocalDataSourceImpl();
    bloc = FavoritesBloc(localDataSource);
  });

  tearDown(() {
    bloc.close();
  });

  group('FavoritesBloc', () {
    test('initial state is FavoritesInitial', () {
      expect(bloc.state, isA<FavoritesInitial>());
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'emits FavoritesLoadingState when LoadFavoritesEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadFavoritesEvent()),
      expect: () => [isA<FavoritesLoadingState>()],
    );
  });
}
