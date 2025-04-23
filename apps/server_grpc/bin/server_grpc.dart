import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc/grpc.dart';

import 'package:server_grpc/server_grpc.dart';

void main() async {
  final server = Server.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
    interceptors: [loggingInterceptor],
  );

  await server.serve(address: 'localhost', port: 8888);

  print('gRPC 服务器启动成功: localhost:8888');
}
