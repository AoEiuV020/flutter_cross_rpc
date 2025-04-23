import 'package:cross_json_rpc/cross_json_rpc.dart';
import 'package:cross_proto/cross_proto.dart';
import 'package:grpc/grpc.dart';
import 'package:stream_channel/stream_channel.dart';

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

class ProductServiceAdapter extends ProductServiceBase {
  final ProductService _adapter;

  ProductServiceAdapter(this._adapter);

  @override
  Future<ProductList> queryProducts(ServiceCall call, ProductQuery request) {
    return _adapter.queryProducts(request);
  }

  @override
  Future<Product> getProduct(ServiceCall call, GetProductRequest request) {
    return _adapter.getProduct(request);
  }

  @override
  Future<ProductList> getAllProducts(ServiceCall call, Empty request) {
    return _adapter.getAllProducts(request);
  }
}

class ProductServiceJsonClient extends ProductServiceClient
    with JsonClientMixin {
  @override
  final JsonRpcClient jsonRpcClient;

  /// 使用已存在的 JsonRpcService 创建客户端
  ProductServiceJsonClient(this.jsonRpcClient)
    : super(JsonClientMixin.channel) {
    jsonRpcClient.listen();
  }

  /// 使用 StreamChannel 创建客户端
  ProductServiceJsonClient.create(StreamChannel<String> channel)
    : jsonRpcClient = JsonRpcClient(channel),
      super(JsonClientMixin.channel) {
    jsonRpcClient.listen();
  }
}
