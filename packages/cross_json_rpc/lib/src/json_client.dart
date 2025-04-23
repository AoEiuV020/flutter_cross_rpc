import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:json_rpc_2/json_rpc_2.dart' show RpcException;

import 'error.dart';
import 'json_rpc_service.dart';
import 'stub_client_channel.dart';
import 'stub_response_future.dart';

mixin JsonClientMixin on Client {
  JsonRpcService get jsonRpcService;
  static const StubClientChannel channel = StubClientChannel();
  @override
  ResponseFuture<R> $createUnaryCall<Q, R>(
    ClientMethod<Q, R> method,
    Q request, {
    CallOptions? options,
  }) {
    return StubResponseFuture(call(method, request));
  }

  Future<R> call<Q, R>(ClientMethod<Q, R> method, Q request) async {
    final requestBytes = method.requestSerializer(request);
    final requestBase64 = base64Encode(requestBytes);
    final dynamic responseBase64List;
    try {
      responseBase64List = await jsonRpcService.sendRequest(method.path, [
        requestBase64,
      ]);
    } on RpcException catch (e) {
      final data = e.data;
      if (data is Map) {
        if (data.containsKey(GrpcErrorUtils.grpcErrorKey)) {
          throw GrpcErrorUtils.deserialize(data[GrpcErrorUtils.grpcErrorKey]);
        }
      }
      rethrow;
    }
    final responseBase64 = (responseBase64List as List)[0] as String;
    final responseBytes = base64Decode(responseBase64);
    return method.responseDeserializer(responseBytes);
  }
}
