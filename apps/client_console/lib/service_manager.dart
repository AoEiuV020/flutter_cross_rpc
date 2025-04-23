import 'package:cross_proto/cross_proto.dart';
import 'package:cross_server/cross_server.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_over_json_rpc/grpc_over_json_rpc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServiceManager {
  final Map<String, ProductService> services = {};
  final Map<String, Future Function()> _cleanupCallbacks = {};

  // 默认服务器地址
  static const defaultGrpcServer = 'localhost:8888';
  static const defaultWsServer = 'ws://localhost:8889/ws';
  static const defaultHttpServer = 'http://localhost:8887/jsonrpc';

  void addLocalService() {
    final name = 'local-${services.length + 1}';
    services[name] = ProductServiceImpl();
    print('已添加本地服务: $name');
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
    print('已添加gRPC服务: $name ($server)');
  }

  Future<void> addWsService(String server) async {
    final channel = WebSocketChannel.connect(Uri.parse(server));
    final jsonRpcClient = JsonRpcClient(channel.cast<String>());

    final name = 'ws-${services.length + 1}';
    final client = ProductServiceJsonClient(jsonRpcClient);
    services[name] = client;
    _cleanupCallbacks[name] = jsonRpcClient.close;
    print('已添加WebSocket服务: $name ($server)');
  }

  Future<void> addHttpService(String server) async {
    final uri = Uri.parse(server);
    final jsonRpcClient = JsonRpcClient(HttpJsonRpcStreamChannel(uri));

    final name = 'http-${services.length + 1}';
    final client = ProductServiceJsonClient(jsonRpcClient);
    services[name] = client;
    _cleanupCallbacks[name] = jsonRpcClient.close;
    print('已添加HTTP服务: $name ($server)');
  }

  void printServiceList() {
    if (services.isEmpty) {
      print('还未添加任何服务');
      return;
    }
    print('\n当前已添加的服务:');
    for (var entry in services.entries) {
      print('- ${entry.key}: ${entry.value.runtimeType}');
    }
  }

  Future<void> cleanup() async {
    for (var entry in _cleanupCallbacks.entries) {
      try {
        await entry.value();
        print('已断开服务连接: ${entry.key}');
      } catch (e) {
        print('断开服务连接失败 ${entry.key}: $e');
      }
    }
    services.clear();
    _cleanupCallbacks.clear();
  }

  Map<String, ProductService> get allServices => services;
}
