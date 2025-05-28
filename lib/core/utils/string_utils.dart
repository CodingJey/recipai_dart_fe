// Helper to convert snake_case or kebab-case to Title Case
String toTitleCase(String text) {
  // Renamed for broader use, made public
  if (text.isEmpty) return '';
  if (text.contains('-')) {
    return text
        .split('-')
        .map(
          (part) => part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
              : '',
        )
        .join('-');
  }
  return text
      .replaceAllMapped(RegExp(r'_'), (match) => ' ')
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '',
      )
      .join(' ');
}
