part of vessel_http;

class ResponseBuilder {

  late int _statusCode;
  late String? _body;
  late Map<String, String> _headers;

  late bool _json;
  late bool _text;

  ///
  ResponseBuilder() {
    this._statusCode = 200;
    this._body = null;
    this._headers = {};

    this._json = false;
    this._text = false;
  }

  void statusCode(int status) => this._statusCode = status;

  void text(String body) {
    this._body = body;
    this._text = true;
  }

  void json(Map<String, dynamic> body) {
    this._body = jsonEncode(body);
    this._json = true;
  }

  void execute(HttpRequest request) {
    request.response.statusCode = this._statusCode;

    this._headers.forEach((key, value) {
      request.response.headers.add(key, value);
    });

    if(this._headers["Content-Type"] == null) {
      if(_json) {
        request.response.headers.add("Content-Type", "application/json");
      } else if (_text) {
        request.response.headers.add("Content-Type", "text/plain");
      } else {
        request.response.headers.add("Content-Type", "*/*");
      }
    }

    request.response.write(this._body);
  }

}