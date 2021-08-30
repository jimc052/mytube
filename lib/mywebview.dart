import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class MyWebView extends StatelessWidget {
  static String get host => "https://www.youtube.com/";

  String watchID;
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(int)? onProgress;
  Function(WebViewController, MyWebView)? onWebViewCreated;
  List<JavascriptChannel>? javascriptChannels;

  MyWebView({this.watchID = "", 
    this.onPageStarted, this.onPageFinished,
    this.onProgress, this.javascriptChannels,
    Key? key}) : super(key: key);
  var webViewController;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: host + this.watchID,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
        if(this.onWebViewCreated is Function)
          this.onWebViewCreated!(webViewController, this);
      },
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onProgress: (int progress) async {
        if(this.onProgress is Function) {
          this.onProgress!(progress);
        }
      },
      javascriptChannels: this.javascriptChannels!.toSet(),
      // navigationDelegate: (NavigationRequest request) async {
      //   print("MyTube.navigationDelegate: ${request.url}");
      //     return NavigationDecision.prevent;
      //     return NavigationDecision.navigate;
      // },
      onPageStarted: (String url) async {
        if(this.onPageStarted is Function) this.onPageStarted!(url);
        // print("myTube.onPageStarted.url: ${await this.webViewController?.currentUrl()}");
      },
      onPageFinished: (String url) async {
        if(this.onPageFinished is Function) this.onPageFinished!(url);
        // interruptClick(url);
      },
      debuggingEnabled: true,
      // gestureNavigationEnabled: true,
    );
  }

  skipAD() async{ // 略過廣告
    await webViewController?.evaluateJavascript(
    '''
      console.log("MyTube: skipAD............")
      if(typeof window.timerAD == "undefined") {
        window.timerAD = setInterval(()=>{
          // Flutter.postMessage(JSON.stringify({x: 0, y: 0})); // 不用了
          let el = document.querySelector(".ytp-ad-skip-button");
          console.log("MyTube: " + (new Date()))
          if(el != null) {
            console.log(el)
            console.lg("MyTube: 略過廣告............");
            el.click();
          }
        }, 1000 * 5)
      }
    ''');
  }
  clearIntervalAD() async { // 取消略過廣告
    await webViewController?.evaluateJavascript(
      '''
      if(typeof window.timerAD != "undefined") {
        console.log("MyTube: clearInterval............")
        clearInterval(window.timerAD)
        delete window.timerAD;
      };
      ''');
  }
  interruptClick(String url) async { // 攔截 anchor click
    await webViewController?.evaluateJavascript(
    '''
    {
      let intervalAnchor = setInterval(()=>{
        let xx = document.querySelectorAll("a.large-media-item-thumbnail-container");
        xx.forEach((item, index) =>{
          // console.log(item)
          let href = item.getAttribute("href");
          if(href.indexOf("javascr") == -1) {
            item.setAttribute("href", "javascript:void(0);");
            // console.log(href);
            item.addEventListener("click", (e)=> {
              e.preventDefault();
              e.stopImmediatePropagation();
              e.stopPropagation();
              Flutter.postMessage(JSON.stringify({href}));
            }, false)
          }
        })
      }, 1 * 1000);
    }

    function MyTubeClick(e) {
      console.log(e)
      console.log("MyTube.Click: " + e.srcElement.getAttribute("href"))
      e.preventDefault();
      e.stopImmediatePropagation();
      e.stopPropagation();

      // Flutter.postMessage(JSON.stringify({}));
      // https://m.youtube.com/watch?v=4KfQ_dtZzhU

    }
    ''');
  }
  pause() async { // 暫停
    await webViewController?.evaluateJavascript(
      '''
      {
        let video = document.querySelector("video"); 
        if(video != null && video.paused == false)
          video.pause();
      }
      ''');
  }
  unmuted() async{ // 靜音
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