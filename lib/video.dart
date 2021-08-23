import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mytube/player.dart';
import 'package:mytube/storage.dart';
import 'dart:ui'; 

class Video extends Dialog {
  String url = "", path = "";

  Video({required this.url})  {
    // print("MyTube.Video: $url");
    var windowSize = window.physicalSize.width; // 可以用的
    print("Video.windowSize: $windowSize");
  }

  @override
  Widget build(BuildContext context) {
    return Panel(url: this.url);
  }
}

class Panel extends StatefulWidget {
  final String url;
  Panel({Key? key, required this.url}) : super(key: key){
    // print("MyTube.Panel.url: " + this.url);
  }

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool local = false;
  WebViewController? webViewController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    local = await Storage.getBool("local");
    local = true;
    print("local: $local .......................");
    this.setState(() {});
  }
  @override
  dispose() {
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
    local = true; this.setState(() {});
  }

  void didChangeAppLifecycleState(AppLifecycleState state) { // App 生命週期
    print("MyTube.video.didChangeAppLifecycleState: ${AppLifecycleState.resumed}");
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.inactive:
        break;
      default:
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      decoration: new BoxDecoration(color: Colors.transparent),
      child: local == true ? Player(url: this.widget.url) : webview() 
    );
  }

  Widget webview(){
    return WebView(
      initialUrl: this.widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
      },
      // javascriptChannels: <JavascriptChannel>[
      //   _javascriptChannel(context),
      // ].toSet(),
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {

      },
      gestureNavigationEnabled: true,
    );
  }
}

/*

    // String directory = "";
    // try {
    //   directory = await methodChannel.invokeMethod('getDownloadsDirectory');
    //   path = directory + '/MyTube';
    //   Directory(path).createSync();
      
    //   await download(url);
    //   yt.close();
    // } catch(err) {
    //   print("$err");
    // }

  Future<void> download(String id) async {
     //https://pub.dev/packages/youtube_explode_dart
    try{
      var video = await yt.videos.get(id);
      // var title = video.title;
      // var author = video.author;
      // var duration = video.duration; // Instance of Duration - 0:19:48.00000
      print("${video.duration}");
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var streams = manifest.muxed;
      // var stream = manifest.muxed.withHigestVideoQuality();
      // var streamInfo = manifest.video.withHighestBitrate();
      // var audioStream = yt.videos.streamsClient.get(streamInfo);

      var audio = streams.first;
      var audioStream = yt.videos.streamsClient.get(audio); // 有聲音，但有 2倍長度

      var fileName = '${video.title}.${audio.container.name.toString()}'
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('|', '');
      var file = File(path + '/$fileName');

      if (file.existsSync()) {
        file.deleteSync();
      }

      // Open the file in writeAppend.
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);

      // Track the file download status.
      var len = audio.size.totalBytes;
      var count = 0;

      // Create the message and set the cursor position.
      var msg = 'Downloading ${video.title}.${audio.container.name}';
      print(msg);

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();

        // print('Downloading.progress: ${progress}');
        output.add(data);
      }
      await output.close();
    } catch(e) {
      print(e);
    }
  }
  Future<void> download_OK(String id) async { // 只有聲音，但有 2倍長度
     //https://pub.dev/packages/youtube_explode_dart
    try{
      var video = await yt.videos.get(id);
      // var title = video.title;
      // var author = video.author;
      // var duration = video.duration; // Instance of Duration - 0:19:48.00000
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var streams = manifest.audioOnly;
      var audio = streams.first;
      var audioStream = yt.videos.streamsClient.get(audio); // 只有聲音，但有 2倍長度

      var fileName = '${video.title}.${audio.container.name.toString()}'
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('|', '');
      var file = File(path + '/$fileName');

      if (file.existsSync()) {
        file.deleteSync();
      }

      // Open the file in writeAppend.
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);

      // Track the file download status.
      var len = audio.size.totalBytes;
      var count = 0;

      // Create the message and set the cursor position.
      var msg = 'Downloading ${video.title}.${audio.container.name}';
      print(msg);

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();

        // print('Downloading.progress: ${progress}');
        output.add(data);
      }
      await output.close();
    } catch(e) {
      print(e);
    }
  }
*/