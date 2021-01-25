import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/components/myMemoryPart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:location/location.dart' as locate;
import 'package:honu_app/network/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:honu_app/config_page.dart';
import 'data/with_people_data.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/data/cameraData.dart';
import 'memory_add_page.dart';
import 'package:honu_app/components/othersMemoryCard.dart';
import 'package:honu_app/memory_details_page.dart';
import 'package:honu_app/modal/custom_modal.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honu_app/modal/play_modal.dart';
import 'package:honu_app/notice_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:honu_app/network/direction_api.dart';
import 'dart:core';
import 'package:honu_app/login_check_page.dart';
import 'package:honu_app/other_video_play_page.dart';
import 'package:honu_app/config_page.dart';
import 'package:honu_app/notice_page.dart';
import 'empty_page.dart';
import 'package:honu_app/data/memory_data.dart';

class MainMapPage extends StatefulWidget {
  @override
  _MainMapPageState createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> with TickerProviderStateMixin {
  GoogleMapController _mapController;

  String _mapStyle;
  TabController _tabController;

  //選択してる思い出
  int _selectedMemory = -1;

  //緯度経度が入る
  LatLng _currentLocal = LatLng(35.6580339,139.7016358);
  locate.Location location = locate.Location();
  locate.LocationData _locationData;
  locate.PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  Set<Marker> _markers = Set();
  Set<Marker> _myMarkers = Set();

  BitmapDescriptor _currentIcon;
  BitmapDescriptor _memoryPoint;

  //思い出の情報入れる
  List<MemoryData> _memoryList = [];
  //検索用
  List<MemoryData> _myMemoryList = [];
  //他人の思い出の情報を入れる
  List<MemoryData> _otherMemoryList = [];

  //ダイアログのフラグ
  bool _flgOther = false;
  bool _flgMe = false;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('json_assets/google_map_style.json').then((string) {
      _mapStyle = string;
    });

    _getMemoryData();
    _getOtherMemoryData();
    //_getLocation(context);

    _tabController = TabController(length: 2, vsync: this);

    //final data = lot.Lottie.asset("json_assets/40183-animation-for-nurse.json").toByteData();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'images/currentIcon.png').then((onValue) {
      _currentIcon = onValue;
    }
    );

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'images/memory_point.png').then((onValue) {
      _memoryPoint = onValue;
    }
    );
    _showDialogOther();
  }

  //思い出データ取得
  Future<void> _getMemoryData() async{
    _memoryList.clear();
    _myMarkers.clear();
    _myMemoryList.clear();

    http.Response res = await Network().getData("memory/get");
    List<dynamic> list = jsonDecode(res.body);
    print("List: " +list.toString());

    for(int i=0; i<list.length; i++){
      DateTime dateTime = DateTime.parse(list[i]["reservation_at"]);
      List<String> member = [];
      List<String> videos = [];
      List<String> pictures = [];
      for(int j=0; j<list[i]["member"].length; j++){
        member.add(list[i]["member"][j]["member_name"]);
        print(member[j]);
      }
      for(int z=0; z<list[i]["pictures"].length; z++){
        videos.add(list[i]["videos"][z]);
        pictures.add(list[i]["pictures"][z]);
        //print(videos[z]);
      }
      _myMemoryList.add(
          MemoryData(
            list[i]["id"],
            list[i]["title"],
            list[i]["thubnail_path"],
            list[i]["public_flag"],
            list[i]["memory_good"],
            list[i]["category_name"],
            member,
            list[i]["memory_address"],
            dateTime,
            list[i]["memory_latitude"],
            list[i]["memory_longitude"],
            videos,
            pictures,
            list[i]["user_name"],
            list[i]["user_profile"],
            DateTime.parse(list[i]["scheduled_at"]),
          )
      );
      _memoryList.add(
          MemoryData(
            list[i]["id"],
            list[i]["title"],
            list[i]["thubnail_path"],
            list[i]["public_flag"],
            list[i]["memory_good"],
            list[i]["category_name"],
            member,
            list[i]["memory_address"],
            dateTime,
            list[i]["memory_latitude"],
            list[i]["memory_longitude"],
            videos,
            pictures,
            list[i]["user_name"],
            list[i]["user_profile"],
            DateTime.parse(list[i]["scheduled_at"]),
          )
      );
      for(int i=0;i<_memoryList.length;i++){
        LatLng locate = LatLng(_memoryList[i].memoryLatitude, _memoryList[i].memoryLongitude);
        //print(locate.longitude.toString() + "," + locate.latitude.toString());

        String origin = _currentLocal.latitude.toString() + "," + _currentLocal.longitude.toString();
        String destination = _memoryList[i].memoryLatitude.toString() + "," + _memoryList[i].memoryLongitude.toString();

        Marker currentMarker = Marker(
            markerId: MarkerId(_memoryList[i].memoryTitle),
            position: locate,
            icon: _memoryPoint,
            onTap: () async{
              List<String> data = await DirectionApi().getDirection(origin, destination, 0);
              bool flg = true;
              print("距離：" + data[0]);

              if(data[0].contains("km")){
                double test = double.parse(data[0].substring(0, data[0].indexOf("km")));
                print(test);
                if(5.0 < test){
                  flg = false;
                  print(test);
                }
              }

              _showDialogPlay(
                  _memoryList[i].memoryTitle,
                  _memoryList[i].userName,
                  _memoryList[i].scheduledDate,
                  _memoryList[i].imagePath,
                  flg,
                  _memoryList[i].memoryId,
                  _memoryList[i].userProfile,
                  _memoryList[i].goodNum,
                  _memoryList[i].videos,
                  _memoryList[i].pictures,
                  true
              );
            }

        );

        _myMarkers.add(currentMarker);
        //_mapController.animateCamera(CameraUpdate.newLatLng(locate));
      }
    }

    setState(() {

    });
  }

  //思い出データ取得
  void _getOtherMemoryData() async{
    _otherMemoryList.clear();
    _markers.clear();

    http.Response res = await Network().getData("memory/get/other");
    List<dynamic> list = jsonDecode(res.body);
    //print("List: " +list.toString());

    for(int i=0; i<list.length; i++){
      DateTime dateTime = DateTime.parse(list[i]["reservation_at"]);
      List<String> member = [];
      List<String> videos = [];
      List<String> pictures = [];
      for(int j=0; j<list[i]["member"].length; j++){
        member.add(list[i]["member"][j]["member_name"]);
        //print(member[j]);
      }
      for(int z=0; z<list[i]["pictures"].length; z++){
        videos.add(list[i]["videos"][z]);
        pictures.add(list[i]["pictures"][z]);
        print(videos[z]);
      }
      _otherMemoryList.add(
          MemoryData(
            list[i]["id"],
            list[i]["title"],
            list[i]["thubnail_path"],
            list[i]["public_flag"],
            list[i]["memory_good"],
            list[i]["category_name"],
            member,
            list[i]["memory_address"],
            dateTime,
            list[i]["memory_latitude"],
            list[i]["memory_longitude"],
            videos,
            pictures,
            list[i]["user_name"],
            list[i]["user_profile"],
            DateTime.parse(list[i]["scheduled_at"]),
          )
      );
      print(_otherMemoryList.length);
      for(int i=0;i<_otherMemoryList.length;i++){
        LatLng locate = LatLng(_otherMemoryList[i].memoryLatitude, _otherMemoryList[i].memoryLongitude);
        //print(locate.longitude.toString() + "," + locate.latitude.toString());

        Marker currentMarker = Marker(
            markerId: MarkerId(_otherMemoryList[i].memoryId.toString()),
            position: locate,
            icon: _memoryPoint,
            onTap: () async{
              String origin = _currentLocal.latitude.toString() + "," + _currentLocal.longitude.toString();
              String destination = _otherMemoryList[i].memoryLatitude.toString() + "," + _otherMemoryList[i].memoryLongitude.toString();
              print("あああ" + origin + ", " + destination);
              await new Future.delayed(new Duration(milliseconds: 100));
              List<String> data = await DirectionApi().getDirection(origin, destination, 0);
              bool flg = true;
              if(data[0] == null){
                print("距離：" + data[0]);

                if(data[0].contains("km")){
                  double test = double.parse(data[0].substring(0, data[0].indexOf("km")));
                  print(test);
                  if(5.0 < test){
                    flg = false;
                    print(test);
                  }
                }
              }

              _showDialogPlay(
                  _otherMemoryList[i].memoryTitle,
                  _otherMemoryList[i].userName,
                  _otherMemoryList[i].scheduledDate,
                  _otherMemoryList[i].imagePath,
                  flg,
                  _otherMemoryList[i].memoryId,
                  _otherMemoryList[i].userProfile,
                  _otherMemoryList[i].goodNum,
                  _otherMemoryList[i].videos,
                  _otherMemoryList[i].pictures,
                  false
              );
            }
        );

        _markers.add(currentMarker);
        //_mapController.animateCamera(CameraUpdate.newLatLng(locate));
      }
    }
    await _getLocation(context);
    setState(() {

    });

  }

  //現在地取得
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

    setState(() {
      _currentLocal = LatLng(_locationData.latitude, _locationData.longitude);

      Marker currentMarker = Marker(
        markerId: MarkerId("test"),
        position: _currentLocal,
        icon: _currentIcon,

      );

      _markers.add(currentMarker);
      _myMarkers.add(currentMarker);
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocal));

    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async{
    setState(() {
      _mapController = controller;
      _mapController.setMapStyle(_mapStyle);
    });
  }

  void _searchMemoryList(String word){
    print("tes");
    _memoryList.clear();
    _myMemoryList.forEach((element) {
      if(element.memoryTitle.contains(word) || element.memoryAddress.contains(word)){
        print(element.memoryTitle);
        _memoryList.add(element);
      }
    });
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 90,
            left: 0,
            height: MediaQuery.of(context).size.height - 90,
            width: MediaQuery.of(context).size.width,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      height: MediaQuery.of(context).size.height - 90,
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        onTap: (latLang){
                          //print(latLang.longitude.toString() + "," +latLang.latitude.toString());
                          //print(_currentLocal.longitude);
                        },
                        markers: _markers,
                        //mapType: MapType.terrain,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentLocal,
                          zoom: 18.0,
                        ),
                        scrollGesturesEnabled: true,
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height/8,
                      left: 0,
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10.0,),
                              height: 35,
                              width: 150,
                              child: RaisedButton(
                                color: Theme.of(context).cardColor,
                                shape: StadiumBorder(),
                                child: Row(
                                  children: [
                                    Text("周辺の思い出", style: TextStyle(color: Theme.of(context).primaryColor),),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Badge(
                                        badgeColor: Theme.of(context).primaryColor,
                                        elevation: 0,
                                        badgeContent: Text(_otherMemoryList.length.toString(), style: TextStyle(color: Colors.white),),
                                      ),
                                    )
                                  ],
                                ),
                                onPressed: (){},
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 10.0, left: 10.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for(int i=0; i<_otherMemoryList.length; i++)
                                        Padding(
                                            padding: _selectedMemory == i ? EdgeInsets.only(right: 12.0) :EdgeInsets.only(right: 12.0, top: 10.0),
                                            child: GestureDetector(
                                              child: OthersMemoryCard(
                                                memoryTitle: _otherMemoryList[i].memoryTitle,
                                                postedDateTime: _otherMemoryList[i].notificationDate,
                                                goodNum: _otherMemoryList[i].goodNum,
                                                //imagePath: "images/penguin.jpg",
                                                imagePath: _otherMemoryList[i].imagePath,
                                                instFlag: 1,
                                              ),
                                              onTap: (){
                                                LatLng memoryLocate = LatLng(_otherMemoryList[i].memoryLatitude, _otherMemoryList[i].memoryLongitude);
                                                _mapController.animateCamera(CameraUpdate.newLatLng(memoryLocate));
                                                setState(() {
                                                  if(_selectedMemory == i){
                                                    _selectedMemory = -1;
                                                  }else{
                                                    _selectedMemory = i;
                                                  }
                                                });
                                              },
                                            )
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height/8 + 230,
                      right: 10.0,
                      height: 50,
                      width: 50,
                      child: GestureDetector(
                        onTap: (){
                          _getMemoryData();
                          _getOtherMemoryData();
                          _getLocation(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffCCD5DD).withOpacity(0.4),
                                spreadRadius: 1.0,
                                blurRadius: 10.0,
                                offset: Offset(0, 8),
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(Icons.refresh_rounded, color: Color(0xff3A9CF6),),
                          ),
                        ),
                      )
                    )
                  ],
                ),
                Container(
                  child: SlidingSheet(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.2),
                    cornerRadius: 20,
                    snapSpec: SnapSpec(
                      snap: true,
                      snappings: [0.4, 0.7, 1.0],
                      positioning: SnapPositioning.relativeToAvailableSpace,
                    ),
                    body: GoogleMap(
                      onTap: (latLang){
                        print(latLang.longitude.toString() + "," +latLang.latitude.toString());
                        FocusScope.of(context).unfocus();
                      },
                      //mapType: MapType.terrain,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocal,
                        zoom: 18.0,
                      ),
                      markers: _myMarkers,
                      scrollGesturesEnabled: true,
                    ),
                    //body: Container(),
                    builder: (context, state) {
                      return Container(
                        height: MediaQuery.of(context).size.height -  MediaQuery.of(context).size.height/ 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10.0),
                                height: 5.0,
                                width: 50.0,
                                color: Color(0xffEEEEEE),
                              ),
                            ),
                            Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 10.0, bottom: 15.0),
                                  height: 60,
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "動画を検索",
                                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xff5CBFB4),),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: BorderSide(color: Color(0xffF5F6F7)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: BorderSide(color: Color(0xffF5F6F7),),
                                      ),
                                      filled: true,
                                      fillColor: Color(0xffF5F6F7),
                                      hoverColor: Color(0xffF5F6F7),
                                    ),
                                    onSubmitted: (value) async{
                                      _searchMemoryList(value);
                                      setState(() {

                                      });
                                    },
                                  ),
                                )
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(_memoryList.length == 0)
                                      Image.asset(
                                        "images/illust01.png",
                                        height: 150.0,
                                        width: 150.0,
                                      ),
                                    if(_memoryList.length == 0)
                                      Container(
                                        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                                        width: 200,
                                        child: Text(_myMemoryList.length == 0 ? "まだ思い出はありません。思い出を残しませんか？" : "検索に該当する思い出はありませんでした。", style: TextStyle(color: Color(0xff333333)), textAlign: TextAlign.center,),
                                      ),
                                    if(_myMemoryList.length == 0)
                                      Container(
                                        height: 50.0,
                                        width: 200.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0),
                                            color: Theme.of(context).primaryColor
                                        ),
                                        child: Center(
                                          child: Text("思い出を残す", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                    if(_memoryList.length != 0)
                                      for(int i=0; i< _memoryList.length; i++)
                                        GestureDetector  (
                                          behavior: HitTestBehavior.opaque,
                                          child: MyMemoryPart(
                                            memoryTitle: _memoryList[i].memoryTitle == null ? "" :_memoryList[i].memoryTitle,
                                            address: _memoryList[i].memoryAddress == null ? "" :_memoryList[i].memoryAddress,
                                            //imagePath: "images/penguin.jpg",
                                            imagePath: _memoryList[i].imagePath,
                                          ),
                                          onTap: (){
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => MemoryDetailsPage(
                                                      memoryId: _memoryList[i].memoryId,
                                                      imagePath: _memoryList[i].imagePath,
                                                      memoryTitle: _memoryList[i].memoryTitle == null ? "" :_memoryList[i].memoryTitle,
                                                      publicFlag: _memoryList[i].publicFlag,
                                                      goodNum: _memoryList[i].goodNum,
                                                      categoryName: _memoryList[i].categoryName,
                                                      withPeople: _memoryList[i].withPeople,
                                                      memoryAddress: _memoryList[i].memoryAddress,
                                                      notificationDate: _memoryList[i].notificationDate,
                                                      carLat: _currentLocal.latitude,
                                                      carLon: _currentLocal.longitude,
                                                      memoLat: _memoryList[i].memoryLatitude,
                                                      memoLon: _memoryList[i].memoryLongitude,
                                                    )
                                                )
                                            ).then((value) async{
                                              await _getMemoryData();
                                              // setState(() {
                                              //
                                              // });
                                              if(value == null){

                                                return null;
                                              }
                                              _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(value[0], value[1])));
                                              setState(() {

                                              });

                                            });
                                          },
                                        ),
                                    Container(
                                      height: 100,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            height: 90,
            width: MediaQuery.of(context).size.width,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1.0,
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      )
                    ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      onTap: (value){
                        if(!_flgMe){
                          _showDialogMe();
                        }
                        _flgMe = true;
                        setState(() {

                        });
                      },
                      tabs: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text("他人の思い出"),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text("自分の思い出"),
                        ),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogPlay(String title, String user,DateTime uploadDate, String imagePath, bool flg, int id, String profilePath,int goodNum, List<String> videos, List<String> pictures, bool myFlg){
    _showPlayDialog(
        title,
        user,
        uploadDate,
        MediaQuery.of(context).size.height / 3,
        MediaQuery.of(context).size.width  - MediaQuery.of(context).size.width / 6,
        imagePath,
        flg,
        id,
        profilePath,
        goodNum,
        videos,
        pictures,
        myFlg
    );
  }

  void _showDialogOther(){
    _showDialog(
      "近くにある思い出を見てみよう",
      "マップには自分の思い出だけでなく、他者や自治体が残したその土地の過去が保存されています。",
      400.0,
      300.0,
      Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/main_other.png")
            )
        ),
      ),
      70.0,
    );
  }
  void _showDialogMe(){
    _showDialog(
      "マイマップ機能で人生の地図を作り上げよう",
      "自分が残してきた動画の履歴や位置情報を確認することができます。",
      400.0,
      300.0,
      Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/main_me.png")
            )
        ),
      ),
      70.0,
    );
  }

  Future<void> _showPlayDialog(String title, String user, DateTime uploadDateTime, double height, double width,
      String imagePath, bool flg, int id, String profilePath, int goodNum, List<String> videos, List<String> pictures, bool myFlg) async{
    await showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            children: [
              SingleChildScrollView(
                child: Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          top: 5,
                          right: 10,
                          height: 30.0,
                          width: 30.0,
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffF5F6F7)
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.clear, size: 20.0, color: Colors.black,),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop(context);
                            },
                          )
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        height: 100.0,
                        width: width,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Text("思い出を再生しますか？", style: TextStyle(color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none),
                              textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 0,
                        width: width,
                        height: 120,
                        child: Container(
                          height: 120,
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 76.0,
                                width: 76.0,
                                margin: EdgeInsets.only(right: 10.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          child: _richText("タイトル", title),
                                        ),
                                      ),
                                      _richText("ユーザー", user),
                                      _richText("時期", uploadDateTime.year.toString() + "." + uploadDateTime.month.toString().padLeft(2,"0") + "." + uploadDateTime.day.toString().padLeft(2,"0") )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        width: width,
                        child: Center(
                          child: GestureDetector(
                            child: Container(
                              height: 50.0,
                              width: 160,
                              margin: EdgeInsets.only(top: 24.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                color: flg ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Text(
                                  "再生する",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xffF7F7FC),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onTap: (){
                              if(flg){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => OtherVideoPlayPage(
                                          id: id,
                                          profilePath: profilePath,
                                          userName: user,
                                          memoryTitle: title,
                                          createDate: uploadDateTime,
                                          goodNum: goodNum,
                                          videos: videos,
                                          pictures: pictures,
                                          myFlag: myFlg,
                                        )
                                    )
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
    );
  }

  void _showDialog(String title, String content, double height, double width, Widget widget, double contextHeight) async{
    await showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              top: 5,
                              right: 10,
                              height: 30.0,
                              width: 30.0,
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffF5F6F7)
                                  ),
                                  child: Center(
                                    child: Icon(Icons.clear, size: 20.0, color: Colors.black,),
                                  ),
                                ),
                                onTap: (){Navigator.of(context, rootNavigator: true).pop(context);},
                              )
                          ),
                          Positioned(
                            top: 10,
                            left: 0,
                            height: 100.0,
                            width: width,
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Text(title, style: TextStyle(color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none), textAlign: TextAlign.center,),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 70,
                            left: 0,
                            width: width,
                            child: Center(
                              child: widget,
                            ),
                          ),
                          Positioned(
                            bottom: 70,
                            left: 0,
                            height: contextHeight,
                            width: width,
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10.0),
                                child: Text(content, style: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none), textAlign: TextAlign.center,),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 0,
                            width: width,
                            child: Center(
                                child: Container(
                                  width: 180,
                                  height: 40.0,
                                  child: RaisedButton(
                                    child: Text("閉じる", style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
                                    color: Theme.of(context).primaryColor,
                                    shape: const StadiumBorder(),
                                    onPressed: (){
                                      Navigator.of(context, rootNavigator: true).pop(context);
                                    },
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }
    );
  }

  Widget _richText(String title, String context){
    return RichText(
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
      text: TextSpan(
          style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),
          children:[
            TextSpan(
              text: title + " : ",
            ),
            TextSpan(
              text: context,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ]
      ),
    );
  }
}
