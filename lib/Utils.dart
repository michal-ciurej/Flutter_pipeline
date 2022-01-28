import 'package:alerts/main.dart';
import 'package:http/http.dart' as http;

Future<String> fetchImageAsset(name) async {
  final response = await http
      .get(Uri.parse(protocol+'://' + serverAddress + ':' + port + '/landscaper-service/api/static/' + name));

  return response.body;
}
