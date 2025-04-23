import 'dart:io';

import 'package:cross_wrapper/cross_wrapper.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:cross_server/cross_server.dart';

void main() async {
  print('初始化 JSON-RPC 服务器...');
  final server = JsonServer.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
  );
  print('JSON-RPC 服务器初始化完成');

  print('开始创建 WebSocket 服务器...');
  final httpServer = await HttpServer.bind('localhost', 8889);
  print('JSON-RPC Server 已启动并监听: ws://localhost:8889');

  var connectedChannels = httpServer
      .where((request) => request.uri.path == '/ws')
      .transform(WebSocketTransformer())
      .map(IOWebSocketChannel.new);
  connectedChannels.listen((WebSocketChannel socket) {
    final jsonRpcServer = JsonRpcServer(socket.cast<String>());
    server.serveServer(jsonRpcServer);
  });
}
