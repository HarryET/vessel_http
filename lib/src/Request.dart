part of vessel_http;

class Request {

  late final HttpRequest _internalRequest;

  late final Map<String, dynamic> json;
  late final String body;

  late final Map<String, String> headers;

  Request(this._internalRequest, VesselHttp server) {
    this.headers = {};
    this._internalRequest.headers.forEach((name, values) {
      this.headers[name] = values.first;
    });
  }

  Future<void> finalise({bool shouldDecodeJson = true}) async {
    this.body = await utf8.decodeStream(this._internalRequest);
    if(shouldDecodeJson) {
      this.json = jsonDecode(this.body) as Map<String, dynamic>;
    }
  }

}

class WebsocketRequest {

  late final WebSocket _internalSocket;
  late final Stream<WebsocketMessage<String>> onMessage;
  late final StreamController<WebsocketMessage<String>> _onMessageController;

  WebsocketRequest(this._internalSocket, VesselHttp server) {
    this._onMessageController = StreamController.broadcast();
    this.onMessage = this._onMessageController.stream;

    this._internalSocket.listen((e) {
      if(e is String) {
        this._onMessageController.add(WebsocketMessage<String>(e));
      } else {
        this.sendJson({
          "message": "Invalid message data, must be sent as a `String`"
        });
      }
    });
  }

  void sendJson(Map<String, dynamic> data) async => this._internalSocket.add(jsonEncode(data));

  void sendString(String data) async => this._internalSocket.add(data);

  Future<void> close({int? code}) async => this._internalSocket.close(code);

}

class WebsocketMessage<T> {

  late final T rawData;

  WebsocketMessage(this.rawData);

  Map<String, dynamic> toJson() => jsonDecode(this.rawData.toString()) as Map<String, dynamic>;

}