import 'dart:io';

import 'package:vessel_http/vessel_http.dart';

class DemoHandler extends RequestHandler {

  @override
  Future<ResponseBuilder> get(Request request) async {
    return ResponseBuilder()
      ..statusCode(200)
      ..json({
        "name": request.params.getValue("name")
      });
  }

}

void main() {
  final server = VesselHttps(VesselHttps.generateSecurityContext(Directory.current.path + "\\example\\certs\\cert.pem", Directory.current.path + "\\example\\certs\\key.pem", "dartdart"));

  server.registerHandler("/hello/:name", DemoHandler());

  server.listen();
}
