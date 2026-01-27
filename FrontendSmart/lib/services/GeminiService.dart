import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  Future<String> generarReceta(String ingredientes) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-03-25:generateContent?key=$_apiKey',
    );

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Genera una receta saludable con estos ingredientes: $ingredientes",
            },
          ],
        },
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    print("Código de respuesta: ${response.statusCode}");
    print("Respuesta: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  }
}
