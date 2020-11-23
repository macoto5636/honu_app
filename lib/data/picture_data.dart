import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

//撮影したデータ
class PictureData{
  String picturePath;
  bool videoFlag;
  String videoPath;
  bool takeFlag;

  PictureData(this.picturePath, this.videoFlag, this.videoPath, this.takeFlag);
}

class PictureDataProvider extends ChangeNotifier{
  List<PictureData> _pictureData = [PictureData(null, false, null, false),PictureData(null, false, null, false),PictureData(null, false, null, false),PictureData(null, false, null, false),PictureData(null, false, null, false)];
  int _pictureNum = 0;

  List<PictureData> get pictureData => _pictureData;
  int get pictureNum => _pictureNum;

  PictureData getPictureData(int index){
    return _pictureData[index];
  }

  void addPictureData(PictureData data, int index){
    _pictureData[index] = data;
  }

  void addPictureNum(){
    _pictureNum++;
  }

  void removePictureData(int index) {
    _pictureData[index] = PictureData(null, false, null, false);
    _pictureData.sort((a,b) => a.picturePath == null? 1: 0);
  }

  void removePictureNum(){
    _pictureNum--;
  }

  void clearPictureData(){
    for(int i=0; i<5; i++){
      _pictureData[i] = PictureData(null, false, null, false);
    }
    _pictureNum = 0;
  }
}

//タイムメッセージ
class TimeMessageData{
  String picturePath;
  String videoPath;

  TimeMessageData(this.picturePath, this.videoPath);
}

class TimeMessageDataProvider extends ChangeNotifier{
  TimeMessageData _timeMessageData = TimeMessageData(null, null);

  TimeMessageData get timeMessageData => _timeMessageData;

  void addTimeMessageData(TimeMessageData data){
    _timeMessageData = data;
  }

  void clearTimeMessageData(){
    _timeMessageData = TimeMessageData(null, null);
  }

}
