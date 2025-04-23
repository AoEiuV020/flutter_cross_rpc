import 'package:cross_wrapper/cross_wrapper.dart';

import 'grpc.dart';
import 'test.dart';

void main() async {
  final channel = createChannel();
  // 创建 stub
  final ProductService stub = ProductServiceGrpcClient(channel);

  try {
    await test(stub);
  } catch (e) {
    print('发生错误: $e');
  } finally {
    // 关闭 channel
    await channel.shutdown();
  }
}
