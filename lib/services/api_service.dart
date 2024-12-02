import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jailbreak_detection/services/client.dart';
import 'package:path_provider/path_provider.dart';

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


  Future<void> storeInsecureData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/insecure_data.txt');
    await file.writeAsString('Sensitive Information: Exposed!');
    print('Insecure data written to: ${file.path}');
  }

  Future<void> fetchInsecureData() async {
    final client = createInsecureHttpClient();
    final request = await client.getUrl(Uri.parse('https://example.com/data'));
    final response = await request.close();
    response.transform(const SystemEncoding().decoder).listen((data) {
      print('Received data: $data');
    });
  }


}
