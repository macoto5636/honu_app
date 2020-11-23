import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as videoThumbnail;

import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/data/cameraData.dart';
import 'package:honu_app/save_form_page.dart';
import 'package:honu_app/modal/custom_modal.dart';

class TimeMessagePage extends StatefulWidget {
  @override
  _TimeMessagePageState createState() => _TimeMessagePageState();
}

class _TimeMessagePageState extends State<TimeMessagePage>  with WidgetsBindingObserver{
  // カメラ情報のリスト
  //List<CameraDescription> cameras = [];

  //カメラのコントローラー
  CameraController _cameraController;
  // コントローラーに設定されたカメラを初期化する関数
  Future<void> _initializeControllerFuture;

  //カメラの切替用
  int _cameraState = 0;
  String _videoPath;
  String _imagePath;

  CountDownController _controller = CountDownController();

  bool _flag = false;


  //カメラの情報撮ってくるやつ
  Future<Null> getCamera() async{
    WidgetsFlutterBinding.ensureInitialized();
    //cameras = await availableCameras();

    _cameraController = CameraController(
      context.read<CameraDataProvider>().cameras.first,
      //カメラの解像度の設定　maxは利用可能な最大の解像度
      ResolutionPreset.max,
    );
    //await Future.delayed(Duration(milliseconds: 5));
    _initializeControllerFuture = _cameraController.initialize();

  }

