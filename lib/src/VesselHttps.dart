part of vessel_http;

class VesselHttps extends VesselHttp {

  final SecurityContext ssl;
  final int httpsPort;

  late final Stream<HttpRequest> _requests;
  late final StreamController<HttpRequest> _requestController;

  VesselHttps(this.ssl, {String name = "Vessel HTTPS", this.httpsPort = 8081, int httpPort = 8080}) : super(name: name, port: httpPort) {
    this._requestController = StreamController.broadcast();
    this._requests = this._requestController.stream;
  }

  @override
  void listen() async {
    this._internalServer = await HttpServer.bindSecure(this.listenAddress, 80, this.ssl, backlog: this.backlog);

    this._logger.info("Server online and listening @ https://${_prod ? "0.0.0.0" : "127.0.0.1"}:${this.httpsPort}");

    await for (final req in this._internalServer) {
      print(req.requestedUri);
      if(req.requestedUri.hasPort) {
        if([this.httpsPort, this.port].contains(req.requestedUri.port)) {
          this._requestController.add(req);
        }
      } else {
        if([this.httpsPort, this.port].contains(80)) {
          this._requestController.add(req);
        }
      }

      this._logger.info("[${req.method.toUpperCase()}] ${req.requestedUri.toString()}");

      final response = await this._handleRequest(req);
      if(response != null) {
        response.execute(req);
      }

      await req.response.close();
    }
  }

  static SecurityContext generateSecurityContext(String chainPath, String privateKeyPath, String privateKeyPassword) {
    return SecurityContext()
      ..useCertificateChain(chainPath)
      ..usePrivateKey(privateKeyPath, password: privateKeyPassword);
  }

}