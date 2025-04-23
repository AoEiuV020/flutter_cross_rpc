// ignore_for_file: implementation_imports

import 'package:grpc/src/client/channel.dart';

class StubClientChannel implements ClientChannel {
  const StubClientChannel();
  @override
  noSuchMethod(Invocation invocation) {}
}
