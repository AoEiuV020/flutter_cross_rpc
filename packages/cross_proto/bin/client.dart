import 'dart:io';
import 'package:cross_proto/cross_proto.dart';

void main() async {
  try {
    final socket = await Socket.connect('localhost', 8888);
    print('已连接到服务器');

    // 处理服务器响应
    socket.listen(
      (List<int> data) {
        final methodName = String.fromCharCode(data[0]);
        final messageBytes = data.sublist(1);

        switch (methodName) {
          case 'Q':
            final products = ProductList.fromBuffer(messageBytes);
            print('\n查询结果:');
            for (var product in products.items) {
              print('- ${product.name}: ￥${product.price}');
            }
            break;

          case 'G':
            final product = Product.fromBuffer(messageBytes);
            print('\n获取到商品:');
            print('- ID: ${product.id}');
            print('- 名称: ${product.name}');
            print('- 价格: ￥${product.price}');
            print('- 库存: ${product.stock}');
            break;
        }
      },
      onError: (error) {
        print('发生错误: $error');
        socket.close();
      },
      onDone: () {
        print('连接已关闭');
        socket.close();
      },
    );

    // 测试用例1：查询商品
    print('\n发送查询请求...');
    final query = ProductQuery(keyword: 'phone');
    socket.add(['Q'.codeUnitAt(0), ...query.writeToBuffer()]);

    // 等待一下，确保第一个响应已经处理
    await Future.delayed(Duration(seconds: 1));

    // 测试用例2：获取商品
    print('\n发送获取商品请求...');
    final request = GetProductRequest(id: 1);
    socket.add(['G'.codeUnitAt(0), ...request.writeToBuffer()]);

    // 等待响应处理完成后关闭
    await Future.delayed(Duration(seconds: 1));
    await socket.close();
  } catch (e) {
    print('发生错误: $e');
  }
}
