class FBExeption implements Exception {
  final String message;

  FBExeption(this.message);
  @override
  String toString() {
    return message;
  }
}
