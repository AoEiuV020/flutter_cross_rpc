import 'dart:async';
import 'dart:io';

import 'package:cross_wrapper/cross_wrapper.dart';
import 'package:stream_channel/stream_channel.dart';

import 'package:cross_client/cross_client.dart';
import 'test.dart';

void main() async {
  print('开始连接 WebSocket 服务器...');
  final socket = await WebSocket.connect('ws://localhost:8889/ws');
  print('WebSocket 连接成功建立');

  print('创建消息控制器...');
  final controller = StreamController<String>();
  controller.stream.listen(
    (data) {
      print('发送消息到服务器: $data');
      socket.add(data);
    },
    onError: (error) {
      print('发送消息时发生错误: $error');
      socket.addError(error);
    },
    onDone: () {
      print('消息控制器完成，准备关闭连接');
      socket.close();
    },
  );

  print('创建 StreamChannel...');
  final channel = StreamChannel<String>(
    socket.map((message) {
      print('收到服务器消息: $message');
      return message as String;
    }),
    controller.sink,
  );

  print('创建 ProductService 客户端存根...');
  final ProductService stub = ProductServiceWrapper(
    ProductServiceJsonClient.create(channel),
  );

  try {
    print('开始执行测试...');
    await test(stub);
    print('测试执行完成');
  } catch (e) {
    print('执行过程中发生错误: $e');
  } finally {
    print('清理资源...');
    await controller.close();
    await socket.close();
    print('连接已关闭，程序结束');
  }
}
