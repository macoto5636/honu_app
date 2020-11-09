import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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
  //カメラのコントローラー
  CameraController _cameraController;
  // コントローラーに設定されたカメラを初期化する関数
  Future<void> _initializeControllerFuture;
  //カメラの切替用
  int _cameraState = 0;
  //録音フラグ
  bool _videoFlag = false;

  VideoPlayerController _videoController;
  VoidCallback _videoPlayerListener;
  String _videoPath;
  String _imagePath;

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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたタイミングで、カメラのコントローラを破棄する
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    _videoController.dispose();
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
        //onNewCameraSelected(_cameraController.description);
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

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {
      });
    });
  }

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
      //showInSnackBar('Error: select a camera first.');
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
      _error = e.toString();
      return null;
    }
    _videoFlag = true;
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
    } on CameraException catch (e) {
      _showCameraException(e);
      setState(() {
        _error = e.toString();
      });
      print("いいい_cameraController Error");
      return null;
    }
    _videoFlag = false;
    await _startVideoPlayer();
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

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController videoPlayerController =
    VideoPlayerController.file(File(_videoPath));
    _videoPlayerListener = () {
      if (_videoController != null && _videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        _videoController.removeListener(_videoPlayerListener);
      }
    };
    videoPlayerController.addListener(_videoPlayerListener);
    await videoPlayerController.setLooping(true);
    await videoPlayerController.initialize();
    await _videoController?.dispose();
    if (mounted) {
      setState(() {
        _imagePath = null;
        _videoController = videoPlayerController;
      });
    }
    print("ビデオプレイヤーコントローラー");
    await videoPlayerController.play();
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
              height:  MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.black,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
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
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
                child: Center(
                  child: Icon(Icons.flash_off),
                ),
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(left: 50.0, right: 50.0),
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cameraController != null && _cameraController.value.isRecordingVideo ?
                          Colors.red :
                          Colors.grey,
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  if(_videoFlag){
                    onStopButtonPressed();
                  }else{
                    onVideoRecordButtonPressed();
                  }
                },
              ),
              GestureDetector(
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  child: Center(
                    child: Icon(Icons.flip_camera_ios_outlined),
                  ),
                ),
                onTap: (){
                  _cameraState++;
                  onTapChangeCamera(widget.cameras[_cameraState % 2]);
                },
              ),
              _thumbnailWidget(),

            ],
          ),
        ),
      ],
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
