import 'package:flutter/material.dart';

import '../service_manager.dart';
import '../service_test.dart';
import '../widgets/service_list.dart';

class ServiceTestPage extends StatefulWidget {
  const ServiceTestPage({super.key});

  @override
  State<ServiceTestPage> createState() => _ServiceTestPageState();
}

class _ServiceTestPageState extends State<ServiceTestPage> {
  final _serviceManager = ServiceManager();

  void _addLocalService() {
    _serviceManager.addLocalService();
    _showSnackBar('已添加本地服务');
  }

  Future<void> _addGrpcService() async {
    final server = await _showInputDialog(
      '添加gRPC服务',
      '请输入gRPC服务器地址:',
      ServiceManager.defaultGrpcServer,
    );
    if (server == null) return;

    try {
      await _serviceManager.addGrpcService(server);
      _showSnackBar('已添加gRPC服务');
    } catch (e) {
      _showSnackBar('添加服务失败: $e');
    }
  }

  Future<void> _addWsService() async {
    final server = await _showInputDialog(
      '添加WebSocket服务',
      '请输入WebSocket服务器地址:',
      ServiceManager.defaultWsServer,
    );
    if (server == null) return;

    try {
      await _serviceManager.addWsService(server);
      _showSnackBar('已添加WebSocket服务');
    } catch (e) {
      _showSnackBar('添加服务失败: $e');
    }
  }

  Future<void> _cleanup() async {
    await _serviceManager.cleanup();
    _showSnackBar('已清理所有服务连接');
  }

  Future<void> _testAllServices() async {
    if (!_serviceManager.hasServices) {
      _showSnackBar('请先添加至少一个服务！');
      return;
    }

    final results = <String>[];
    for (var entry in _serviceManager.allServices.entries) {
      results.add('\n测试服务: ${entry.key}');
      try {
        final serviceResults = await ServiceTest.testService(entry.value);
        results.addAll(serviceResults);
      } catch (e) {
        results.add('测试失败: $e');
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('测试结果'),
            content: SingleChildScrollView(child: Text(results.join('\n'))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  Future<String?> _showInputDialog(
    String title,
    String message,
    String defaultValue,
  ) async {
    final controller = TextEditingController(text: defaultValue);
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: message),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('商品服务测试客户端'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListenableBuilder(
                listenable: _serviceManager,
                builder:
                    (context, _) => Text(
                      '已添加的服务 (${_serviceManager.allServices.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(child: ServiceList(serviceManager: _serviceManager)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addLocalService,
                    icon: const Icon(Icons.computer),
                    label: const Text('本地服务'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addGrpcService,
                    icon: const Icon(Icons.cloud),
                    label: const Text('gRPC服务'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addWsService,
                    icon: const Icon(Icons.wifi),
                    label: const Text('WS服务'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _testAllServices,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('测试所有服务'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _cleanup,
                    icon: const Icon(Icons.delete),
                    label: const Text('清理所有服务'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
