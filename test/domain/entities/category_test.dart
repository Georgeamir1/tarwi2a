import 'package:flutter_test/flutter_test.dart';
import 'package:tarwi2a/domain/entities/category.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Category', () {
    test('two categories with same fields are equal', () {
      const a = testCategory;
      const b = Category(
        id: 'cat-1',
        name: 'Pizza',
        nameAr: 'بيتزا',
        imageUrl: 'https://example.com/pizza.png',
        sortOrder: 1,
        isActive: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes a field', () {
      final renamed = testCategory.copyWith(nameAr: 'بيتزا جديدة');

      expect(renamed.nameAr, 'بيتزا جديدة');
      expect(renamed.id, testCategory.id);
      expect(renamed.name, testCategory.name);
    });

    test('props are accessible', () {
      expect(testCategory.id, 'cat-1');
      expect(testCategory.name, 'Pizza');
      expect(testCategory.nameAr, 'بيتزا');
      expect(testCategory.imageUrl, 'https://example.com/pizza.png');
      expect(testCategory.sortOrder, 1);
      expect(testCategory.isActive, true);
    });
  });
}
