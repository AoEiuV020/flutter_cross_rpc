import 'dart:convert';
import 'dart:io';

import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';

void main(List<String> arguments) async {
  var address = 'localhost';
  var port = 8887;

  if (arguments.isNotEmpty) {
    final parts = arguments[0].split(':');
    if (parts.length == 2) {
      address = parts[0];
      port = int.tryParse(parts[1]) ?? 8887;
    }
  }

  print('初始化 JSON-RPC 服务器...');
  final server = JsonServer.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
  );
  print('JSON-RPC 服务器初始化完成');

  print('开始创建 HTTP 服务器...');
  final httpServer = await HttpServer.bind(address, port);
  print('JSON-RPC Server 已启动并监听: http://$address:$port/jsonrpc');

  await for (HttpRequest request in httpServer) {
    if (request.uri.path == '/jsonrpc' && request.method == 'POST') {
      try {
        // 读取请求体并发送到 channel
        final content = await utf8.decodeStream(request);
        final data = await server.singleRequest(content);

        // 设置响应头
        request.response.headers.contentType = ContentType.json;
        request.response.write(data);
        request.response.close();
      } catch (e) {
        print('处理请求时发生错误: $e');
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.close();
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.close();
    }
  }
}
