import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recipes_app/core/constants/enums.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/meal_recipe_bloc/meal_recipe_bloc.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_grid_item_widget.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_grid_shimmer_widget.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_list_item_widget.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_list_shimmer_widget.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.nameAsc;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String? _selectedCategory;
  String? _selectedArea;

  List<CategoryModel> _categories = [];
  List<AreaModel> _areas = [];

  bool _categoriesLoading = true;
  bool _areasLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<MealRecipeBloc>().add(const LoadAllCategoriesEvent());
    context.read<MealRecipeBloc>().add(const LoadAllAreasEvent());
    context.read<MealRecipeBloc>().add(const LoadRecentMealsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _applyFilters();
      });
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _onAreaSelected(String? area) {
    setState(() {
      _selectedArea = area;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim();
    context.read<MealRecipeBloc>().add(
      ApplyFiltersEvent(
        searchQuery: query.isNotEmpty ? query : null,
        category: _selectedCategory,
        area: _selectedArea,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedArea = null;
      _searchController.clear();
    });
    context.read<MealRecipeBloc>().add(const ClearFiltersEvent());
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_selectedArea != null) count++;
    return count;
  }

  List<T> _sortMeals<T>(List<T> meals, String Function(T) getName) {
    final sorted = List<T>.from(meals);
    sorted.sort((a, b) {
      if (_sortOption == SortOption.nameAsc) {
        return getName(a).compareTo(getName(b));
      } else {
        return getName(b).compareTo(getName(a));
      }
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'Recipes',
          style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: IconButton(
              icon: Icon(
                _viewMode == ViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                size: 20.sp,
                color: const Color(0xFF129575),
              ),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == ViewMode.grid
                      ? ViewMode.list
                      : ViewMode.grid;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 12.w, left: 4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: PopupMenuButton<SortOption>(
              icon: Icon(
                Icons.sort_rounded,
                size: 20.sp,
                color: const Color(0xFF129575),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (option) {
                setState(() {
                  _sortOption = option;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortOption.nameAsc,
                  child: Text(SortOption.nameAsc.label),
                ),
                PopupMenuItem(
                  value: SortOption.nameDesc,
                  child: Text(SortOption.nameDesc.label),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search any recipe...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[500],
                  size: 22.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
            ),
          ),
          BlocConsumer<MealRecipeBloc, MealRecipeState>(
            listener: (context, state) {
              if (state is CategoriesLoadedState) {
                setState(() {
                  _categories = state.categories;
                  _categoriesLoading = false;
                });
              } else if (state is AreasLoadedState) {
                setState(() {
                  _areas = state.areas;
                  _areasLoading = false;
                });
              }
            },
            buildWhen: (previous, current) =>
                current is! CategoriesLoadedState &&
                current is! AreasLoadedState,
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _categoriesLoading
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF129575,
                                      ).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 4.h,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFF129575),
                                        size: 24.sp,
                                      ),
                                      hint: Row(
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            size: 18.sp,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Category',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      items: _categories
                                          .map(
                                            (cat) => DropdownMenuItem(
                                              value: cat.name,
                                              child: Text(
                                                cat.name,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: _onCategorySelected,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _areasLoading
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF129575,
                                      ).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 4.h,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedArea,
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFF129575),
                                        size: 24.sp,
                                      ),
                                      hint: Row(
                                        children: [
                                          Icon(
                                            Icons.public_outlined,
                                            size: 18.sp,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Area',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      items: _areas
                                          .map(
                                            (area) => DropdownMenuItem(
                                              value: area.name,
                                              child: Text(
                                                area.name,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: _areasLoading
                                          ? null
                                          : _onAreaSelected,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeFilterCount > 0) SizedBox(height: 12.h),
                  if (_activeFilterCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Active Filters:',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: Icon(
                                  Icons.clear_all,
                                  size: 16.sp,
                                  color: const Color(0xFF129575),
                                ),
                                label: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: const Color(0xFF129575),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              if (_selectedCategory != null)
                                Chip(
                                  label: Text(
                                    _selectedCategory!,
                                    style: const TextStyle(
                                      color: Color(0xFF129575),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 16.sp,
                                    color: const Color(0xFF129575),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              if (_selectedArea != null)
                                Chip(
                                  label: Text(
                                    _selectedArea!,
                                    style: const TextStyle(
                                      color: Color(0xFF129575),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 16.sp,
                                    color: const Color(0xFF129575),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedArea = null;
                                    });
                                    _applyFilters();
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 8.h),
                ],
              );
            },
          ),
          Expanded(
            child: BlocConsumer<MealRecipeBloc, MealRecipeState>(
              listener: (context, state) {},
              buildWhen: (previous, current) =>
                  current is! CategoriesLoadedState &&
                  current is! AreasLoadedState,
              builder: (context, state) {
                if (state is MealRecipeLoadingState) {
                  return _viewMode == ViewMode.grid
                      ? const RecipeGridShimmerWidget()
                      : const RecipeListShimmerWidget();
                } else if (state is MealsLoadedState) {
                  final sortedMeals = _sortMeals(
                    state.meals,
                    (meal) => meal.name,
                  );
                  return _buildMealsList(sortedMeals);
                } else if (state is MealsSummaryLoadedState) {
                  final sortedMeals = _sortMeals(
                    state.meals,
                    (meal) => meal.name,
                  );
                  return _buildMealsSummaryList(sortedMeals);
                } else if (state is MealRecipeErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(state.message),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is MealRecipeEmptyState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 48.sp, color: Colors.grey),
                        SizedBox(height: 16.h),
                        Text(state.message),
                      ],
                    ),
                  );
                } else if (state is RecentMealsLoadedState) {
                  return _buildRecentMealsView(state.meals);
                }
                return _buildEmptyStateWithSearch();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<MealModel> meals) {
    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return RecipeGridItemWidget(
            id: meal.id,
            name: meal.name,
            imageUrl: meal.thumbnail ?? '',
            category: meal.category,
            area: meal.area,
            onTap: () async {
              final bloc = context.read<MealRecipeBloc>();
              await context.push('/recipe-detail/${meal.id}', extra: meal);
              if (mounted) {
                bloc.add(const LoadRecentMealsEvent());
              }
            },
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: meals.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return RecipeListItemWidget(
            id: meal.id,
            name: meal.name,
            imageUrl: meal.thumbnail ?? '',
            category: meal.category,
            area: meal.area,
            onTap: () async {
              final bloc = context.read<MealRecipeBloc>();
              await context.push('/recipe-detail/${meal.id}', extra: meal);
              if (mounted) {
                bloc.add(const LoadRecentMealsEvent());
              }
            },
          );
        },
      );
    }
  }

  Widget _buildMealsSummaryList(List<MealSummaryModel> meals) {
    if (_viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return RecipeGridItemWidget(
            id: meal.id,
            name: meal.name,
            imageUrl: meal.thumbnail,
            onTap: () async {
              final bloc = context.read<MealRecipeBloc>();
              await context.push('/recipe-detail/${meal.id}');
              if (mounted) {
                bloc.add(const LoadRecentMealsEvent());
              }
            },
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: meals.length,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return RecipeListItemWidget(
            id: meal.id,
            name: meal.name,
            imageUrl: meal.thumbnail,
            onTap: () async {
              final bloc = context.read<MealRecipeBloc>();
              await context.push('/recipe-detail/${meal.id}');
              if (mounted) {
                bloc.add(const LoadRecentMealsEvent());
              }
            },
          );
        },
      );
    }
  }

  Widget _buildRecentMealsView(List<MealModel> meals) {
    final sortedMeals = _sortMeals(meals, (meal) => meal.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Text(
            'Recently Viewed',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _buildMealsList(sortedMeals)),
      ],
    );
  }

  Widget _buildEmptyStateWithSearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Find Your Perfect Recipe',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Search for recipes or use filters above',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
