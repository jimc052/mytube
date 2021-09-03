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
  var timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    eventChannel.receiveBroadcastStream().listen((data) async {
      if(data == "unplugged") {
        this.webViewController!.pause();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        timer = Timer(Duration(minutes: 20), () { // video.dart 要 pop
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
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    this.webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          String url = (await this.webViewController!.currentUrl()).toString();
          if(url.indexOf("/watch?") > -1) {
            this.webViewController!.unmuted();
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
}
