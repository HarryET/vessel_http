part of vessel_http;

class NotFoundError extends Error {
  @override
  StackTrace? get stackTrace => StackTrace.empty;
}