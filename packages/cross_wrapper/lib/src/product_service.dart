import 'package:cross_proto/cross_proto.dart';

/// 商品服务的抽象接口定义
abstract class ProductService {
  /// 查询商品列表
  Future<ProductList> queryProducts(ProductQuery query);

  /// 获取单个商品
  Future<Product> getProduct(GetProductRequest request);

  // 获取所有商品
  Future<ProductList> getAllProducts(Empty request);
}

class ProductServiceWrapper implements ProductService {
  final dynamic target;

  ProductServiceWrapper(this.target);
  @override
  Future<ProductList> queryProducts(ProductQuery query) async {
    return await target.queryProducts(query);
  }

  @override
  Future<Product> getProduct(GetProductRequest request) async {
    return await target.getProduct(request);
  }

  @override
  Future<ProductList> getAllProducts(Empty request) async {
    return await target.getAllProducts(request);
  }

  @override
  String toString() {
    return target.toString();
  }
}
