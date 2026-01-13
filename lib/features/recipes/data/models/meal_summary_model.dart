import 'package:equatable/equatable.dart';

class MealSummaryModel extends Equatable {
  final String id;
  final String name;
  final String thumbnail;

  const MealSummaryModel({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  factory MealSummaryModel.fromJson(Map<String, dynamic> json) {
    return MealSummaryModel(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnail,
    };
  }

  @override
  List<Object?> get props => [id, name, thumbnail];
}