  @override
  void initState() {
    super.initState();
    getCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたタイミングで、カメラのコントローラを破棄する
    WidgetsBinding.instance.removeObserver(this);
    // _cameraController.dispose();
    // _videoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        onTapChangeCamera(_cameraController.description);
      }
    }
  }

  //カメラの切替処理
  void onTapChangeCamera(CameraDescription cameraDescription) async{
    if(_cameraController != null){
      await _cameraController.dispose();
    }
    _cameraController = CameraController(cameraDescription, ResolutionPreset.max);

    _cameraController.addListener(() {
      if(mounted){
        setState(() {});
      }
    });
    await _cameraController.initialize();
    if(mounted){
      setState(() {});
    }
  }

  //録画ボタン押したとき(動画撮影開始)
  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {
      });
    });
  }

  //録画ボタンを離したとき(動画撮影終了)
  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {
      });
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _showCameraException(CameraException e) {
    print(e.code + e.description);
  }

  //録音開始時
  Future<String> startVideoRecording() async {
    if (!_cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';
    print("テスト" + dirPath);
    if (_cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      _videoPath = filePath;
      await _cameraController.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  //録画止めたとき
  Future<void> stopVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      setState(() {

      });
      print("あああ!_cameraController.value.isRecordingVideo");
      return null;
    }

    try {
      await _cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      setState(() {

      });
      print("いいい_cameraController Error");
      return null;
    }

    _getThumbnail();
    //await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await _cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  //resumeされたとき
  Future<void> resumeVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      return null;
    }
    try {
      await _cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      setState(() {

      });
      rethrow;
    }
  }

  //撮った動画のサムネ取得とリストに追加
  Future<void> _getThumbnail() async{
    final uint8list = await videoThumbnail.VideoThumbnail.thumbnailData(
      video: _videoPath,
      imageFormat: videoThumbnail.ImageFormat.JPEG,
      maxWidth: 600, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    File file = File(filePath);
    //画像を保存してる
    await file.writeAsBytes(uint8list);

    String path = file.path;

    context.read<TimeMessageDataProvider>().addTimeMessageData(TimeMessageData(path,_videoPath));

    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SaveFormPage()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(!_flag){
        _showDialog();
        _flag = true;
      }
    });
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
            top: 0,
            left: 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.black,
            )
          ),
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                return Positioned(
                  top: 75,
                  left: 0,
                  //height:  MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    color: Colors.black,
                    child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: CameraPreview(_cameraController),
                    ),
                  )
                );
              }else{
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            }
          ),
          Positioned(
            left: 0,
            bottom: MediaQuery.of(context).size.height/10,
            height: 100.0,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //フラッシュ設定
                Container(
                  height: 50.0,
                  width: 50.0,
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   color: Colors.white.withOpacity(0.4),
                  // ),
                  child: Center(
                    child: Icon(Icons.flash_off, color: Colors.white,),
                  ),
                ),
                //撮影ボタン
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 10.0),
                    height: 95.0,
                    width: 95.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 3.0),
                    ),
                    child: Center(
                        child: _cameraController!=null && _cameraController.value.isRecordingVideo ?
                        CircularCountDownTimer(
                          // Countdown duration in Seconds
                          duration: 30,
                          // Controller to control (i.e Pause, Resume, Restart) the Countdown
                          controller: _controller,
                          // Width of the Countdown Widget
                          width: 100.0,
                          // Height of the Countdown Widget
                          height: 100.0,
                          // // Default Color for Countdown Timer
                          iniColor: LinearGradient(
                            colors: <Color>[
                              Color(0xffffffff),
                              Color(0xffffffff),
                            ],
                          ).createShader(
                            Rect.fromLTWH(
                              0.0,
                              0.0,
                              250.0,
                              70.0,
                            ),
                          ),
                          // Filling Color for Countdown Timer
                          shaderColor: LinearGradient(
                            colors: <Color>[
                              Color(0xffF28080),
                              Color(0xffFFCD82),
                            ],
                          ).createShader(
                            Rect.fromLTWH(
                              0.0,
                              0.0,
                              200.0,
                              70.0,
                            ),
                          ),
                          // Background Color for Countdown Widget
                          backgroundColor: null,
                          // Border Thickness of the Countdown Circle
                          strokeWidth: 4.0,
                          // Text Style for Countdown Text
                          textStyle: TextStyle(
                              fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold),
                          // true for reverse countdown (max to 0), false for forward countdown (0 to max)
                          isReverse: false,
                          // true for reverse animation, false for forward animation
                          isReverseAnimation: false,
                          // Optional [bool] to hide the [Text] in this widget.
                          isTimerTextShown: false,
                          // Function which will execute when the Countdown Ends
                          onComplete: () {
                            // Here, do whatever you want
                            print('Countdown Ended');
                            //onStopButtonPressed();
                          },
                        ):
                        Container(
                          height: 72.0,
                          width: 72.0,
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: _cameraController != null && _cameraController.value.isRecordingVideo ?
                          //     Colors.red :
                          //     Colors.grey,
                          // ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4.0)
                          ),
                        )
                      ),
                  ),
                  //録画開始(長押し時)
                  onLongPressStart:(details){
                    if(_cameraController != null && _cameraController.value.isInitialized && !_cameraController.value.isRecordingVideo){
                      onVideoRecordButtonPressed();
                    }
                  },
                  //録画終了(長押し終了時)
                  onLongPressEnd:(details){
                    onStopButtonPressed();
                  },
                ),
                //カメラ切替
                GestureDetector(
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle,
                    //   color: Colors.white.withOpacity(0.4),
                    // ),
                    child: Center(
                      child: Icon(Icons.flip_camera_ios_outlined, color: Colors.white,),
                    ),
                  ),
                  onTap: (){
                    _cameraState++;
                    onTapChangeCamera(context.read<CameraDataProvider>().cameras[_cameraState % 2]);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            height: MediaQuery.of(context).size.height/10,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Center(
                child: GestureDetector(
                  child: Text("スキップ", style: TextStyle(color: Colors.grey, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                  onTap: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SaveFormPage()
                        )
                    );
                  },
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(){
    CustomModal(context).showCustomDialog(
        "未来の自分に　　　　呼びかけよう！",
        "未来の自分に動画を見に来てもらえるようにビデオメッセージを残しましょう。",
        400.0,
        300.0,
        Container(
          height: 150.0,
          width: 150.0,
          color: Theme.of(context).primaryColor,
          child: Text("ogrゾーン", style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
        )
    );
  }
}
