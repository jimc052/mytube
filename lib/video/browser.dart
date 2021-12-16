import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mytube/youtube.dart';
import 'package:flutter/services.dart';

class Browser extends StatefulWidget {
  final String url;

  Browser({Key? key, required this.url}) : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with WidgetsBindingObserver {
  WebViewController? webViewController;
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  var timer, noAD = true, videoState = "ended";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    eventChannel.receiveBroadcastStream().listen((data) async {
      // print("MyTube.broadcast: ${data}");
      if(data == "unplugged") {
        this.webViewController!.pause();
      } else if(videoState == "paused" && data == "plugged") {
        this.webViewController!.play();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        timer = Timer(Duration(minutes: 30), () { // video.dart 要 pop
          if(noAD == false)
            this.webViewController!.pause();
        }); 
        break;
      case AppLifecycleState.resumed:
        if(timer != null) timer.cancel();
        break;
      default:
    }
  }
  @override
  void reassemble() async { // develope mode
    super.reassemble();
    // noAD = false;
  }
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    this.webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: noAD == true ? "" : this.widget.url,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
        if(noAD == true) _loadHtmlFromAssets();
      },
      javascriptChannels: <JavascriptChannel>[
        javascriptChannel(context),
      ].toSet(),
      onProgress: (int progress) async {
        // print("MyTube.onProgress: ${progress}");
        if(noAD == false && progress == 100) {
          String url = (await this.webViewController!.currentUrl()).toString();
          if(url.indexOf("/watch?") > -1) {
            this.webViewController!.unmuted();
          }
        }
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
        String url = (await this.webViewController!.currentUrl()).toString();
        print("MyTube.onPageFinished: $url");
        if(noAD == true) {
            await webViewController!.evaluateJavascript(
              '''
                execute('${this.widget.url.replaceAll("https://m.youtube.com/watch?v=", "")}')
              '''
            );
        }
      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString("www/index.html");
    webViewController!.loadUrl(Uri.dataFromString(fileHtmlContents,
      mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString());
  }

  JavascriptChannel javascriptChannel(BuildContext context) { // 不用了
    return JavascriptChannel( // 接收來自 javascript
      name: 'Flutter',
      onMessageReceived: (JavascriptMessage message) async {
        print("MyTube.javascript: ${message.message}");
        Map<String, dynamic> obj = jsonDecode(message.message);
        if(obj["msg"] is String && obj["msg"] == "無法播放") {
          noAD = false;
          this.webViewController!.loadUrl(this.widget.url);
          setState(() {});
        } else if(obj["state"] is String) 
          this.videoState = obj["state"];
      }
    );
  }
}
