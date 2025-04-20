import 'package:cross_proto/cross_proto.dart';
import 'package:test/test.dart';

void main() {
  test('should create Product instance', () {
    final product = Product(
      id: 1,
      name: 'Test Product',
      price: 99.99,
      stock: 100,
    );

    expect(product.id, equals(1));
    expect(product.name, equals('Test Product'));
    expect(product.price, equals(99.99));
    expect(product.stock, equals(100));
  });

  test('should create ProductQuery instance', () {
    final query = ProductQuery(
      keyword: 'test',
      minPrice: 10.0,
      maxPrice: 100.0,
    );

    expect(query.keyword, equals('test'));
    expect(query.minPrice, equals(10.0));
    expect(query.maxPrice, equals(100.0));
  });

  test('should create GetProductRequest instance', () {
    final request = GetProductRequest(id: 1);
    expect(request.id, equals(1));
  });
}
