import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cross_proto/cross_proto.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// 自定义RPC错误
class RpcError implements Exception {
  final String message;
  RpcError(this.message);
  
  @override
  String toString() => message;
}

/// 简单的消息读写器
class MessageTransport {
  final Socket _socket;
  final _responseController = StreamController<List<int>>.broadcast();

  MessageTransport(this._socket) {
    _socket.listen(
      _responseController.add,
      onError: _responseController.addError,
      onDone: _responseController.close,
    );
  }

  /// 发送请求并等待响应
  Future<List<int>> sendAndReceive(String method, List<int> message) async {
    final methodCode = method.codeUnitAt(0);
    _socket.add([methodCode, ...message]);
    
    final response = await _responseController.stream.first;
    final responseType = String.fromCharCode(response[0]);
    final responseData = response.sublist(1);

    // 检查是否是错误响应
    if (responseType == 'E') {
      final errorMessage = utf8.decode(responseData);
      throw RpcError(errorMessage);
    }

    return responseData;
  }

  void close() {
    _responseController.close();
    _socket.close();
  }
}

/// 简单的 RPC 客户端实现
class SimpleRpcClient implements $pb.RpcClient {
  final MessageTransport _transport;
  final Duration timeout;
  final int maxRetries;

  SimpleRpcClient(Socket socket, {
    this.timeout = const Duration(seconds: 5),
    this.maxRetries = 3,
  }) : _transport = MessageTransport(socket);

  @override
  Future<T> invoke<T extends $pb.GeneratedMessage>(
    $pb.ClientContext? ctx,
    String serviceName,
    String methodName,
    $pb.GeneratedMessage request,
    T emptyResponse,
  ) async {
    var attempts = 0;
    while (true) {
      try {
        attempts++;
        final methodCode = methodName == 'QueryProducts' ? 'Q' : 'G';
        
        // 发送请求并等待响应
        final responseData = await _transport
            .sendAndReceive(methodCode, request.writeToBuffer())
            .timeout(timeout);

        // 解析响应
        return emptyResponse..mergeFromBuffer(responseData);
      } on RpcError {
        // RPC错误直接抛出，不需要重试
        rethrow;
      } catch (e) {
        if (attempts >= maxRetries) {
          throw RpcError('调用失败 ($methodName): $e');
        }
        // 等待后重试
        await Future.delayed(Duration(milliseconds: 200 * attempts));
      }
    }
  }
}

void main() async {
  Socket? socket;
  
  try {
    print('正在连接服务器...');
    socket = await Socket.connect('localhost', 8888);
    print('已连接到服务器: ${socket.remoteAddress.address}:${socket.remotePort}');

    // 创建 RPC 客户端
    final rpcClient = SimpleRpcClient(
      socket,
      timeout: Duration(seconds: 5),
      maxRetries: 3,
    );
    final api = ProductServiceApi(rpcClient);

    try {
      // 测试1：使用 API 查询商品
      print('\n1. 测试查询全部商品:');
      var products = await api.queryProducts(null, ProductQuery());
      print('找到 ${products.total} 个商品:');
      for (var p in products.items) {
        print('- ${p.name}: ￥${p.price}');
      }

      // 测试2：按关键词搜索
      print('\n2. 测试按关键词搜索 (iPhone):');
      products = await api.queryProducts(
        null,
        ProductQuery(keyword: 'iphone'),
      );
      print('找到 ${products.total} 个商品:');
      for (var p in products.items) {
        print('- ${p.name}: ￥${p.price}');
      }

      // 测试3：按价格范围搜索
      print('\n3. 测试按价格范围搜索 (1500-2500):');
      products = await api.queryProducts(
        null,
        ProductQuery(
          minPrice: 1500,
          maxPrice: 2500,
        ),
      );
      print('找到 ${products.total} 个商品:');
      for (var p in products.items) {
        print('- ${p.name}: ￥${p.price}');
      }

      // 测试4：获取单个商品
      print('\n4. 测试获取单个商品 (ID: 1):');
      final product = await api.getProduct(
        null,
        GetProductRequest(id: 1),
      );
      print('商品详情:');
      print('- ID: ${product.id}');
      print('- 名称: ${product.name}');
      print('- 价格: ￥${product.price}');
      print('- 库存: ${product.stock}');

      // 测试5：测试错误处理 - 获取不存在的商品
      print('\n5. 测试错误处理 - 获取不存在的商品 (ID: 999):');
      try {
        await api.getProduct(null, GetProductRequest(id: 999));
      } catch (e) {
        print('预期的错误: $e');
      }

    } finally {
      // 关闭连接
      socket.close();
      print('\n已关闭连接');
    }
  } catch (e) {
    print('发生错误: $e');
    socket?.close();
  }
}
