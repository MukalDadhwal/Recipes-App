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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool? _localFavoriteStatus;
  YoutubePlayerController? _youtubeController;
  String? _youtubeVideoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<MealRecipeBloc>().add(GetMealByIdEvent(widget.mealId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  void _ensureYoutubeController(String videoId) {
    if (_youtubeController != null && _youtubeVideoId == videoId) {
      return;
    }

    _youtubeController?.dispose();
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
            expandedHeight: 300.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'meal_${meal.id}',
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: '${meal.thumbnail ?? ''}/large',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.restaurant, size: 48.sp),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.restaurant, size: 48.sp),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              BlocBuilder<FavoritesBloc, FavoritesState>(
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
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                    onPressed: () => _toggleFavorite(meal, isFavorite),
                  );
                },
              ),
            ],
          ),
        ];
      },
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    if (meal.category != null) ...[
                      Chip(
                        label: Text(
                          meal.category!,
                          style: TextStyle(color: Colors.black87),
                        ),
                        avatar: Icon(Icons.category, size: 16.sp),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (meal.area != null)
                      Chip(
                        label: Text(
                          meal.area!,
                          style: TextStyle(color: Colors.black87),
                        ),
                        avatar: Icon(Icons.place, size: 16.sp),
                      ),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Ingredients'),
              Tab(text: 'Instructions'),
            ],
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
          if (videoId.isNotEmpty) ...[
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
      padding: EdgeInsets.all(16.w),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: ImageUtils.getIngredientImage(ingredient.key),
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 50.w,
                  height: 50.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.fastfood, size: 24.sp),
                ),
              ),
            ),
            title: Text(
              ingredient.key,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              ingredient.value,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.all(16.w),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  steps[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
