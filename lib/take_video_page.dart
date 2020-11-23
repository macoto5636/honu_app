import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:honu_app/data/cameraData.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/processing_picture_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as videoThumbnail;
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:provider/provider.dart';

import 'package:honu_app/time_message_page.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/components/components.dart';

class TakeVideoPage extends StatefulWidget {

  final List<CameraDescription> cameras;

  const TakeVideoPage({
    Key key,
    @required this.cameras,
  }) : super(key: key);

  @override
  _TakeVideoPageState createState() => _TakeVideoPageState();
}

class _TakeVideoPageState extends State<TakeVideoPage> with WidgetsBindingObserver {
  //撮影した写真や動画のパスを保存
  //List<String> _picturePaths = []..length = 5;
  //List<PictureData> _pictureData = []..length = 5;
  //List<CameraDescription> cameras = [];
  List<PictureData> _pictureData = [PictureData(null, false, null, false), PictureData(null, false, null, false), PictureData(null, false, null, false), PictureData(null, false, null, false), PictureData(null, false, null, false)];
  int _pictureNum = 0;
  //カメラのコントローラー
  CameraController _cameraController;
  // コントローラーに設定されたカメラを初期化する関数
  Future<void> _initializeControllerFuture;
  //カメラの切替用
  int _cameraState = 0;


  VideoPlayerController _videoController;
  VoidCallback _videoPlayerListener;
  String _videoPath;
  String _imagePath;

  CountDownController _controller = CountDownController();

  String _error = "";

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.cameras[0],
      //カメラの解像度の設定　maxは利用可能な最大の解像度
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _cameraController.initialize();
    //context.read<PictureDataProvider>().clearPictureData();
    _pictureData = context.read<PictureDataProvider>().pictureData;
    _pictureNum = context.read<PictureDataProvider>().pictureNum;

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

