class ImageUtils {
  ImageUtils._();

  static String getIngredientImage(String ingredientName) {
    final cleanName = ingredientName.trim().toLowerCase().replaceAll(
      ' ',
      '%20',
    );
    return 'https://www.themealdb.com/images/ingredients/$cleanName.png';
  }
}

enum ImageSize { small, medium, large }
