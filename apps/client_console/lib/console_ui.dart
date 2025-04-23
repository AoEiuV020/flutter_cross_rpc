import 'dart:io';

class ConsoleUI {
  static void printMenu() {
    print('\n=== 商品服务测试客户端 ===');
    print('1. 添加本地服务实现');
    print('2. 添加gRPC服务');
    print('3. 添加WebSocket服务');
    print('4. 添加http服务');
    print('9. 查看已添加的服务');
    print('0. 开始测试');
    print('c. 断开服务');
    print('q. 退出程序');
  }

  static String readUserInput(String prompt, {String defaultValue = ''}) {
    stdout.write(prompt);
    if (defaultValue.isNotEmpty) {
      stdout.write('[$defaultValue] ');
    }
    final input = stdin.readLineSync()?.trim() ?? '';
    return input.isEmpty ? defaultValue : input;
  }
}
