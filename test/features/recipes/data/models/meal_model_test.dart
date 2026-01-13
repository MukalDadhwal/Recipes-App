import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';

void main() {
  group('MealModel', () {
    test('fromJson should create a valid MealModel', () {
      final json = {
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Preheat oven to 350° F.',
        'strMealThumb':
            'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
        'strTags': 'Meat,Casserole',
        'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
        'strIngredient1': 'soy sauce',
        'strIngredient2': 'water',
        'strIngredient3': 'brown sugar',
        'strMeasure1': '3/4 cup',
        'strMeasure2': '1/2 cup',
        'strMeasure3': '1/4 cup',
      };

      final meal = MealModel.fromJson(json);

      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'Japanese');
      expect(meal.ingredients.isNotEmpty, true);
      expect(meal.measures.isNotEmpty, true);
    });

    test('toJson should create a valid JSON map', () {
      const meal = MealModel(
        id: '52772',
        name: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        instructions: 'Preheat oven to 350° F.',
        thumbnail:
            'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
        ingredients: {'ingredient1': 'soy sauce', 'ingredient2': 'water'},
        measures: {'measure1': '3/4 cup', 'measure2': '1/2 cup'},
      );

      final json = meal.toJson();

      expect(json['idMeal'], '52772');
      expect(json['strMeal'], 'Teriyaki Chicken Casserole');
      expect(json['strCategory'], 'Chicken');
      expect(json['strArea'], 'Japanese');
    });

    test('two MealModel instances with same values should be equal', () {
      const meal1 = MealModel(id: '52772', name: 'Teriyaki Chicken Casserole');

      const meal2 = MealModel(id: '52772', name: 'Teriyaki Chicken Casserole');

      expect(meal1, meal2);
    });
  });
}
