import 'package:go_router/go_router.dart';
import '../../features/recipes/presentation/pages/recipe_list_page.dart';
import '../../features/recipes/presentation/pages/recipe_detail_page.dart';
import '../../features/recipes/presentation/pages/favourites_page.dart';
import '../../features/recipes/presentation/pages/random_meal_page.dart';
import '../../features/recipes/presentation/widgets/navbar_widget.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return NavbarWidget(currentPath: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const RecipeListPage(),
        ),
        GoRoute(
          path: '/random',
          name: 'random',
          builder: (context, state) => const RandomMealPage(),
        ),
        GoRoute(
          path: '/favourites',
          name: 'favourites',
          builder: (context, state) => const FavouritesPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/recipe-detail/:mealId',
      name: 'recipe-detail',
      builder: (context, state) {
        final mealId = state.pathParameters['mealId']!;
        final meal = state.extra;
        return RecipeDetailPage(mealId: mealId, meal: meal);
      },
    ),
  ],
);
