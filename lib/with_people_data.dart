import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class WithPeopleData{
  int id;
  String name;
  int flag;

  WithPeopleData(this.id, this.name, this.flag);
}

class PeopleData extends ChangeNotifier{
  List<String> _peopleData = [];

  List<String> get peopleData => _peopleData;


  void addPeople(String data){
    _peopleData.add(data);

    notifyListeners();
  }

  void removePeople(String data){
    final index = _peopleData.indexWhere((element) => element == data);
    _peopleData.removeAt(index);

    notifyListeners();
  }

  void clearPeople(){
    _peopleData.clear();
    notifyListeners();
  }

}
