import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int?> getTrustScore(int signal, String encryption, String band) async {
  final url = Uri.parse("http://10.0.2.2:8000/score"); // Android эмуляторын localhost

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "signal": signal,
      "encryption": encryption,
      "band": band,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["trust_score"];
  } else {
    print("Error: ${response.statusCode}");
    return null;
  }
}
