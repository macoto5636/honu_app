import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:honu_app/main.dart';
import 'package:honu_app/start_page.dart';

class LoginCheckPage extends StatelessWidget {
  _checkAuth() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

    return token == null ? false :true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAuth(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapshot.data ? MyHomePage():  StartPage();
      },
    );
  }
}
