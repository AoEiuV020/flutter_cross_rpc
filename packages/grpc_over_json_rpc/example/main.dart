import 'dart:io';

import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:cross_proto/cross_proto.dart';
import 'package:grpc/grpc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  print('初始化 JSON-RPC 服务器...');
  final server = JsonServer.create(services: [ProductServiceImpl()]);
  print('JSON-RPC 服务器初始化完成');

  print('开始创建 WebSocket 服务器...');
  final httpServer = await HttpServer.bind('localhost', 8889);
  print('JSON-RPC Server 已启动并监听: ws://localhost:8889');

  var connectedChannels = httpServer
      .where((request) => request.uri.path == '/ws')
      .transform(WebSocketTransformer())
      .map(IOWebSocketChannel.new);

  connectedChannels.listen((WebSocketChannel channel) {
    print('新客户端连接');
    server.serve(channel.cast<String>());

    // 监听连接关闭事件, 测试用，客户端断开后关闭服务器，
    channel.sink.done.then((_) {
      print('客户端断开连接');
      httpServer.close(force: true).then((_) {
        print('服务器已关闭');
        exit(0); // 完全退出程序
      });
    });
  });

  client();
}

void client() async {
  print('开始连接 WebSocket 服务器...');
  var channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8889/ws'));
  print('WebSocket 连接成功建立');
  var jsonRpcClient = JsonRpcClient(channel.cast<String>());
  print('创建 ProductService 客户端...');
  final client = ProductServiceJsonClient(jsonRpcClient);

  try {
    print('开始测试 $client ...\n');

    // 测试1：查询所有商品
    print('1. 查询所有商品:');
    var response = await client.queryProducts(ProductQuery());
    print('找到 ${response.total} 个商品:');
    for (var product in response.items) {
      print('- ${product.name}: ￥${product.price}');
    }
    print('测试执行完成');
  } catch (e) {
    print('执行过程中发生错误: $e');
  } finally {
    print('清理资源...');
    await jsonRpcClient.close();
    print('连接已关闭，程序结束');
  }
}

/// 客户端实现，
class ProductServiceJsonClient extends ProductServiceClient
    with JsonClientMixin {
  @override
  final JsonRpcClient jsonRpcClient;

  ProductServiceJsonClient(this.jsonRpcClient)
    : super(JsonClientMixin.channel) {
    jsonRpcClient.listen();
  }
}

/// 服务端实现，
class ProductServiceImpl extends ProductServiceBase {
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
  Future<Product> getProduct(
    ServiceCall call,
    GetProductRequest request,
  ) async {
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
  Future<ProductList> queryProducts(
    ServiceCall call,
    ProductQuery request,
  ) async {
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
  Future<ProductList> getAllProducts(ServiceCall call, Empty request) async {
    print('处理 getAllProducts 请求:');

    final allProducts = _products.values.toList();

    print('查询成功: 返回 ${allProducts.length} 个商品');
    return ProductList(items: allProducts, total: allProducts.length);
  }
}
