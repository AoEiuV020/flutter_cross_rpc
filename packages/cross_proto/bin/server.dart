import 'dart:io';
import 'package:cross_proto/cross_proto.dart';

void main() async {
  // 创建TCP服务器
  final server = await ServerSocket.bind('localhost', 8888);
  print('服务器启动在 localhost:8888');

  await for (Socket client in server) {
    print('客户端已连接: ${client.remoteAddress.address}:${client.remotePort}');

    // 处理客户端连接
    handleClient(client);
  }
}

void handleClient(Socket client) {
  client.listen(
    (List<int> data) {
      try {
        // 获取方法名（第一个字节）和消息内容
        final methodName = String.fromCharCode(data[0]);
        final messageBytes = data.sublist(1);

        switch (methodName) {
          case 'Q': // QueryProducts
            final query = ProductQuery.fromBuffer(messageBytes);
            print('收到查询请求: keyword=${query.keyword}');

            // 创建响应
            final products = ProductList(
              items: [
                Product(id: 1, name: 'iPhone', price: 999.99, stock: 100),
                Product(id: 2, name: 'MacBook', price: 1999.99, stock: 50),
              ],
              total: 2,
            );

            // 发送响应
            client.add([methodName.codeUnitAt(0), ...products.writeToBuffer()]);
            break;

          case 'G': // GetProduct
            final request = GetProductRequest.fromBuffer(messageBytes);
            print('收到获取商品请求: id=${request.id}');

            // 创建响应
            final product = Product(
              id: request.id,
              name: 'Product ${request.id}',
              price: 99.99,
              stock: 10,
            );

            // 发送响应
            client.add([methodName.codeUnitAt(0), ...product.writeToBuffer()]);
            break;

          default:
            print('未知的方法: $methodName');
        }
      } catch (e) {
        print('处理请求时出错: $e');
      }
    },
    onError: (error) {
      print('客户端错误: $error');
      client.close();
    },
    onDone: () {
      print('客户端断开连接');
      client.close();
    },
  );
}
