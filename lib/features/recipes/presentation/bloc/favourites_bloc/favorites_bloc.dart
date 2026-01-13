import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recipes_app/features/recipes/data/datasources/meal_local_data_source.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final MealLocalDataSource localDataSource;

  FavoritesBloc(this.localDataSource) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoadingState());
    try {
      final favorites = await localDataSource.getAllFavorites();
      if (favorites.isEmpty) {
        emit(FavoritesEmptyState());
      } else {
        emit(FavoritesLoadedState(favorites));
      }
    } catch (e) {
      emit(FavoritesErrorState('Failed to load favorites: ${e.toString()}'));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoriteAddedState(event.meal.id));
    try {
      await localDataSource.addToFavorites(event.meal);
    } catch (e) {
      emit(FavoritesErrorState('Failed to add to favorites: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoriteRemovedState(event.mealId));
    try {
      await localDataSource.removeFromFavorites(event.mealId);
    } catch (e) {
      emit(
        FavoritesErrorState('Failed to remove from favorites: ${e.toString()}'),
      );
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatusEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFav = await localDataSource.isFavorite(event.mealId);
      emit(FavoriteStatusState(event.mealId, isFav));
    } catch (e) {
      emit(
        FavoritesErrorState('Failed to check favorite status: ${e.toString()}'),
      );
    }
  }
}
