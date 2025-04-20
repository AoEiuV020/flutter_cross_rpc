import 'package:cross_proto/cross_proto.dart';
import 'package:cross_client/src/product_client.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:test/test.dart';

class MockProductServiceApi implements ProductServiceApi {
  final List<Product> _mockProducts = [
    Product(
      id: 1,
      name: 'iPhone 15',
      price: 999.99,
      stock: 100,
    ),
    Product(
      id: 2,
      name: 'MacBook Pro',
      price: 1999.99,
      stock: 50,
    ),
  ];

  @override
  Future<Product> getProduct($pb.ClientContext? ctx, GetProductRequest request) async {
    return _mockProducts.firstWhere(
      (p) => p.id == request.id,
      orElse: () => Product(id: request.id),
    );
  }

  @override
  Future<ProductList> queryProducts($pb.ClientContext? ctx, ProductQuery request) async {
    var results = _mockProducts.where((product) {
      if (request.keyword.isNotEmpty &&
          !product.name.toLowerCase().contains(request.keyword.toLowerCase())) {
        return false;
      }
      if (request.minPrice > 0 && product.price < request.minPrice) {
        return false;
      }
      if (request.maxPrice > 0 && product.price > request.maxPrice) {
        return false;
      }
      return true;
    }).toList();

    return ProductList(
      items: results,
      total: results.length,
    );
  }

  // 注意：这是mock实现，不需要真正的RpcClient
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ProductClient client;
  late MockProductServiceApi mockApi;

  setUp(() {
    mockApi = MockProductServiceApi();
    client = ProductClient(mockApi);
  });

  group('ProductClient Tests', () {
    test('should get product by id', () async {
      final product = await client.getProduct(1);
      expect(product.id, equals(1));
      expect(product.name, equals('iPhone 15'));
      expect(product.price, equals(999.99));
    });

    test('should return empty product for non-existent id', () async {
      final product = await client.getProduct(999);
      expect(product.id, equals(999));
      expect(product.name, isEmpty);
      expect(product.price, equals(0));
    });

    test('should query products with keyword', () async {
      final results = await client.queryProducts(keyword: 'iphone');
      expect(results.total, equals(1));
      expect(results.items.first.name, contains('iPhone'));
    });

    test('should query products with price range', () async {
      final results = await client.queryProducts(
        minPrice: 1500,
        maxPrice: 2500,
      );
      expect(results.total, equals(1));
      expect(results.items.first.name, equals('MacBook Pro'));
    });

    test('should return all products with empty query', () async {
      final results = await client.queryProducts();
      expect(results.total, equals(2));
      expect(results.items.length, equals(2));
    });
  });
}