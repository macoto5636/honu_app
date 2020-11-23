import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

class CameraDataProvider extends ChangeNotifier{
  List<CameraDescription> _cameras = [];

  List<CameraDescription> get cameras => _cameras;

  void addCameraData(List<CameraDescription> data){
    _cameras = data;
  }
}