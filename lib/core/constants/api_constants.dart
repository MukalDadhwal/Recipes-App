class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static const String searchByName = '/search.php';
  static const String filterByArea = '/filter.php';
  static const String filterByCategory = '/filter.php';
  static const String lookupById = '/lookup.php';
  static const String listCategories = '/categories.php';
  static const String listAreas = '/list.php';
  static const String randomMeal = '/random.php';

  static const int connectionTimeout = 30000; // 30 secs
  static const int receiveTimeout = 30000;
}
