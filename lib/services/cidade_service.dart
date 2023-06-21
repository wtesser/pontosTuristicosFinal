import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../model/cidade_model.dart';

class CidadeService{

  static const _baseurl = 'http://cloud.colegiomaterdei.com.br: 8090/cidades';

  Future<List<Cidade>> findCidade() async{
    final uri = Uri.parse(_baseurl);
    final Response response = await get(uri);
    if(response.statusCode != 200 || response.body.isEmpty){
      throw Exception();

    }

    final decodeBody = jsonDecode(response.body) as List;
    return decodeBody.map((e) => Cidade.
    fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveCidade(Cidade cidade) async{
    final uri = Uri.parse(_baseurl);
    final headers = {
      HttpHeaders.connectionHeader: 'appplication/json',
    };
    final body = cidade.toJson();
    final Response response = await post(uri, body: body, headers: headers);
    if(response.statusCode != 200 || response.body.isNotEmpty){
      throw Exception();
    }

    Future<void> deletaCidade(Cidade cidade) async {
      final uri = Uri.parse('$_baseurl/${cidade.codigo}');
      final Response response = await delete(uri);
      if(response.statusCode != 200){
        throw Exception();
      }
    }



  }

}