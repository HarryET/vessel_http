part of vessel_http;

class VesselHttp {
  late final HttpServer _internalServer;
  late final List<HandlerMetadata> _handlers;
  late final Logger _logger;
  late final DateTime _started;

  final bool _prod = const bool.fromEnvironment("dart.vm.product");

  late final int port;
  late final String listenAddress;
  late final int backlog;

  /// Create a new instance of the server
  VesselHttp({String name = "Vessel HTTP", this.port = 8080, this.listenAddress = "0.0.0.0", this.backlog = 10}) {
    this._handlers = [];
    this._started = DateTime.now();
    this._logger = Logger(name);

    Logger.root.onRecord.listen((record) {
      print("[${record.time}] [${record.level.name}] [${record.loggerName}] ${record.message}");
    });
  }

  void registerHandler<T extends RequestHandler>(String route, T handler) {
    this._handlers.add(HandlerMetadata(handler, route));
    this._logger.info("Handler registered for $route");
  }

  HandlerMetadata? _selectHandler(HttpRequest request) {
    try {
      return this._handlers.firstWhere((handler) {
        final pathString = request.requestedUri.path;
        final match = handler.routeRegex.stringMatch(pathString);
        return match != null && match.length == pathString.length;
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  Future<ResponseBuilder?> _handleRequest(HttpRequest request) async {
    try {
      final meta = this._selectHandler(request);

      if(meta == null) {
        throw NotFoundError();
      }

      ResponseBuilder? res;

      final requestData = Request(request, meta, this);
      final shouldDecodeJson = request.headers["content-type"]?.first == "application/json";
      await requestData.finalise(shouldDecodeJson: shouldDecodeJson);

      switch (request.method.toLowerCase()) {
        case "get": {
          if(WebSocketTransformer.isUpgradeRequest(request)) {
            final socket = await WebSocketTransformer.upgrade(request);
            await meta.handler.websocket(WebsocketRequest(socket, this));
            break;
          }

          res = await meta.handler.get(requestData);
          break;
        }
        case "post": return await meta.handler.post(requestData);
        case "put": return await meta.handler.put(requestData);
        case "patch": return await meta.handler.put(requestData);
        case "delete": return await meta.handler.put(requestData);
        case "options": return await meta.handler.patch(requestData);
        case "head": return await meta.handler.put(requestData);
        default: return await meta.handler.custom(requestData);
      }

      return res;
    } on NotFoundError {
      this._logger.warning("Not Found: [${request.method.toUpperCase()}] ${request.requestedUri.toString()}");
      return ResponseBuilder()
        ..statusCode(HttpStatus.notFound)
        ..json({
          "status": HttpStatus.notFound,
          "message": "Not Found: ${request.method.toLowerCase()} ${request.requestedUri.toString()}"
        });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      final res = ResponseBuilder()
        ..statusCode(HttpStatus.internalServerError);

      if(_prod) {
        res
          ..json({
            "status": HttpStatus.internalServerError,
            "message": "Unknown internal server exception"
          });
      } else {
        res
          ..json({
            "status": HttpStatus.internalServerError,
            "message": "Unknown internal server exception",
            "exception": e.toString()
          });
      }

      this._logger.severe("Internal Server Exception: ${e.toString()}");
      return res;
    }
  }

  /// Listen for requests
  void listen() async {
    this._internalServer = await HttpServer.bind(this.listenAddress, this.port, backlog: this.backlog);

    this._logger.info("Server online and listening @ http://${_prod ? "0.0.0.0" : "127.0.0.1"}:${this.port}");

    await for (final request in this._internalServer) {
      this._logger.info("[${request.method.toUpperCase()}] ${request.requestedUri.toString()}");
      final response = await this._handleRequest(request);
      if(response != null) {
        response.execute(request);
      }

      await request.response.close();
    }
  }
}
