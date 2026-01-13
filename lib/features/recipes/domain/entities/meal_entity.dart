import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
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

  const MealEntity({
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
