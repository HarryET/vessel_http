part of vessel_http;

class HandlerMetadata {

  final RequestHandler handler;
  late final String _rawRoute;
  late final RegExp routeRegex;

  HandlerMetadata(this.handler, String route) {
    this._rawRoute = route;

    final routeUri = Uri.parse(route);
    var regexRaw = r"";

    routeUri.pathSegments.forEach((segment) {
      regexRaw += r"\/";
      if(segment.startsWith(":")) {
        regexRaw += r"[a-zA-Z0-9%_-]+";
      } else {
        regexRaw += segment;
      }
    });

    this.routeRegex = RegExp(regexRaw);
  }

}