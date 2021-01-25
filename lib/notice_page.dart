import 'package:flutter/material.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  String _value = "";
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
            title: Text("通知", style: TextStyle(fontSize: 16.0, color: Color(0xff333333),fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: EdgeInsets.only(top: 150.0, bottom: 20.0),
            child: Image.asset(
              "images/illust02.png",
              height: 150,
              width: 150,
            ),
          ),
          Container(
            width: 200.0,
            child: Text("通知はまだありません", textAlign: TextAlign.center,),
          )

        ],
      )
    );
  }
}
