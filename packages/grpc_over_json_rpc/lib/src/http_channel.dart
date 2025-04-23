import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:stream_channel/stream_channel.dart';

class HttpJsonRpcStreamChannel extends StreamChannelMixin<String> {
  final Uri uri;
  final _incomingController = StreamController<String>();
  final _outgoingController = StreamController<String>();
  final http.Client _client;

  HttpJsonRpcStreamChannel(this.uri) : _client = http.Client() {
    _outgoingController.stream.listen(_handleOutgoing);
  }

  @override
  Stream<String> get stream => _incomingController.stream;

  @override
  StreamSink<String> get sink => _outgoingController.sink;

  Future<void> _handleOutgoing(String message) async {
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: message,
      );

      if (response.statusCode == 200) {
        _incomingController.add(response.body);
      } else {
        _incomingController.addError(
          Exception('HTTP error ${response.statusCode}: ${response.body}'),
        );
      }
    } catch (e) {
      _incomingController.addError(e);
    }
  }

  Future<void> close() async {
    await _outgoingController.close();
    await _incomingController.close();
    _client.close();
  }
}
