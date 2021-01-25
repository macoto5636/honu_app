import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as locate;
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:honu_app/with_people_page.dart';
import 'package:honu_app/data/with_people_data.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/save_complete_page.dart';
import 'package:honu_app/network/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:honu_app/network/aws_s3.dart';

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

final poolId = DotEnv().env['PoolID'];
final awsFolderPath = DotEnv().env['AwsFolderPath'];
final bucketName = DotEnv().env['BucketName'];

class SaveFormPage extends StatefulWidget {
  @override
  _SaveFormPageState createState() => _SaveFormPageState();
}

class _SaveFormPageState extends State<SaveFormPage> {
  final _formKey = GlobalKey<FormState>();

  locate.Location location = locate.Location();

  List<PictureData> _pictureData = [PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true)];

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

  int _categoryId;

  TextEditingController _textEditingController;

  SaveFormData _saveFormData;
  int _titleLength;
  bool _serviceEnabled;
  locate.PermissionStatus _permissionGranted;

  //緯度経度が入る
  locate.LocationData _locationData;

  //住所が入る
  List<Placemark> _placeMarks;

  bool isFileUploading = false;

  @override
  void initState() {
    super.initState();

    _pictureData = context.read<PictureDataProvider>().pictureData;
    _getLocation(context);
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

  //位置情報
  Future<void> _getLocation(context) async{

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locate.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != locate.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print("_locationData" + _locationData.toString());

    _placeMarks = await placemarkFromCoordinates(_locationData.latitude, _locationData.longitude);

    setState(() {
      _saveFormData.x = _locationData.latitude;
      _saveFormData.y = _locationData.longitude;
      _saveFormData.address = _placeMarks[0].administrativeArea + _placeMarks[0].locality + _placeMarks[0].name;
      print("address:"+_saveFormData.address);
    });
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

  //保存
  Future<String> addMemory() async{
    if(_saveFormData.title == "" || _saveFormData.categoryName == ""){
      print("入力しろ");
      return null;
    }

    setState(() {
      isFileUploading = true;
    });

    FocusScope.of(context).unfocus();

    //category_nameからcategory_idを求める
    //誉は浜で捨てたのでゴリ押しで求める
    int categoryId = _categoryList.indexWhere((element) => element == _saveFormData.categoryName);
    categoryId++;
    String videoPath = context.read<TimeMessageDataProvider>().timeMessageData.videoPath;
    print("categoryID" + categoryId.toString());
    if(videoPath != null){
      videoPath = await AwsS3().uploadVideo(videoPath, "timemessage", true);
    }

    _categoryId = categoryId;

    //データベースと合わせるためフォーマットする
    String noticeData = DateFormat('yy-MM-dd HH:mm').format(_saveFormData.noticeDate);

    String scheduledData;
    if(_saveFormData.publicFlag){
      scheduledData = DateFormat('yy-MM-dd HH:mm').format(_saveFormData.scheduledData);
    }else{
      scheduledData = DateFormat('yy-MM-dd HH:mm').format(DateTime.now());
    }
    print(scheduledData);

    List<String> picturePaths = [];
    List<String> videoPaths = [];

    //print(memoryData);
    //print("a" + jsonEncode(memoryData).toString());

    for(int i=0;i<_pictureData.length; i++){
      if(_pictureData[i].picturePath == null){
        print("break");
        break;
      }
      String picturePath = await AwsS3().uploadImage(_pictureData[i].picturePath, "picture", 1200, 1200, 60);
      String videoMemoryPath;
      if(_pictureData[i].videoFlag){
        print(_pictureData[i].videoPath);
        videoMemoryPath = await AwsS3().uploadVideo(_pictureData[i].videoPath, "video", _pictureData[i].volumeFlag);
      }
      picturePaths.add(picturePath);
      videoPaths.add(videoMemoryPath);
    }

    final memoryData = {
      "memory_title" : _saveFormData.title,
      "public_flag" : _saveFormData.publicFlag,
      "x" : _saveFormData.x,
      "y" : _saveFormData.y,
      "address" : _saveFormData.address,
      "thumbnail_path" : picturePaths[0],
      "user_id" : 2,
      "category_id" : categoryId,
      "memory_music" : _saveFormData.musicName,
      "time_message_video_path" : videoPath,
      "reservation_at" : noticeData,
      "scheduled_at" : scheduledData,
      "member" : _saveFormData.withPeople,
      "picture_paths": picturePaths,
      "video_paths" : videoPaths
    };

    http.Response res = await Network().postData(memoryData, "memory/store");
    print("result" + res.body.toString());
    context.read<PictureDataProvider>().clearPictureData();

    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SaveCompletePage(categoryId: _categoryId, lat: _locationData.latitude, lon: _locationData.longitude,)
        )
    );

    return "1";
  }




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
        middle: Text("保存設定"),
        trailing: GestureDetector(
          child: Text("保存", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          onTap: () async{
            await addMemory();
          },
        ),
      ),
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Scaffold(
              body: Stack(
                children:[
                  Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      //タイトル
                      Row(
                        children: [
                          Container(
                            constraints: BoxConstraints.expand(height: 90.0 , width: 90.0),
                            margin: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(_pictureData[0].picturePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                constraints: BoxConstraints.expand(height: 100.0, width: MediaQuery.of(context).size.width - 110),
                                margin: EdgeInsets.only(top: 20.0),
                                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                child: CupertinoTextField(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                  ),
                                  controller: _textEditingController,
                                  placeholder: "タイトルを書く",
                                  style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  onChanged: (value){
                                    _onChangedTitle(value);
                                  },
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints.expand(height: 30.0, width: MediaQuery.of(context).size.width - 110),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child:  Text(_titleLength.toString() + "/20", style: TextStyle(color: Colors.grey,fontSize: 12.0), textAlign: TextAlign.right,),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      //通知予定日
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: _buildListTile(
                            "通知予定日",
                            _saveFormData.noticeDate.year.toString()+"/"+_saveFormData.noticeDate.month.toString()+"/"+_saveFormData.noticeDate.day.toString(),
                            0 ,
                            true
                        ),
                        onTap: (){
                          _selectDate(context);
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      //位置情報
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 5.0),
                                child: Text("位置情報", style: TextStyle(color: Colors.grey,fontSize: 12.0)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 5.0,),
                                child: Text(_saveFormData.address, style: TextStyle(color: Colors.black, fontSize: 16.0),),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0,bottom: 5.0),
                                child: Text("x:" + _saveFormData.x.toStringAsFixed(2) + "　y:" + _saveFormData.y.toStringAsFixed(2), style: TextStyle(color: Colors.black, fontSize: 14.0),),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      //カテゴリー
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: _saveFormData.categoryName=="" ?
                        _buildListTile("カテゴリーを追加", _saveFormData.categoryName, 0, false) :
                        _buildListTile("カテゴリーを追加", _saveFormData.categoryName, 0, true),
                        onTap: (){
                          _onShowCategoryPicker();
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      //一緒にいた人
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(_saveFormData.withPeople.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0, top: 5.0),
                                    child: Text("一緒にいた人", style: TextStyle(color: Colors.grey,fontSize: 12.0)),
                                  ),
                                if(_saveFormData.withPeople.isNotEmpty)
                                  Container(
                                    constraints: BoxConstraints.tightForFinite(width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/10),
                                    margin: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                                    child: Wrap(
                                      spacing: 10.0,
                                      runSpacing: 10.0,
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      //direction: Axis.horizontal,
                                      children: [
                                        for(int i=0; i< _saveFormData.withPeople.length; i++)
                                          _buildWith(_saveFormData.withPeople[i]),
                                      ],
                                    ),
                                  ),
                                if(_saveFormData.withPeople.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                                    child: Text("一緒にいた人を追加", style: TextStyle(color: Colors.black, fontSize: 16.0),),
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
                                        ),
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => WithPeoplePage()
                              )
                          ).then((value){
                            setState(() {
                              _saveFormData.withPeople = context.read<PeopleData>().peopleData;
                              print("test" + context.read<PeopleData>().peopleData.toString());
                            });
                          });
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      //音楽
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _saveFormData.musicName == "" ?
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                                child: Text("音楽を設定", style: TextStyle(color: Colors.black, fontSize: 16.0),),
                              ):
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                                child: Text(_saveFormData.musicName, style: TextStyle(color: Colors.black, fontSize: 16.0),),
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
                                      ),
                                    )
                                )
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            activeColor: Color(0xffF09794),
                            value: true,
                            groupValue: _saveFormData.publicFlag,
                            onChanged: _handleRadio,
                          ),
                          !_saveFormData.publicFlag?
                          GestureDetector(
                            child: Text("公開", style: TextStyle(fontSize: 18.0),),
                            onTap: (){_handleRadio(true);},
                          ):
                          Text("公開", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                          Text("　"),
                          Radio(
                            activeColor: Color(0xffF09794),
                            value: false,
                            groupValue: _saveFormData.publicFlag,
                            onChanged: _handleRadio,
                          ),
                          _saveFormData.publicFlag?
                          GestureDetector(
                            child: Text("非公開", style: TextStyle(fontSize: 18.0),),
                            onTap: (){_handleRadio(false);},
                          ):
                          Text("非公開", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: Text("※ 公開を選択すると他のアプリユーザーにもこの動画が閲覧できるようになります",
                          style: TextStyle(color: Colors.grey,fontSize: 12.0),
                          softWrap: true,
                        ),
                      ),
                      if(_saveFormData.publicFlag)
                        Divider(
                          color: Colors.grey,
                        ),
                      if(_saveFormData.publicFlag)
                      //通知予定日
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: _buildListTile(
                              "公開予定日",
                              _saveFormData.scheduledData.year.toString()+"/"+_saveFormData.scheduledData.month.toString()+"/"+_saveFormData.scheduledData.day.toString()+ " " + _saveFormData.scheduledData.hour.toString().padLeft(2, "0") + ":" + _saveFormData.scheduledData.minute.toString().padLeft(2,"0"),
                              0 ,
                              true
                          ),
                          onTap: (){
                            _selectDateTime(context);
                          },
                        ),
                    ],
                  ),
                ),
                if(isFileUploading)
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        height: 110,
                        width: 122,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text("思い出を保存中", style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),),
                            )
                          ],
                        ),
                      ),
                    )
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String context, int iconFlag, bool confirmFlag){
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(confirmFlag)
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 5.0),
                child: Text(title, style: TextStyle(color: Colors.grey,fontSize: 12.0)),
              ),
            if(confirmFlag)
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                child: Text(context, style: TextStyle(color: Colors.black, fontSize: 16.0),),
              ),
            if(!confirmFlag)
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 5.0),
                child: Text(title, style: TextStyle(color: Colors.black, fontSize: 16.0),),
              ),

          ],
        ),
        Expanded(
          child: Container(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: iconFlag == 0 ?
                  RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.chevron_right, size: 36.0, color: Colors.grey,),
                  ) :
                  Icon(Icons.chevron_right, size: 36.0, color: Colors.grey,),
              )
            )
          ),
        ),
      ],
    );
  }

  Widget _buildWith(String name){
    return Container(
      padding: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(name),
    );
  }
}
