import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/components/myMemoryPart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:location/location.dart' as locate;

import 'data/with_people_data.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/data/cameraData.dart';
import 'memory_add_page.dart';
import 'package:honu_app/components/othersMemoryCard.dart';

import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<CameraDescription> cameras = [];

void main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code + e.description);
  }
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PeopleData()),
        ChangeNotifierProvider(create: (_) => PictureDataProvider()),
        ChangeNotifierProvider(create: (_) => TimeMessageDataProvider()),
        ChangeNotifierProvider(create: (_) => CameraDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xffFF9882),
        accentColor: Color(0xffFF9882),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  GoogleMapController _mapController;
  String _mapStyle;
  TabController _tabController;

  int _currentIndex = 1;

  //緯度経度が入る
  LatLng _currentLocal = LatLng(35.6580339,139.7016358);
  locate.Location location = locate.Location();
  locate.LocationData _locationData;
  locate.PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    context.read<CameraDataProvider>().addCameraData(cameras);

    rootBundle.loadString('json_assets/google_map_style.json').then((string) {
      _mapStyle = string;
    });

    _getLocation(context);

    _tabController = TabController(length: 2, vsync: this);
  }

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

    Marker currentMarker = Marker(
      position: _currentLocal,
      icon: BitmapDescriptor.fromAsset("images/penguin.jpg")
    );

    setState(() {
      _currentLocal = LatLng(_locationData.latitude, _locationData.longitude);
      Marker currentMarker = Marker(
          position: _currentLocal,
          icon: BitmapDescriptor.fromAsset("images/penguin.jpg")
      );
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
     // _mapController.setMapStyle(_mapStyle).catchError((){print("aout");});
    });
  }

  _handleTabSelection() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: (){FocusScope.of(context).unfocus();},
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
                            print(latLang.longitude.toString() + "," +latLang.latitude.toString());
                          },
                          //mapType: MapType.terrain,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _currentLocal,
                            zoom: 17.0,
                          ),
                          scrollGesturesEnabled: true,
                        ),
                      ),
                      Positioned(
                        bottom: 70,
                        left: 0,
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        child: _buildOthersMemory(context),
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
                          zoom: 17.0,
                        ),
                        scrollGesturesEnabled: true,
                      ),
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
                                    ),
                                  )
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for(int i=0; i<10; i++)
                                        MyMemoryPart(
                                          memoryTitle: "Test",
                                          address: "大阪府大阪市北区",
                                          imagePath: "images/penguin.jpg",
                                        )
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
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   height: _tabController.index == 0 ?
            //     MediaQuery.of(context).size.height / 3:
            //     MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   child: TabBarView(
            //     controller: _tabController,
            //     children: [
            //       _buildOthersMemory(context),
            //       Container(
            //         child: SlidingSheet(
            //           elevation: 8,
            //           cornerRadius: 10,
            //           snapSpec: SnapSpec(
            //             snap: true,
            //             snappings: [0.4, 0.7, 1.0],
            //             positioning: SnapPositioning.relativeToAvailableSpace,
            //           ),
            //           builder: (context, state) {
            //             return Container(
            //               height: 500,
            //               child: Center(
            //                 child: Text('This is the content of the sheet'),
            //               ),
            //             );
            //           },
            //         ),
            //       )
            //     ],
            //   ),
            // ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: "通知"),
          BottomNavigationBarItem(icon: Icon(null), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 25.0),
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => MemoryAddPage()
                  )
              );
            },
            tooltip: 'Increment',
            child: Icon(Icons.add, color: Colors.white,),
          ),
        ),
      )
    );
  }
}

Widget _buildOthersMemory(context){
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10.0),
          height: 35,
          width: 140,
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
                    badgeContent: Text("3", style: TextStyle(color: Colors.white),),
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
                  for(int i=0; i<5; i++)
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: OthersMemoryCard(
                        memoryTitle: "ああsああああああああああああああああああ",
                        postedDateTime: DateTime.now(),
                        goodNum: 12,
                        imagePath: "images/penguin.jpg",
                        instFlag: 1,
                      ),
                    )
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}
