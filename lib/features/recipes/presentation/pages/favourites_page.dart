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
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text(
            'My Favorites',
            style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700),
          ),
        ),
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
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 64.sp,
                              color: const Color(0xFF129575),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48.w),
                            child: Text(
                              'Start adding your favorite recipes and they\'ll appear here',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
