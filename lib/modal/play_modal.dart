import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/other_video_play_page.dart';
import 'package:honu_app/modal/modal_overlay.dart';

class PlayModal {
  BuildContext context;

  PlayModal(this.context) : super();

  //表示
  void showPlayDialog(String title, String user, DateTime uploadDateTime, double height, double width,
      String imagePath, bool flg, int id, String profilePath, int goodNum, List<String> videos, List<String> pictures) {
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
                            child: Icon(
                              Icons.clear, size: 20.0, color: Colors.black,),
                          ),
                        ),
                        onTap: () {
                          hidePlayDialog();
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
                    child: Center(
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Container(
                            height: 76.0,
                            width: 180.0,
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
                            hidePlayDialog();
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
                                )
                              )
                            );
                          },
                        ),
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
  void hidePlayDialog() {
    Navigator.of(context).pop();
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
