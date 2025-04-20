import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cross_proto/cross_proto.dart';
import 'package:protobuf/protobuf.dart' as $pb;

// 实现 ProductServiceBase
class MyProductService extends ProductServiceBase {
  @override
  Future<Product> getProduct(
    $pb.ServerContext ctx,
    GetProductRequest request,
  ) async {
    print('处理 getProduct 请求: {id: ${request.id}}');

    if (request.id <= 0) {
      print('错误：无效的商品ID: ${request.id}');
      throw ArgumentError('商品ID必须大于0');
    }

    // 模拟数据库中的商品
    final products = {
      1: Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
      2: Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
    };

    final product = products[request.id];
    if (product == null) {
      print('错误：找不到商品: ${request.id}');
      throw ArgumentError('商品不存在');
    }

    print('成功返回商品: {id: ${product.id}, name: ${product.name}}');
    return product;
  }

  @override
  Future<ProductList> queryProducts(
    $pb.ServerContext ctx,
    ProductQuery request,
  ) async {
    print(
      '处理 queryProducts 请求: {keyword: ${request.keyword}, price_range: ${request.minPrice}-${request.maxPrice}}',
    );

    if (request.minPrice < 0 || request.maxPrice < 0) {
      print('错误：价格范围无效');
      throw ArgumentError('价格不能为负数');
    }

    // 模拟数据库查询
    final allProducts = [
      Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
      Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
    ];

    var filtered =
        allProducts.where((p) {
          if (request.keyword.isNotEmpty &&
              !p.name.toLowerCase().contains(request.keyword.toLowerCase())) {
            return false;
          }
          if (request.minPrice > 0 && p.price < request.minPrice) return false;
          if (request.maxPrice > 0 && p.price > request.maxPrice) return false;
          return true;
        }).toList();

    print('查询成功，返回 ${filtered.length} 个商品');
    return ProductList(items: filtered, total: filtered.length);
  }

  @override
  $pb.GeneratedMessage createRequest(String method) {
    print('创建请求对象: $method');
    return super.createRequest(method);
  }
}

void main() async {
  print('正在启动服务器...');

  try {
    final server = await ServerSocket.bind('localhost', 8888);
    print('服务器启动成功: ${server.address.host}:${server.port}');

    final service = MyProductService();

    await for (Socket client in server) {
      print('\n新客户端连接: ${client.remoteAddress.address}:${client.remotePort}');
      handleClient(client, service);
    }
  } catch (e) {
    print('服务器启动失败: $e');
    exit(1);
  }
}

void handleClient(Socket client, ProductServiceBase service) {
  client.listen(
    (List<int> data) async {
      try {
        final methodName = String.fromCharCode(data[0]);
        final messageBytes = data.sublist(1);
        final ctx = SimpleServerContext();

        print('\n收到请求: ${methodName == 'Q' ? 'QueryProducts' : 'GetProduct'}');

        try {
          switch (methodName) {
            case 'Q':
              final query = ProductQuery.fromBuffer(messageBytes);
              final result = await service.queryProducts(ctx, query);
              // 发送成功响应，以S开头
              client.add(['S'.codeUnitAt(0), ...result.writeToBuffer()]);
              break;

            case 'G':
              final request = GetProductRequest.fromBuffer(messageBytes);
              final result = await service.getProduct(ctx, request);
              // 发送成功响应，以S开头
              client.add(['S'.codeUnitAt(0), ...result.writeToBuffer()]);
              break;

            default:
              throw ArgumentError('未知的方法');
          }
        } catch (e) {
          // 发送错误响应，以E开头，后面是UTF8编码的错误消息
          final errorBytes = utf8.encode(e.toString());
          client.add(['E'.codeUnitAt(0), ...errorBytes]);
        }
      } catch (e) {
        print('处理请求时出错: $e');
        try {
          // 尝试发送错误消息
          final errorBytes = utf8.encode('内部错误: $e');
          client.add(['E'.codeUnitAt(0), ...errorBytes]);
        } catch (_) {
          // 如果连错误都发送不了，就关闭连接
          client.destroy();
        }
      }
    },
    onError: (error) {
      print('客户端连接错误: $error');
      client.destroy();
    },
    onDone: () {
      print('客户端断开连接');
      client.destroy();
    },
  );
}

class SimpleServerContext implements $pb.ServerContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
