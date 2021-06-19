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
  final server = VesselHttp(port: 80);

  server.registerHandler("/hello/:name", DemoHandler());

  server.listen();
}
