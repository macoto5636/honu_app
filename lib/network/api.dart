import 'dart:convert';
import 'package:http/http.dart' as http;

class Network{
  String _url = 'http://192.168.1.17:8000/api/';

  String getUrl(route){
    return _url + route;
  }

  //POST(データ保存用)
  postData(data, apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  //GET(データ取得用)
  getData(apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.get(
      fullUrl,
      headers: _setHeaders()
    );
  }


  _setHeaders()=>{
    'Content-type' : 'application/json',
    'Accept' : 'application/json'
  };
}