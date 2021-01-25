import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';
import 'package:honu_app/with_people_page.dart';
import 'package:honu_app/data/with_people_data.dart';
import 'package:provider/provider.dart';

class SaveFormData{
  String title;
  DateTime noticeDate;
  String address;
  double x;
  double y;
  String categoryName;
  List<String> withPeople;
  String musicName;
  DateTime scheduledData;
  bool publicFlag;

  SaveFormData(
      this.title,
      this.noticeDate,
      this.address,
      this.x,
      this.y,
      this.categoryName,
      this.withPeople,
      this.musicName,
      this.scheduledData,
      this.publicFlag
      );
}

class UpdateMemoryPage extends StatefulWidget {
  @override
  _UpdateMemoryPageState createState() => _UpdateMemoryPageState();
}

class _UpdateMemoryPageState extends State<UpdateMemoryPage> {
  int _categoryId;

  TextEditingController _textEditingController;
  SaveFormData _saveFormData;
  int _titleLength;

  List<String> _categoryList = [
    "イベント",
    "ランチ",
    "ディナー",
    "遊び",
    "飲み会",
    "学校",
    "観光",
    "ショッピング",
  ];

  @override
  void initState() {
    super.initState();

    DateTime today = DateTime.now();
    _saveFormData = SaveFormData(
      "",
      DateTime(today.year+2, today.month, today.day, today.hour, today.minute),
      "",
      0,
      0,
      "",
      [],
      "",
      DateTime.now(),
      true,
    );

    context.read<PeopleData>().clearPeople();
    //print("test" + _member.peopleData[]);

    _textEditingController = TextEditingController(text: _saveFormData.title);
    _titleLength = _saveFormData.title.length;

  }

  void _handleRadio(bool e) => setState(() {_saveFormData.publicFlag = e;});

  //タイトルの文字数を計算
  _onChangedTitle(String title){
    setState(() {
      _titleLength = title.length;
      _saveFormData.title = title;
    });
  }

  //通知予定日選択
  DateTime _selectDate(BuildContext context){
    DateTime selectDate = _saveFormData.noticeDate;
    FocusScope.of(context).unfocus();

    DatePicker.showDatePicker(context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: new DateTime.now().add(new Duration(days: 2000)),
      theme: DatePickerTheme(
        headerColor: Colors.white,
        backgroundColor: Colors.white,
        itemStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
        doneStyle: TextStyle(
            color: Colors.black,
            fontSize: 16.0
        ),
      ),
      onConfirm: (data){
        setState(() {
          _saveFormData.noticeDate = data;
        });
      },
      currentTime: _saveFormData.noticeDate,
      locale: LocaleType.jp,
    );
    return selectDate;
  }

  //公開予定日選択
  DateTime _selectDateTime(BuildContext context){
    DateTime selectDate = _saveFormData.scheduledData;
    FocusScope.of(context).unfocus();

    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: new DateTime.now().add(new Duration(days: 2000)),
      theme: DatePickerTheme(
        headerColor: Colors.white,
        backgroundColor: Colors.white,
        itemStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
        doneStyle: TextStyle(
            color: Colors.black,
            fontSize: 16.0
        ),
      ),
      onConfirm: (data){
        setState(() {
          _saveFormData.scheduledData = data;
        });
      },
      currentTime: _saveFormData.scheduledData,
      locale: LocaleType.jp,
    );
    return selectDate;
  }

  //カテゴリーを追加
  _onShowCategoryPicker(){
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 3,
            child: CupertinoPicker(
              itemExtent: 30,
              children: [
                for(int i=0; i<_categoryList.length; i++)
                  Text(_categoryList[i]),
              ],
              onSelectedItemChanged: (num){
                setState(() {
                  _saveFormData.categoryName = _categoryList[num];
                });
              },
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
