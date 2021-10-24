import 'package:webview_flutter/webview_flutter.dart';
export 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

extension on WebView { // 沒有用到
  // String get host => "https://www.youtube.com/";
}

extension MyWebController on WebViewController {
  static String get host => "https://www.youtube.com/";
  void skipAD() async { // 略過廣告
    await this.evaluateJavascript(
    '''
      console.log("MyTube: skipAD............")
      if(typeof window.timerAD == "undefined") {
        window.timerAD = setInterval(()=>{
          // Flutter.postMessage(JSON.stringify({x: 0, y: 0})); // 不用了
          let el = document.querySelector(".ytp-ad-skip-button");
          console.log("MyTube.skipAD: " + (new Date()))
          if(el != null) {
            console.log(el)
            console.lg("MyTube.skipAD: 略過廣告............");
            el.click();
          }
        }, 1000 * 5)
      }
    ''');
  }
  clearIntervalAD() async { // 取消略過廣告
    await this.evaluateJavascript(
      '''
      if(typeof window.timerAD != "undefined") {
        console.log("MyTube: clearInterval............")
        clearInterval(window.timerAD)
        delete window.timerAD;
      };
      ''');
  }
  setAnchorClick(String cls) async { // 攔截 anchor click
    print("Mytube.setAnchorClick: $cls");
    await this.evaluateJavascript(
    '''
    setTimeout(()=>{
      let options = document.querySelectorAll("div.chip-bar-contents > *");
      let b = false;
      for(let i = 0; i < options.length; i++) {
        let item = options[i];
        if(item.innerText == "最新上傳") {
          item.click();
          setTimeout(readAnchor, 600);
          b = true;
        }
      }
      if(b == false) readAnchor();
    }, 1000);
    
    function readAnchor(){
      window.intervalAnchor = setInterval(()=>{
        let xx = document.querySelectorAll("$cls");
        xx.forEach((item, index) =>{
          let href = item.getAttribute("href");
          if(href.indexOf("javascr") == -1) {
            if(index == 2) console.log(href)
            item.setAttribute("href", "javascript:void(0);");
            item.setAttribute("_href", href);
            item.addEventListener("click", onAnchorClick, false)
          }
        })
      }, 1 * 1000);        
    }

    function onAnchorClick(e) {
      e.preventDefault();
      e.stopImmediatePropagation();
      e.stopPropagation();
      let tagName = "", parent = e.srcElement;
      do {
        tagName = parent.tagName;
        if(tagName == "A")
          break;
        else
          parent = parent.parentElement;
      } while(tagName != "A")
      let _href = parent.getAttribute("_href");
      Flutter.postMessage(JSON.stringify({href: _href}));
    }
    ''');
  }
  readAnchor(bool b) async {
    if(b == false)
      await this.evaluateJavascript(''' clearInterval(window.intervalAnchor) ''');
    else 
      await this.evaluateJavascript(''' readAnchor() ''');
  }

  pause() async { // 暫停
    await this.evaluateJavascript(
      '''
      {
        let video = document.querySelector("video"); 
        if(video != null && video.paused == false)
          video.pause();
      }
      ''');
  }
  unmuted() async{ // 取消靜音
    await this.evaluateJavascript(
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


class Youtube extends StatelessWidget { // 沒有用到
  static String get host => "https://www.youtube.com/";

  String watchID;
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(int)? onProgress;
  Function(WebViewController)? onWebViewCreated;
  List<JavascriptChannel>? javascriptChannels;

  Youtube({
     this.watchID = "", 
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
          this.onWebViewCreated!(webViewController);
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
        // print("myTube.onPageStarted.url: ${await this.this.currentUrl()}");
      },
      onPageFinished: (String url) async {
        if(this.onPageFinished is Function) this.onPageFinished!(url);
        // setAnchorClick(url);
      },
      debuggingEnabled: true,
      // gestureNavigationEnabled: true,
    );
  }
}