part of 'favorites_bloc.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();
}

final class FavoritesInitial extends FavoritesState {
  @override
  List<Object> get props => [];
}

final class FavoritesLoadingState extends FavoritesState {
  @override
  List<Object> get props => [];
}

final class FavoritesLoadedState extends FavoritesState {
  final List<MealModel> favorites;

  const FavoritesLoadedState(this.favorites);

  @override
  List<Object> get props => [favorites];
}

final class FavoritesEmptyState extends FavoritesState {
  @override
  List<Object> get props => [];
}

final class FavoriteAddedState extends FavoritesState {
  final String mealId;

  const FavoriteAddedState(this.mealId);

  @override
  List<Object> get props => [mealId];
}

final class FavoriteRemovedState extends FavoritesState {
  final String mealId;

  const FavoriteRemovedState(this.mealId);

  @override
  List<Object> get props => [mealId];
}

final class FavoriteStatusState extends FavoritesState {
  final String mealId;
  final bool isFavorite;

  const FavoriteStatusState(this.mealId, this.isFavorite);

  @override
  List<Object> get props => [mealId, isFavorite];
}

final class FavoritesErrorState extends FavoritesState {
  final String message;

  const FavoritesErrorState(this.message);

  @override
  List<Object> get props => [message];
}
