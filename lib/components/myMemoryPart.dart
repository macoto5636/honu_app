import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMemoryPart extends StatelessWidget {
  final String memoryTitle;
  final String address;
  final String imagePath;

  MyMemoryPart({
    Key key,
    this.memoryTitle,
    this.address,
    this.imagePath,
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      height: 70.0,
      width: 350.0,
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  memoryTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 4.0),
                child: Text(
                  address,
                  style: TextStyle(fontSize: 14, color: Color(0xffADADAD)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, top: 10.0),
                width: 280,
                child: Divider(
                  color: Color(0xffADADAD),
                  height: 1,
                  thickness: 0,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
