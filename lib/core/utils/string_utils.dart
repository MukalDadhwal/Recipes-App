class StringUtils {
  StringUtils._();

  static List<String> parseInstructions(String? instructions) {
    if (instructions == null || instructions.isEmpty) {
      return [];
    }

    final steps = instructions
        .replaceAll('\r\n', '\n')
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();

    return steps;
  }

  static String getYoutubeVideoId(String? youtubeUrl) {
    if (youtubeUrl == null || youtubeUrl.isEmpty) {
      return '';
    }

    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );

    final match = regExp.firstMatch(youtubeUrl);
    return match?.group(1) ?? '';
  }
}
