import 'dart:async';
import 'dart:io';

import 'package:cross_json_rpc/cross_json_rpc.dart';
import 'package:cross_wrapper/cross_wrapper.dart';
import 'package:stream_channel/stream_channel.dart';

import 'package:cross_server/cross_server.dart';

void main() async {
  print('初始化 JSON-RPC 服务器...');
  final server = JsonServer.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
  );
  print('JSON-RPC 服务器初始化完成，注册了 ProductServiceAdapter');

  // 创建 WebSocket 服务器
  print('开始创建 WebSocket 服务器...');
  final httpServer = await HttpServer.bind('localhost', 8889);
  print('JSON-RPC Server 已启动并监听: ws://localhost:8889');

  await for (final request in httpServer) {
    print('收到新的 HTTP 请求: ${request.uri.path}');
    if (request.uri.path == '/ws') {
      print('开始处理 WebSocket 升级请求...');
      WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
        print('WebSocket 连接已建立');

        // 创建 StreamController 用于处理发送到 WebSocket 的消息
        print('创建消息控制器...');
        final controller = StreamController<String>();
        controller.stream.listen(
          (data) {
            print('发送消息到客户端: $data');
            webSocket.add(data);
          },
          onError: (error) {
            print('WebSocket 发生错误: $error');
            webSocket.addError(error);
          },
          onDone: () {
            print('StreamController 完成，关闭 WebSocket');
            webSocket.close();
          },
        );

        // 将 WebSocket 转换为 StreamChannel
        print('创建 StreamChannel...');
        final channel = StreamChannel<String>(
          webSocket.map((message) {
            print('收到客户端消息: $message');
            return message as String;
          }),
          controller.sink,
        );

        // 为每个连接提供服务
        print('开始为此连接提供 JSON-RPC 服务');
        server.serve(channel);
      });
    } else {
      print('忽略非 WebSocket 请求: ${request.uri.path}');
    }
  }
}
