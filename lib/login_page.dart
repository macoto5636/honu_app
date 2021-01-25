import 'package:flutter/material.dart';
import 'package:honu_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:honu_app/initial_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  Future _login() async{
    var data = {
      "email" : _email,
      "password" : _password,
    };

    var res = await Network().authData(data, 'auth/login');
    var body = json.decode(res.body);

    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      print(body['token']);
      print(body['user']);

      Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: InitialPage(),
            inheritTheme: true,
            ctx: context
        ),
      );
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/top_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 50.0,
                left: 0.0,
                width: MediaQuery.of(context).size.width,
                child: Image.asset("images/stars.png", fit: BoxFit.fitWidth,),
              ),
              Positioned(
                top: 55,
                left: 30,
                height: 25,
                width: 25,
                child: GestureDetector(
                  child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 25.0,),
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height/8,
                left: 0,
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text("おかえりなさい、honuへ",
                    style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/3 + 40,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.only(left: 36.0, top: 20.0, right: 36.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)
                    ),
                    color: Color(0xffFAFAFA),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            "ログイン",
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0,bottom: 10.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5.0,),
                              hintText: "　メールアドレス",
                              hintStyle: TextStyle(color: Color(0xffADADAD)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              filled: true,
                              fillColor: Color(0xffFFFFFF),
                              hoverColor: Color(0xffFFFFFF),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return 'メールアドレスを入力してください';
                              }
                              _email = value;
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintText: "　パスワード",
                              hintStyle: TextStyle(color: Color(0xffADADAD)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              filled: true,
                              fillColor: Color(0xffFFFFFF),
                              hoverColor: Color(0xffFFFFFF),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Color(0xffEAEAEA), width: 2.0),
                              ),
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
                                child: Text("ログイン", style: TextStyle(color: Color(0xffF7F7FC), fontSize: 16.0, fontWeight: FontWeight.bold),),
                              ),
                            ),
                            onTap: (){
                              if(_formKey.currentState.validate()){
                                _login();
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text("パスワード忘れた", style: TextStyle(fontSize: 14.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Color(0xffEAEAEA), thickness: 2.0,),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Text("または"),
                            ),
                            Expanded(
                              child: Divider(color: Color(0xffEAEAEA), thickness: 2.0,),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Color(0xff333333)),
                          ),
                          child: Center(
                            child: Text("Instagramでログイン"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),
                              children: [
                                TextSpan(
                                  text: "アカウントをお持ちでない方は"
                                ),
                                TextSpan(
                                  text: "こちら",
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                                ),
                              ]
                            ),
                          ),
                        )

                      ],
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
