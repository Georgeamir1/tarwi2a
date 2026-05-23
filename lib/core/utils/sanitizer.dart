import 'package:html/parser.dart' as html_parser;

class Sanitizer {
  static String sanitize(String? input) {
    if (input == null || input.isEmpty) return '';

    final document = html_parser.parse(input);
    final text = document.body?.text ?? document.text ?? '';
    return text.trim();
  }

  static String? sanitizeNullable(String? input) {
    return input == null ? null : sanitize(input);
  }

  static String stripAllTags(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
