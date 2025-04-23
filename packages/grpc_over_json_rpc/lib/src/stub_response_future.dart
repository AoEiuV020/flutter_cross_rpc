import 'package:async/async.dart';
import 'package:grpc/grpc.dart';

class StubResponseFuture<R> extends DelegatingFuture<R>
    implements ResponseFuture<R> {
  StubResponseFuture(super.future);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
