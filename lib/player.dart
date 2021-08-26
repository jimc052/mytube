import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';

class Player extends StatefulWidget {
  final String url;
  Player({Key? key, required this.url}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  int processing = 0;
  Download download = new Download();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await download.getVideo(this.widget.url);
    await download.execute(onProcessing: (int process){
      processing = process;
      setState(() { });
    });
    print("下載完了...............");
  }
  @override
  dispose() {
    super.dispose();
    download.stop = true;
  }
  @override
  void reassemble() async {
    super.reassemble();
  }

  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: new BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(20.0), //容器内补白
        width: double.infinity,
        child: download == null || download.title.length == 0 ? loading() : step2()
      )
    );
  }

  Widget loading() {
    return new Center( //保证控件居中效果
        child: new SizedBox(
          width: 250.0,
          height: 120.0,
          child: new Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                // new Padding(
                //   padding: const EdgeInsets.only(top: 20.0),
                //   child: "loading",
                // ),
              ],
            ),
          ),
        ),
      );
  }

  Widget step2(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(processing == 100)
          Expanded(flex: 1, 
            child: Text("WebView",
              textAlign: TextAlign.left,
              style: new TextStyle(
                // color: Colors.blue,
                fontSize: 20,
              )
            )
          ),
        Text(download.title,
          textAlign: TextAlign.left,
          style: new TextStyle(
            color: Colors.blue,
            fontSize: 25,
          )
        ),
        Text("作者：" + download.author,
          textAlign: TextAlign.left,
          style: new TextStyle(
            // color: Colors.blue,
            fontSize: 20,
          )
        ),
        if(processing < 100)
          Text("時間：" + download.duration.toString().replaceAll(".000000", ""),
            textAlign: TextAlign.left,
            style: new TextStyle(
              // color: Colors.blue,
              fontSize: 20,
            )
          ),
        if(processing < 100)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 30,),
            LinearProgressIndicator(  
                // backgroundColor: Colors.cyanAccent,  
                // valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),  
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.blue),
                value: processing.toDouble() / 100,  
              ),
              Text(processing.toString(),
                textAlign: TextAlign.center,
                style: new TextStyle(
                  // color: Colors.blue,
                  fontSize: 20,
                )
              ),
          ]
        ),
      ]
    );
  }
}
