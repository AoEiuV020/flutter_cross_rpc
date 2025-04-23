import 'package:cross_json_rpc/cross_json_rpc.dart';
import 'package:cross_proto/cross_proto.dart';
import 'package:stream_channel/stream_channel.dart';

class ProductServiceJsonClient extends ProductServiceClient
    with JsonClientMixin {
  @override
  final JsonRpcService jsonRpcService;

  /// 使用已存在的 JsonRpcService 创建客户端
  ProductServiceJsonClient(this.jsonRpcService)
    : super(JsonClientMixin.channel) {
    jsonRpcService.listen();
  }

  /// 使用 StreamChannel 创建客户端
  ProductServiceJsonClient.create(StreamChannel<String> channel)
    : jsonRpcService = JsonRpcService.fromSingleStream(channel),
      super(JsonClientMixin.channel) {
    jsonRpcService.listen();
  }
}
