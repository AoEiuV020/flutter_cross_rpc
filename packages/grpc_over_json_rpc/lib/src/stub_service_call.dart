import 'package:grpc/grpc.dart';

class StubServiceCall implements ServiceCall {
  const StubServiceCall();
  @override
  noSuchMethod(Invocation invocation) {}
}
