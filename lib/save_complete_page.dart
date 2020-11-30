import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaveCompletePage extends StatefulWidget {
  @override
  _SaveCompletePageState createState() => _SaveCompletePageState();
}

class _SaveCompletePageState extends State<SaveCompletePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(),
        middle: Text("保存設定"),
        trailing: GestureDetector(
          child: Text("マイマップへ", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          onTap: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
      child: Container(),
    );
  }
}
