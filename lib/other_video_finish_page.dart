import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtherVideoFinishPage extends StatelessWidget {
  final String imagePath;

  OtherVideoFinishPage({
    Key key,
    this.imagePath
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Color(0xffF9AB81)
            ],
            stops: const [
              0.0,
              1.0,
            ],
          )
        ),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top:  MediaQuery.of(context).size.height/4),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        image: DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        "思い出を見にきてくれて\nありがとう！",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 35.0),
                      height: 56.0,
                      width: 248.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white
                      ),
                      child: Center(
                        child: Text(
                          "INSTAGRAMでシェア",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16.0,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 18.0),
                      child: GestureDetector(
                        child: Text(
                          "投稿せずに閉じる",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: (){
                          //Navigator.popUntil(context, ModalRoute.withName("/home"));
                          Navigator.of(context).pop();
                        },
                      ),
                    )
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
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
