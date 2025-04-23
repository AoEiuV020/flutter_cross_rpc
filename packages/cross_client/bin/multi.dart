import 'package:cross_server/cross_server.dart';
import 'package:cross_wrapper/cross_wrapper.dart';

import 'grpc.dart';
import 'test.dart';

void main() async {
  // 创建 gRPC channel
  final channel = createChannel();
  final List<ProductService> list =
      [ProductServiceImpl(), ProductServiceGrpcClient(channel)].toList();

  try {
    for (var stub in list) {
      await test(stub);
    }
  } catch (e) {
    print('发生错误: $e');
  } finally {
    // 关闭 channel
    await channel.shutdown();
  }
}
