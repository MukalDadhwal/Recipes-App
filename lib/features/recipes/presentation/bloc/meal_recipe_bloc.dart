import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'meal_recipe_event.dart';
part 'meal_recipe_state.dart';

class MealRecipeBloc extends Bloc<MealRecipeEvent, MealRecipeState> {
  MealRecipeBloc() : super(MealRecipeInitial()) {
    on<MealRecipeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
