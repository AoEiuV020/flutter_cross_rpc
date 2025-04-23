import 'package:grpc/grpc.dart';

class GrpcErrorUtils {
  static Map<String, dynamic> serialize(GrpcError error) {
    return {
      'code': error.code.toString(),
      'message': error.message,
      'codeName': error.codeName,
    };
  }

  static GrpcError deserialize(Map<String, dynamic> data) {
    return GrpcError.custom(
      int.tryParse(data['code'] ?? '') ?? 0,
      data['message'],
    );
  }
}
