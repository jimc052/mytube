import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mytube/player.dart';
import 'package:mytube/storage.dart';
import 'dart:ui'; 

class Video extends StatefulWidget {
  final String url;
  Video({Key? key, required this.url}) : super(key: key){
    // print("MyTube.Video.url: " + this.url);
  }

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  int local = -1;
  WebViewController? webViewController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    local = await Storage.getInt("isLocal");
    // local = true;
    print("MyTube.local: $local .......................");
    this.setState(() {});
  }
  @override
  dispose() {
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
    local = -1; this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Stack(
        alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(color: Colors.transparent),
            width: double.infinity,
            child: local == -1 ? null : (local == 1  ? Player(url: this.widget.url) : webview())
          ),
          if(local > -1)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: MaterialButton(
                shape: CircleBorder(),
                color: Colors.blue,
                padding: EdgeInsets.all(20),
                onPressed: () async {
                  local = local == 1 ? 0 : 1;
                  await Storage.setInt("isLocal", local);
                  setState(()  { });
                },
                child: Icon( local == 0 ? Icons.vertical_align_bottom_sharp : Icons.wb_cloudy_sharp, size: 30, color: Colors.white,
                ),
              )
            ) 
          ,
        ],
      ),
    );
  }

  Widget webview(){
    return WebView(
      initialUrl: this.widget.url,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
      },
      // javascriptChannels: <JavascriptChannel>[
      //   _javascriptChannel(context),
      // ].toSet(),
      onProgress: (int progress) async {
        if(progress == 100) {
          String url = (await this.webViewController?.currentUrl()).toString();
          if(url.indexOf("/watch?") > -1) {
            unmuted();
          } 
        }
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {

      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  unmuted() async{ //
    await webViewController?.evaluateJavascript(
    '''
      if(typeof window.muted == "undefined") {
        window.muted = false;
        console.log("MyTube: mute............")
        setTimeout(()=>{
          click("ytp-unmute");
          let video = document.querySelector("video"); 
          video.play();
        }, 100 * 6)
      }

      function click(cls){
        let el = document.querySelector("." + cls) ;
        if(el != null) {
          el.click();
          return true;
        } else {
          return false;
        }
      }
    ''');
  }
}