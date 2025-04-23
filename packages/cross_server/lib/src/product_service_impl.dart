import 'package:cross_proto/cross_proto.dart';
import 'package:cross_wrapper/cross_wrapper.dart';
import 'package:grpc/grpc.dart';

class ProductServiceImpl implements ProductService {
  // 模拟数据库中的商品列表
  static final List<Product> _productList = [
    Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
    Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
    Product(id: 3, name: 'iPad', price: 599.99, stock: 200),
    Product(id: 4, name: 'AirPods', price: 199.99, stock: 300),
  ];

  // 将商品列表转换为Map以便快速查询
  static final Map<int, Product> _products = Map.fromEntries(
    _productList.map((product) => MapEntry(product.id, product)),
  );

  @override
  Future<Product> getProduct(GetProductRequest request) async {
    print('处理 getProduct 请求: ID=${request.id}');

    final product = _products[request.id];
    if (product == null) {
      // details没用，client有反序列化但是server没有序列化，
      throw GrpcError.notFound('商品不存在: ID=${request.id}', [request]);
    }

    print('返回商品: ${product.name}');
    return product;
  }

  @override
  Future<ProductList> queryProducts(ProductQuery request) async {
    print('处理 queryProducts 请求:');
    print('- 关键词: ${request.keyword}');
    print('- 价格范围: ${request.minPrice} - ${request.maxPrice}');

    var filtered =
        _products.values.where((p) {
          if (request.keyword.isNotEmpty &&
              !p.name.toLowerCase().contains(request.keyword.toLowerCase())) {
            return false;
          }
          if (request.minPrice > 0 && p.price < request.minPrice) return false;
          if (request.maxPrice > 0 && p.price > request.maxPrice) return false;
          return true;
        }).toList();

    print('查询成功: 返回 ${filtered.length} 个商品');
    return ProductList(items: filtered, total: filtered.length);
  }

  @override
  Future<ProductList> getAllProducts(Empty request) async {
    print('处理 getAllProducts 请求:');

    final allProducts = _products.values.toList();

    print('查询成功: 返回 ${allProducts.length} 个商品');
    return ProductList(items: allProducts, total: allProducts.length);
  }
}
