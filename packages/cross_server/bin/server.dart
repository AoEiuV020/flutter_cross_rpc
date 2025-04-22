import 'dart:async';

import 'package:grpc/grpc.dart';

import 'package:cross_server/cross_server.dart';

/// 日志拦截器
FutureOr<GrpcError?> loggingInterceptor(
  ServiceCall call,
  ServiceMethod<dynamic, dynamic> method,
) async {
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
    services: [ProductServiceAdapter()],
    interceptors: [loggingInterceptor],
  );

  await server.serve(address: 'localhost', port: 8888);

  print('gRPC 服务器启动成功: localhost:8888');
}
