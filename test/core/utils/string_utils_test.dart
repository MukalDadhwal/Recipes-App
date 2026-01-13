import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/core/utils/string_utils.dart';

void main() {
  group('StringUtils', () {
    group('parseInstructions', () {
      test('should parse instructions correctly with newlines', () {
        const instructions =
            'Step 1: Mix ingredients\nStep 2: Bake at 350F\nStep 3: Serve hot';

        final result = StringUtils.parseInstructions(instructions);

        expect(result.length, 3);
        expect(result[0], 'Step 1: Mix ingredients');
        expect(result[1], 'Step 2: Bake at 350F');
        expect(result[2], 'Step 3: Serve hot');
      });

      test('should return empty list for null instructions', () {
        final result = StringUtils.parseInstructions(null);

        expect(result, isEmpty);
      });

      test('should return empty list for empty instructions', () {
        final result = StringUtils.parseInstructions('');

        expect(result, isEmpty);
      });

      test('should trim whitespace from steps', () {
        const instructions = '  Step 1  \n  Step 2  ';

        final result = StringUtils.parseInstructions(instructions);

        expect(result[0], 'Step 1');
        expect(result[1], 'Step 2');
      });
    });

    group('getYoutubeVideoId', () {
      test('should extract video ID from youtube.com/watch url', () {
        const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

        final result = StringUtils.getYoutubeVideoId(url);

        expect(result, 'dQw4w9WgXcQ');
      });

      test('should extract video ID from youtu.be url', () {
        const url = 'https://youtu.be/dQw4w9WgXcQ';

        final result = StringUtils.getYoutubeVideoId(url);

        expect(result, 'dQw4w9WgXcQ');
      });

      test('should return empty string for null url', () {
        final result = StringUtils.getYoutubeVideoId(null);

        expect(result, isEmpty);
      });

      test('should return empty string for empty url', () {
        final result = StringUtils.getYoutubeVideoId('');

        expect(result, isEmpty);
      });

      test('should return empty string for invalid url', () {
        const url = 'https://www.google.com';

        final result = StringUtils.getYoutubeVideoId(url);

        expect(result, isEmpty);
      });
    });
  });
}
