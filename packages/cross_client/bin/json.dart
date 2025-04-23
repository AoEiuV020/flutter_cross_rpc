import 'package:cross_proto/cross_proto.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'test.dart';

void main() async {
  print('开始连接 WebSocket 服务器...');
  var socket = WebSocketChannel.connect(Uri.parse('ws://localhost:8889/ws'));
  print('WebSocket 连接成功建立');
  var jsonRpcClient = JsonRpcClient(socket.cast<String>());

  print('创建 ProductService 客户端...');
  final ProductService stub = ProductServiceJsonClient(jsonRpcClient);

  try {
    print('开始执行测试...');
    await test(stub);
    print('测试执行完成');
  } catch (e) {
    print('执行过程中发生错误: $e');
  } finally {
    print('清理资源...');
    await jsonRpcClient.close();
    print('连接已关闭，程序结束');
  }
}
