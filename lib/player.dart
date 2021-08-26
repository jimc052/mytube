import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  void alert(msg) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.red,
            size: 30,
          ),
          Padding(padding: EdgeInsets.only(right: 10)),
          Text(msg,
            style: TextStyle(
              color: Colors.red,
              fontSize: 30,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (BuildContext context) => dialog,
    );

    //print("in alert()");
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    try{
      // await download.getVideo(this.widget.url);
      // await download.execute(onProcessing: (int process){
      //   processing = process;
      //   setState(() { });
      // });
      // print("MyTube.player: 下載完了...............\n ${download.fileName}");
    } catch(e) {
      alert(e);
    }
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
        child: webview()
        // child: download == null || download.title.length == 0 ? loading() : step2()
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
          Expanded(flex: 1,  child: webview()),
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
  Widget webview(){
    return WebView(
      initialUrl: new Uri.dataFromString(html(), mimeType: 'text/html').toString(),
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      allowsInlineMediaPlayback: true,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        // this.webViewController = webViewController;
      },
      onProgress: (int progress) async {
        if(progress == 100) {
          // String url = (await this.webViewController?.currentUrl()).toString();
          // if(url.indexOf("/watch?") > -1) {
          //   unmuted();
          // } 
        }
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {

      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  String html(){
    // /storage/emulated/0/Download/MyTube/
    // // <video src="file:///${download.fileName}" controls></video>
    return '''
      <video src="file:///storage/emulated/0/Download/MyTube/jim.3gpp" controls></video>
      Hollo Jim
    ''';
  }
}
