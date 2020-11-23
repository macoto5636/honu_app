import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'data/with_people_data.dart';
import 'package:honu_app/data/picture_data.dart';
import 'package:honu_app/data/cameraData.dart';
import 'memory_add_page.dart';

import 'package:camera/camera.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    context.read<CameraDataProvider>().addCameraData(cameras);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("動画を保存　マイマップ", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times!!:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemoryAddPage()
              )
          );
          _incrementCounter;
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
