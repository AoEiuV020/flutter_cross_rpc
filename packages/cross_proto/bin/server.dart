import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:cross_proto/cross_proto.dart';

class ProductServiceImpl extends ProductServiceBase {
  @override
  Future<Product> getProduct(ServiceCall call, GetProductRequest request) async {
    print('处理 getProduct 请求: ID=${request.id}');

    // 模拟数据库中的商品
    final products = {
      1: Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
      2: Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
    };

    final product = products[request.id];
    if (product == null) {
      throw GrpcError.notFound('商品不存在: ID=${request.id}');
    }

    print('返回商品: ${product.name}');
    return product;
  }

  @override
  Future<ProductList> queryProducts(ServiceCall call, ProductQuery request) async {
    print('处理 queryProducts 请求:');
    print('- 关键词: ${request.keyword}');
    print('- 价格范围: ${request.minPrice} - ${request.maxPrice}');

    // 模拟数据库查询
    final allProducts = [
      Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
      Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
      Product(id: 3, name: 'iPad', price: 599.99, stock: 200),
      Product(id: 4, name: 'AirPods', price: 199.99, stock: 300),
    ];

    var filtered = allProducts.where((p) {
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
}

/// 日志拦截器
FutureOr<GrpcError?> loggingInterceptor(
    ServiceCall call, ServiceMethod<dynamic, dynamic> method) async {
  try {
    print('开始处理请求:');
    print('- 名称: ${method.name}');
    
    // 继续处理请求
    return null;
  } catch (error) {
    if (error is GrpcError) rethrow;
    print('发生错误: $error');
    return GrpcError.internal(error.toString());
  }
}

void main() async {
  final server = Server.create(
    services: [ProductServiceImpl()],
    interceptors: [loggingInterceptor],
  );

  await server.serve(
    address: 'localhost',
    port: 8888,
  );

  print('gRPC 服务器启动成功: localhost:8888');
}
