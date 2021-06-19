part of vessel_http;

class VesselHttps extends VesselHttp {

  final SecurityContext ssl;
  late final HttpServer _internalHttpsServer;
  final int httpsPort;

  late final Stream<HttpRequest> _requests;
  late final StreamController<HttpRequest> _requestController;

  VesselHttps(this.ssl, {String name = "Vessel HTTPS", this.httpsPort = 8081, int httpPort = 8080}) : super(name: name, port: httpPort) {
    this._requestController = StreamController.broadcast();
    this._requests = this._requestController.stream;
  }

  @override
  void listen() async {
    this._internalHttpsServer = await HttpServer.bindSecure(this.listenAddress, this.httpsPort, this.ssl, backlog: this.backlog);
    this._internalServer = await HttpServer.bind(this.listenAddress, this.port, backlog: this.backlog);

    this._logger.info("Server online and listening @ https://${_prod ? "0.0.0.0" : "127.0.0.1"}:${this.port}");

    this._internalHttpsServer.listen((req) => this._requestController.add(req));
    this._internalServer.listen((req) => this._requestController.add(req));

    await for (final request in this._requests) {
      this._logger.info("[${request.method.toUpperCase()}] ${request.requestedUri.toString()}");

      final response = await this._handleRequest(request);
      if(response != null) {
        response.execute(request);
      }

      await request.response.close();
    }
  }

  static SecurityContext generateSecurityContext(String chainPath, String privateKeyPath, String privateKeyPassword) {
    return SecurityContext()
      ..useCertificateChain(chainPath)
      ..usePrivateKey(privateKeyPath, password: privateKeyPassword);
  }

}