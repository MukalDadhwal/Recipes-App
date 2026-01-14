import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recipes_app/core/utils/image_utils.dart';
import 'package:recipes_app/core/utils/string_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/favourites_bloc/favorites_bloc.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/meal_recipe_bloc/meal_recipe_bloc.dart';
import 'package:recipes_app/injection.dart';
import 'package:shimmer/shimmer.dart';

class RecipeDetailPage extends StatelessWidget {
  final String mealId;
  final dynamic meal;

  const RecipeDetailPage({super.key, required this.mealId, this.meal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<FavoritesBloc>()..add(CheckFavoriteStatusEvent(mealId)),
      child: _RecipeDetailPageContent(mealId: mealId, meal: meal),
    );
  }
}

class _RecipeDetailPageContent extends StatefulWidget {
  final String mealId;
  final dynamic meal;

  const _RecipeDetailPageContent({required this.mealId, this.meal});

  @override
  State<_RecipeDetailPageContent> createState() =>
      _RecipeDetailPageContentState();
}

class _RecipeDetailPageContentState extends State<_RecipeDetailPageContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;
  bool? _localFavoriteStatus;
  YoutubePlayerController? _youtubeController;
  String? _youtubeVideoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _favoriteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _favoriteScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_favoriteAnimationController);
    _tabController = TabController(length: 3, vsync: this);
    context.read<MealRecipeBloc>().add(GetMealByIdEvent(widget.mealId));
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _tabController.dispose();
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  void _ensureYoutubeController(String videoId) {
    if (_youtubeController != null && _youtubeVideoId == videoId) {
      return;
    }

    try {
      _youtubeController?.dispose();
    } catch (e) {
      // Controller already disposed ignore
    }
    
    _youtubeVideoId = videoId;
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  void _toggleFavorite(MealModel meal, bool currentStatus) {
    _favoriteAnimationController.forward(from: 0.0);
    setState(() {
      _localFavoriteStatus = !currentStatus;
    });
    if (currentStatus) {
      context.read<FavoritesBloc>().add(RemoveFromFavoritesEvent(meal.id));
    } else {
      context.read<FavoritesBloc>().add(AddToFavoritesEvent(meal));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.meal != null && widget.meal is MealModel) {
      return Scaffold(body: _buildDetailContent(widget.meal as MealModel));
    }

    return Scaffold(
      body: BlocBuilder<MealRecipeBloc, MealRecipeState>(
        builder: (context, state) {
          if (state is MealRecipeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MealDetailLoadedState) {
            return _buildDetailContent(state.meal);
          } else if (state is MealRecipeErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildDetailContent(MealModel meal) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 320.h,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'meal_${meal.id}',
                    child: CachedNetworkImage(
                      imageUrl: '${meal.thumbnail ?? ''}/large',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.restaurant, size: 48.sp),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.restaurant, size: 48.sp),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    bool isFavorite = _localFavoriteStatus ?? false;
                    if (_localFavoriteStatus == null) {
                      if (state is FavoriteStatusState) {
                        isFavorite = state.isFavorite;
                      } else if (state is FavoriteAddedState) {
                        isFavorite = state.mealId == meal.id;
                      } else if (state is FavoriteRemovedState) {
                        isFavorite = false;
                      }
                    }
                    return ScaleTransition(
                      scale: _favoriteScaleAnimation,
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.red : Colors.black87,
                          ),
                        ),
                        onPressed: () => _toggleFavorite(meal, isFavorite),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ];
      },
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (meal.category != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 14.sp,
                              color: const Color(0xFF129575),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              meal.category!,
                              style: TextStyle(
                                color: const Color(0xFF129575),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (meal.area != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place,
                              size: 14.sp,
                              color: const Color(0xFF129575),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              meal.area!,
                              style: TextStyle(
                                color: const Color(0xFF129575),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF129575),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: const Color(0xFF129575),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Ingredients'),
                Tab(text: 'Instructions'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(meal),
                _buildIngredientsTab(meal),
                _buildInstructionsTab(meal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(MealModel meal) {
    final videoId = StringUtils.getYoutubeVideoId(meal.youtubeUrl);

    if (videoId.isNotEmpty) {
      _ensureYoutubeController(videoId);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (videoId.isNotEmpty && _youtubeController != null) ...[
            Text(
              'Video Tutorial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
              ),
            ),
            SizedBox(height: 24.h),
          ],
          if (meal.tags != null && meal.tags!.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: meal.tags!.split(',').map((tag) {
                return Chip(
                  label: Text(
                    tag.trim(),
                    style: TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
          ],
          Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Text(
            meal.instructions ?? 'No instructions available',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(MealModel meal) {
    final ingredients = meal.ingredientsWithMeasures;

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: ImageUtils.getIngredientImage(ingredient.key),
                width: 55.w,
                height: 55.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(
                    width: 55.w,
                    height: 55.h,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 55.w,
                  height: 55.h,
                  color: Colors.grey[100],
                  child: Icon(
                    Icons.fastfood,
                    size: 24.sp,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
            title: Text(
              ingredient.key,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
            trailing: Text(
              ingredient.value,
              style: TextStyle(
                color: const Color(0xFF129575),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsTab(MealModel meal) {
    final steps = StringUtils.parseInstructions(meal.instructions);

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF129575),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF129575).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
