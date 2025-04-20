import 'package:cross_proto/cross_proto.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// 产品服务客户端
class ProductClient {
  final ProductServiceApi _api;
  final $pb.ClientContext? _ctx;

  ProductClient(this._api, {$pb.ClientContext? context}) : _ctx = context;

  /// 根据ID获取商品
  Future<Product> getProduct(int id) async {
    final request = GetProductRequest(id: id);
    return await _api.getProduct(_ctx, request);
  }

  /// 查询商品列表
  Future<ProductList> queryProducts({
    String keyword = '',
    double minPrice = 0,
    double maxPrice = 0,
  }) async {
    final query = ProductQuery(
      keyword: keyword,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    return await _api.queryProducts(_ctx, query);
  }
}