import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future createAgoraToken(String channel) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://agora-token-gen22.herokuapp.com/access_token?channel=$channel'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200)
      return jsonDecode(await response.stream.bytesToString());
    else
      print(response.reasonPhrase);
  }
}
