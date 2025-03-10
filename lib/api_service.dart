import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static http.Client _httpClient = http.Client();

  static void setHttpClient(http.Client client) {
    _httpClient = client;
  }

  static http.Client get httpClient => _httpClient;
}
