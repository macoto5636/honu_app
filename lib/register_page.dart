import 'package:flutter/material.dart';
import 'package:honu_app/register_complete_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String _userName;
  String _email;
  String _password;

  Future _register() async{
    var data = {
      "user_name": _userName,
      "email" : _email,
      "password" : _password,
      "role" : 1,
    };

    print("test");
    var res = await Network().authData(data, 'auth/register');
    print(res.body);
    var body = json.decode(res.body);
    print("test");

    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));

      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => RegisterCompletePage()
      ));

    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("アカウント作成", style: TextStyle(fontSize: 16.0, color: Color(0xff333333),fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 35.0, right: 35.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text("さぁはじめましょう", style: TextStyle(fontSize: 28.0, color: Color(0xff333333), fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Text("その地に残した思い出で、当時のあなたの記憶がもう一度鮮明に蘇る。", style: TextStyle(fontSize: 14.0, color: Color(0xff333333), fontWeight: FontWeight.normal),),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "ユーザーネーム",
                        ),
                        validator: (value){
                          if(value.isEmpty){
                            return 'ユーザネームを入力してください';
                          }
                          _userName = value;
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "メールアドレス",
                        ),
                        validator: (value){
                          if(value.isEmpty){
                            return 'メールアドレスを入力してください';
                          }
                          if(!EmailValidator.validate(value)){
                            return '正しい形式で入力してください';
                          }
                          _email = value;
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "パスワード",
                        ),
                        validator: (value){
                          if(value.isEmpty){
                            return 'パスワードを入力してください';
                          }
                          _password = value;
                          return null;
                        },
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(top: 30.0),
                          height: 56,
                          width: 344,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: Center(
                            child: Text("登録する", style: TextStyle(color: Color(0xffF7F7FC), fontSize: 16.0, fontWeight: FontWeight.bold),),
                          ),
                        ),
                        onTap: (){
                          if(_formKey.currentState.validate()){
                            _register();
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(fontSize: 12.0, color: Color(0xffADADAD)),
                            children: [
                              TextSpan(
                                  text: "アカウント作成することにより、"
                              ),
                              TextSpan(
                                  text: "利用規約",
                                  style: TextStyle(color: Color(0xff333333))
                              ),
                              TextSpan(
                                  text: "および"
                              ),
                              TextSpan(
                                  text: "プライバシーポリシー",
                                  style: TextStyle(color: Color(0xff333333))
                              ),
                              TextSpan(
                                  text: "に同意するものとします"
                              ),
                            ]
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}
