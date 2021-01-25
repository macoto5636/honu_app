import 'package:flutter/material.dart';
import 'package:honu_app/main.dart';
import 'package:honu_app/start_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:honu_app/initial_page.dart';

class RegisterCompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text("会員登録完了", style: TextStyle(fontSize: 16.0, color: Color(0xff333333),fontWeight: FontWeight.bold)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height/2 + 100,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                "ご登録ありがとうございます",
                style: TextStyle(fontSize: 22.0, color: Color(0xff333333), fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Text(
                "honuを始める準備ができました。",
                style: TextStyle(fontSize: 16.0, color: Color(0xff333333)),
              ),
            ),
            Container(
              child: Text(
                "ログイン後、honuを楽しんでください。",
                style: TextStyle(fontSize: 16.0, color: Color(0xff333333)),
              ),
            ),
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(top: 30.0),
                height: 56,
                width: 234,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Center(
                  child: Text("閉じる", style: TextStyle(color: Color(0xffF7F7FC), fontSize: 16.0, fontWeight: FontWeight.bold),),
                ),
              ),
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: InitialPage(),
                      inheritTheme: true,
                      ctx: context
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
