import 'package:equatable/equatable.dart';

class AreaModel extends Equatable {
  final String name;

  const AreaModel({required this.name});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(name: json['strArea'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'strArea': name};
  }

  @override
  List<Object?> get props => [name];
}
