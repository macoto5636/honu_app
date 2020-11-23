import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'take_video_page.dart';

import 'package:honu_app/processing_picture_page.dart';
import 'package:honu_app/library_page.dart';
import 'package:honu_app/data/picture_data.dart';


class MemoryAddPage extends StatefulWidget {
  @override
  _MemoryAddPageState createState() => _MemoryAddPageState();
}

class _MemoryAddPageState extends State<MemoryAddPage> {
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  // カメラ情報のリスト
  List<CameraDescription> cameras = [];

  //appbar名
  List<String> titles = ["アルバム", "撮影"];
  //下にあるメニューの値
  int _sliding = 1;

  Future<Null> getCamera() async{
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  }

  Future<void> _requestPermissionCamera() async {
    var status = await Permission.camera.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Align(
              widthFactor: 1.0,
              alignment: Alignment.center,
              child: GestureDetector(
                child: Text("キャンセル", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                onTap: (){
                  context.read<PictureDataProvider>().clearPictureData();
                  Navigator.of(context).pop();
                },
              )
          ),
          middle: Text(titles[_sliding]),
          trailing: GestureDetector(
            child: Text("次へ", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none),),
            onTap: (){
              if(context.read<PictureDataProvider>().pictureData[0].picturePath != null){
                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProcessingPicturePage(),
                    )
                );
              }
            },
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Theme.of(context).canvasColor,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    height: MediaQuery.of(context).size.height/10 - 20.0,
                    width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/ 5,
                    child: CupertinoSlidingSegmentedControl(
                      thumbColor: Theme.of(context).primaryColor,
                      backgroundColor:  Theme.of(context).canvasColor,
                      children: {
                        0: Container(
                          padding: EdgeInsets.symmetric(vertical: 9.0),
                          child: _sliding == 0?
                            Text("アルバム", style: TextStyle(color: Colors.white, fontSize: 14.0, decoration: TextDecoration.none),):
                            Text("アルバム", style: TextStyle(color: Colors.grey, fontSize: 14.0, decoration: TextDecoration.none),),
                        ),
                        1: Container(
                          padding: EdgeInsets.symmetric(vertical: 9.0),
                          child: _sliding == 1?
                            Text("撮影", style: TextStyle(color: Colors.white, fontSize: 14.0, decoration: TextDecoration.none),):
                            Text("撮影", style: TextStyle(color: Colors.grey, fontSize: 14.0, decoration: TextDecoration.none),),
                        ),
                      },
                      groupValue: _sliding,
                      onValueChanged: (value){
                        setState(() {
                          _sliding = value;
                        });
                      },
                    ),
                  )
                )
              ),
            ),
            Positioned(
              top: 85,
              left: 0,
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/5,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: _buildPage(_sliding),
              ),
            ),
          ],
        )
    );
  }

  Widget _buildPage(int num){
    Widget page = Container();
    switch(num){
      case 0:
        page = LibraryPage();
        break;
      case 1:
      //権限の確認　自動でやってくれるって言ってたのにやってくれないなんでだってばよ
        switch(_permissionStatus){
          case PermissionStatus.undetermined:
          //権限が未選択
            _requestPermissionCamera();
            break;
          case PermissionStatus.granted:
          //許可済み
            break;
          default:
            return _showPermissionDialog("カメラ");
        }

        getCamera();
        page = FutureBuilder(
          future: getCamera(),
          builder: (context, snapshot){
            if(cameras.length > 0){
              return TakeVideoPage(cameras: cameras,);
            }else{
              print("penguin");
              return Container(
                color: Colors.black,
                child: Text("3"),
              );
            }
          }
        );
        //page = TakeVideoPage(camera: cameras.first);
        break;
    }
    return page;
  }

  //権限確認のダイアログ
  //あとで帰る
  Widget _showPermissionDialog(String text){
    return CupertinoAlertDialog(
      title: Text("honuの" + text + "へのアクセスを許可しますか？"),
      content: Text("思い出を残すために利用します。"),
      actions: [
        FlatButton(
          child: Text("許可しない", style: TextStyle(color: Colors.blue),),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("許可", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
          onPressed: (){
            openAppSettings();
          },
        ),
      ],
    );
  }
}
