part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();
}

final class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();

  @override
  List<Object> get props => [];
}

final class AddToFavoritesEvent extends FavoritesEvent {
  final MealModel meal;

  const AddToFavoritesEvent(this.meal);

  @override
  List<Object> get props => [meal];
}

final class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String mealId;

  const RemoveFromFavoritesEvent(this.mealId);

  @override
  List<Object> get props => [mealId];
}

final class CheckFavoriteStatusEvent extends FavoritesEvent {
  final String mealId;

  const CheckFavoriteStatusEvent(this.mealId);

  @override
  List<Object> get props => [mealId];
}
