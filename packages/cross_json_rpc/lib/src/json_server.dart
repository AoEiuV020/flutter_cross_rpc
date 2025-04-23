import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:json_rpc_2/error_code.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:stream_channel/stream_channel.dart';

import 'error.dart';
import 'json_rpc_service.dart';
import 'stub_service_call.dart';

class JsonServer {
  static const serviceCall = StubServiceCall();
  final Map<String, Service> _services = {};

  JsonServer.create({required List<Service> services}) {
    for (final service in services) {
      _services[service.$name] = service;
    }
  }

  Future<List<String>> _handleRpcRequest(Parameters parameters) async {
    final methodParts = parameters.method.split('/');
    if (methodParts.length != 3 || methodParts[0].isNotEmpty) {
      throw GrpcError.invalidArgument(
        'Invalid method format. Expected: /service/method',
      );
    }
    final name = methodParts[1];
    final method = methodParts[2];
    final service = _services[name];

    if (service == null) {
      throw GrpcError.unimplemented('Service not found: $name');
    }
    final serviceMethod = service.$lookupMethod(method);
    if (serviceMethod == null) {
      throw GrpcError.unimplemented('Method not found: $method');
    }
    final requestBase64 = (parameters.value as List)[0] as String;
    final requestBytes = base64Decode(requestBase64);
    final request = serviceMethod.deserialize(requestBytes);
    // 必须靠createRequestStream把泛型带出来才能执行handler,否则参数Future类型无法正确，
    final requests = serviceMethod.createRequestStream(
      Stream.empty().listen((data) {}),
    );
    requests.add(request);
    requests.close();
    final responses = serviceMethod.handle(serviceCall, requests.stream);
    final response = await responses.single;
    final responseBytes = serviceMethod.serialize(response);
    final responseBase64 = base64Encode(responseBytes);
    return [responseBase64];
  }

  Future<void> serve(StreamChannel<String> channel) {
    return serveServer(JsonRpcServer(channel));
  }

  Future<void> serveServer(JsonRpcServer server) async {
    server.registerFallback(
      (Parameters parameters) async {
            try {
              return await _handleRpcRequest(parameters);
            } on GrpcError catch (e) {
              throw RpcException(
                SERVER_ERROR,
                e.message ?? 'Unknown gRPC error',
                data: {
                  GrpcErrorUtils.grpcErrorKey: GrpcErrorUtils.serialize(e),
                },
              );
            }
          }
          as dynamic, // 这里返回值要求是void不对，可以有返回值的，
    );
    // 这里不await，因为serve参考grpc是成功启动就返回，而jsonRpc里的listen是关闭后才返回，
    server.listen();
  }
}
