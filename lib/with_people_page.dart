import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:honu_app/data/with_people_data.dart';
import 'package:honu_app/network/api.dart';

class WithPeoplePage extends StatefulWidget {
  @override
  _WithPeoplePageState createState() => _WithPeoplePageState();
}

class _WithPeoplePageState extends State<WithPeoplePage> {
  //名前が入る
  List<WithPeopleData> _peopleList = [];

  //追加される名前が入る
  String _newName = "";

  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();

    _getData(context);
    _textEditingController = TextEditingController(text: _newName);
  }
  
  //一緒にいた人を取得する
  Future<void> _getData(BuildContext context) async{
    _peopleList.clear();
    http.Response res = await Network().getData("friend/1");
    List<dynamic> list = jsonDecode(res.body);
    print("List: " +list.toString());

    //ProviderからWithPeopleDataを取得
    List<String> withPeopleList = context.read<PeopleData>().peopleData;

    setState(() {
      for(int i=0; i<list.length; i++){
        int flg = 0;
        //既にpeopleListにある場合はtrueにする
        for(int j=0; j < withPeopleList.length; j++){
          if(list[i]['friend_name'] == withPeopleList[j]){
            flg = 1;
          }
        }
        _peopleList.add(WithPeopleData(list[i]['id'], list[i]['friend_name'], flg));

      }
    });
    return true;
  }

  //追加処理
  void _addWithPeople() async{
    //ユーザ取得処理あとでかく

    //textFieldから文字列をとってくる
    _newName = _textEditingController.text;
    int userId = 1;

    //textFieldが空のとき
    if(_newName == ""){

    }else{
      final data = {
        "friend_name" : _newName,
        "user_id" : userId,
      };

      print(data.toString());
      http.Response res = await Network().postData(data, "friend/store");
      print("result" + res.body.toString());

      setState(() {
        _peopleList.add(WithPeopleData(int.parse(res.body), _newName, 0));
        _textEditingController.text = "";
      });
    }
  }

  //削除処理
  void _deleteWithPeople(int id, int index) async{
    http.Response res = await Network().getData('friend/delete/' + id.toString());
    print("result" + res.body.toString());
    context.read<PeopleData>().removePeople(_peopleList[index].name);

    setState(() {
      _peopleList.removeAt(index);
    });
  }

  //選択したとき
  void _onTapSelectButton(BuildContext context, int index){
    setState(() {
      if(_peopleList[index].flag == 0){
        _peopleList[index].flag = 1;
        context.read<PeopleData>().addPeople(_peopleList[index].name);
      }else{
        _peopleList[index].flag = 0;
        context.read<PeopleData>().removePeople(_peopleList[index].name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
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
        middle: Text("一緒にいた人"),
        trailing: GestureDetector(
          child: Text("保存", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          onTap: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints.expand(height: 35.0, width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/3),
                margin: EdgeInsets.only(top: 100.0),
                child: CupertinoTextField(
                  placeholder: "メンバーの追加",
                  controller: _textEditingController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 100.0, left: 10.0),
                child: RaisedButton(
                  child: Text("追加", style: TextStyle(color: Colors.white),),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xffF09794),
                  onPressed: (){
                    _addWithPeople();
                  },
                ),
              )
            ],
          ),
          Container(
            constraints: BoxConstraints.expand(height: 30.0),
            margin: EdgeInsets.only(top: 14.0, bottom: 10.0),
            padding: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
            color: Color(0xffF5F6F7),
            child: Text("一緒にいた人", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
          ),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for(int i=0; i<_peopleList.length; i++)
                      _buildListItem(_peopleList[i].id, _peopleList[i].name, _peopleList[i].flag, i),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(int id, String name, int flag, int index){
    return Column(
      children: [
        Dismissible(
          key: Key(id.toString()),
          onDismissed: (direction){
            _deleteWithPeople(id, index);
          },
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: Icon(Icons.delete_forever, color: Colors.white,),
              ),
            )
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30.0, top:10.0, bottom: 10.0),
                  child: Text(name, style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top:10.0, right: 30.0, bottom: 10.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _peopleList[index].flag == 0 ?
                      Icon(Icons.circle, color: Color(0xffF5F6F7), size: 24.0):
                      Icon(Icons.check_circle, color: Color(0xff8DC8C8), size: 24.0,),
                    ),
                  ),
                ),
              ],
            ),
            onTap: (){
              _onTapSelectButton(context, index);
            },
          ),
        ),
        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
