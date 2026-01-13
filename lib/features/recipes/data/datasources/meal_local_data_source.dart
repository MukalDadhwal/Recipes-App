import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';

abstract class MealLocalDataSource {
  Future<void> cacheMeal(MealModel meal);
  Future<MealModel?> getCachedMeal(String id);
  Future<List<MealModel>> getAllCachedMeals();
  Future<void> clearCache();

  Future<void> addToFavorites(MealModel meal);
  Future<void> removeFromFavorites(String mealId);
  Future<bool> isFavorite(String mealId);
  Future<List<MealModel>> getAllFavorites();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  static const String _cachedMealsBox = 'cached_meals';
  static const String _favoriteMealsBox = 'favorite_meals';

  Box<MealModel>? _cachedBox;
  Box<MealModel>? _favoritesBox;

  Future<Box<MealModel>> get cachedMealsBox async {
    _cachedBox ??= await Hive.openBox<MealModel>(_cachedMealsBox);
    return _cachedBox!;
  }

  Future<Box<MealModel>> get favoriteMealsBox async {
    _favoritesBox ??= await Hive.openBox<MealModel>(_favoriteMealsBox);
    return _favoritesBox!;
  }

  @override
  Future<void> cacheMeal(MealModel meal) async {
    try {
      final box = await cachedMealsBox;
      await box.put(meal.id, meal);
      print('Meal cached successfully: ${meal.id} - ${meal.name}');
    } catch (e) {
      print('Error caching meal: $e');
    }
  }

  @override
  Future<MealModel?> getCachedMeal(String id) async {
    final box = await cachedMealsBox;
    return box.get(id);
  }

  @override
  Future<List<MealModel>> getAllCachedMeals() async {
    final box = await cachedMealsBox;
    return box.values.toList();
  }

  @override
  Future<void> clearCache() async {
    final box = await cachedMealsBox;
    await box.clear();
  }

  @override
  Future<void> addToFavorites(MealModel meal) async {
    final box = await favoriteMealsBox;
    await box.put(meal.id, meal);
  }

  @override
  Future<void> removeFromFavorites(String mealId) async {
    final box = await favoriteMealsBox;
    await box.delete(mealId);
  }

  @override
  Future<bool> isFavorite(String mealId) async {
    final box = await favoriteMealsBox;
    return box.containsKey(mealId);
  }

  @override
  Future<List<MealModel>> getAllFavorites() async {
    final box = await favoriteMealsBox;
    return box.values.toList();
  }
}
