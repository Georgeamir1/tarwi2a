import 'package:flutter_test/flutter_test.dart';
import 'package:tarwi2a/domain/entities/product.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Product', () {
    test('two products with same fields are equal', () {
      const a = testProduct;
      const b = Product(
        id: 'prod-1',
        categoryId: 'cat-1',
        name: 'Margherita',
        nameAr: 'مارجريتا',
        description: 'Cheese and tomato',
        descriptionAr: 'جبنة و طماطم',
        price: 75.0,
        imageUrl: 'https://example.com/margherita.png',
        isAvailable: true,
        sortOrder: 1,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes a field', () {
      final updated = testProduct.copyWith(price: 90.0);

      expect(updated.price, 90.0);
      expect(updated.id, testProduct.id);
      expect(updated.name, testProduct.name);
    });

    test('props are accessible', () {
      expect(testProduct.id, 'prod-1');
      expect(testProduct.categoryId, 'cat-1');
      expect(testProduct.name, 'Margherita');
      expect(testProduct.nameAr, 'مارجريتا');
      expect(testProduct.price, 75.0);
      expect(testProduct.isAvailable, true);
      expect(testProduct.sortOrder, 1);
    });
  });
}
