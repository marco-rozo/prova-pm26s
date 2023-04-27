import 'dart:convert';

import 'package:prova_pm26s/model/cep.dart';
import 'package:prova_pm26s/rest_client/rest_client.dart';

class CepProvider {
  RestClient restClient = new RestClient();

  //Api do BrasilAPI https://brasilapi.com.br/docs#tag/CEP-V2
  //Funciona a requisiçao
  //Porém, dependendo do CEP procurado, ele não retorna todos os dados
  //Exemplo 1:
  //https://brasilapi.com.br/api/cep/v2/09550610 -> retorna os dados de endereço, de lat e long
  //pois é cep de uma cidade grande
  //Exemplo 2:
  //https://brasilapi.com.br/api/cep/v2/89930000 -> retorna os dados da cidade apenas, sem lat e long ou endereço
  //pois se trata de uma cidade pequena.
  Future<ResponseCep?> getCepData(String cep) async {
    try {
      var response = await restClient.httpClient
          .get(Uri.http(BASE_URL, '/api/cep/v2/$cep'), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        print(response.body);
        var data = json.decode(response.body);

        return ResponseCep.fromMap(data);
      } else {
        print(response.statusCode);
        print(response.body);
        return null;
      }
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    } finally {
      restClient.httpClient.close();
    }
  }
}
