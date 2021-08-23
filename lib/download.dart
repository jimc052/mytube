import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

class Download {
  static String title = "", author = "", fileName = "";
  static Duration duration = Duration(seconds: 0);

  static Future<void> execute(String url, {required Function(dynamic) onLoad, 
    required Function(int) onProcessing}) async { // 
    //https://pub.dev/packages/youtube_explode_dart
    final yt = YoutubeExplode();
    try {
      final methodChannel = const MethodChannel('com.flutter/MethodChannel');
      String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
      String path = directory + '/MyTube';
      // print("MyTube: $path");
      Directory(path).createSync();

      var video = await yt.videos.get(url);
      Download.title = video.title;
      Download.author = video.author;
      Download.duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000
      onLoad({
        "title": video.title
        // "author", video.author
        // duration: video.duration ?? Duration(seconds: 0)
      });
      print("${video.duration}");
      var manifest = await yt.videos.streamsClient.getManifest(url);
      var streams = manifest.muxed;
      // var stream = manifest.muxed.withHigestVideoQuality();
      // var streamInfo = manifest.video.withHighestBitrate();
      // var audioStream = yt.videos.streamsClient.get(streamInfo);

      var audio = streams.withHighestBitrate();
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
      Download.fileName = path + '/$fileName';
      // print("MyTube: ${Download.fileName}");
      var file = File(Download.fileName);

      if (file.existsSync()) {
        file.deleteSync();
      }

      var output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = audio.size.totalBytes;
      var count = 0;
      print('MyTube.Downloading: ${video.title}.${audio.container.name}');

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        if(progress % 10 == 0) {
          // print('MyTube.Downloading.progress: ${progress}');
          onProcessing(progress);
        }
        output.add(data);
      }
      await output.close();
      yt.close();
    } catch(e) {
      print(e);
    }
  }
}

/*

class Download {
  final Function(int) onProcessing;

  Download({required this.onProcessing}) {
    print("Download: constructor.........");
  }

  static String title = "", author = "", fileName = "";
  static Duration duration = Duration(seconds: 0);

  static Future<void> execute(String url, {onload:  process}) async {
    //https://pub.dev/packages/youtube_explode_dart
    final yt = YoutubeExplode();
    try {
      final methodChannel = const MethodChannel('com.flutter/MethodChannel');
      String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
      String path = directory + '/MyTube';
      Directory(path).createSync();

      var video = await yt.videos.get(url);
      Download.title = video.title;
      Download.author = video.author;
      Download.duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000
      print("${video.duration}");
      var manifest = await yt.videos.streamsClient.getManifest(url);
      var streams = manifest.muxed;
      // var stream = manifest.muxed.withHigestVideoQuality();
      // var streamInfo = manifest.video.withHighestBitrate();
      // var audioStream = yt.videos.streamsClient.get(streamInfo);

      var audio = streams.withHighestBitrate();
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
      Download.fileName = path + '/$fileName';
      print("${Download.fileName}");
      var file = File(Download.fileName);

      if (file.existsSync()) {
        file.deleteSync();
      }

      // Open the file in writeAppend.
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);

      // Track the file download status.
      var len = audio.size.totalBytes;
      var count = 0;

      // Create the message and set the cursor position.
      var msg = 'Downloading: ${video.title}.${audio.container.name}';
      print(msg);

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        if(progress % 10 == 0)
          print('Downloading.progress: ${progress}');

        process(progress);
        output.add(data);
      }
      await output.close();
      yt.close();
    } catch(e) {
      print(e);
    }
    
  }
}

*/