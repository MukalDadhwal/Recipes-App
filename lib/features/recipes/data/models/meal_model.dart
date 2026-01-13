import 'package:equatable/equatable.dart';

class MealModel extends Equatable {
  final String id;
  final String name;
  final String? drinkAlternate;
  final String? category;
  final String? area;
  final String? instructions;
  final String? thumbnail;
  final String? tags;
  final String? youtubeUrl;
  final Map<String, String> ingredients;
  final Map<String, String> measures;
  final String? source;
  final String? imageSource;
  final String? creativeCommonsConfirmed;
  final String? dateModified;

  const MealModel({
    required this.id,
    required this.name,
    this.drinkAlternate,
    this.category,
    this.area,
    this.instructions,
    this.thumbnail,
    this.tags,
    this.youtubeUrl,
    this.ingredients = const {},
    this.measures = const {},
    this.source,
    this.imageSource,
    this.creativeCommonsConfirmed,
    this.dateModified,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String, String>{};
    final measures = <String, String>{};

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients['ingredient$i'] = ingredient.toString();
      }
      if (measure != null && measure.toString().trim().isNotEmpty) {
        measures['measure$i'] = measure.toString();
      }
    }

    return MealModel(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      drinkAlternate: json['strDrinkAlternate'] as String?,
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      thumbnail: json['strMealThumb'] as String?,
      tags: json['strTags'] as String?,
      youtubeUrl: json['strYoutube'] as String?,
      ingredients: ingredients,
      measures: measures,
      source: json['strSource'] as String?,
      imageSource: json['strImageSource'] as String?,
      creativeCommonsConfirmed: json['strCreativeCommonsConfirmed'] as String?,
      dateModified: json['dateModified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'idMeal': id,
      'strMeal': name,
      'strDrinkAlternate': drinkAlternate,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnail,
      'strTags': tags,
      'strYoutube': youtubeUrl,
      'strSource': source,
      'strImageSource': imageSource,
      'strCreativeCommonsConfirmed': creativeCommonsConfirmed,
      'dateModified': dateModified,
    };

    int index = 1;
    ingredients.forEach((key, value) {
      json['strIngredient$index'] = value;
      index++;
    });

    index = 1;
    measures.forEach((key, value) {
      json['strMeasure$index'] = value;
      index++;
    });

    return json;
  }

  List<MapEntry<String, String>> get ingredientsWithMeasures {
    final List<MapEntry<String, String>> result = [];
    final sortedIngredientKeys = ingredients.keys.toList()..sort();

    for (final key in sortedIngredientKeys) {
      final index = key.replaceAll('ingredient', '');
      final ingredient = ingredients[key]!;
      final measure = measures['measure$index'] ?? '';
      result.add(MapEntry(ingredient, measure));
    }

    return result;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    drinkAlternate,
    category,
    area,
    instructions,
    thumbnail,
    tags,
    youtubeUrl,
    ingredients,
    measures,
    source,
    imageSource,
    creativeCommonsConfirmed,
    dateModified,
  ];
}
