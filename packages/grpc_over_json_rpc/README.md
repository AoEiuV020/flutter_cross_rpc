# grpc_over_json_rpc

一个Dart包，允许你通过JSON-RPC协议运行gRPC风格的服务调用。该包提供了一个桥接层，让你能够在任意支持双向数据流的channel上使用JSON-RPC实现类gRPC服务。

## 特性

- 🔄 gRPC风格服务转JSON-RPC调用
- 🌐 支持任意双向数据流channel（如WebSocket、TCP等）
- 🛠 简单的服务器和客户端实现

## 兼容性限制

由于JSON-RPC协议的限制，本包只支持gRPC的部分功能：

- ❌ 不支持流式调用（streaming），因为JSON-RPC不支持流
- ✅ 仅支持一元调用（unary calls）
- ✅ 方法的参数和返回值必须是Protocol Buffer消息（message）
- ✅ 支持标准gRPC错误码

## 快速开始

1. 在你的项目中添加依赖:

```bash
dart pub add grpc_over_json_rpc
```

## 使用方法

### 服务器端实现

使用 `JsonServer` 创建服务器：

```dart
// 创建JSON-RPC服务器
// YourServiceImpl是grpc生成的Base类的实现，
final server = JsonServer.create(services: [YourServiceImpl()]);

// 创建任意支持双向数据流的channel
// 这里以WebSocket为例
WebSocketChannel channel;
server.serve(channel.cast<String>());
```

### 客户端实现

使用 `JsonClientMixin` 创建客户端：

> 继承grpc生成的Client类，并实现 `JsonClientMixin`  
> 注意：如果有多个服务客户端，应该共用同一个 `JsonRpcClient` 实例

```dart
class YourServiceJsonClient extends YourServiceClient with JsonClientMixin {
  @override
  final JsonRpcClient jsonRpcClient;

  YourServiceJsonClient(this.jsonRpcClient)
      : super(JsonClientMixin.channel) {
    jsonRpcClient.listen();
  }
}

// 使用支持双向数据流的channel创建客户端
final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8889/ws'));
final jsonRpcClient = JsonRpcClient(channel.cast<String>());
final client = YourServiceJsonClient(jsonRpcClient);

// 调用方法 (只支持一元调用)
final response = await client.yourMethod(request);
```

## 补充说明

- 支持标准的Protocol Buffers消息序列化
- 支持标准的gRPC错误处理机制
- 可以在任何支持双向数据流的channel上工作

有关更多示例和详细用法，请查看 `/example` 目录。
