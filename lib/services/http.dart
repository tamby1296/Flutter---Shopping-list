import 'package:http/http.dart' as http;

class HTTPService {
  final String host;
  final Uri url;

  HTTPService({required this.host}) : url = Uri.https(host);

  void post() {}
}
