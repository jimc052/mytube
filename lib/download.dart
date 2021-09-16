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
  var audio = null, streams;

  static Future<String> folder() async {
    final methodChannel = const MethodChannel('com.flutter/MethodChannel');
    String directory = await methodChannel.invokeMethod('getDownloadsDirectory');
    return directory + '/MyTube';
  }

  Future<void> getVideo(String url) async {
    this.url = url;
    try {
      var video = await yt.videos.get(url);
      title = video.title;
      author = video.author;
      duration = video.duration ?? Duration(seconds: 0); // Instance of Duration - 0:19:48.00000

      print("${video}");
    } catch(e){
      print(e);
      throw e;
    }
  }

  Future<dynamic> getVideoStream() async {
    try {
      print("MyTube.url: $url");
      var manifest = await yt.videos.streamsClient.getManifest(url);
      streams = manifest.muxed; // manifest.videoOnly;
      
      // List arr = streams.toList();
      // for(int i = 0; i < arr.length; i++) {
      //   print("MyTube.${i + 1}: ${arr[i].size.totalMegaBytes.toStringAsFixed(2) + 'MB'}, " 
      //     + "${arr[i].videoQualityLabel}, ${arr[i].videoQuality}, " 
      //     + "videoCodec: ${arr[i].videoCodec}, audioCodec: ${arr[i].audioCodec}, " 
      //     + arr[i].container.name.toString());
      //   if(arr[i].videoQualityLabel == "360p") {
      //     audio = arr[i];
      //     break;
      //   }
      //   // streams.first.size.totalMegaBytes.toStringAsFixed(3);
      // }
      
     
      return streams;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> getAudioStream() async { // ok 的
    try {
      var manifest = await yt.videos.streamsClient.getManifest(url);
      streams = manifest.audioOnly;
      // audio = streams.last;
    } catch(e) {
      print(e);
      throw e;
    }
  }

  dispose(){
    yt.close();
  }

  Future<void> execute({String fileName = "", String folder = "", bool isVideo = true, required Function(int) onProcessing}) async {
    try {
      // if(isVideo == true)
      //   await getVideoStream();
      // else 
      //   await getAudioStream();

      print("MyTube.audio: ${audio.size.totalMegaBytes.toStringAsFixed(2) + 'MB'}, videoQualityLabel: ${audio.videoQualityLabel}, videoQuality: ${audio.videoQuality}, videoCodec: ${audio.videoCodec}, audioCodec: ${audio.audioCodec}");
      print("MyTube.container: " + audio.container.name.toString());

      fileName = ((fileName.length == 0) ? 'youtube' : fileName) 
        + '.${audio.container.name.toString()}';

      path = await Download.folder();
      // print("MyTube: $path");
      if(Directory(path).existsSync() == false)
        Directory(path).createSync();

      if(folder.length > 0 && Directory(path + '/$folder').existsSync() == false) {
          Directory(path + '/$folder').createSync();
      }
      
      this.fileName = path + (folder.length > 0 ? '/$folder' : '') + '/$fileName';
      var file = File(this.fileName);

      if (file.existsSync()) {
        file.deleteSync();
      }

      var audioStream = yt.videos.streamsClient.get(audio); // 有聲音，但有 2倍長度
      var output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = audio.size.totalBytes;
      var count = 0;

      await for (final data in audioStream) {
        count += data.length;
        var progress = ((count / len) * 100).ceil();
        if(stop == false) onProcessing(progress);
        output.add(data);
      }
      await output.close();
      
    } catch(e) {
      print(e);
      throw e;
    }
  }
}