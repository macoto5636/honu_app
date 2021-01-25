import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OthersMemoryCard extends StatelessWidget {
  final String memoryTitle;
  final DateTime postedDateTime;
  final int goodNum;
  final String imagePath;
  final int instFlag;

  OthersMemoryCard({
    Key key,
    this.memoryTitle,
    this.postedDateTime,
    this.goodNum,
    this.imagePath,
    this.instFlag
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 175,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xffCCD5DD).withOpacity(0.4),
            spreadRadius: 1.0,
            blurRadius: 13.0,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.0),
            height: 100,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                //image: AssetImage(imagePath),
                image: NetworkImage(imagePath),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8.0),
            height: 50,
            width: 150,
            child: Text(
              memoryTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 5.0),
                child: Text(
                  postedDateTime.year.toString() + "." + postedDateTime.month.toString().padLeft(2, "0") + "." + postedDateTime.day.toString().padLeft(2, "0"),
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 5.0, right: 10.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.favorite_outline, size: 20.0, color: Theme.of(context).primaryColor,),
                      Text(goodNum.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  )
                )
              )

            ],
          )

        ],
      )
    );
  }
}
