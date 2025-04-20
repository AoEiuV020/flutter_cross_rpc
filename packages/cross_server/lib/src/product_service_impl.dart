import 'package:cross_proto/cross_proto.dart';
import 'package:protobuf/protobuf.dart' as $pb;

class ProductServiceImpl extends ProductServiceBase {
  // 模拟数据库中的商品数据
  final _products = <Product>[
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
  Future<Product> getProduct($pb.ServerContext ctx, GetProductRequest request) async {
    final product = _products.firstWhere(
      (p) => p.id == request.id,
      orElse: () => Product()..id = request.id,
    );
    return product;
  }

  @override
  Future<ProductList> queryProducts($pb.ServerContext ctx, ProductQuery request) async {
    var filteredProducts = _products.where((product) {
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
      items: filteredProducts,
      total: filteredProducts.length,
    );
  }
}
