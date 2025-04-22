import 'package:grpc/grpc.dart';

ClientChannel createChannel() {
  final channel = ClientChannel(
    'localhost',
    port: 8888,
    options: ChannelOptions(
      credentials: const ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(
        codecs: const [GzipCodec(), IdentityCodec()],
      ),
      idleTimeout: Duration(minutes: 1),
    ),
  );
  return channel;
}
