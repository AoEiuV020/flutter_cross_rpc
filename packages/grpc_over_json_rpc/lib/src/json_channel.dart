import 'dart:async';

import 'package:stream_channel/stream_channel.dart';

typedef MessageHandler = Future<String> Function(String message);

class JsonRpcStreamChannel extends StreamChannelMixin<String> {
  final MessageHandler onMessage;
  final _incomingController = StreamController<String>();
  final _outgoingController = StreamController<String>();

  JsonRpcStreamChannel(this.onMessage) {
    _outgoingController.stream.listen(
      _handleOutgoing,
      onDone: () {
        _incomingController.close();
      },
    );
  }

  @override
  Stream<String> get stream => _incomingController.stream;

  @override
  StreamSink<String> get sink => _outgoingController.sink;

  Future<void> _handleOutgoing(String message) async {
    try {
      final response = await onMessage(message);
      _incomingController.add(response);
    } catch (e) {
      _incomingController.addError(e);
    }
  }

  Future<void> close() async {
    await _outgoingController.close();
    await _incomingController.close();
  }
}