  //プレビューの削除ボタン押したとき
  void onTapDeleteButton(int index) async{
    PictureData pictureData = context.read<PictureDataProvider>().getPictureData(index);

    //ファイルの削除
    final file = await File(pictureData.picturePath);
    await file.delete();
    //動画だったとき、動画も削除
    if(pictureData.videoFlag){
      final videoFile = await File(pictureData.videoPath);
      await videoFile.delete();
    }
    context.read<PictureDataProvider>().removePictureData(index);
    setState(() {
      _pictureData = context.read<PictureDataProvider>().pictureData;
      context.read<PictureDataProvider>().removePictureNum();
      _pictureNum = context.read<PictureDataProvider>().pictureNum;
    });
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

  //撮影ボタン押したとき(写真撮影開始)
  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          _imagePath = filePath;
          _videoController?.dispose();
          _videoController = null;
        });
        if (filePath != null){
          print('Picture saved to $filePath');

          setState(() {
            //_picturePaths[_pictureNum] = filePath;
            context.read<PictureDataProvider>().addPictureData(
                PictureData(filePath, false, null, true),
                _pictureNum
            );

            _pictureData = context.read<PictureDataProvider>().pictureData;
          });
          for(int i=0; i<5; i++){
            print(i.toString() + ":" + _pictureData[i].toString());
          }
          context.read<PictureDataProvider>().addPictureNum();
          _pictureNum = context.read<PictureDataProvider>().pictureNum;

          if(_pictureNum == 5){
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProcessingPicturePage()
                )
            );
          }
        }
      }
    });
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
      print("A recording is already started, do nothing");
      return null;
    }

    try {
      _videoPath = filePath;
      await _cameraController.startVideoRecording(filePath).then((value) => print("撮る！！"));
    } on CameraException catch (e) {
      _showCameraException(e);
      _error = e.toString();
      return null;
    }
    return filePath;
  }

  //録画止めたとき
  Future<void> stopVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      setState(() {
        _error = "!_cameraController.value.isRecordingVideo";
      });
      print("あああ!_cameraController.value.isRecordingVideo");
      return null;
    }

    try {
      await _cameraController.stopVideoRecording();
      print("撮った！！");
    } on CameraException catch (e) {
      _showCameraException(e);
      setState(() {
        _error = e.toString();
      });
      print("いいい_cameraController Error");
      return null;
    }

    _getThumbnail();
    await _startVideoPlayer();
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
        _error = e.toString();
      });
      rethrow;
    }
  }

  //写真撮影
  Future<String> takePicture() async {
    if(_pictureNum == 5){
      return null;
    }

    if (!_cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (_cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await _cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
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

    //リストに追加
    context.read<PictureDataProvider>().addPictureData(
        PictureData(path, true, _videoPath, true),
        _pictureNum
    );
    setState(() {
      _pictureData = context.read<PictureDataProvider>().pictureData;
      context.read<PictureDataProvider>().addPictureNum();
      _pictureNum = context.read<PictureDataProvider>().pictureNum;
    });

    if(_pictureNum == 5){
      Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => TimeMessagePage()
          )
      );
    }

  }

  //撮った動画のプレビュー
  Future<void> _startVideoPlayer() async {
    // final VideoPlayerController videoPlayerController =
    // VideoPlayerController.file(File(_videoPath));
    // _videoPlayerListener = () {
    //   if (_videoController != null && _videoController.value.size != null) {
    //     // Refreshing the state to update video player with the correct ratio.
    //     if (mounted) setState(() {});
    //     _videoController.removeListener(_videoPlayerListener);
    //   }
    // };
    // videoPlayerController.addListener(_videoPlayerListener);
    // await videoPlayerController.setLooping(false);
    // await videoPlayerController.initialize();
    // await _videoController?.dispose();
    // if (mounted) {
    //   setState(() {
    //     _imagePath = null;
    //     _videoController = videoPlayerController;
    //   });
    // }
    // print("ビデオプレイヤーコントローラー");
    // await videoPlayerController.play();
  }

  void _showCameraException(CameraException e) {
    print(e.code + e.description);
    _error = e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.black,
          ),
        ),
        FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            return Positioned(
              bottom: 0,
              left: 0,
              //height:  MediaQuery.of(context).size.height,
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
        }),
        Positioned(
          left: 0,
          bottom: 0,
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
                          Color(0xffff7f7f),
                          Color(0xffFFCD82),
                        ],
                      ).createShader(
                        Rect.fromLTWH(
                          0.0,
                          0.0,
                          255.0,
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
                        onStopButtonPressed();
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
                //写真撮影(タップ時)
                onTap: (){
                  if(_cameraController != null && _cameraController.value.isInitialized && !_cameraController.value.isRecordingVideo){
                    onTakePictureButtonPressed();
                  }
                },
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
                  onTapChangeCamera(widget.cameras[_cameraState % 2]);
                },
              ),
              //_thumbnailWidget(),

            ],
          ),
        ),
        Positioned(
          left: 10.0,
          top: MediaQuery.of(context).size.height / 5,
          height: 330.0,
          width: 60.0,
          child: Column(
            children: [
              for(int i=0; i<5; i++)
                Expanded(
                  child: _buildThumbnailWidget(i, context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailWidget(int index, context){
    return Stack(
      children: [
        Positioned(
          top: 5,
          left: 0,
          height: 50.0,
          width: 50.0,
          child: GestureDetector(
            child: Container(
              decoration: previewBoxDecoration,
              child: _pictureData[index].picturePath == null ?
              Container():
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.file(
                  File(_pictureData[index].picturePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: (){
              _showDeleteDialog(context, index);
            },
          )
        ),
        if( _pictureData[index].picturePath != null )
        Positioned(
          top: 0,
          right: 0,
          height: 20.0,
          width: 20.0,
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffEA3737),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.clear, color: Colors.white, size: 15.0,),
              ),
            ),
            onTap: (){
              _showDeleteDialog(context, index);
            },
          )
        ),
      ],
    );
  }

  //ダイアログ
  _showDeleteDialog(context, int index){
    showDialog(
      context: context,
      builder: (context){
        return CupertinoAlertDialog(
          title: Text("確認"),
          content: Text("選択した写真/動画を削除してよろしいでしょうか？"),
          actions: [
            FlatButton(
              child: Text("いいえ", style: TextStyle(color: Colors.blue),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("はい", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
              onPressed: (){
                onTapDeleteButton(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _videoController == null && _imagePath == null
                ? Container()
                : SizedBox(
              child: (_videoController == null)
                  ? Image.file(File(_imagePath))
                  : Container(
                child: Center(
                  child: AspectRatio(
                      aspectRatio:
                      _videoController.value.size != null
                          ? _videoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(_videoController)),
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink)),
              ),
              width: 64.0,
              height: 64.0,
            ),
          ],
        ),
      ),
    );
  }
}
