import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/other_video_finish_page.dart';
import 'package:video_player/video_player.dart';
import 'package:honu_app/other_video_play_page.dart';

class OtherVideoPlayPage extends StatefulWidget {
  final int id;
  final String profilePath;
  final String userName;
  final String memoryTitle;
  final DateTime createDate;
  final int goodNum;
  final List<String> videos;
  final List<String> pictures;
  final bool myFlag;

  OtherVideoPlayPage({
    Key key,
    this.id,
    this.profilePath,
    this.userName,
    this.memoryTitle,
    this.createDate,
    this.goodNum,
    this.videos,
    this.pictures,
    this.myFlag
  });
  @override
  _OtherVideoPlayPageState createState() => _OtherVideoPlayPageState();
}

class _OtherVideoPlayPageState extends State<OtherVideoPlayPage> {

  //VideoPlayerController _videoPlayerController;

  //とりあえず流せれる動画いれる
  List<String> _videos = [];
  List<VideoPlayerController> _videoControllers = [];

  List<String> _weekList = ["Mon", "Tue", "Wen", "Thu", "Fri", "Sat", "Sun"];
  String _weekStr = "";

  bool _playFlag = true;

  bool myFlag = false;

  int _num = 0;

  @override
  void initState() {
    super.initState();

    _weekStr = _weekList[widget.createDate.weekday];


    for(int i=0; i<widget.videos.length; i++){
      if(widget.videos[i] != null){
        _videos.add(widget.videos[i]);
      }
    }

    for(int i=0; i<_videos.length; i++){
      VideoPlayerController videoPlayerController = VideoPlayerController.network(
          _videos[i]
      )..initialize().then((_) {
        //_videoPlayerController.setLooping(true);
        setState(() {

        });
      });
      _videoControllers.add(videoPlayerController);
      _videoControllers[i].addListener(() {
        if(_videoControllers[i].value.duration == _videoControllers[i].value.position){
          if(i == _videoControllers.length-1){
            print("end");
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OtherVideoFinishPage(imagePath: widget.pictures[0],))
            );
          }else{
            print("play:" + i.toString());
            setState(() {
              _num++;
            });
            _videoControllers[i+1].play();
          }
        }
      });
    }
    _videoControllers[0].play();

    // _videoPlayerController = VideoPlayerController.network(
    //     _videos[0]
    // )..initialize().then((_) {
    //   //_videoPlayerController.setLooping(true);
    //   setState(() {});
    //   _videoPlayerController.play();
    // });

  }

  @override
  void dispose() {
    for(int i=0; i<_videoControllers.length; i++){
      _videoControllers[i].dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_videoControllers[0] == null) return Container();

    if(_videoControllers[0].value.initialized){
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _videoControllers[0].value.initialized? AspectRatio(
              aspectRatio: _videoControllers[0].value.aspectRatio,
              child: VideoPlayer(_videoControllers[_num]),
            ):
            Container(
              height: 150.0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: _videoControllers[_num].value.isPlaying
                ? SizedBox.shrink()
                : Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 100.0,
                ),
              ),
            )
          ),
          Positioned(
            top: 0,
            left: 0,
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.0),
                      ],
                      stops: const [
                        0.0,
                        1.0,
                      ],
                    )
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height : 42,
                            width: 42,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10.0),
                            child: Text(
                              widget.userName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  shadows: [ Shadow(
                                    blurRadius: 7.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(0, 3.0),
                                  ),
                                  ],
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for(int i=0; i<_videoControllers.length; i++)
                              Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 40) / (_videoControllers.length),
                                    child: VideoProgressIndicator(
                                      _videoControllers[i],
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                          playedColor: Colors.white
                                      ),
                                    ),
                                  )
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
            ),
          ),
          //タイトルと日付
          Positioned(
            bottom: 0,
            left: 0,
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [
                      0.0,
                      1.0,
                    ],
                  )
              ),
              child: Container(
                padding: EdgeInsets.only(left: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //タイトル
                    Text(
                      widget.memoryTitle,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                          shadows: [ Shadow(
                            blurRadius: 7.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 3.0),
                          ),
                          ],
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    //日付
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        widget.createDate.year.toString() + "." + widget.createDate.month.toString().padLeft(2,"0") + "." + widget.createDate.day.toString().padLeft(2,"0") + "($_weekStr)",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            shadows: [ Shadow(
                              blurRadius: 7.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(0, 3.0),
                            ),
                            ],
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                _videoControllers[_num].value.isPlaying ? _videoControllers[_num].pause() : _videoControllers[_num].play();
              });
            },
          ),
          //いいね
          if(!widget.myFlag)
          Positioned(
            bottom: 80,
            right: 30,
            child: Container(
              child: Column(
                children: [
                  Icon(Icons.favorite_outline, size: 34.0, color: Colors.white,),
                  Text(
                    widget.goodNum.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        shadows: [
                          Shadow(
                            blurRadius: 7.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 3.0),
                          ),
                        ],
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 20,
            height: 33,
            width: 33,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: Center(
                  child: Icon(Icons.clear, color: Colors.white, size: 20,),
                ),
              ),
              onTap: (){
                Navigator.of(context).pop();
              },
            ),
          )

        ],
      );
    }else{
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/top_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0.0,
              left: 0.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("images/pink_wave.png", fit: BoxFit.fitWidth,),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("images/stars.png", fit: BoxFit.fitWidth,),
            ),
            Positioned(
              bottom: 20.0,
              left: 0.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset("images/orange_wave.png", fit: BoxFit.fitWidth,),
            ),
            Positioned(
              top: 0,
              left: 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: !myFlag ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.memoryTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 36.0),
                      child: Text(
                        widget.createDate.year.toString() + "." + widget.createDate.month.toString().padLeft(2,"0") + "." + widget.createDate.day.toString().padLeft(2,"0") + "($_weekStr)",
                        style: TextStyle(
                          color: Color(0xffFFE70D),
                          fontSize: 16.0,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )
                  ],
                ):
                Text("おかえりなさい",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            )
          ],
        )
      );
    }


  }
}
