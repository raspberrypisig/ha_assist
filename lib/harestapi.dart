import 'dart:convert';

import 'package:http/http.dart' as http;

class HARestAPI {
  Future<bool> ping(String haUrl, String token) async {
    var url = Uri.parse("$haUrl/api/");
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<String> talkToHA(String haUrl, String token, String message) async {
    var url = Uri.parse("$haUrl/api/services/conversation/process");
    var response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"text": message}));
    return response.body;
  }
}
