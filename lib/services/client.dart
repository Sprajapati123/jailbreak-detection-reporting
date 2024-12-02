import 'dart:io';

HttpClient createInsecureHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    return true; // Disable SSL validation
  };
  return client;
}
