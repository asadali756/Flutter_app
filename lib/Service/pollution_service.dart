import 'package:http/http.dart' as http;
import 'dart:convert';

class PollutionService {
  final String token = '1520eb41851ccdab8e0471f8c872950f582a9c31';

  Future<Map<String, dynamic>?> getCityAQI(String city) async {
    final url = Uri.parse('https://api.waqi.info/feed/$city/?token=$token');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        return jsonData['data'];
      }
    }
    return null;
  }
}
