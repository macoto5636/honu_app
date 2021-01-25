import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:honu_app/start_page.dart';
import 'package:page_transition/page_transition.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  int _id;
  String _userName = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //print(prefs.getString('user'));
    var list = json.decode(prefs.getString('user') ?? '');
    setState(() {
      _id = list["id"];
      _userName = list["user_name"];
      _email = list["email"];
    });
  }

  Future logout() async{
    var res = await Network().getData("auth/logout");
    print(res.body);
    var body = json.decode(res.body);
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: StartPage(),
          inheritTheme: true,
          ctx: context
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: false,
            title: Text("設定", style: TextStyle(fontSize: 16.0, color: Color(0xff333333),fontWeight: FontWeight.bold)),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 600,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 35.0, right: 35.0),
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color(0xff333333)),
                  ),
                  child: Center(
                    child: Text("Instagramと連携"),
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                _buildListTile("ユーザーネーム", _userName),
                Divider(
                  color: Colors.grey,
                ),
                _buildListTile("メールアドレス", _email),
                Divider(
                  color: Colors.grey,
                ),
                _buildListTile("パスワード", "セキュリティ上表示できません"),
                Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(left: 20.0,),
                    alignment: Alignment.centerLeft,
                    child: Text("アイコン変更", style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),),
                  ),
                  onTap: (){

                  },
                ),
                Divider(
                  color: Colors.grey,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(left: 20.0,),
                    alignment: Alignment.centerLeft,
                    child: Text("ログアウト", style: TextStyle(fontSize: 14.0, color: Color(0xffF24D4D)),),
                  ),
                  onTap: (){
                    logout();
                  },
                ),
                // Divider(
                //   color: Colors.grey,
                // ),
                // Container(
                //   height: 50.0,
                //   padding: EdgeInsets.only(left: 20.0),
                //   alignment: Alignment.centerLeft,
                //   child: Text("アカウントを削除する", style: TextStyle(fontSize: 14.0, color: Color(0xffF24D4D)),),
                // ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  height: 50.0,
                  padding: EdgeInsets.only(left: 20.0),
                  alignment: Alignment.bottomLeft,
                  child: Text("各種情報", style: TextStyle(fontSize: 12.0, color: Color(0xffADADAD), fontWeight: FontWeight.bold),),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.only(left: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text("プライバシーポリシー", style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),),
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.only(left: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text("利用規約", style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),),
                ),

              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildListTile(String title, String context){
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0, top: 5.0),
              child: Text(title, style: TextStyle(color: Colors.grey,fontSize: 12.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
              child: Text(context, style: TextStyle(color: Colors.black, fontSize: 14.0),),
            ),
          ],
        ),
        Expanded(
          child: Container(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(Icons.chevron_right, size: 36.0, color: Colors.grey,),
                    ) 
                  )
              )
          ),
        ),
      ],
    );
  }
}
