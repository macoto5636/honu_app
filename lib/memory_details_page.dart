import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/network/direction_api.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';

class MemoryDetailsPage extends StatefulWidget {
  final int memoryId;
  final String imagePath;
  final String memoryTitle;
  final int publicFlag;
  final int goodNum;
  final String categoryName;
  final List<String> withPeople;
  final String memoryAddress;
  final DateTime notificationDate;
  final double carLat;
  final double carLon;
  final double memoLat;
  final double memoLon;

  MemoryDetailsPage({
    Key key,
    this.memoryId,
    this.imagePath,
    this.memoryTitle,
    this.publicFlag,
    this.goodNum,
    this.categoryName,
    this.withPeople,
    this.memoryAddress,
    this.notificationDate,
    this.carLat,
    this.carLon,
    this.memoLat,
    this.memoLon,
  });

  @override
  _MemoryDetailsPageState createState() => _MemoryDetailsPageState();
}

class _MemoryDetailsPageState extends State<MemoryDetailsPage> {
  //一緒にした人で使うカラーを適当に5つくらい用意する
  List<Color> _colorList = [Color(0xffFF756A), Color(0xffFF9052), Color(0xffFFE70D), Color(0xff99ccff), Color(0xff99ffcc)];
  String dis = "0";
  String dur = "0";
  String origin = "0";
  String des = "0";

  List<double> _latLon = [];

  @override
  void initState() {
    super.initState();
    _direShop();

    origin = widget.carLat.toString()+ "," + widget.carLon.toString();
    des = widget.memoLat.toString() + "," + widget.memoLon.toString();

    _latLon.add(widget.memoLat);
    _latLon.add(widget.memoLon);
  }

  Future<void> _deleteMemory() async{

    http.Response res = await Network().getData("memory/delete/" + widget.memoryId.toString());
    print(res.body);
    Navigator.of(context).pop();
  }


  Future<void> _direShop() async{
    List<String> data = await DirectionApi().getDirection(origin, des, 0);

    setState(() {
      dis = data[0];
      dur = data[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            height: MediaQuery.of(context).size.height / 3 - 50,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imagePath),
                  fit: BoxFit.cover,
                )
              ),
              child: Stack(
                children: [
                  //戻るアイコン設置
                  Positioned(
                    top: 62,
                    left: 25,
                    height: 42,
                    width: 42,
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).canvasColor,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff000000).withOpacity(0.4),
                              spreadRadius: 1.0,
                              blurRadius: 13.0,
                              offset: Offset(4, 4),
                            )
                          ]
                        ),
                        child: Center(
                          child: Icon(Icons.chevron_left_rounded, size: 33.6, color: Color(0xff3A9CF6),),
                        ),
                      ),
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3 - 100,
            left: 0,
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3 + 50,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Color(0xffFAFAFA),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //公開or非公開テキスト
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, left: 30.0),
                      child: widget.publicFlag == 1 ?
                        Text("公開中", style: TextStyle(fontSize: 14.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),):
                        Text("非公開", style: TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.bold),),
                    ),
                    //タイトル
                    Container(
                      padding: EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0),
                      child: Text(
                        widget.memoryTitle,
                        style: TextStyle(
                          fontSize: 28.0,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                    //境界線
                    Padding(
                      padding: EdgeInsets.only(top: 24, bottom: 24),
                      child: Divider(
                        color: Color(0xffEAEAEA),
                        thickness: 1.0,
                      ),
                    ),
                    //いいね数
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 24.0, right: 24.0),
                      padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubTitle("いいねの数"),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                              children: [
                                Icon(Icons.favorite, color: Color(0xffFFBE82), size: 20.0,),
                                Text(" " + widget.goodNum.toString(), style: TextStyle(fontSize: 16, color: Color(0xff333333), fontWeight: FontWeight.bold),)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    //カテゴリ、一緒にいた人、場所
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 24.0 ,left: 24.0, right: 24.0),
                      padding: EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0, bottom: 16.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      //カテゴリ,一緒にいた人,場所
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //カテゴリ
                          _buildSubTitle("カテゴリー"),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Text(widget.categoryName, style: TextStyle(fontSize: 16, color: Color(0xff333333), fontWeight: FontWeight.bold),)
                          ),
                          //境界線
                          Padding(
                            padding: EdgeInsets.only(top: 10,bottom: 10),
                            child: Divider(
                              color: Color(0xffEAEAEA),
                              thickness: 1.0,
                            ),
                          ),
                          //一緒に居た人
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: _buildSubTitle("一緒に居た人"),
                          ),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: [
                              for(int i=0;i<widget.withPeople.length; i++)
                                _buildWithPeople(widget.withPeople[i], _colorList[i%5]),
                            ],
                          ),
                          //境界線
                          Padding(
                            padding: EdgeInsets.only(top: 10,bottom: 10),
                            child: Divider(
                              color: Color(0xffEAEAEA),
                              thickness: 1.0,
                            ),
                          ),
                          //場所
                          _buildSubTitle("場所"),
                          Container(
                            margin: EdgeInsets.only(top: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_rounded, color: Color(0xff3A9CF6), size: 18.0,),
                                Container(
                                  width: 261,
                                  child: Text(" " + widget.memoryAddress, style: TextStyle(fontSize: 14.0, color: Color(0xff333333)),softWrap: true, ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 25, top: 5.0),
                            child: Text(dis + " / " + dur),
                          )

                        ],
                      ),
                    ),
                    //通知予定日
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 24.0, top: 24.0 , right: 24.0),
                      padding: EdgeInsets.only(left: 24.0, top: 16.0, bottom: 16.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 14.0),
                            child: Icon(Icons.not_started),
                          ),
                          _buildSubTitle("通知予定日"),
                          Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.notificationDate.year.toString() + "/" + widget.notificationDate.month.toString().padLeft(2,"0") + "/" + widget.notificationDate.day.toString().padLeft(2,"0") + "予定",
                              style: TextStyle(fontSize: 16.0, color: Color(0xff333333)),
                            ),
                          )
                        ],
                      ),
                    ),
                    //情報を編集、削除
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0),
                      padding: EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0, bottom: 16.0,),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 48,
                            padding: EdgeInsets.only(top: 5.0,bottom: 5.0,),
                            child: Text("情報を編集する", style: TextStyle(fontSize: 16.0, color: Color(0xff3A9CF6))),
                          ),
                          Divider(
                            color: Color(0xffEAEAEA),
                            thickness: 1.0,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              padding: EdgeInsets.only(top: 5.0,bottom: 5.0,),
                              child: Text("思い出を削除する", style: TextStyle(fontSize: 16.0, color: Color(0xffF24D4D))),
                            ),
                            onTap: (){
                              _buildDeleteDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        height: 56.0,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 35.0, top: 24.0, right: 35.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            "思い出を探しに行く",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xffF7F7FC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.of(context).pop(_latLon);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTitle(String title){
    return Text(title, style: TextStyle(fontSize: 12, color: Color(0xffADADAD), fontWeight: FontWeight.bold),);
  }

  Widget _buildWithPeople(String name, Color color,){
    return Column(
      children: [
        Container(
          height: 42.0,
          width: 42.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Icon(Icons.person_outline, color: color,),
          ),
        ),
        Text(name, style: TextStyle(fontSize: 12.0, color: Color(0xff333333)),),
      ],
    );
  }

  void _buildDeleteDialog() async{
    await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("思い出を削除してもよろしいでしょうか？"),
          content: Text("一度削除した思い出を復元することはできません"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("キャンセル"),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: Text("削除"),
              onPressed: (){
                _deleteMemory();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
