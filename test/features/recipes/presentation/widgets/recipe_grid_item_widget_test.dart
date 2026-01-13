import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_grid_item_widget.dart';

void main() {
  group('RecipeGridItemWidget', () {
    testWidgets('should render recipe name', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: RecipeGridItemWidget(
                id: '1',
                name: 'Test Recipe',
                imageUrl: 'https://example.com/image.jpg',
                category: 'Chicken',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('should render category when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: RecipeGridItemWidget(
                id: '1',
                name: 'Test Recipe',
                imageUrl: 'https://example.com/image.jpg',
                category: 'Chicken',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Chicken'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: RecipeGridItemWidget(
                id: '1',
                name: 'Test Recipe',
                imageUrl: 'https://example.com/image.jpg',
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should contain Hero widget with correct tag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: RecipeGridItemWidget(
                id: '456',
                name: 'Test Recipe',
                imageUrl: 'https://example.com/image.jpg',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final heroFinder = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'meal_456',
      );

      expect(heroFinder, findsOneWidget);
    });
  });
}
