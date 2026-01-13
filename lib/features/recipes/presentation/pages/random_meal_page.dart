import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/features/recipes/presentation/bloc/meal_recipe_bloc/meal_recipe_bloc.dart';

class RandomMealPage extends StatelessWidget {
  const RandomMealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Meal')),
      body: BlocBuilder<MealRecipeBloc, MealRecipeState>(
        builder: (context, state) {
          if (state is MealRecipeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RandomMealLoadedState) {
            return _buildRandomMealView(context, state.meal);
          } else if (state is MealRecipeErrorState) {
            return _buildErrorView(context, state.message);
          }
          return _buildInitialView(context);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shuffle,
              size: 100.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 32.h),
            Text(
              'Feeling Lucky Today?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Click the button below to discover a random recipe',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MealRecipeBloc>().add(const GetRandomMealEvent());
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Generate Random Recipe'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                textStyle: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomMealView(BuildContext context, meal) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () =>
                        context.push('/recipe-detail/${meal.id}', extra: meal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            meal.thumbnail ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.restaurant, size: 48.sp),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  if (meal.category != null) ...[
                                    Chip(
                                      label: Text(meal.category!),
                                      avatar: Icon(Icons.category, size: 16.sp),
                                    ),
                                    SizedBox(width: 8.w),
                                  ],
                                  if (meal.area != null)
                                    Chip(
                                      label: Text(meal.area!),
                                      avatar: Icon(Icons.place, size: 16.sp),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<MealRecipeBloc>().add(const GetRandomMealEvent());
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Try Another Recipe'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MealRecipeBloc>().add(const GetRandomMealEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
