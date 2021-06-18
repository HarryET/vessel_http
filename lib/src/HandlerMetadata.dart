part of vessel_http;

class HandlerMetadata {

  final RequestHandler handler;
  late final String _rawRoute;
  late final RegExp routeRegex;

  /// int is the segment id, string is the name.
  late final List<String?> paramMap;

  HandlerMetadata(this.handler, String route) {
    this._rawRoute = route;
    final routeUri = Uri.parse(route);
    var regexRaw = r"";

    this.paramMap = List.filled(routeUri.pathSegments.length, null);

    for(var i = 0; i < routeUri.pathSegments.length; i++) {
      final segment = routeUri.pathSegments[i];
      regexRaw += r"\/";
      if(segment.startsWith(":")) {
        this.paramMap[i] = segment.substring(1, segment.length);
        regexRaw += r"[a-zA-Z0-9%_-]+";
      } else {
        regexRaw += segment;
      }
    }

    this.routeRegex = RegExp(regexRaw);
  }

}