import 'package:http/http.dart' as http;

class HARestAPI {
  Future<bool> ping(String haUrl, String token) async {
    var url = Uri.parse(haUrl);
    var response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
