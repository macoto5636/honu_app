import 'package:flutter/material.dart';

import 'package:honu_app/modal/modal_overlay.dart';

class CustomModal{
  BuildContext context;
  CustomModal(this.context) : super();

  //表示
  void showCustomDialog(String title, String content, double height, double width, Widget widget, double contextHeight){
    Navigator.push(
      context,
      ModalOverlay(
        Center(
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
                        child: Icon(Icons.clear, size: 20.0, color: Colors.black,),
                      ),
                    ),
                    onTap: (){hideCustomDialog();},
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
                          hideCustomDialog();
                        },
                      ),
                    )
                  ),
                ),
              ],
            ),
          )
        ),
      ),

    );
  }

  //非表示
  void hideCustomDialog() {
    Navigator.of(context).pop();
  }
}