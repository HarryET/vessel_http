part of vessel_http;

class RequestHandler {
  final ResponseBuilder _defaultResponse = ResponseBuilder()
    ..statusCode(HttpStatus.notFound)
    ..json({
      "status": HttpStatus.notFound,
      "message": "Method Not Accepted"
    });

  Future<ResponseBuilder> get(Request request) async => _defaultResponse;
  Future<ResponseBuilder> post(Request request) async => _defaultResponse;
  Future<ResponseBuilder> put(Request request) async => _defaultResponse;
  Future<ResponseBuilder> patch(Request request) async => _defaultResponse;
  Future<ResponseBuilder> delete(Request request) async => _defaultResponse;
  Future<ResponseBuilder> options(Request request) async => _defaultResponse;
  Future<ResponseBuilder> head(Request request) async => _defaultResponse;
  Future<ResponseBuilder> custom(Request request) async => _defaultResponse;

  Future<void> websocket(WebsocketRequest ws) async {
  }

}