class HttException implements Exception {
  final String msg;
  final int statusCode;

  HttException({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    return msg;
  }
}
