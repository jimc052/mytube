import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
//https://pub.dev/packages/youtube_explode_dart

class Download {
  String title = "", author = "", fileName = "", path = "", url = "";
  Duration duration = Duration(seconds: 0);
  final yt = YoutubeExplode();
  bool stop = false;

  Future<void> getVideo(String url) async {
    this.url = url;
    try {
      final methodChannel = const MethodChannel('com.flutter/MethodChannel');
      String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
      path = directory + '/MyTube';
      // print("MyTube: $path");
      Directory(path).createSync();

      var video = await yt.videos.get(url);
      title = video.title;
      author = video.author;
      duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000

      print("${video.duration}");
      
    } catch(e){
      print(e);
    }
  }


  Future<void> execute({required Function(int) onProcessing}) async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(url);
      var streams = manifest.muxed;
      // var stream = manifest.muxed.withHigestVideoQuality();
      // var streamInfo = manifest.video.withHighestBitrate();
      // var audioStream = yt.videos.streamsClient.get(streamInfo);

      var audio = streams.withHighestBitrate();
      var audioStream = yt.videos.streamsClient.get(audio); // 有聲音，但有 2倍長度

      var fileName = '${title}.${audio.container.name.toString()}'
          .replaceAll(r'\', '')
          .replaceAll('/', '')
          .replaceAll('*', '')
          .replaceAll('?', '')
          .replaceAll('"', '')
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('|', '');
      this.fileName = path + '/$fileName';
      // print("MyTube: ${Download.fileName}");
      var file = File(this.fileName);

      if (file.existsSync()) {
        file.deleteSync();
      }

      var output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = audio.size.totalBytes;
      var count = 0;
      print('MyTube.Downloading: ${title}.${audio.container.name}');

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        // if(progress % 5 == 0) {
          // print('MyTube.Downloading.progress: ${progress}');
          if(stop == false)
            onProcessing(progress);
        // }
        output.add(data);
      }
      await output.close();
      yt.close();
    } catch(e) {
      print(e);
    }
  }
}