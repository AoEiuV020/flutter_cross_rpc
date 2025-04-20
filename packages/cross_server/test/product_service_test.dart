import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/src/product_service_impl.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:test/test.dart';

// 创建一个简单的 ServerContext 模拟实现
class TestServerContext implements $pb.ServerContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ProductServiceBase service;
  late $pb.ServerContext ctx;

  setUp(() {
    service = ProductServiceImpl();
    ctx = TestServerContext();
  });

  group('ProductService Tests', () {
    test('should create request messages correctly', () {
      expect(
        service.createRequest('QueryProducts'),
        isA<ProductQuery>(),
      );
      expect(
        service.createRequest('GetProduct'),
        isA<GetProductRequest>(),
      );
      expect(
        () => service.createRequest('NonExistentMethod'),
        throwsArgumentError,
      );
    });

    test('should handle queryProducts correctly', () async {
      // 测试空查询
      final emptyResult = await service.queryProducts(ctx, ProductQuery());
      expect(emptyResult.total, equals(2));
      expect(emptyResult.items.length, equals(2));

      // 测试关键词查询
      final keywordResult = await service.queryProducts(
        ctx,
        ProductQuery(keyword: 'iphone'),
      );
      expect(keywordResult.total, equals(1));
      expect(keywordResult.items.first.name, contains('iPhone'));

      // 测试价格范围查询
      final priceResult = await service.queryProducts(
        ctx,
        ProductQuery(
          minPrice: 1500,
          maxPrice: 2500,
        ),
      );
      expect(priceResult.total, equals(1));
      expect(priceResult.items.first.name, equals('MacBook Pro'));
    });

    test('should handle getProduct correctly', () async {
      // 测试获取存在的商品
      final existingProduct = await service.getProduct(
        ctx,
        GetProductRequest(id: 1),
      );
      expect(existingProduct.id, equals(1));
      expect(existingProduct.name, equals('iPhone 15'));
      expect(existingProduct.price, equals(999.99));

      // 测试获取不存在的商品
      final nonExistentProduct = await service.getProduct(
        ctx,
        GetProductRequest(id: 999),
      );
      expect(nonExistentProduct.id, equals(999));
      expect(nonExistentProduct.name, isEmpty);
    });

    test('should handle method calls through handleCall', () async {
      // 测试 queryProducts 方法调用
      final queryResult = await service.handleCall(
        ctx,
        'QueryProducts',
        ProductQuery(keyword: 'macbook'),
      );
      expect(queryResult, isA<ProductList>());
      final productList = queryResult as ProductList;
      expect(productList.total, equals(1));
      expect(productList.items.first.name, contains('MacBook'));

      // 测试 getProduct 方法调用
      final getResult = await service.handleCall(
        ctx,
        'GetProduct',
        GetProductRequest(id: 2),
      );
      expect(getResult, isA<Product>());
      final product = getResult as Product;
      expect(product.id, equals(2));
      expect(product.name, equals('MacBook Pro'));
    });

    test('should throw on invalid method name in handleCall', () {
      expect(
        () => service.handleCall(ctx, 'InvalidMethod', ProductQuery()),
        throwsArgumentError,
      );
    });
  });
}
