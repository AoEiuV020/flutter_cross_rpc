import 'package:cross_server/cross_server.dart';
import 'package:cross_wrapper/cross_wrapper.dart';

import 'test.dart';

void main() async {
  // 创建 stub
  final ProductService stub = ProductServiceWrapper(ProductServiceImpl());

  try {
    await test(stub);
  } catch (e) {
    print('发生错误: $e');
  }
}
