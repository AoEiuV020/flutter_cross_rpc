// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:stream_channel/stream_channel.dart';

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

  Future<void> serve(StreamChannel<String> channel) {
    return serveJsonRpcService(JsonRpcService.fromSingleStream(channel));
  }

  Future<void> serveJsonRpcService(JsonRpcService jsonRpcService) async {
    jsonRpcService.registerFallback((Parameters parameters) async {
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
    });
    jsonRpcService.listen();
  }
}
