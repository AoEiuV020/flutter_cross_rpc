import 'dart:io';

import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> args) async {
  var address = 'localhost';
  var port = 8889;

  if (args.isNotEmpty) {
    final parts = args[0].split(':');
    if (parts.length == 2) {
      address = parts[0];
      port = int.tryParse(parts[1]) ?? 8889;
    }
  }

  print('初始化 JSON-RPC 服务器...');
  final server = JsonServer.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
  );
  print('JSON-RPC 服务器初始化完成');

  print('开始创建 WebSocket 服务器...');
  final httpServer = await HttpServer.bind(address, port);
  print('JSON-RPC Server 已启动并监听: ws://$address:$port');

  var connectedChannels = httpServer
      .where((request) => request.uri.path == '/ws')
      .transform(WebSocketTransformer())
      .map(IOWebSocketChannel.new);
  connectedChannels.listen((WebSocketChannel socket) {
    server.serve(socket.cast<String>());
  });
}
