import 'package:cross_proto/cross_proto.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

import 'package:cross_server/src/product_service_impl.dart';

void main() {
  late ProductService service;

  setUp(() {
    service = ProductServiceImpl();
  });

  group('ProductService Tests', () {
    test('should handle queryProducts correctly', () async {
      // 测试空查询
      final emptyResult = await service.queryProducts(ProductQuery());
      expect(emptyResult.total, equals(4));
      expect(emptyResult.items.length, equals(4));

      // 测试关键词查询
      final keywordResult = await service.queryProducts(
        ProductQuery(keyword: 'iphone'),
      );
      expect(keywordResult.total, equals(1));
      expect(keywordResult.items.first.name, contains('iPhone'));

      // 测试价格范围查询
      final priceResult = await service.queryProducts(
        ProductQuery(minPrice: 1500, maxPrice: 2500),
      );
      expect(priceResult.total, equals(1));
      expect(priceResult.items.first.name, equals('MacBook'));
    });

    test('should handle getProduct correctly', () async {
      // 测试获取存在的商品
      final existingProduct = await service.getProduct(
        GetProductRequest(id: 1),
      );
      expect(existingProduct.id, equals(1));
      expect(existingProduct.name, equals('iPhone'));
      expect(existingProduct.price, equals(999.99));
      expect(existingProduct.stock, equals(100));

      // 测试获取不存在的商品
      expect(
        () => service.getProduct(GetProductRequest(id: 999)),
        throwsA(
          predicate((e) => e is GrpcError && e.code == StatusCode.notFound),
        ),
      );
    });
  });
}
