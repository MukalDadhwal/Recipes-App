import 'package:hive/hive.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';

class MealModelAdapter extends TypeAdapter<MealModel> {
  @override
  final int typeId = 0;

  @override
  MealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealModel(
      id: fields[0] as String,
      name: fields[1] as String,
      drinkAlternate: fields[2] as String?,
      category: fields[3] as String?,
      area: fields[4] as String?,
      instructions: fields[5] as String?,
      thumbnail: fields[6] as String?,
      tags: fields[7] as String?,
      youtubeUrl: fields[8] as String?,
      ingredients: (fields[9] as Map).cast<String, String>(),
      measures: (fields[10] as Map).cast<String, String>(),
      source: fields[11] as String?,
      imageSource: fields[12] as String?,
      creativeCommonsConfirmed: fields[13] as String?,
      dateModified: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.drinkAlternate)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.instructions)
      ..writeByte(6)
      ..write(obj.thumbnail)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.youtubeUrl)
      ..writeByte(9)
      ..write(obj.ingredients)
      ..writeByte(10)
      ..write(obj.measures)
      ..writeByte(11)
      ..write(obj.source)
      ..writeByte(12)
      ..write(obj.imageSource)
      ..writeByte(13)
      ..write(obj.creativeCommonsConfirmed)
      ..writeByte(14)
      ..write(obj.dateModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
