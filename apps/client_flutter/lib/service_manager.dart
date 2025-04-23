import 'package:flutter/material.dart';

import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServiceManager extends ChangeNotifier {
  final Map<String, ProductService> services = {};
  final Map<String, Future Function()> _cleanupCallbacks = {};

  static const String defaultGrpcServer = 'localhost:8888';
  static const String defaultWsServer = 'ws://localhost:8889/ws';

  void addLocalService() {
    final name = 'local-${services.length + 1}';
    services[name] = ProductServiceImpl();
    notifyListeners();
  }

  Future<void> addGrpcService(String server) async {
    final parts = server.split(':');
    if (parts.length != 2) {
      throw FormatException('无效的服务器地址格式，应为 host:port');
    }

    final channel = ClientChannel(
      parts[0],
      port: int.parse(parts[1]),
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    final name = 'grpc-${services.length + 1}';
    services[name] = ProductServiceGrpcClient(channel);
    _cleanupCallbacks[name] = channel.shutdown;
    notifyListeners();
  }

  Future<void> addWsService(String server) async {
    final channel = WebSocketChannel.connect(Uri.parse(server));
    final jsonRpcClient = JsonRpcClient(channel.cast<String>());

    final name = 'ws-${services.length + 1}';
    final client = ProductServiceJsonClient(jsonRpcClient);
    services[name] = client;
    _cleanupCallbacks[name] = jsonRpcClient.close;
    notifyListeners();
  }

  Future<void> cleanup() async {
    for (var entry in _cleanupCallbacks.entries) {
      try {
        await entry.value();
        debugPrint('已断开服务连接: ${entry.key}');
      } catch (e) {
        debugPrint('断开服务连接失败 ${entry.key}: $e');
      }
    }
    services.clear();
    _cleanupCallbacks.clear();
    notifyListeners();
  }

  Map<String, ProductService> get allServices => services;
  bool get hasServices => services.isNotEmpty;
}
