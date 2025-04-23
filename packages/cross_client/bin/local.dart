import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';

import 'test.dart';

void main() async {
  // 创建 stub
  final ProductService stub = ProductServiceImpl();

  try {
    await test(stub);
  } catch (e) {
    print('发生错误: $e');
  }
}
