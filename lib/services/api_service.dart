import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<http.Response> registerUser({
    required String username,
    required String name,
    required String lastName,
    required String password,
  }) async {
    final url = Uri.parse('http://10.0.2.2:5176/api/UsersApi/register'); // Use 10.0.2.2 for Android Emulator

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json-patch+json',
    };

    final body = jsonEncode({
      "username": username,
      "name": name,
      "lastName": lastName,
      "password": password,
      "role": "string", // Adjust as needed
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user: ${response.statusCode}\n${response.body}');
    }
  }
}
