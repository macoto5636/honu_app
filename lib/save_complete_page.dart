import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/data/shop_data.dart';
import 'package:http/http.dart' as http;
import 'package:honu_app/network/api.dart';
import 'package:honu_app/network/direction_api.dart';
import 'dart:convert';

class DirectionShop{
  String distance;
  String duration;
  DirectionShop(this.distance, this.duration);
}

class SaveCompletePage extends StatefulWidget {
  final int categoryId;
  final double lat;
  final double lon;
  SaveCompletePage({
    Key key,
    this.categoryId,
    this.lat,
    this.lon
  }): super(key: key);

  @override
  _SaveCompletePageState createState() => _SaveCompletePageState();
}

class _SaveCompletePageState extends State<SaveCompletePage> {

  List<ShopData> _shopData = [];

  List<DirectionShop> _directionShop = [DirectionShop("0", "0"),DirectionShop("0", "0"),DirectionShop("0", "0"),DirectionShop("0", "0"),DirectionShop("0", "0"),DirectionShop("0", "0"),DirectionShop("0", "0")];

  List<Color> _color = [];

  @override
  void initState() {
    super.initState();

    _getShopData();
  }

  Future<void> _getShopData() async{
    _shopData.clear();
    http.Response res = await Network().getData("shop/get/" + widget.categoryId.toString());
    List list = await json.decode(res.body);
    list.forEach((element) {
      DateTime open = DateTime.parse(element['open_time']);
      DateTime close = DateTime.parse(element['close_time']);

      _shopData.add(
        ShopData(
            element['id'],
            element['shop_name'],
            element['shop_category'],
            open,
            close,
            element['regular_holiday'],
            element['shop_tel'].toString(),
            element['shop_address'],
            element['shop_latitude'],
            element['shop_longitude'],
            element['image'],
            element['detail']
        )
      );
    });
    await _direShop();

    setState(() {

    });
  }

  Future<void> _direShop() async{
    String origin = widget.lat.toString()+ "," + widget.lon.toString();
    int i = 0;
    _shopData.forEach((element) async{
      String des = element.latitude.toString() + "," + element.longitude.toString();
      List<String> data = await DirectionApi().getDirection(origin, des, 0);
      _directionShop[i] = (DirectionShop(data[0], data[1]));
      i++;
      setState(() {

      });
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color(0xffE5E5E5),
      navigationBar: CupertinoNavigationBar(
        leading: Container(),
        middle: Text("保存設定"),
        trailing: GestureDetector(
          child: Text("マイマップへ", style: TextStyle(color: Colors.blue, fontSize: 17.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          onTap: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            //Navigator.of(context).pop();
            //Navigator.popUntil(context, ModalRoute.withName("/home"));
          },
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              child: Container(
                margin: EdgeInsets.only(left: 30, top: 120.0, right: 30, bottom: 20.0),
                child: Text("この近くで思い出を残しにいきませんか？", style: TextStyle(color: Color(0xff333333), fontSize: 22.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none),),
              ),
              onTap: () async{
                await _getShopData();
                setState(() {

                });
                print(_shopData[0].shopName);
              },
            ),
            for(int i=0; i<_shopData.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: _buildShopBox(_shopData[i], 330, MediaQuery.of(context).size.width - 50, _directionShop[i]),
              ),

          ],
        ),
      ),
    );
  }

  Widget _buildShopBox(ShopData shopData, double height, double width, DirectionShop direData){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white
      ),
      child: Column(
        children: [
          Container(
            height: height - (height/3),
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Image.asset(
                shopData.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: height/3,
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 16.0 , bottom: 6.0),
                  width: 90,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      shopData.categoryName,
                      style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text(
                    shopData.detail,
                    style: TextStyle(color: Color(0xff333333), fontSize: 16.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 3.0 , right: 16.0),
                  width: width - 16.0,
                  child: Text(
                    direData.distance + " ・ " +  direData.duration,
                    style: TextStyle(color: Colors.blue, fontSize: 12.0, fontWeight: FontWeight.normal, decoration: TextDecoration.none),
                    textAlign: TextAlign.right,

                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
