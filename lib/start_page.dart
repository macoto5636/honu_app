import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:honu_app/login_page.dart';
import 'package:honu_app/register_page.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin{
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                top: 0.0,
                left: 0.0,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: TabBarView(
                            controller: _controller,
                            children: [
                              for(int i=0; i<2; i++)
                                _buildMemory(i)
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ),
              Positioned(
                top: 150,
                left: 0,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  child: Center(
                    child: TabPageSelector(
                      controller: _controller,
                      color: Colors.white.withOpacity(0.5),
                      selectedColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                height: MediaQuery.of(context).size.height/ 6 + 20,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height/ 5 + 10,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0)
                        ),
                        color: Colors.white.withOpacity(0.1)
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                height: MediaQuery.of(context).size.height/ 6 + 10,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height/ 5 + 10,
                    width: MediaQuery.of(context).size.width - 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0)
                        ),
                        color: Colors.white.withOpacity(0.2)
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                height: MediaQuery.of(context).size.height/ 6,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0)
                      ),
                      color: Color(0xffFAFAFA),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: _buildButton(Theme.of(context).primaryColor, Theme.of(context).primaryColor, Colors.white, 164.0, 52.0, "ログイン"),
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()
                              )
                          );
                        },
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      GestureDetector(
                         child: _buildButton(Colors.white, Theme.of(context).primaryColor, Theme.of(context).primaryColor, 164.0, 52.0, "会員登録"),
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()
                              )
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _buildMemory(int num){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(num == 0 ? "PUT YOUR MEMORY" : "MAKE YOUR MAP" , style: TextStyle(color: Color(0xffFFE70D), fontSize: 16.0),),
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
          height: 240.0,
          width: 240.0,
          child: Image.asset(
            num == 0? "images/illust01.png" : "images/illust02.png",
            fit: BoxFit.fitHeight,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Text(
            num == 0?
                "その地に残された思い出が、":
                "思い出を地図に記録し、",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0
            ),
            textAlign: TextAlign.center,

          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 20.0),
          child: Text(
            num == 0?
            "過去の記憶を鮮明に蘇らせます。":
            "人生の地図を作り上げよう。",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0
            ),
            textAlign: TextAlign.center,

          ),
        ),
        Container(
          height: 100,
        )
      ],
    );
  }

  Widget _buildButton(Color backgroundColor, Color borderColor, Color textColor, double width, double height, String text){
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: borderColor),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: textColor, fontSize: 14.0),),
      ),
    );
  }
}
