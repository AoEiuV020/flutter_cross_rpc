import 'package:cross_proto/cross_proto.dart';
import 'package:test/test.dart';

void main() {
  group('Product Tests', () {
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

    test('should convert Product to/from JSON', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        price: 99.99,
        stock: 100,
      );

      // 转换为JSON
      final jsonMap = product.toProto3Json() as Map<String, dynamic>;
      expect(jsonMap['id'], equals(1)); // Proto3 JSON格式中数字会转为字符串
      expect(jsonMap['name'], equals('Test Product'));
      expect(jsonMap['price'], equals(99.99));
      expect(jsonMap['stock'], equals(100));

      // 从JSON转回对象
      final decodedProduct = Product.create()..mergeFromProto3Json(jsonMap);
      expect(decodedProduct.id, equals(product.id));
      expect(decodedProduct.name, equals(product.name));
      expect(decodedProduct.price, equals(product.price));
      expect(decodedProduct.stock, equals(product.stock));
    });
  });

  group('ProductQuery Tests', () {
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

    test('should convert ProductQuery to/from JSON', () {
      final query = ProductQuery(
        keyword: 'test query',
        minPrice: 10.0,
        maxPrice: 100.0,
      );

      // 转换为JSON
      final jsonMap = query.toProto3Json() as Map<String, dynamic>;
      expect(jsonMap['keyword'], equals('test query'));
      expect(jsonMap['minPrice'], equals(10.0));
      expect(jsonMap['maxPrice'], equals(100.0));

      // 从JSON转回对象
      final decodedQuery = ProductQuery.create()..mergeFromProto3Json(jsonMap);
      expect(decodedQuery.keyword, equals(query.keyword));
      expect(decodedQuery.minPrice, equals(query.minPrice));
      expect(decodedQuery.maxPrice, equals(query.maxPrice));
    });
  });

  group('ProductList Tests', () {
    test('should convert ProductList with items to/from JSON', () {
      final productList = ProductList(
        items: [
          Product(id: 1, name: 'Product 1', price: 10.0, stock: 5),
          Product(id: 2, name: 'Product 2', price: 20.0, stock: 10),
        ],
        total: 2,
      );

      // 转换为JSON
      final jsonMap = productList.toProto3Json() as Map<String, dynamic>;
      expect(jsonMap['total'], equals(2));
      expect((jsonMap['items'] as List).length, equals(2));
      expect((jsonMap['items'] as List)[0]['name'], equals('Product 1'));
      expect((jsonMap['items'] as List)[1]['name'], equals('Product 2'));

      // 从JSON转回对象
      final decodedList = ProductList.create()..mergeFromProto3Json(jsonMap);
      expect(decodedList.total, equals(productList.total));
      expect(decodedList.items.length, equals(2));
      expect(decodedList.items[0].name, equals('Product 1'));
      expect(decodedList.items[1].name, equals('Product 2'));
    });
  });

  group('GetProductRequest Tests', () {
    test('should convert GetProductRequest to/from JSON', () {
      final request = GetProductRequest(id: 123);

      // 转换为JSON
      final jsonMap = request.toProto3Json() as Map<String, dynamic>;
      expect(jsonMap['id'], equals(123));

      // 从JSON转回对象
      final decodedRequest =
          GetProductRequest.create()..mergeFromProto3Json(jsonMap);
      expect(decodedRequest.id, equals(request.id));
    });
  });
}
