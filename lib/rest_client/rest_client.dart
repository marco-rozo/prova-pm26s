import 'package:http/http.dart' as http;

//url base
const BASE_URL = 'brasilapi.com.br';

//nossa classe responsável por encapsular os métodos http
class RestClient {
  final httpClient = http.Client();
}
