import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:io';

import 'package:honu_app/time_message_page.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/components/components.dart';

class ProcessingPicturePage extends StatefulWidget {
  @override
  _ProcessingPicturePageState createState() => _ProcessingPicturePageState();
}

class _ProcessingPicturePageState extends State<ProcessingPicturePage> {
  //appbar名
  List<String> titles = ["フィルター", "編集"];
  //下にあるメニューの値
  int _sliding = 0;

  //撮影したデータ
  List<PictureData> _pictureData = [PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true), PictureData(null, false, null, false, true)];
  List<imgLib.Image> _processingPicture = [null, null, null, null, null];
  List<VideoPlayerController> _videoControllers = [null, null, null, null, null];

  //選択しているデータのインデックス
  int _selectPictureData = 0;
  
  @override
  void initState() {
    super.initState();
    _pictureData = context.read<PictureDataProvider>().pictureData;

    _videoPlayer();
  }

  Future<void> _videoPlayer() async{
    //videoの設定
    for(int i=0; i<_pictureData.length; i++){
      if(_pictureData[i].videoFlag){
        VideoPlayerController videoPlayerController = VideoPlayerController.file(File(_pictureData[i].videoPath));
        setState(() {

        });
        await videoPlayerController.setLooping(true);
        await videoPlayerController.initialize();
        //print(_videoControllers[i].value.initialized);
        _videoControllers[i] = videoPlayerController;
      }
    }
    setState(() {

    });
  }

  @override
  void dispose() {
    for(int i=0; i<_videoControllers.length; i++){
      if(_videoControllers[i] != null){
        _videoControllers[i].dispose();
      }
    }
    super.dispose();
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
          ),
        ),
        middle: Text(titles[_sliding]),
        trailing: GestureDetector(
          child: Text("次へ", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none),),
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TimeMessagePage()
              )
            );
          },
        ),
      ),
      child: Stack(
        children: [
          //写真表示or動画を表示
          Positioned(
            top: 0,
            left: 0,
            height: MediaQuery.of(context).size.height -  MediaQuery.of(context).size.height/3,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_pictureData[_selectPictureData].picturePath),
                  fit: BoxFit.cover
                )
              ),
            ),
          ),
          if(_pictureData[_selectPictureData].videoPath != null && _videoControllers[_selectPictureData] != null)
            Positioned(
              top: 0,
              left: 0,
              height: MediaQuery.of(context).size.height -  MediaQuery.of(context).size.height/3,
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: _videoControllers[0].value.aspectRatio,
                child: VideoPlayer(_videoControllers[_selectPictureData]),
              ),
            ),
          //撮影で撮ったやつの一覧
          if(_pictureData[_selectPictureData].videoPath != null && _videoControllers[_selectPictureData] != null)
            Positioned(
              top: 100,
              right: 10,
              height: 54,
              width: 54,
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3)
                  ),
                  child: Center(
                    child: _videoControllers[_selectPictureData].value.volume != 0.0 ?
                        Icon(Icons.volume_up_outlined, size: 24.0, color: Colors.white,):
                        Icon(Icons.volume_off_outlined, size: 24.0, color: Colors.white,)
                    ,
                  ),
                ),
                onTap: (){
                  if(_videoControllers[_selectPictureData].value.volume != 0.0){
                    _pictureData[_selectPictureData].volumeFlag = false;
                    setState(() {
                      _videoControllers[_selectPictureData].setVolume(0.0);
                    });
                  }else{
                    _pictureData[_selectPictureData].volumeFlag = true;
                    setState(() {
                      _videoControllers[_selectPictureData].setVolume(1.0);
                    });
                  }
                  context.read<PictureDataProvider>().addPictureData(_pictureData[_selectPictureData], _selectPictureData);
                },
              ),
            ),
          Positioned(
            bottom: MediaQuery.of(context).size.height/3,
            left: 0,
            height: 60.0,
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for(int i=0; i<5; i++)
                      _buildThumbnailWidget(i, context)
                  ],
                ),
              ),
            ),
          ),
          //menuによって表示かえるところ
          Positioned(
            bottom: 0,
            left: 0,
            height: MediaQuery.of(context).size.height/3,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Theme.of(context).canvasColor,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0, left: 20.0,bottom: 10.0),
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(_pictureData[_selectPictureData].picturePath),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                        ),
                        Text("ノーマル",  style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30.0, left: 20.0,bottom: 10.0),
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(_pictureData[_selectPictureData].picturePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                        ),
                        Text("グレースケール",  style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          //menu
          Positioned(
            bottom: 0,
            left: 0,
            height: MediaQuery.of(context).size.height/10,
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(bottom: 20.0),
                width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/ 5,
                child: CupertinoSlidingSegmentedControl(
                  //thumbColor: Theme.of(context).canvasColor,
                  backgroundColor:  Theme.of(context).canvasColor,
                  children: {
                    0: Container(
                      padding: EdgeInsets.symmetric(vertical: 9.0),
                      child: _sliding == 0?
                      Text("フィルター", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0, decoration: TextDecoration.none),):
                      Text("フィルター", style: TextStyle(color: Colors.grey, fontSize: 14.0, decoration: TextDecoration.none),),
                    ),
                    1: Container(
                      padding: EdgeInsets.symmetric(vertical: 9.0),
                      child: _sliding == 1?
                      Text("編集", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0, decoration: TextDecoration.none),):
                      Text("編集", style: TextStyle(color: Colors.grey, fontSize: 14.0, decoration: TextDecoration.none),),
                    ),
                  },
                  groupValue: _sliding,
                  onValueChanged: (value){
                    setState(() {
                      _sliding = value;
                    });
                  },
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  imgLib.Image grayscaleAlpha(imgLib.Image image) {
    // Make sure the image uses the alpha channel.
    image.channels = imgLib.Channels.rgba;
    // Map the luminance (grayscale) of the image to the alpha channel.
    return imgLib.remapColors(image, alpha: imgLib.Channel.luminance);
  }

  Widget _buildThumbnailWidget(int index, context){
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 10.0),
        height: 50.0,
        width: 50.0,
        decoration: _selectPictureData != index ?
          previewBoxDecoration:
          BoxDecoration(
            border: Border.all(color: Colors.black, width: 3.0),
            borderRadius: BorderRadius.circular(5.0)
          ),
        child: _pictureData[index].picturePath != null &&_pictureData[index].takeFlag == true?
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(_pictureData[index].picturePath,height: 50.0,width: 50.0, fit: BoxFit.cover,),
            ),
          ],
        ):
        Container(),
      ),
      onTap: (){
        if(_pictureData[index].picturePath != null){
          if(_pictureData[_selectPictureData].videoFlag && _videoControllers[_selectPictureData] != null){
            _videoControllers[_selectPictureData].pause();
            setState(() {

            });
          }
          setState(() {
            _selectPictureData = index;
            if(_pictureData[index].videoFlag && _videoControllers[_selectPictureData] != null){
              _videoControllers[index].play();
            }
          });
        }
      },
    );
  }
}
