import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc/grpc.dart';

import 'package:server_grpc/server_grpc.dart';

void main(List<String> args) async {
  var address = 'localhost';
  var port = 8888;

  if (args.isNotEmpty) {
    final parts = args[0].split(':');
    if (parts.length == 2) {
      address = parts[0];
      port = int.tryParse(parts[1]) ?? 8888;
    }
  }

  final server = Server.create(
    services: [ProductServiceAdapter(ProductServiceImpl())],
    interceptors: [loggingInterceptor],
  );

  await server.serve(address: address, port: port);

  print('gRPC 服务器启动成功: $address:$port');
}
