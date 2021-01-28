import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MemoryData{
  int memoryId;
  String memoryTitle;
  String imagePath;
  int publicFlag;
  int goodNum;
  String categoryName;
  List<String> withPeople;
  String memoryAddress;
  DateTime notificationDate;
  double memoryLatitude;
  double memoryLongitude;
  List<String> videos;
  List<String> pictures;
  String userName;
  String userProfile;
  DateTime scheduledDate;

  MemoryData(
      this.memoryId,
      this.memoryTitle,
      this.imagePath,
      this.publicFlag,
      this.goodNum,
      this.categoryName,
      this.withPeople,
      this.memoryAddress,
      this.notificationDate,
      this.memoryLatitude,
      this.memoryLongitude,
      this.videos,
      this.pictures,
      this.userName,
      this.userProfile,
      this.scheduledDate
  );

}

class MyMemoryProvider extends ChangeNotifier{
  List<MemoryData> _myMemoryList = [];

  List<MemoryData> get myMemoryList => _myMemoryList;

  MemoryData getMyMemoryList(int index){
    return _myMemoryList[index];
  }

  void addMyMemory(MemoryData memory){
    _myMemoryList.add(memory);
    notifyListeners();
  }

  void addMyMemoryList(List<MemoryData> memories){
    memories.forEach((element) {
      _myMemoryList.add(element);
    });
    notifyListeners();
  }

  void clearMyMemoryList(){
    _myMemoryList.clear();
    notifyListeners();
  }
}

class OtherMemoryProvider extends ChangeNotifier{
  List<MemoryData> _otherMemoryList = [];

  List<MemoryData> get otherMemoryList => _otherMemoryList;

  MemoryData getMyMemoryList(int index){
    return _otherMemoryList[index];
  }

  void addMyMemory(MemoryData memory){
    _otherMemoryList.add(memory);
    notifyListeners();
  }

  void addMyMemoryList(List<MemoryData> memories){
    memories.forEach((element) {
      _otherMemoryList.add(element);
    });
    notifyListeners();
  }

  void clearMyMemoryList(){
    _otherMemoryList.clear();
    notifyListeners();
  }
}