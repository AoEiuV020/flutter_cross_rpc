import 'package:client_console/client_console.dart';

void main() async {
  final serviceManager = ServiceManager();

  while (true) {
    ConsoleUI.printMenu();

    try {
      final server = ServiceManager.defaultHttpServer;
      await serviceManager.addHttpService(server);
      if (serviceManager.allServices.isEmpty) {
        print('请先添加至少一个服务！');
        continue;
      }
      for (var entry in serviceManager.allServices.entries) {
        print('\n测试服务: ${entry.key}');
        try {
          await test(entry.value);
        } catch (e) {
          print('测试失败: $e');
        }
      }
      print('正在清理连接...');
      await serviceManager.cleanup();
      print('退出程序');
      return;
    } catch (e) {
      print('操作失败: $e');
    }
  }
}
