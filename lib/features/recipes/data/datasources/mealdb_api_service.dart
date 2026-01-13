import 'package:dio/dio.dart';
import 'package:recipes_app/core/constants/api_constants.dart';
import 'package:recipes_app/core/constants/app_strings.dart';
import 'package:recipes_app/core/error/exceptions.dart';
import 'package:recipes_app/features/recipes/data/models/area_model.dart';
import 'package:recipes_app/features/recipes/data/models/category_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_model.dart';
import 'package:recipes_app/features/recipes/data/models/meal_summary_model.dart';

abstract class MealDbApiService {
  Future<List<MealModel>> searchMealsByName(String query);
  Future<List<MealSummaryModel>> filterMealsByArea(String area);
  Future<List<MealSummaryModel>> filterMealsByCategory(String category);
  Future<MealModel?> getMealById(String id);
  Future<MealModel?> getRandomMeal();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<AreaModel>> getAllAreas();
}

class MealDbApiServiceImpl implements MealDbApiService {
  final Dio dio;

  MealDbApiServiceImpl(this.dio) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: ApiConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  Future<T> _handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const NetworkException(AppStrings.timeoutError);
        case DioExceptionType.connectionError:
          throw const NetworkException(AppStrings.noInternetConnection);
        case DioExceptionType.badResponse:
          throw ServerException(
            e.response?.data?['message'] ?? AppStrings.serverError,
          );
        default:
          throw const ServerException(AppStrings.unknownError);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MealModel>> searchMealsByName(String query) async {
    return _handleApiCall(() async {
      final response = await dio.get(
        ApiConstants.searchByName,
        queryParameters: {'s': query},
      );

      if (response.data == null || response.data['meals'] == null) {
        return [];
      }

      final meals = (response.data['meals'] as List)
          .map((meal) => MealModel.fromJson(meal as Map<String, dynamic>))
          .toList();

      return meals;
    });
  }

  @override
  Future<List<MealSummaryModel>> filterMealsByArea(String area) async {
    return _handleApiCall(() async {
      final response = await dio.get(
        ApiConstants.filterByArea,
        queryParameters: {'a': area},
      );

      if (response.data == null || response.data['meals'] == null) {
        return [];
      }

      final meals = (response.data['meals'] as List)
          .map(
            (meal) => MealSummaryModel.fromJson(meal as Map<String, dynamic>),
          )
          .toList();

      return meals;
    });
  }

  @override
  Future<List<MealSummaryModel>> filterMealsByCategory(String category) async {
    return _handleApiCall(() async {
      final response = await dio.get(
        ApiConstants.filterByCategory,
        queryParameters: {'c': category},
      );

      if (response.data == null || response.data['meals'] == null) {
        return [];
      }

      final meals = (response.data['meals'] as List)
          .map(
            (meal) => MealSummaryModel.fromJson(meal as Map<String, dynamic>),
          )
          .toList();

      return meals;
    });
  }

  @override
  Future<MealModel?> getMealById(String id) async {
    return _handleApiCall(() async {
      final response = await dio.get(
        ApiConstants.lookupById,
        queryParameters: {'i': id},
      );

      if (response.data == null || response.data['meals'] == null) {
        return null;
      }

      final meals = response.data['meals'] as List;
      if (meals.isEmpty) {
        return null;
      }

      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    });
  }

  @override
  Future<MealModel?> getRandomMeal() async {
    return _handleApiCall(() async {
      final response = await dio.get(ApiConstants.randomMeal);

      if (response.data == null || response.data['meals'] == null) {
        return null;
      }

      final meals = response.data['meals'] as List;
      if (meals.isEmpty) {
        return null;
      }

      return MealModel.fromJson(meals.first as Map<String, dynamic>);
    });
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return _handleApiCall(() async {
      final response = await dio.get(ApiConstants.listCategories);

      if (response.data == null || response.data['categories'] == null) {
        return [];
      }

      final categories = (response.data['categories'] as List)
          .map(
            (category) =>
                CategoryModel.fromJson(category as Map<String, dynamic>),
          )
          .toList();

      return categories;
    });
  }

  @override
  Future<List<AreaModel>> getAllAreas() async {
    return _handleApiCall(() async {
      final response = await dio.get(
        ApiConstants.listAreas,
        queryParameters: {'a': 'list'},
      );

      if (response.data == null || response.data['meals'] == null) {
        return [];
      }

      final areas = (response.data['meals'] as List)
          .map((area) => AreaModel.fromJson(area as Map<String, dynamic>))
          .toList();

      return areas;
    });
  }
}
