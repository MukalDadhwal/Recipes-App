import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recipes_app/core/constants/enums.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipes App',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(
                _viewMode == ViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                size: 22.sp,
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
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: PopupMenuButton<SortOption>(
              icon: Icon(Icons.sort_rounded, size: 22.sp),
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
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: _categoriesLoading
                                  ? 'Loading Categories...'
                                  : 'Category',
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
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
                            onChanged: _categoriesLoading
                                ? null
                                : _onCategorySelected,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedArea,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: _areasLoading
                                  ? 'Loading Areas...'
                                  : 'Area',
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
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
                            onChanged: _areasLoading ? null : _onAreaSelected,
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
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: Icon(Icons.clear_all, size: 16.sp),
                                label: const Text('Clear All'),
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
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  deleteIcon: Icon(Icons.close, size: 16.sp),
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
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  deleteIcon: Icon(Icons.close, size: 16.sp),
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
            child: BlocBuilder<MealRecipeBloc, MealRecipeState>(
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
    print("BUILDING MEAL MODEL LIST **********************");
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
            onTap: () {
              context.push('/recipe-detail/${meal.id}', extra: meal);
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
            onTap: () {
              context.push('/recipe-detail/${meal.id}', extra: meal);
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
            onTap: () {
              context.push('/recipe-detail/${meal.id}');
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
            onTap: () {
              context.push('/recipe-detail/${meal.id}');
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
          padding: EdgeInsets.all(16.w),
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
