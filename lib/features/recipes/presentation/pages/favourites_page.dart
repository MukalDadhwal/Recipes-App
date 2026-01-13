import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/favourites_bloc/favorites_bloc.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_grid_item_widget.dart';
import 'package:recipes_app/injection.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
    with AutomaticKeepAliveClientMixin {
  late FavoritesBloc _favoritesBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _favoritesBloc = getIt<FavoritesBloc>();
    _favoritesBloc.add(const LoadFavoritesEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoritesBloc.add(const LoadFavoritesEvent());
  }

  @override
  void dispose() {
    _favoritesBloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _favoritesBloc.add(const LoadFavoritesEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _favoritesBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Favourites'), actions: const []),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoadedState) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final meal = state.favorites[index];
                    return RecipeGridItemWidget(
                      id: meal.id,
                      name: meal.name,
                      imageUrl: meal.thumbnail ?? '',
                      category: meal.category,
                      area: meal.area,
                      onTap: () => context.push(
                        '/recipe-detail/${meal.id}',
                        extra: meal,
                      ),
                    );
                  },
                ),
              );
            } else if (state is FavoritesEmptyState) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No favorites yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Add meals to your favorites to see them here',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is FavoritesErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(state.message),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<FavoritesBloc>().add(
                        const LoadFavoritesEvent(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Loading favorites...'));
          },
        ),
      ),
    );
  }
}
