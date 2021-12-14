import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mytube/youtube.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart' show rootBundle;

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
      initialUrl: "", // this.widget.url,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
        _loadHtmlFromAssets();
      },
      // javascriptChannels: <JavascriptChannel>[
      //   _javascriptChannel(context),
      // ].toSet(),
      onProgress: (int progress) async {
        // print("MyTube.onProgress: ${progress}");
        if(progress == 100) {
        }
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
        // print("MyTube.onPageFinished");
        await webViewController!.evaluateJavascript(
          '''
            execute('${this.widget.url.replaceAll("https://m.youtube.com/watch?v=", "")}')
          '''
        );
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
}
