import 'package:client_console/client_console.dart';

void main() async {
  final serviceManager = ServiceManager();

  while (true) {
    ConsoleUI.printMenu();
    final choice = ConsoleUI.readUserInput('请选择操作 (0-4): ', defaultValue: '');

    try {
      switch (choice) {
        case '1':
          serviceManager.addLocalService();
        case '2':
          final server = ConsoleUI.readUserInput(
            '请输入gRPC服务器地址: ',
            defaultValue: ServiceManager.defaultGrpcServer,
          );
          await serviceManager.addGrpcService(server);
        case '3':
          final server = ConsoleUI.readUserInput(
            '请输入WebSocket服务器地址: ',
            defaultValue: ServiceManager.defaultWsServer,
          );
          await serviceManager.addWsService(server);
        case '4':
          serviceManager.printServiceList();
        case '0':
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
        case 'q':
          print('正在清理连接...');
          await serviceManager.cleanup();
          print('退出程序');
          return;
        default:
          print('无效的选择，请重试');
      }
    } catch (e) {
      print('操作失败: $e');
    }
  }
}
