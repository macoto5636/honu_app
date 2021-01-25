import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/components/myMemoryPart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:honu_app/config_page.dart';
import 'data/with_people_data.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/data/cameraData.dart';
import 'memory_add_page.dart';
import 'package:camera/camera.dart';
import 'package:honu_app/notice_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:core';
import 'package:honu_app/login_check_page.dart';
import 'package:honu_app/main_map.dart';
import 'empty_page.dart';

List<CameraDescription> cameras = [];

Future main() async{
  await DotEnv().load('.env');
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
        primaryColor: Color(0xffFF756A),
        accentColor: Color(0xffFF756A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        "/" : (BuildContext context) => LoginCheckPage(),
        "/home" : (BuildContext context) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 1;
  List<Widget> _tabPages = [
    Container(),
    Container(),
    Container(),
  ];

  @override
  void initState() {
    super.initState();

    context.read<CameraDataProvider>().addCameraData(cameras);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabPages[0] = NoticePage();
    _tabPages[1] = MainMapPage();
    _tabPages[2] = ConfigPage();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_){
    //   if(!_flgOther){
    //     _showDialogOther();
    //     _flgOther = true;
    //   }
    // });

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
        child: _tabPages[_currentIndex],
        onTap: (){
          FocusScope.of(context).unfocus();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: "通知"),
          BottomNavigationBarItem(icon: Icon(null), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
        ],
        onTap: (value){
          if(_currentIndex == value){
            _currentIndex = 1;
          }else{
            _currentIndex = value;
          }
          setState(() {

          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 25.0),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xffFF9882).withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FittedBox(
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => EmptyPage()
                  )
              ).then((value){
                //_getMemoryData();
                //_getOtherMemoryData();
                //_getLocation(context);
                print("now top page");
              });
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => MemoryAddPage()
                  )
              );
            },
            child: Container(
              child: Icon(Icons.add, color: Colors.white,),
            ),
          ),
        ),
      )
    );
  }
}

