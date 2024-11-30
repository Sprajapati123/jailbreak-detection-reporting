import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com"; // Example API

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse("$baseUrl/posts"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load posts");
    }
  }
}
