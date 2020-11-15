import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:honu_app/save_form_page.dart';

class TimeMessagePage extends StatefulWidget {
  @override
  _TimeMessagePageState createState() => _TimeMessagePageState();
}

class _TimeMessagePageState extends State<TimeMessagePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Align(
          widthFactor: 1.0,
          alignment: Alignment.center,
          child: GestureDetector(
            child: Icon(Icons.chevron_left, color: Colors.blue, size: 34.0,),
            onTap: (){
              Navigator.of(context).pop();
            },
          ),
        ),
        middle: Text("タイムメッセージ"),
        trailing: GestureDetector(
          child: const Text("次へ", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SaveFormPage()
              )
            );
          },
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            height: 60.0,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Color(0xffF09794),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 20,
            height: 40.0,
            width: 100.0,
            child: RaisedButton(
              child: Text("スキップ", style: TextStyle(color: Colors.white),),
              shape: StadiumBorder(),
              color: Colors.black,
              onPressed: (){},
            ),
          ),
        ],
      ),
    );
  }
}
