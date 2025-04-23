import 'dart:async';

import 'package:grpc/grpc.dart';


/// 日志拦截器
FutureOr<GrpcError?> loggingInterceptor(
  ServiceCall call,
  ServiceMethod<dynamic, dynamic> method,
) async {
  try {
    print('开始处理请求:');
    print('- 名称: ${method.name}');

    // 继续处理请求
    return null;
  } catch (error) {
    if (error is GrpcError) rethrow;
    print('发生错误: $error');
    return GrpcError.internal(error.toString());
  }
}
