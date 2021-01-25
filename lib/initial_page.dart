import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:honu_app/main.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with TickerProviderStateMixin{
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              bottom: MediaQuery.of(context).size.height / 8 + 50,
              left: 0,
              height: 20,
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: Center(
                  child: TabPageSelector(
                    controller: _controller,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 9,
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    for(int i=0; i<2; i++)
                      _buildPage(i)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              height: MediaQuery.of(context).size.height / 9,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xffEAEAEA),
                    ),
                  )
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                        child: Text(
                            "スキップ",
                            style: TextStyle(color: Colors.blue, fontSize: 14.0, fontWeight: FontWeight.bold)
                        ),
                      onTap: (){
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: MyHomePage(),
                              inheritTheme: true,
                              ctx: context
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int num){
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 6,
        ),
        Container(
          height: 240,
          width: 240,
          child: Image.asset(
            num == 0? "images/onbording01.png" : "images/onbording02.png",
            fit: BoxFit.fitHeight,
          ),
        ),
        Container(
          height: 60,
          margin: EdgeInsets.only(left: 40.0, bottom: 24.0, right: 40.0),
          child: num == 0 ?
            Text(
              "過去の自分からの呼びかけを受け入れよう。",
              style: TextStyle(
                fontSize: 22.0,
                color: Color(0xff333333),
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ):
            Text(
              "さぁはじめましょう",
              style: TextStyle(
                  fontSize: 28.0,
                  color: Color(0xff333333),
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
        ),
        Container(
          margin: EdgeInsets.only(left:47.0, bottom: 34.0, right: 47.0),
          child: Text(
            num == 0? "このアプリは、動画の取り忘れを防止するために、指定日に動画を取りに来る通知を送信します。" : "honuはあなたの当時の感情や気持ちを蘇らせ、感動を最大化させる体験を提供します。ぜひお楽しみください。",
            style: TextStyle(
                fontSize: 14.0,
                color: Color(0xff333333),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
          child: Container(
            height: 56.0,
            width: 268,
            decoration: BoxDecoration(
              borderRadius: num==0? BorderRadius.circular(0.0) : BorderRadius.circular(30.0),
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(num == 0? "通知をオン" : "始める",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ),
          onTap: (){
            if(num == 1){
              Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: MyHomePage(),
                    inheritTheme: true,
                    ctx: context
                ),
              );
            }
          },
        )
      ],
    );
  }
}
