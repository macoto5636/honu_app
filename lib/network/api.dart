import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

class Network{

  String _url = 'http://54.88.211.18/api/';
  //String _url = 'http://localhost:8000/api/';

  static var token;

  Future<void> _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
  }

  String getUrl(route){
    return _url + route;
  }

  //認証用
  authData(data,apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  //POST(データ保存用)
  postData(data, apiUrl) async{
    var fullUrl = _url + apiUrl;
    await _getToken();
    return await http.post(
      fullUrl,
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  //GET(データ取得用)
  getData(apiUrl) async{
    print(_url);
    await _getToken();
    var fullUrl = _url + apiUrl;
    return await http.get(
      fullUrl,
      headers: _setHeaders()
    );

  }

  _setHeaders()=>{
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };
}